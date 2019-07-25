# cross origin request is okay only for NGL.extended.js

from pyramid.view import view_config
from pyramid.response import FileResponse
from ..models import User

import logging
log = logging.getLogger(__name__)


@view_config(route_name='extended_menu')
def extended_menu(request):
    return crossorigin(request, 'michelanglo_menu.js')

@view_config(route_name='extended')
def extended(request):
    return crossorigin(request, 'michelanglo.js')

def crossorigin(request, page):
    log.info(f'CORS request for {page} by {User.get_username(request)}')
    response = FileResponse(f'michelanglo_app/static/{page}', request)
    response.headers.update({
        'Access-Control-Allow-Origin': '*',
    })
    return response