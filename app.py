from waitress import serve
from pyramid.paster import get_app
import os

# custom `app.py` made to use instead of using `pserve` as I am not running a venv atm.

if 'SQL_URL' in os.environ:  # postgres in production!
    app = get_app('production.ini', 'main', options={'sql_url':os.environ['SQL_URL']})
else:
    app = get_app('development.ini', 'main')
serve(app, host='0.0.0.0', port=8088, threads=50)