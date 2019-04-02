from pyramid.view import view_config
from pyramid.response import Response

from sqlalchemy.exc import DBAPIError

from ..models import User

from pyramid.security import (
    remember,
    forget,
    )

import re

def sanitise_text(text):
    nasty = '[\x00\|\-\*\/\<\>\,\=\<\>\~\!\^\(\)\'\"]'
    value = re.sub(nasty,'', text)
    if len(value) == 0:
        return 'blank'
    return value


@view_config(route_name='login', renderer="json")
def login_view(request):
    action   = request.params['action']
    username = sanitise_text(request.params['username'])
    password = sanitise_text(request.params['password'])
    print('login_view', action)
    user = request.dbsession.query(User).filter_by(name=username).first()
    if action == 'login':
        if user is not None and user.check_password(password):
            headers = remember(request, user.id)
            request.response.headerlist.extend(headers)
            return {'status': 'logged in', 'name': user.name, 'rank': user.role}
        elif user:
            request.response.status = 400
            return {'status': 'wrong password'}
        else:
            request.response.status = 400
            return {'status': 'wrong username'}
    elif action == 'register':
        if not user:
            if username == 'admin':
                new_user = User(name=username, role='admin')
            else:
                new_user = User(name=username, role='basic')
            new_user.set_password(password)
            request.dbsession.add(new_user)
            return {'status': 'registered', 'name': new_user.name, 'rank': new_user.role}
        else:
            request.response.status = 400
            return {'status': 'existing username'}
    elif action == 'logout':
        headers = forget(request)
        request.response.headerlist.extend(headers)
        return {'status': 'logged out'}
    elif action == 'promote':
        if request.user and request.user.role == 'admin': ##only admins can make admins
            target=request.dbsession.query(User).filter_by(name=username).one()
            target.role = 'admin'
            request.dbsession.add(target)
            return {'status': 'promoted'}
        else:
            request.response.status = 400
            return {'status': 'access denied'}
    elif action == 'kill':
        if request.user and request.user.role == 'admin': ##only admins have a licence to kill
            target=request.dbsession.query(User).filter_by(name=username).one()
            request.dbsession.delete(target)
            return {'status': 'deleted'}
        else:
            request.response.status = 400
            return {'status': 'access denied'}
    elif action == 'reset':
        if request.user and request.user.role == 'admin': ##only admins can reset the password
            target=request.dbsession.query(User).filter_by(name=username).one()
            target.set_password('password')
            request.dbsession.add(target)
            return {'status': 'reset'}
        else:
            request.response.status = 400
            return {'status': 'access denied'}
    else:
        request.response.status = 400
        return {'status': 'unknown request'}
