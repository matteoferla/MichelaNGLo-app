### https://docs.pylonsproject.org/projects/pyramid/en/latest/tutorials/wiki2/definingmodels.html#add-user-py

from sqlalchemy import (
    Column,
    Integer,
    Text
)
from .meta import Base

class Publication(Base):
    """ The SQLAlchemy declarative model class for a publication object.

CREATE TABLE publication (
    id INTEGER NOT NULL,
    identifier VARCHAR ( 255 ) UNIQUE NOT NULL,
    url VARCHAR ( 255 ),
    authors  VARCHAR ( 255 ),
    year INT,
    title  VARCHAR ( 255 ),
    journal  VARCHAR ( 255 ),
    issue  VARCHAR ( 255 ),
    PRIMARY KEY (id)
);

    """
    __tablename__ = 'publication'
    id = Column(Integer, primary_key=True)
    identifier = Column(Text, nullable=False, unique=True)  ## uuid
    url = Column(Text, default='#')
    year = Column(Integer, default=2020)
    authors = Column(Text, default='TBA')
    title = Column(Text, default='TBA')
    journal = Column(Text, default='manuscript in preparation')
    issue = Column(Text, default='NA')

    @classmethod
    def get_citation(cls, request, identifier):
        self = request.dbsession.query(cls).filter(cls.identifier == identifier).first()
        if self is not None:
            return self
        else:
            return None

    def to_html(self):
        return f'<a href="{self.url}" target="_blank">{self.authors}, ({self.year} &#8220;{self.title}&#8221; <b>{self.journal}</b> <i>{self.issue}</i> <i class="far fa-external-link"></i></a>'

    @classmethod
    def from_request(cls, request):
        identifier = request.params['identifier']
        data = {k: request.params[k] for k in ('identifier', 'url', 'authors', 'year', 'title', 'journal', 'issue') if k in request.params}
        self = request.dbsession.query(cls).filter_by(identifier=identifier).first()
        if self is not None:
            for k in data:
                setattr(self, k, request.params[k])
        else:
            self = cls(**data)
        request.dbsession.add(self)
        return self
