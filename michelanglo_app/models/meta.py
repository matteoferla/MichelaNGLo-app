from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.schema import MetaData
import uuid

# def auto_constraint_name(constraint, table):
#     if constraint.name is None or constraint.name == "_unnamed_":
#         return "sa_autoname_%s" % str(uuid.uuid4())[0:5]
#     else:
#         return constraint.name

# Recommended naming convention used by Alembic, as various different database
# providers will autogenerate vastly different names making migrations more
# difficult.
NAMING_CONVENTION = {
    #"auto_constraint_name": auto_constraint_name,
    "ix": "ix_%(column_0_label)s",
    "uq": "uq_%(table_name)s_%(column_0_name)s",
    "ck": "ck_%(table_name)s_%(constraint_name)s",
    "fk": "fk_%(table_name)s_%(column_0_name)s_%(referred_table_name)s",
    "pk": "pk_%(table_name)s"
}

metadata = MetaData(naming_convention=NAMING_CONVENTION)
Base = declarative_base(metadata=metadata)
