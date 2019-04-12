### https://docs.pylonsproject.org/projects/pyramid/en/latest/tutorials/wiki2/definingmodels.html#add-user-py
import bcrypt
from sqlalchemy import (
    Column,
    Integer,
    Text
)

from .meta import Base
from .pages import Page


class User(Base):
    """ The SQLAlchemy declarative model class for a User object. """
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True)
    name = Column(Text, nullable=False, unique=True)
    role = Column(Text, nullable=False) #basic|admin|friend|trashcan
    email = Column(Text)
    owned_pages = Column(Text)  #space separated list as text as array is not valid
    visited_pages = Column(Text)
    password_hash = Column(Text)

    def set_password(self, pw):
        pwhash = bcrypt.hashpw(pw.encode('utf8'), bcrypt.gensalt())
        self.password_hash = pwhash.decode('utf8')
        return self

    def check_password(self, pw):
        if self.password_hash is not None:
            expected_hash = self.password_hash.encode('utf8')
            return bcrypt.checkpw(pw.encode('utf8'), expected_hash)
        return False

    def _add_page(self, pagename, group='visited_pages'):
        pages = self._get_pages(group)
        pages.append(pagename)
        setattr(self,group, ' '.join(pages))
        return self

    def add_visited_page(self,pagename):
        self._add_page(pagename, 'visited_pages')
        return self

    def add_owned_page(self,pagename):
        self._add_page(pagename, 'owned_pages')
        return self

    def get_owned_pages(self):
        return self._get_pages('owned_pages')

    def get_visited_pages(self):
        return list(set(self._get_pages('visited_pages')) - set(self.get_owned_pages()))

    def _get_pages(self, group='visited_pages'):
        # for p in [Page(pagename) for pagename in user.owned_pages.split()] if p.exists()
        if getattr(self, group):
            return self._filter_pages(getattr(self, group).split())
        else:
            return []

    def _filter_pages(self, pages):
        raw = [Page(pagename) for pagename in pages]
        return [page.identifier for page in raw if page.exists(try_both=True)]

    ############### these methods return not list of string but list of Page instatnces.
    def _get_loaded_pages(self, group='visited_pages'):
        pagelist = []
        if group == 'visited_pages':
            fun = self.get_visited_pages
        else:
            fun = self.get_owned_pages
        for pagename in fun():
            page = Page(pagename)
            if page.is_password_protected():
                page.settings = {'title': '***********', 'description': 'This page is encrypted.'}
            else:
                page.load()
            pagelist.append(page)
        return pagelist

    def get_visited_loaded_pages(self):
        return self._get_loaded_pages(group='visited_pages')

    def get_owned_loaded_pages(self):
        return self._get_loaded_pages(group='owned_pages')

    def remove_visited_page(self, page):
        self.visited_pages.replace(page,'')
