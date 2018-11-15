from waitress import serve
from pyramid.paster import get_app

# custom `app.py` made to use instead of using `pserve` as I am not running a venv atm.

app = get_app('production.ini', 'main')
serve(app, host='0.0.0.0', port=8080, threads=50)
