### https://docs.pylonsproject.org/projects/pyramid/en/latest/tutorials/wiki2/definingmodels.html#add-user-py
import bcrypt
from sqlalchemy import (
    Column,
    Integer,
    Text
)
from .meta import Base

class Doi(Base):
    """ The SQLAlchemy declarative model class for a r-page object.
    """
    __tablename__ = 'redirects'
    id = Column(Integer, primary_key=True)
    long = Column(Text, nullable=False, unique=True)
    short = Column(Text, nullable=False, unique=True)

    @classmethod
    def reroute(cls, request, short):
        #get the DB version...
        self = request.dbsession.query(cls).filter(cls.short == short.lower()).first()
        if self is not None:
            return self.long
        else:
            return None
