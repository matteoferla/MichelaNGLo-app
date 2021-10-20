from waitress import serve
from pyramid.paster import get_app, setup_logging
from pyramid.router import Router
import os, argparse

# ======================================================================================================================

# custom `app.py` due to os.environs...
parser = argparse.ArgumentParser()
parser.add_argument('-c', '--config', help='run the specified config file')
parser.add_argument('-d', '--dev', action='store_true', help='run in dev mode, short for `--config development.ini`')
print(parser.parse_args())
if parser.parse_args().config:
    configfile = parser.parse_args().config
    print(f'RUNNING {configfile}')
elif parser.parse_args().dev:
    print('*' * 10)
    print('RUNNING IN DEV MODE')
    print('*' * 10)
    configfile = 'development.ini'
else:
    configfile = 'production.ini'

# ----------------------------------------------------------------------------------------------------------------------

setup_logging(configfile)
app: Router = get_app(configfile, 'main')

# ======================================================================================================================

if __name__ == '__main__':
    serve(app, host='0.0.0.0', port=8088, threads=50)
