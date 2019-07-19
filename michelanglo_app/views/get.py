from pyramid.view import view_config
from pyramid.renderers import render_to_response
import traceback
from ..models.pages import Page
from ..models.user import User
from ..models.trashcan import get_trashcan, get_public
from ..transplier import PyMolTranspiler
import uuid
import shutil
import os
import io
import json

import logging
log = logging.getLogger(__name__)
from ._common_methods import get_username, is_malformed, notify_admin

from .default import custom_messages

#from pprint import PrettyPrinter
#pprint = PrettyPrinter()


@view_config(route_name='get')
def get_ajax(request):
    malformed = is_malformed(request, 'item')
    if malformed:
        return {'status': malformed}

    def log_it():
        log.warn(f'{get_username(request)} was refused {request.params["item"]}, code: {request.response.status}')

    user = request.user
    modals = {'register': "../templates/login/register_modalcont.mako",
            'login': "../templates/login/login_modalcont.mako",
            'forgot': "../templates/login/forgot_modalcont.mako",
            'logout': "../templates/login/logout_modalcont.mako",
            'password': "../templates/login/password_modalcont.mako"}
    ###### get the user page list.
    if request.params['item'] == 'pages':
        if not user:
            request.response.status = 401
            log_it()
            return render_to_response("../templates/part_error.mako", {'error': '401'}, request)
        elif user.role == 'admin':
            target = request.dbsession.query(User).filter_by(name=request.POST['username']).one()
            return render_to_response("../templates/login/pages.mako", {'user': target}, request)
        elif request.POST['username'] == user.name:
            return render_to_response("../templates/login/pages.mako", {'user': request.user}, request)
        else:
            request.response.status = 403
            log_it()
            return render_to_response("../templates/part_error.mako", {'error': '403'}, request)
    ####### get the modals
    elif request.params['item'] in  modals.keys():
        return render_to_response(modals[request.params['item']], { 'user': request.user}, request)
    ####### get the implementation code.
    elif request.params['item'] == 'implement':
        ## should non editors be able to see this??
        page = Page(request.params['page'])
        if 'key' in request.params:
            page = Page(request.params['page'], request.params['key'])
        else:
            page = Page(request.params['page'])
        settings = page.load()
        return render_to_response("../templates/results/implement.mako", settings, request)
    else:
        request.response.status = 404
        log_it()
        return render_to_response("../templates/part_error.mako", {'error': '404'}, request)

@view_config(route_name='get_pages', renderer='json')
def get_pages(request):
    """
    Get pages for API purposes
    :param request:
    :return:
    """
    user = request.user
    log.info(f'{get_username(request)} request API view of pages')
    data = {}
    if not user:
        data['owned'] = 'not logged in'
        data['visited'] = 'not logged in'
        data['error'] = 'not logged in'
    else:
        if user.role == 'admin':
            data['all'] = {'unencrypted': [p.replace('.p','') for p in os.listdir(os.path.join('michelanglo_app', 'user-data')) if os.path.splitext(p)[1] == '.p'],
                           'encrypted': [p.replace('.ep','') for p in os.listdir(os.path.join('michelanglo_app', 'user-data')) if os.path.splitext(p)[1] == '.ep']}
        else:
            data['all'] = 'RESTRICTED'
        data['owned'] = user.get_owned_pages()
        data['visited'] = user.get_visited_pages()
    data['public'] = request.dbsession.query(User).filter_by(name='public').one().get_owned_pages()
    return data

@view_config(route_name='set', renderer='json')
def set_ajax(request):
    if not request.user or request.user.role != 'admin':
        request.response.status = 403
        log.warn(f'{get_username(request)} was refused setting.')
    else:
        malformed = is_malformed(request, 'item')
        if malformed:
            return {'status': malformed}
        if request.params['item'] == 'msg':
            malformed = is_malformed(request, 'title','descr','bg')
            if malformed:
                return {'status': malformed}
            custom_messages.append({el: request.params[el] for el in ('title','descr','bg')})
            log.info(f'{get_username(request)} set a new custom message.')
            return {'status': 'success'}
        elif request.params['item'] == 'clear_msg':
            log.info(f'{get_username(request)} cleared custom messages.')
            while custom_messages:
                custom_messages.pop()
            return {'status': 'success'}
        elif request.params['item'] == 'terminate':
            if 'code' in request.params and request.params['code'] == os.environ['SECRETCODE']:
                log.warning(f'{get_username(request)} terminated the app')
                notify_admin(f'{get_username(request)} terminated the app')
                os.system('kill `lsof -t -i:8088`') ## is this the most graceful way of kill itself???
            else:
                log.warning(f'{get_username(request)} tried to terminate the app')
                notify_admin(f'{get_username(request)} tried to terminate the app')
                return {'status': 'wrong secret code.'}
        else:
            return {'status': 'unknown cmd'}



