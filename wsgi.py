from pyramid.paster import get_app, setup_logging

ini_path = '/home/matteo/Coding/PyMOL-to-NGL-transpiler/production.ini'

setup_logging(ini_path)
application = get_app(ini_path, 'main')
