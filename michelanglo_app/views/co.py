# cross origin request is okay only for NGL.extended.js

from pyramid.view import view_config
from pyramid.response import FileResponse

import logging
log = logging.getLogger(__name__)

from ._common_methods import get_username

@view_config(route_name='extended')
def post(request):
    log.info(f'CORS request for michelanglo.js by {get_username(request)}')
    response = FileResponse('michelanglo_app/static/ngl.extended.js', request)
    response.headers.update({
        'Access-Control-Allow-Origin': '*',
    })
    return response