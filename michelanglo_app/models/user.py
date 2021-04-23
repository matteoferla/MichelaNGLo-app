### https://docs.pylonsproject.org/projects/pyramid/en/latest/tutorials/wiki2/definingmodels.html#add-user-py
import bcrypt
from sqlalchemy import (
    Column,
    Integer,
    Text
)

from .meta import Base
from .pages import Page

from typing import List

class Pagegroup:
    ### see User
    pages = property(lambda self: getattr(self.user, self.groupname) if getattr(self.user, self.groupname) is not None else '',
                     lambda self, value: setattr(self.user, self.groupname, value))

    def __init__(self, user, group):
        self.user = user
        self.group = group
        self.groupname = group+'_pages'

    def remove(self, pagename):
        self.pages = self.pages.replace(pagename,'')

    def add(self, pagename):
        self.pages += ' ' + pagename

    def set(self, pagenames):
        self.pages = ' '.join(pagenames)

    def get(self) -> List[str]:
        """
        Returns a list of string, while select returns list of page objects (without loading them)
        """
        if self.group == 'visited':
            if self.user.visited_pages is None:
                return []
            else:
                return list(set(self.user.visited_pages.split()) - set(self.user.owned.get()))
        else:
            if self.user.owned_pages is None:
                return []
            else:
                return self.user.owned_pages.split()

    def select(self, session) -> List[Page]:
        pagenames = self.get()
        pages = Page.select_list(session, pagenames)
        self.set([p.identifier for p in pages])
        return pages


class User(Base):
    """ The SQLAlchemy declarative model class for a User object.
    Contains `visited_pages` and `owned_pages` DB entries and the `.visited` and `.owned` attributes,
    which have the methods .get() .set(pagenames) .delete(pagename) .add(pagename), which work on pagenames/uuids
    while the method .select(request.dbsession) is the same as get but interacts with the DB Page table...
    """
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True)
    name = Column(Text, nullable=False, unique=True)
    role = Column(Text, nullable=False) #basic|admin|friend|trashcan
    email = Column(Text)
    owned_pages = Column(Text)  #space separated list as text as array is not valid in mySQL... but I have switched to postgres...
    visited_pages = Column(Text)
    password_hash = Column(Text)
    _visited = None
    _owned = None

    @property
    def visited(self):
        if not self._visited:
            self._visited = Pagegroup(self, 'visited')
        return self._visited

    @property
    def owned(self):
        if not self._owned:
            self._owned = Pagegroup(self, 'owned')
        return self._owned

    def set_password(self, pw):
        pwhash = bcrypt.hashpw(pw.encode('utf8'), bcrypt.gensalt())
        self.password_hash = pwhash.decode('utf8')
        return self

    def check_password(self, pw):
        if self.password_hash is not None:
            expected_hash = self.password_hash.encode('utf8')
            return bcrypt.checkpw(pw.encode('utf8'), expected_hash)
        return False

    @staticmethod
    def get_username(request):
        """
        Returns the useraname or the IP address...
        :param request:
        :return:
        """
        # registered user
        if request.user:
            return f'{request.user.name} ({request.user.role})'
        # unregistered
        ip = '/'.join([request.environ[x] for x in ("REMOTE_ADDR",
                                                    "HTTP_X_FORWARDED_FOR",
                                                    "HTTP_CLIENT_IP") if x in request.environ and request.environ[x] != '127.0.0.1'])
        if ip != '':
            return ip
        else:
            return 'localhost'

