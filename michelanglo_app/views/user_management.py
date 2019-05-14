############ THIS IS COPY PASTE FROM MICHELANGLO. PLEASE EDIT THAT TOO.



__doc__ = """
This file contains only one method (`user_view`).
data = {'username': 'testdummy',
        'password': 'crash',
        'email': 'testdummy@example.com',
        'action': 'register'}
action can be login (username and password), logout (nothing), register (also req. `email`), whoami (debug only)
if the user is admin it can also be promote (req. `role`), kill, reset
the reply "status" and occasionally "username"


The modal that controls it is `login/user_modal.mako`. However the content is controlled by a ajax to `/get` to get the relevant `*_modalcont.mako` (content).
"""
from pyramid.view import view_config
from ..models import User

import logging
log = logging.getLogger(__name__)

from pyramid.security import (
    remember,
    forget,
    )

import re, os

def sanitise_text(text):
    ### completely not needed.
    nasty = '[\x00\|\-\*\/\<\>\,\=\<\>\~\!\^\(\)\'\"]'
    value = re.sub(nasty,'', text)
    if len(value) == 0:
        return 'blank'
    return value

def log_reply(fun):
    def inner(request):
        reply = fun(request)
        log.info(str(reply)+f'(code: {request.response.status})')
        return reply
    return inner

@view_config(route_name='login', renderer="json")
@log_reply
def user_view(request):
    # sort out inputs
    action   = request.params['action']
    if 'username' in request.params:
        username = sanitise_text(request.params['username'])
    else:
        username ='ERROR'
    if 'password' in request.params:
        password = sanitise_text(request.params['password'])
    else:
        password = ''

    targetuser = request.dbsession.query(User).filter_by(name=username).first()
    requestor = request.user
    # deal with inputs.
    if action == 'whoami':
        if requestor is not None:
            return {'status': 'verification', 'name': requestor.name, 'rank': requestor.role}
        else:
            return {'status': 'verification', 'name': 'guest', 'rank': 'guest'}
    elif action == 'login':
        if targetuser is not None and targetuser.check_password(password):
            headers = remember(request, targetuser.id)
            request.response.headerlist.extend(headers)
            return {'status': 'logged in', 'name': targetuser.name, 'rank': targetuser.role}
        elif targetuser:
            request.response.status = 400
            return {'status': 'wrong password'}
        else:
            request.response.status = 400
            return {'status': 'wrong username'}
    elif action == 'register':
        if username in ('guest', 'Anonymous', 'trashcan', 'public'): ##blacklisted
            request.response.status = 403
            return {'status': 'forbidden'}
        if not targetuser:
            if username == 'admin': #once only.
                new_user = User(name=username, role='admin')
            else:
                new_user = User(name=username, role='basic', email=request.params['email'])
            new_user.set_password(password)
            request.dbsession.add(new_user)
            targetuser = request.dbsession.query(User).filter_by(name=username).first()
            headers = remember(request, targetuser.id)
            request.response.headerlist.extend(headers)
            return {'status': 'registered', 'name': targetuser.name, 'rank': targetuser.role}
        else:
            request.response.status = 400
            return {'status': 'existing username'}
    elif action == 'logout':
        headers = forget(request)
        request.response.headerlist.extend(headers)
        return {'status': 'logged out'}
    elif action == 'promote':
        if requestor and requestor.role == 'admin': ##only admins can make admins
            target=request.dbsession.query(User).filter_by(name=username).one()
            target.role = request.POST['role']
            request.dbsession.add(target)
            return {'status': 'promoted'}
        else:
            request.response.status = 403
            return {'status': 'access denied'}
    elif action == 'kill':
        if requestor and requestor.role == 'admin': ##only admins have a licence to kill
            target=request.dbsession.query(User).filter_by(name=username).one()
            request.dbsession.delete(target)
            return {'status': 'deleted'}
        else:
            request.response.status = 403
            return {'status': 'access denied'}
    elif action == 'change_password':
        if requestor and requestor.check_password(sanitise_text(request.params['password'])):
            requestor.set_password(sanitise_text(request.params['newpassword']))
            request.dbsession.add(requestor)
        else:
            request.response.status = 403
            return {'status': 'wrong password'}
    elif action == 'reset':
        if requestor and requestor.role == 'admin': ##only admins can set password this way.
            target=request.dbsession.query(User).filter_by(name=username).one()
            target.set_password('password')
            request.dbsession.add(target)
            return {'status': 'reset'}
        else:
            request.response.status = 403
            return {'status': 'access denied'}
    else:
        request.response.status = 405
        return {'status': 'unknown request'}
