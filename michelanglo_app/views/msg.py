from ._common_methods import notify_admin, get_username
from pyramid.view import view_config

import logging
log = logging.getLogger(__name__)

@view_config(route_name='msg', renderer='json')
def send_msg(request):
    if 'page' in request.params and 'text' in request.params:
        log.warning(f'{get_username(request)} reported {request.params["page"]}')
        notify_admin(f'{get_username(request)} reported {request.params["page"]} because {request.params["text"]}')
        return {'status': 'ok'}
    else:
        request.response.status = 400
        return {'status': 'No page or txt specified'}