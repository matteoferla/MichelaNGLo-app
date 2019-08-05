from ._common_methods import notify_admin
from pyramid.view import view_config
from ..models import User

import logging
log = logging.getLogger(__name__)

@view_config(route_name='msg', renderer='json')
def send_msg(request):
    if 'page' in request.params and 'text' in request.params:
        if 'event' == 'report':
            log.warning(f'{User.get_username(request)} reported {request.params["page"]}')
            notify_admin(f'{User.get_username(request)} reported {request.params["page"]} because {request.params["text"]}')
        else:
            if request.user:
                log.info(f'{User.get_username(request)} sent a message')
                notify_admin(f'Message from {User.get_username(request)} ({request.params["page"]}) stating:\n {request.params["text"]}')
            else:
                request.response.status = 403
                return {'status': 'Unregistered user.'}
        return {'status': 'ok'}
    else:
        request.response.status = 400
        return {'status': 'No page or txt specified'}