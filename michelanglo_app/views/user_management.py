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
from pyramid.view import view_config, view_defaults
from .common_methods import notify_admin, is_malformed
from ..models import User, Page

import time

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

from datetime import datetime

@view_defaults(route_name='login')
class UserView:

    def __init__(self, request):
        self.request = request
        self.requestor = self.request.user
        # sort out inputs
        if 'action' in self.request.params:
            self.action = self.request.params['action']
        else:
            self.action = None
        # to be filled conditionally
        # logged in?
        if 'username' in self.request.params:
            self.username = sanitise_text(self.request.params['username']).strip()
            self.targetuser = self.request.dbsession.query(User).filter_by(name=self.username).first()
        else:
            self.username = None
            self.targetuser = None
        # logging in?
        if 'password' in self.request.params:
            self.password = sanitise_text(self.request.params['password']).strip()
        else:
            self.password = ''
        # double security
        if 'code' in request.params and request.params['code'] == os.environ['SECRETCODE']:
            self.code_verified = True
        else:
            self.code_verified = False

    @view_config(renderer="json")
    def respond(self):
        reply = self.choose_response()
        log.info(str(reply)+f'(code: {self.request.response.status})')
        return reply

    def choose_response(self):
        if self.action is None:
            return is_malformed(self.request, 'action')
        # deal with username independent actions (post login).
        if self.action in ('whoami', 'logout', 'change_password'):
            if self.action == 'whoami':
                return self.whoami()
            elif self.action == 'logout':
                return self.logout()
            elif self.action == 'change_password':
                return self.change_password()
            else:
                pass
        elif self.action in ('login', 'register', 'forgot'):
            if self.username is None:
                return is_malformed(self.request, 'username')
            elif self.action == 'login':
                return self.login()
            elif self.action == 'register':
                return self.register()
            elif self.action == 'forgot':
                self.forgot()
            else:
                pass
        elif self.action in ('promote', 'kill', 'reset', 'email'):
            if self.requestor and self.requestor.role == 'admin':  ##only admins!
                if self.username is None:
                    return is_malformed(self.request, 'username')
                elif self.action == 'promote':
                    self.targetuser.role = self.request.POST['role']
                    self.request.dbsession.add(self.targetuser)
                    return {'status': 'promoted'}
                elif self.action == 'kill':
                    self.request.dbsession.delete(self.targetuser)
                    return {'status': 'deleted'}
                elif self.action == 'reset':
                    self.targetuser.set_password('password')
                    self.request.dbsession.add(self.targetuser)
                    return {'status': 'reset'}
                elif self.action == 'email' and self.code_verified:
                    return {'status': 'email', 'name': self.targetuser.name, 'email': self.targetuser.email}
                else:
                    self.request.response.status = 400
                    return {'status': 'malformed'}
            else:
                self.request.response.status = 403
                return {'status': 'access denied'}
        else:
            self.request.response.status = 405
            return {'status': 'unknown request'}


    ####### Authenticated actions
    def whoami(self):
        # logged in action
        if self.requestor is not None:
            return {'status': 'verification', 'name': self.requestor.name, 'rank': self.requestor.role}
        else:
            return {'status': 'verification', 'name': 'guest', 'rank': 'guest'}

    def logout(self):
        # logged in action
        headers = forget(self.request)
        self.request.response.headerlist.extend(headers)
        return {'status': 'logged out'}

    def change_password(self):
        # logged in action
        if self.requestor and self.requestor.check_password(sanitise_text(self.request.params['password'])):
            self.requestor.set_password(sanitise_text(self.request.params['newpassword']))
            self.request.dbsession.add(self.requestor)
        else:
            self.request.response.status = 403
            return {'status': 'wrong password'}

    ####### Unauthenticated actions
    def login(self):
        #pre log in action
        if self.has_exceeded_tries():
            self.request.response.status = 429
            return {'status': 'Too many failures. Ten requests in ten minutes. Try again later.'}
        elif self.targetuser is not None and self.targetuser.check_password(self.password):
            headers = remember(self.request, self.targetuser.id)
            self.request.response.headerlist.extend(headers)
            return {'status': 'logged in', 'name': self.targetuser.name, 'rank': self.targetuser.role}
        elif self.targetuser:
            self.request.response.status = 400
            return {'status': 'wrong password'}
        else:
            self.request.response.status = 400
            return {'status': 'wrong username'}

    def register(self):
        #pre log in action
        if self.targetuser:
            self.request.response.status = 409
            return {'status': 'existing username'}
        elif self.username in ('guest', 'Anonymous', 'anonymous', 'error', '', 'trashcan', 'public'):
            self.request.response.status = 403
            return {'status': 'forbidden'}
        else:
            if self.username == 'admin': #once only...
                new_user = User(name=self.username, role='admin')
            else:
                new_user = User(name=self.username, role='new', email=self.request.params['email'])
            new_user.set_password(self.password)
            self.request.dbsession.add(new_user)
            new_user = self.request.dbsession.query(User).filter_by(name=self.username).first()
            headers = remember(self.request, new_user.id)
            self.request.response.headerlist.extend(headers)
            return {'status': 'registered', 'name': new_user.name, 'rank': new_user.role}

    def forgot(self):
        #pre log in action
        if 'email' in self.request.params:
            email = str(self.request.params['email'])
            targetuser = self.request.dbsession.query(User).filter_by(email=email).first()
            if targetuser:
                if notify_admin(f' {targetuser.name} ({email}) has requested a password reset.'):
                    return {'status': 'request sent'}
                else:
                    self.request.response.status = 503
                    return {'status': 'message could not be sent. Please email manually'}
            else:
                self.request.response.status = 403
                return {'status': 'Unrecognised email address'}
        else:
            self.request.response.status = 402
            return {'status': 'Missing email address'}

    ### other

    def has_exceeded_tries(self):
        now = datetime.now().timestamp()
        if 'tries' in self.request.session:
            if len(self.request.session['tries']) > 10:
                if now - self.request.session['tries'][-9] < 10 * 60:  # ten minutes.
                    return True
            self.request.session['tries'].append(now)
        else:
            self.request.session['tries'] = [now]
        return False

