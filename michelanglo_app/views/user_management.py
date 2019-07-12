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
from ._common_methods import notify_admin
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

from datetime import datetime

def has_exceeded_tries(request):
    now = datetime.now().timestamp()
    if 'tries' in request.session:
        if len(request.session['tries']) >10:
            if now - request.session['tries'][-9] < 10*60: #ten minutes.
                return True
        request.session['tries'].append(now)
    else:
        request.session['tries'] = [now]
    return False


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
        if has_exceeded_tries(request):
            request.response.status = 429
            return {'status': 'Too many failures. Ten requests in ten minutes. Try again later.'}
        elif targetuser is not None and targetuser.check_password(password):
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
        if targetuser:
            request.response.status = 409
            return {'status': 'existing username'}
        elif username in ('guest', 'Anonymous', 'anonymous', 'error', '', 'trashcan', 'public'):
            request.response.status = 403
            return {'status': 'forbidden'}
        else:
            if username == 'admin': #once only.
                new_user = User(name=username, role='admin')
            else:
                new_user = User(name=username, role='basic', email=request.params['email'])
            new_user.set_password(password)
            request.dbsession.add(new_user)
            headers = remember(request, new_user.id)
            request.response.headerlist.extend(headers)
            return {'status': 'registered', 'name': new_user.name, 'rank': new_user.role}
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
    elif action == 'forgot':
        if 'email' in request.params:
            email = str(request.params['email'])
            targetuser = request.dbsession.query(User).filter_by(email=email).first()
            if targetuser:
                if notify_admin(f' {targetuser.name} ({email}) has requested a password reset.'):
                    return {'status': 'request sent'}
                else:
                    request.response.status = 503
                    return {'status': 'message could not be sent. Please email manually'}
            else:
                request.response.status = 403
                return {'status': 'Unrecognised email address'}
    else:
        request.response.status = 405
        return {'status': 'unknown request'}
