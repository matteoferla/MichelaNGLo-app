__docs__ = """
To install...
# get python
sudo apt-get install python3
# make venv
sudo apt-get install python3-venv
python3 -m venv env
./env/bin/pip install -e .
# make pymol
sudo apt-get install python3-dev libglm-dev freeglut3-dev libglew-dev libpng12-dev libfreetype6-dev build-essential libxml++2.6-dev
sudo apt-get install libpng-dev # if libpng12-dev fails.
./env/bin/pip install pmw numpy
prefix=env/pymol
modules=$prefix/modules
mkdir -p $prefix
mkdir -p $modules
git clone https://github.com/schrodinger/pymol-open-source.git env/pymol
cd env/pymol
sudo ./env/bin/python3 setup.py build install --home=${prefix}/ --install-lib=$modules --install-scripts=$prefix/
#add the module to python
#sudo echo $modules > env/lib/python3.6/dist-packages/pymol.pth  #mac
sudo echo $modules > env/lib/python3.6/site-packages/pymol.pth  #linux
./env/bin/alembic -c production.ini revision --autogenerate -m "lets get this party started"

command for shitedows 7 when venv fails. without the \\ as \ is a special character. God I hate windows.
C:\\Users\\matteo\\AppData\\Local\\Continuum\\anaconda3\\Scripts\\pip3.exe install -e .
C:\\Users\\matteo\\AppData\Local\\Continuum\\anaconda3\Scripts\\alembic.exe -c production.ini revision --autogenerate -m "use Users"
C:\\Users\\matteo\\AppData\Local\\Continuum\\anaconda3\\Scripts\\alembic.exe -c development.ini upgrade head
also requires to be installed by mouse:
https://www.enterprisedb.com/downloads/postgres-postgresql-downloads
"""

import os

from setuptools import setup, find_packages

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
    'db-psycopg2'
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
