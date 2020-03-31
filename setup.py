__docs__ = """
To install fully please see git_docs/deploy.md
"""

import os, warnings

from setuptools import setup, find_packages

warnings.warn('PLEASE READ THE FILE `git_docs/deploy.md`')

here = os.path.abspath(os.path.dirname(__file__))

requires = [
    'plaster_pastedeploy',
    'pyramid',
    'pyramid_mako',
    'pyramid_debugtoolbar',
    'waitress',
    'alembic',
    'pyramid_retry',
    'pyramid_tm',
    'SQLAlchemy',
    'transaction',
    'zope.sqlalchemy',
    'bcrypt',
    'numpy',
    'pycrypto',
    'markdown',
    'psycopg2-binary',
    'requests',
    'sentry-sdk',
    'apscheduler',
    'imageio'#,
    #'bio',
    #'pyrosetta'
]

tests_require = [
    'WebTest >= 1.3.1',  # py3 compat
    'pytest >= 3.7.4',
    'pytest-cov',
]

setup(
    name='michelanglo_app',
    version='0.0',
    description='michelanglo_app',
    long_description=__docs__,
    classifiers=[
        'Programming Language :: Python',
        'Framework :: Pyramid',
        'Topic :: Internet :: WWW/HTTP',
        'Topic :: Internet :: WWW/HTTP :: WSGI :: Application',
    ],
    author='',
    author_email='',
    url='',
    keywords='web pyramid pylons',
    packages=find_packages(),
    include_package_data=True,
    zip_safe=False,
    extras_require={
        'testing': tests_require,
    },
    install_requires=requires,
    entry_points={
        'paste.app_factory': [
            'main = michelanglo_app:main',
        ],
        'console_scripts': [
            'initialize_michelanglo_app_db=michelanglo_app.scripts.initialize_db:main',
        ],
    },
)
