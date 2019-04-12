import os, re, pickle, datetime
import base64
from Crypto.Cipher import AES
from Crypto.Hash import SHA256
from Crypto import Random

##################### Page
# The reason this is not a DB is because
# * the PDB files can get massive
# * the
# * they are easy to query anyway as they have a uuid

class Page:
    def __init__(self, identifier, key=None):
        self.identifier = identifier.replace('\\','/').replace('*','').split('/')[-1]
        self.unencrypted_path = os.path.join('michelanglo_app', 'user-data', self.identifier + '.p')
        self.encrypted_path = os.path.join('michelanglo_app', 'user-data', self.identifier + '.ep')
        if key:
            self.path = self.encrypted_path
        else:
            self.path = self.unencrypted_path
        self.settings = {}
        if key:
            self.key = key.encode('utf-8')
        else:
            self.key = None

    def exists(self, try_both = False):
        if try_both:
            if os.path.exists(self.unencrypted_path) or os.path.exists(self.encrypted_path):
                return True
        elif os.path.exists(self.path):
            return True
        else:
            return False

    def is_password_protected(self, raise_error = False):
        path_exists = os.path.exists(os.path.join('michelanglo_app', 'user-data', self.identifier + '.p'))
        epath_exists = os.path.exists(os.path.join('michelanglo_app', 'user-data', self.identifier + '.ep'))
        if path_exists and not epath_exists:
            return False
        elif not path_exists and epath_exists:
            return True
        else:
            if raise_error:
                raise FileExistsError
            else:
                return False

    def load(self, die_on_error = False):
        if self.exists():
            if not self.is_password_protected():
                with open(self.path, 'rb') as fh:
                    self.settings  = pickle.load(fh)
            elif self.key:
                with open(self.path, 'rb') as fh:
                    cryptic = fh.read()
                    decryptic = self._decrypt(cryptic)
                    self.settings = pickle.loads(decryptic)
            else:
                raise ValueError('No key provided.')
        else:
            if die_on_error:
                raise FileNotFoundError(self.identifier)
            else:
                print(self.identifier,'not found')
        return self.settings

    def save(self, settings=None):
        ## sort things out
        if not settings:
            settings = self.settings
        if 'description' not in settings:
            settings['description'] = 'Editable text. press pen to edit.'
        if 'title' not in settings:
            settings['title'] = 'User submitted structure'
        for fun, keys in ((list, ('editors', 'visitors', 'authors')),
                      (bool, ('image', 'uniform_non_carbon', 'verbose', 'validation', 'save', 'public','confidential')),
                      (str, ('viewport', 'stick', 'backgroundcolor', 'loadfun', 'proteinJSON', 'pdb', 'description', 'title', 'data_other'))):
            for key in keys:
                if key not in settings:
                    settings[key] = fun()
        # metadata
        settings['date'] = str(datetime.datetime.now())
        settings['page'] = self.identifier
        settings['key'] = self.key # is this wise??
        ## write
        with open(self.path, 'wb') as fh:
            if not self.key:
                pickle.dump(settings, fh)
            else:
                uncryptic = pickle.dumps(settings)
                cryptic = self._encrypt(uncryptic)
                fh.write(cryptic)

    def delete(self):
        if os.path.exists(self.encrypted_path):
            os.remove(self.encrypted_path)
        elif os.path.exists(self.unencrypted_path):
            os.remove(self.unencrypted_path)
        else:
            print('Impossible. cannot remove missing item')

    @staticmethod
    def sanitise_URL(page):
        return page.replace('\\', '/').replace('*', '').split('/')[-1]

    @staticmethod
    def sanitise_HTML(code):
        return re.sub('<\s?\/?script', '&lt;script', code, re.IGNORECASE)

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