###################

def permission(request, page, mode='edit', key_label='encryption_key'):
    """
    :param request:
    :param page:
    :param mode: Permission for view are laxer. Everything is the same as editing.
    :param key_label:
    :return:
    """
    user = request.user
    if page is None:
        request.response.status_int = 404
        log.warning(f'{User.get_username(request)} requested a missing page ({request.host_url}).')
        return {'status': 'page not found'}
    elif not page.existant: #but used to exist.
        request.response.status_int = 410
        log.warning(f'{User.get_username(request)} requested a deleted page {page.identifier}')
        return {'status': 'page no longer existent'}
    elif page.encrypted:
        if key_label not in request.params:
            request.response.status_int = 403
            log.warning(f'{User.get_username(request)} requested an encrypted page {page.identifier} without {key_label}')
            return {'status': 'page requires key'}
        else:
            page.key = request.params[key_label].encode('utf-8')
            try:
                page.load()
                request.response.status_int = 200
                return {'status': 'OK'}  # valid key
            except ValueError:
                request.response.status_int = 403
                log.warning(f'{User.get_username(request)} requested an encrypted page {page.identifier} with wrong key')
                return {'status': 'page requires correct key'}
    else:
        try:
            page.load()
        except FileNotFoundError:
            page.existant = False
            request.response.status_int = 404
            log.error(f'Page not found {page.identifier}')
            return {'status': 'Page not found!'}
        if mode != 'view' and not user:
            request.response.status_int = 401
            log.warning(f'{User.get_username(request)} not authorised to {mode} page {page.identifier}')
            return {'status': f'not authorised to {mode} page without at least logging in'}
        elif mode != 'view' and not (page.identifier in user.owned.pages or
                                      user.role == 'admin' or ('freelyeditable' in page.settings and page.settings['freelyeditable'])):
            ## only owners and admins can edit freely.
            request.response.status_int = 403
            log.warning(f'{User.get_username(request)} not authorised to {mode} page {page.identifier}')
            return {'status': f'not authorised to {mode} page'}
        else:
            return {'status': 'OK'}
