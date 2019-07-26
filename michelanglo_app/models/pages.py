import os, re, pickle, datetime
import base64
from Crypto.Cipher import AES
from Crypto.Hash import SHA256
from Crypto import Random

##################### Page
# The reason this is not a full DB is because
# * the PDB files can get massive

#import bcrypt
from sqlalchemy import (
    Column,
    Integer,
    Text,
    DateTime,
    Boolean
)

from .meta import Base



class Page(Base):
    """ The SQLAlchemy declarative model class for a Page object.
        This is just to speed up things. The actual data is in user-data as a pickle!
        CREATE TABLE pages (
        index SERIAL PRIMARY KEY NOT NULL,
        uuid TEXT NOT NULL UNIQUE,
        title TEXT,
        exists BOOL,
        edited BOOL,
        encrypted BOOL,
        timestamp TIMESTAMP NOT NULL);

        """
    __tablename__ = 'pages'
    id = Column(Integer, primary_key=True)
    identifier = Column(Text, nullable=False, unique=True)
    title = Column(Text)
    exists = Column(Boolean)
    edited = Column(Boolean)
    encrypted = Column(Boolean)
    timestamp = Column(DateTime)
    settings = None  #watchout this ought to be a dict, but dict is mutable.
    key = None
    unencrypted_path = property(lambda self: os.path.join('michelanglo_app', 'user-data', self.identifier + '.p'))
    encrypted_path = property(lambda self: os.path.join('michelanglo_app', 'user-data', self.identifier + '.ep'))
    thumb_path = property(lambda self: os.path.join('michelanglo_app', 'user-data', self.identifier + '.png'))
    path = property(lambda self: self.encrypted_path if self.encrypted is True else self.unencrypted_path)

    def __init__(self, identifier, key=None):
        self.identifier = identifier.replace('\\','/').replace('*','').split('/')[-1]
        if key:
            self.encrypted = True
            self.key = key.encode('utf-8')  # this does not get committed to the db. Promise.
        else:
            self.encrypted = False
            self.key = None
        self.settings = {}

    def load(self):
        if self.exists:
            if self.encrypted:
                if self.key:
                    with open(self.path, 'rb') as fh:
                        cryptic = fh.read()
                        decryptic = self._decrypt(cryptic)
                        self.settings = pickle.loads(decryptic)
                else:
                    raise ValueError('No key provided.')
            else:
                with open(self.path, 'rb') as fh:
                    self.settings = pickle.load(fh)
        elif os.path.exists(self.path):
            raise FileExistsError(f'File {self.identifier} exists but is not in the DB!')
        else:
            raise FileNotFoundError(f'File {self.identifier} ought to exist?')
        return self

    def save(self, settings=None):
        ## sort things out
        if self.settings is None: # bad coding.
            self.settings = {}
        if settings is not None:  ### I need to consider whether, for the purpose of the API. I really want everything saved.
            print(settings, self.settings)
            settings = {**self.settings, **settings}
        else:
            settings = self.load().settings
        if 'description' not in settings:
            settings['description'] = '## Description\n\nEditable text. press pen to edit.'
        if 'title' not in settings:
            settings['title'] = 'User submitted structure'
        for fun, keys in ((list, ('editors', 'visitors', 'authors')),
                      (bool, ('image', 'uniform_non_carbon', 'verbose', 'validation', 'save', 'public','confidential')),
                      (str, ('viewport', 'stick', 'backgroundcolor', 'loadfun', 'proteinJSON', 'pdb', 'description', 'title', 'data_other'))):
            for key in keys:
                if key not in settings:
                    settings[key] = fun()
        # metadata
        settings['date'] = str(datetime.datetime.now())  # redundant and disused.
        settings['page'] = self.identifier
        if self.encrypted:
            settings['key'] = self.key # is this wise? It will be encrypted in. So should be. This is so it the mako template requests are good.
        ## write
        with open(self.path, 'wb') as fh:
            if not self.encrypted:
                pickle.dump(settings, fh)
            elif not self.key:
                raise ValueError(f'Impossible. No key provided in saving {self.identifier}...')
            else:
                uncryptic = pickle.dumps(settings)
                cryptic = self._encrypt(uncryptic)
                fh.write(cryptic)
        self.exists = True
        self.title = settings['title'] ## keep synched!
        self.timestamp = datetime.datetime.utcnow()
        return self

    #https://stackoverflow.com/questions/42568262/how-to-encrypt-text-with-a-password-in-python
    def _encrypt(self, source, encode=False):
        key = SHA256.new(self.key).digest()  # use SHA-256 over our key to get a proper-sized AES key
        IV = Random.new().read(AES.block_size)  # generate IV
        encryptor = AES.new(key, AES.MODE_CBC, IV)
        padding = AES.block_size - len(source) % AES.block_size  # calculate needed padding
        source += bytes([padding]) * padding  # Python 2.x: source += chr(padding) * padding
        data = IV + encryptor.encrypt(source)  # store the IV at the beginning and encrypt
        return base64.b64encode(data).decode("latin-1") if encode else data

    def _decrypt(self, source, decode=False):
        if decode:
            source = base64.b64decode(source.encode("latin-1"))
        key = SHA256.new(self.key).digest()  # use SHA-256 over our key to get a proper-sized AES key
        IV = source[:AES.block_size]  # extract the IV from the beginning
        decryptor = AES.new(key, AES.MODE_CBC, IV)
        data = decryptor.decrypt(source[AES.block_size:])  # decrypt
        padding = data[-1]  # pick the padding value from the end; Python 2.x: ord(data[-1])
        if data[-padding:] != bytes([padding]) * padding:  # Python 2.x: chr(padding) * padding
            raise ValueError("Invalid padding...")
        return data[:-padding]  # remove the padding

    def delete(self):
        if self.exists:
            os.remove(self.path)
            self.exists = False
        else:
            pass
        return self

    @staticmethod
    def sanitise_URL(page):
        return page.replace('\\', '/').replace('*', '').split('/')[-1]

    @staticmethod
    def sanitise_HTML(code):
        def substitute(code, pattern, message):
            code = re.sub(f'<[^>]*?{pattern}[\s\S]*?>', message, code, re.IGNORECASE | re.MULTILINE | re.DOTALL)
            pseudo = re.sub('''(<[^>]*?)['`"][\s\S]*?['`"]''', r'\1', code, re.IGNORECASE | re.MULTILINE | re.DOTALL)
            print(pseudo)
            if re.search(f'<[^>]*?{pattern}[\s\S]*?>', pseudo):  # go extreme.
                print('here!', pattern)
                code = re.sub(pattern, message, code, re.IGNORECASE | re.MULTILINE | re.DOTALL)
            return code

        code = re.sub('<!--*?-->', 'COMMENT REMOVED', code)
        for character in ('\t', '#x09;', '&#x0A;', '&#x0D;', '\0'):
            code = code.replace(character, ' ' * 4)
        code = code.replace(character, ' ' * 4)
        for tag in ('script', 'iframe', 'object', 'link', 'style', 'meta', 'frame', 'embed'):
            code = substitute(code, tag, tag.upper() + ' BLOCKED')
        for attr in ('javascript', 'vbscript', 'livescript', 'xss', 'seekSegmentTime', '&{', 'expression'):
            code = substitute(code, attr, attr.upper() + ' BLOCKED')
        code = substitute(code, 'on\w+', 'ON-EVENT BLOCKED')
        for letter in range(65, 123):
            code = substitute(code, f'&#0*{letter};', 'HEX ENCODED LETTER BLOCKED')
            code = substitute(code, f'&#x0*{letter:02X};', 'HEX ENCODED LETTER BLOCKED')
        return code

    def commit(self, request):
        cls = self.__class__
        request.dbsession.add(self)

    def __str__(self):
        return Page.identifier

    @classmethod
    def select(cls, request, identifier):
        #get the DB version...
        self = request.dbsession.query(cls).filter(cls.identifier == identifier).first()
        return self

    @classmethod
    def select_list(cls, request, pages):
        """returns the list of existing pages as Page objects from the db"""
        query = request.dbsession.query(cls).filter(cls.identifier.in_(pages)).all()
        return [page for page in query if page.exists]
