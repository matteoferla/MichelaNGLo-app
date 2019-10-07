### https://docs.pylonsproject.org/projects/pyramid/en/latest/tutorials/wiki2/definingmodels.html#add-user-py
import bcrypt
from sqlalchemy import (
    Column,
    Integer,
    Text
)
from .meta import Base

class Doi(Base):
    """ The SQLAlchemy declarative model class for a User object.
    Contains `visited_pages` and `owned_pages` DB entries and the `.visited` and `.owned` attributes,
    which have the methods .get() .set(pagenames) .delete(pagename) .add(pagename), which work on pagenames/uuids
    while the method .select(request) is the same as get but interacts with the DB Page table...
    """
    __tablename__ = 'redirects'
    id = Column(Integer, primary_key=True)
    long = Column(Text, nullable=False, unique=True)
    short = Column(Text, nullable=False, unique=True)

    @classmethod
    def reroute(cls, request, short):
        #get the DB version...
        self = request.dbsession.query(cls).filter(cls.short == short).first()
        if self:
            return self.long
        else:
            return None
