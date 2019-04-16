from pyramid.view import view_config
from pyramid.security import remember
import os, pickle, uuid
from ..models.user import User
from ..models.pages import Page

@view_config(route_name='venus', renderer="json")
def backdoor_for_venus(request):
    """
    Two layers of security. A shared environment variable and REMOTE_ADDR 127.0.0.1
    """
    if request.environ['REMOTE_ADDR'] in ('127.0.0.1','brc10.well.ox.ac.uk', 'fe80::695d:c288:e51a:b759%11') and request.params['code'] == os.environ['SECRETCODE']: #it is VENUS
        pagename = str(uuid.uuid4())
        settings = {'authors': [request.params['username']],
                    'proteinJSON': '['+request.params['protein']+']',
                    'title': request.params['title'],
                    'description': request.params['description'],
                    'page': pagename,
                    'editable': True, 'backgroundcolor': 'white', 'validation': None, 'js': None, 'pdb': '', 'loadfun': ''
                    }
        Page(pagename).save(settings)
        # deal with logged-in-ness at Michelanglo
        # is this wise? Let's assume it is not wise to play with it so it is commented out for now.
        #requestor = request.dbsession.query(User).filter_by(name=request.params['username']).first()
        #setcookie = remember(request, requestor.id)
        requestor = request.dbsession.query(User).filter_by(name=request.params['username']).first()
        requestor.add_owned_page(pagename)
        request.dbsession.add(requestor)
        print(__name__,pagename)
        return {'status': 'success', 'page': pagename}
    else:
        print(__name__)
        print(request.environ['REMOTE_ADDR'])
        print(request.params['code'])
        request.response.status = 403
        return {'status': 'stranger danger'}
