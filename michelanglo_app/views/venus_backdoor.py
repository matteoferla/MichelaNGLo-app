from pyramid.view import view_config
from pyramid.security import remember
import os, pickle, uuid
from ..models import User, Page

import logging
log = logging.getLogger(__name__)

@view_config(route_name='venus', renderer="json")
def backdoor_for_venus(request):
    """
    Two layers of security. A shared environment variable and REMOTE_ADDR 127.0.0.1
    """

    if request.environ['REMOTE_ADDR'] in ('127.0.0.1') and request.params['code'] == os.environ['SECRETCODE'] and 'HTTP_X_FORWARDED_FOR' not in request.environ: #it is VENUS
        log.info(f'{User.get_username(request)} made a page with VENUS')
        pagename = str(uuid.uuid4())
        settings = {'authors': [request.params['username']],
                    'proteinJSON': '['+request.params['protein']+']',
                    'title': request.params['title'],
                    'description': request.params['description'],
                    'page': pagename,
                    'columns_viewport': 6,
                    'columns_text': 6,
                    'editable': True, 'backgroundcolor': 'white', 'validation': None, 'js': None, 'pdb': '', 'loadfun': ''
                    }
        Page(pagename).save(settings).commit(request)
        # deal with logged-in-ness at Michelanglo
        # is this wise? Let's assume it is not wise to play with it so it is commented out for now.
        #requestor = request.dbsession.query(User).filter_by(name=request.params['username']).first()
        #setcookie = remember(request, requestor.id)
        requestor = request.dbsession.query(User).filter_by(name=request.params['username']).first()
        requestor.owned.add(pagename)
        request.dbsession.add(requestor)
        return {'status': 'success', 'page': pagename}
    else:
        request.response.status = 403
        log.warn(f'{User.get_username(request)} pretended to be VENUS') #a purposeful attack
        return {'status': 'stranger danger'}
