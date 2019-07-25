import json

from pyramid.view import view_config
from pyramid.renderers import render_to_response
from ..models import Page, User
from pyramid.response import FileResponse
from .user_management import permission

import logging, json, os
log = logging.getLogger(__name__)

from . import custom_messages

@view_config(route_name='userdata', renderer="../templates/user_protein.mako")
def userdata_view(request):
    pagename = request.matchdict['id']
    log.info(f'{User.get_username(request)} is looking at a page {pagename}')
    page = Page.select(request, pagename)
    verdict = permission(request, page, 'view', key_label='key')
    if 'mode' in request.params and request.params['mode'] == 'json':
        json_mode = True
    else:
        json_mode = False
    if verdict['status'] != 'OK' and json_mode:
        return render_to_response("json", verdict, request)
    elif verdict['status'] != 'OK' and not json_mode:
        if request.response.status == 410:
            response_settings = {'project': 'Michelanglo', 'user': request.user,
                                 'page': pagename,
                                 'custom_messages': json.dumps(custom_messages),
                                 'meta_title': 'Michelaɴɢʟo: sculpting protein views on webpages without coding.',
                                 'meta_description': 'Convert PyMOL files, upload PDB files or submit PDB codes and ' + \
                                                     'create a webpage to edit, share or implement standalone on your site',
                                 'meta_image': '/static/tim_barrel.png',
                                 'meta_url': 'https://michelanglo.sgc.ox.ac.uk/'
                                 }
            return render_to_response("../templates/410.mako", response_settings, request)
        if request.response.status in (401, 403): #unknown or forbidden
            response_settings = {'project': 'Michelanglo', 'user': request.user,
                                 'page': pagename,
                                 'meta_title': 'Michelaɴɢʟo: sculpting protein views on webpages without coding.',
                                 'meta_description': 'Convert PyMOL files, upload PDB files or submit PDB codes and ' + \
                                                     'create a webpage to edit, share or implement standalone on your site',
                                 'meta_image': '/static/tim_barrel.png',
                                 'meta_url': 'https://michelanglo.sgc.ox.ac.uk/'
                                 }
            return render_to_response("../templates/encrypted.mako", response_settings, request)
    else:
        ## yay! you are not a terrorist!
        settings = page.settings
        if page.encrypted:
            settings['encryption_key'] = request.params['key']   ### For the Mako!
        else:
            settings['encryption_key'] = None
        ### add new values
        if 'freelyeditable' not in settings:
            settings['freelyeditable'] = False
        settings['user'] = request.user
        user = request.user
        if user:
            if settings['freelyeditable']:
                settings['editable'] = True
                user.add_visited_page(pagename)
                settings['visitors'].append(user.name)
            elif user.role == 'admin':
                # this means admin does not leave a trace upon inspection. Fine for admin bots. Bad human admin.
                settings['editable'] = True
            elif pagename in user.get_owned_pages():
                settings['editable'] = True
            elif pagename in user.get_visited_pages():
                settings['editable'] = False
            else:
                user.add_visited_page(pagename)
                request.dbsession.add(user)
                settings['visitors'].append(user.name)
                page.save()
                settings['editable'] = False
        else:
            settings['editable'] = False
        ### extras?
        if 'remote' in request.params:
            settings['remote'] = True
        if 'bootstrap' in request.params:
            settings['bootstrap'] = request.params['bootstrap']
        if 'no_user' in request.params:
            settings['no_user'] = True
            settings['no_analytics'] = True
        else:
            settings['no_user'] = False
            settings['no_analytics'] = False  ## Google analytics always on...
        if 'no_buttons' in request.params:
            settings['no_buttons'] = True
        else:
            settings['no_buttons'] = False
        if 'columns_viewport' in request.params:
            settings['columns_viewport'] = int(request.params['columns_viewport'])
            settings['columns_text'] = 12 - settings['columns_viewport']
        elif not 'columns_viewport' in settings:
            settings['columns_viewport'] = 9
            settings['columns_text'] = 3
        else:
            pass  # use the default settings within the page.
        if not 'location_viewport' in settings:
            settings['location_viewport'] = 'left'
        settings['current_page'] = 'NOT A MENU OPTION....'
        # API
        if 'mode' in request.params and request.params['mode'] == 'json':
            settings['user'] = User.get_username(request)  # user isn't json serialisable
            # print('pageserve', 'request', type(settings['proteinJSON']))
            settings['proteinJSON'] = settings['proteinJSON']  # json.dumps() #because this is done badly.
            return render_to_response("json", settings, request)
        else:
            settings['meta_title'] = 'Michelaɴɢʟo user-created page: ' + settings['title']
            settings['meta_description'] = settings['description'][:150]
            settings['meta_image'] = f'https://michelanglo.sgc.ox.ac.uk/thumb/{page.identifier}'
            settings['meta_url'] = 'https://michelanglo.sgc.ox.ac.uk/data/' + page.identifier
            settings['custom_messages'] = json.dumps(custom_messages)
            return settings   ## renders via the "../templates/user_protein.mako"



@view_config(route_name='userthumb')
def thumbnail(request):
    pagename = request.matchdict['id']
    page = Page.select(request, pagename)
    verdict = permission(request, page, 'view', key_label='key')
    if verdict['status'] != 'OK':
        request.response.status = 200 # we would block facebook and twitter otherwise...
        response = FileResponse(os.path.join('michelanglo_app', 'static', 'tim_barrel.png'))
    elif not os.system(f'node michelanglo_app/thumbnail.js {pagename}'):
        response = FileResponse(page.thumb)
    else:
        log.error(f'Thumbnail generation failed for {pagename}')
        response = FileResponse(os.path.join('michelanglo_app', 'static', 'tim_barrel.png'))
    response.headers.update({
        'Access-Control-Allow-Origin': '*',
    })
    return response

@view_config(route_name='save_pdb', renderer='string')
def save_pdb(request):
    page = Page.select(request.params['uuid'])
    verdict = permission(request, page, key_label='key')
    if verdict['status'] == 'OK':
        pdb = page.load().settings['pdb']
        if isinstance(pdb, str):
            log.warning(f'{page} has a pre-beta PDB!??')
            return pdb
        else:
            return pdb[0][1] #pdb is
    else:
        return verdict

@view_config(route_name='save_zip', renderer="string")
def save_zip(request):
    raise NotImplementedError

