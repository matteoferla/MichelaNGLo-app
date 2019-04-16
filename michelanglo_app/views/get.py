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


#from pprint import PrettyPrinter
#pprint = PrettyPrinter()


@view_config(route_name='get')
def get_ajax(request):
    user = request.user
    modals = {'register': "../templates/login/register_modalcont.mako",
            'login': "../templates/login/login_modalcont.mako",
            'forgot': "../templates/login/forgot_modalcont.mako",
            'logout': "../templates/login/logout_modalcont.mako",
            'password': "../templates/login/password_modalcont.mako"}
    ###### get the user page list.
    if request.params['item'] == 'pages':
        if not user:
            request.response.status = 403
            return render_to_response("../templates/404.mako", {'project': 'Michelanglo', 'user': request.user}, request)
        elif user.role == 'admin':
            target = request.dbsession.query(User).filter_by(name=request.POST['username']).one()
            return render_to_response("../templates/login/pages.mako", {'project': 'Michelanglo', 'user': target}, request)
        elif request.POST['username'] == user.name:
            return render_to_response("../templates/login/pages.mako", {'project': 'Michelanglo', 'user': request.user}, request)
        else:
            request.response.status = 403
            return render_to_response("../templates/404.mako", {'project': 'Michelanglo', 'user': request.user}, request)
    ####### get the modals
    elif request.params['item'] in  modals.keys():

        return render_to_response(modals[request.params['item']], {'project': 'Michelanglo', 'user': request.user}, request)
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
        print('unknown item '+request.params['item'])
        return render_to_response("../templates/404.mako", {'project': 'Michelanglo', 'user': request.user}, request)
