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

from ._common_methods import is_js_true

from ._common_methods import get_username

import logging
log = logging.getLogger(__name__)


@view_config(route_name='edit_user-page', renderer='json')
def edit(request):
    log.info(f'Page edit requested by {get_username(request)}')
    # get ready
    page = Page(request.POST['page'])
    user = request.user
    # check if encrypted
    if page.is_password_protected():
        page.key = request.POST['encryption_key'].encode('uft-8')
        page.path = page.encrypted_path
    # load data
    settings = page.load()
    if not settings:
        request.response.status = 404
        log.warn(f'{get_username(request)} requested a missing page')
        return {'error': 'page not found'}
    ## cehck permissions
    if not user or not (page.identifier in user.get_owned_pages() or user.role == 'admin' or settings['freelyeditable']): ## only owners and admins can edit.
        request.response.status = 403
        log.warn(f'{get_username(request)} is not autharised to edit page')
        return {'error': 'not authorised'}
    else:
        #add author if user was an upgraded to editor by the original author. There are three lists: authors (can and have edited, editors can edit, visitors visit.
        if user.name not in settings['authors']:
            settings['authors'].append(user.name)
        # only admins and friends can edit html fully
        if user.role in ('admin', 'friend'):
            for key in ('loadfun', 'title', 'description'):
                if key in request.POST:
                    settings[key] = request.POST[key]
        else: # regular users have to be sanitised
            for key in ('title', 'description'):
                if key in request.POST:
                    settings[key] = Page.sanitise_HTML(request.POST[key])
        settings['confidential'] = is_js_true(request.POST['confidential'])
        public_from_private= 'public' in settings and not settings['public'] and is_js_true(request.POST['public']) #was private public but is now.
        public_from_nothing= 'public' not in settings and is_js_true(request.POST['public']) #was not decalred but is now.
        if public_from_private or public_from_nothing:
            public = get_public(request)
            public.add_visited_page(page.identifier)
            request.dbsession.add(public)
        elif 'public' in settings and settings['public'] and not is_js_true(request.POST['public']):
                public = get_public(request)
                public.remove_visited_page(page.identifier)
                request.dbsession.add(public)
        else:
            pass
        settings['public'] = is_js_true(request.POST['public'])
        if not settings['public']:
            settings['freelyeditable'] = is_js_true(request.POST['freelyeditable'])
        else:
            settings['freelyeditable'] = False
            #new_editors
        if 'new_editors' in request.POST and request.POST['new_editors']:
            for new_editor in json.loads((request.POST['new_editors'])):
                target = request.dbsession.query(User).filter_by(name=new_editor).one()
                if target:
                    target.add_owned_page(page.identifier)
                    request.dbsession.add(target)
                    settings['editors'].append(target.name)
                else:
                    print('This is impossible...', new_editor, ' does not exist.')
        #encrypt
        if not page.is_password_protected() and request.POST['encryption'] == 'true': # to be encrypted
            page.delete()
            page.key = request.POST['encryption_key'].encode('utf-8')
            page.path = page.encrypted_path
        elif page.is_password_protected() and request.POST['encryption'] == 'false':  #to be dencrypted
            page.delete()
            page.key = None
            page.path = page.unencrypted_path
        else: # no change
            pass
        #alter ratio
        if 'columns_viewport' in request.POST:
            settings['columns_viewport'] = int(request.POST['columns_viewport'])
            settings['columns_text'] = int(request.POST['columns_text'])
        #save
        page.save(settings)
        return {'success': 1}






@view_config(route_name='delete_user-page', renderer='json')
def delete(request):
    # get ready
    log.info(f'{get_username(request)} is requesting to delete page')
    page = Page(request.POST['page'])
    user = request.user
    ownership = user.get_owned_pages()
    ## cehck permissions
    if page.identifier not in ownership and not (user and user.role == 'admin'): ## only owners can delete
        request.response.status = 403
        log.warn(f'{get_username(request)} tried but failed to delete page')
        return {'status': 'Not owner'}
    else:
        page.delete()
        return {'status': 'success'}
