from pyramid.view import view_config

from ..models import User

from pyramid.security import (
    remember,
    forget,
    )

@view_config(route_name='login', renderer="json")
def login_view(request):
    action   = request.params['action']
    username = request.params['username']
    password = request.params['password']
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
    else:
        request.response.status = 400
        return {'status': 'unknown request'}
