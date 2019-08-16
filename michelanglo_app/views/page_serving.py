import json

from pyramid.view import view_config
from pyramid.renderers import render_to_response
from ..models import Page, User
from pyramid.response import FileResponse
from .user_management import permission
from pyramid.httpexceptions import HTTPFound

import logging, json, os
log = logging.getLogger(__name__)

from . import custom_messages
from ._common_methods import is_malformed

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
        response_settings = {'project': 'Michelanglo', 'user': request.user,
                             'page': pagename,
                             'custom_messages': json.dumps(custom_messages),
                             'meta_title': 'Michelaɴɢʟo: sculpting protein views on webpages without coding.',
                             'meta_description': 'Convert PyMOL files, upload PDB files or submit PDB codes and ' + \
                                                 'create a webpage to edit, share or implement standalone on your site',
                             'meta_image': '/static/tim_barrel.png',
                             'meta_url': 'https://michelanglo.sgc.ox.ac.uk/'
                             }
        if request.response.status == 410:
            return render_to_response("../templates/410.mako", response_settings, request)
        elif request.response.status in (401, 403): #unknown or forbidden
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
            return render_to_response("../templates/404.mako", response_settings, request)
    else:
        ## yay! you are not a terrorist!
        settings = page.settings
        if page.encrypted:
            settings['encryption_key'] = request.params['key']   ### For the Mako!
            settings['key'] = request.params['key']  #to be fixed...
        else:
            settings['encryption_key'] = None
            settings['key'] = None
        # first time flag
        if 'is_unseen' not in settings:
            settings['is_unseen'] = False
            settings['firsttime'] = False
        elif settings['is_unseen']:
            settings['firsttime'] = True
            settings['is_unseen'] = False # switch it off.
            page.save(settings)
        else:
            settings['is_unseen'] = False
            settings['firsttime'] = False
        ### add new values
        if 'freelyeditable' not in settings:
            settings['freelyeditable'] = False
        settings['user'] = request.user
        user = request.user
        if user:
            if settings['freelyeditable']:
                settings['editable'] = True
                if pagename not in user.owned_pages:
                    user.visited.add(pagename)
                    settings['visitors'].append(user.name)
            elif user.role == 'admin':
                # this means admin does not leave a trace upon inspection. Fine for admin bots. Bad human admin.
                settings['editable'] = True
            elif pagename in user.owned_pages:
                settings['editable'] = True
            elif pagename in user.owned_pages:
                settings['editable'] = False
            else:
                user.visited.add(pagename)
                request.dbsession.add(user)  ## why?? Autocommit is on. Surely this is pointless. But best not risk it. Leaving it.
                settings['visitors'].append(user.name)
                page.save(settings)
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
            settings['structure_info'] = json.loads(settings['proteinJSON'])  ## regenerate each time for safety!
            return settings   ## renders via the "../templates/user_protein.mako"

@view_config(route_name='monitor', renderer="../templates/monitor.mako")
def monitor(request):
    pagename = request.matchdict['id']
    page = Page.select(request, pagename)
    response_settings = {'project': 'Michelanglo', 'user': request.user,
                         'page': pagename,
                         'custom_messages': json.dumps(custom_messages),
                         'meta_title': 'Michelaɴɢʟo: sculpting protein views on webpages without coding.',
                         'meta_description': 'Convert PyMOL files, upload PDB files or submit PDB codes and ' + \
                                             'create a webpage to edit, share or implement standalone on your site',
                         'meta_image': '/static/tim_barrel.png',
                         'meta_url': 'https://michelanglo.sgc.ox.ac.uk/'
                         }
    verdict = permission(request, page, 'view', key_label='key')
    if verdict['status'] != 'OK':
        request.response.status = 400
        return render_to_response("../templates/404.mako", response_settings, request)
    elif 'image' in request.params:
            file = os.path.join('michelanglo_app','user-data-monitor',f"{page.identifier}-{request.params['image']}.png")
            if page.protected and os.path.exists(file):
                return FileResponse(file)
            else:
                return FileResponse(os.path.join('michelanglo_app', 'static', 'broken.gif'))
    elif not page.protected:
        return {'status': 'unprotected', **response_settings}
    else:
        labelfile = os.path.join('michelanglo_app','user-data-monitor', page.identifier+'.json') ## this is not within hth pickle as nodejs makes it.
        if os.path.exists(labelfile):
            labels = json.load(open(labelfile))
            return {'status': 'monitoring', 'labels': labels, **response_settings}
        else:
            return {'status': 'generating', **response_settings}

@view_config(route_name='userthumb')
def thumbnail(request):
    pagename = request.matchdict['id']
    page = Page.select(request, pagename)
    verdict = permission(request, page, 'monitor', key_label='key')
    if verdict['status'] != 'OK':
        request.response.status = 200 # we would block facebook and twitter otherwise...
        response = FileResponse(os.path.join('michelanglo_app', 'static', 'tim_barrel.png'))
    elif not os.system(f'node michelanglo_app/thumbnail.js {pagename}'):
        response = FileResponse(page.thumb_path)
    else:
        log.error(f'Thumbnail generation failed for {pagename}')
        response = FileResponse(os.path.join('michelanglo_app', 'static', 'tim_barrel.png'))
    response.headers.update({
        'Access-Control-Allow-Origin': '*',
    })
    response.encode_content(encoding='identity') #gzip is pointless on png
    return response

@view_config(route_name='save_pdb', renderer='string')
def save_pdb(request):
    malformed = is_malformed(request, 'uuid', 'index')
    if malformed:
        return {'status': malformed}
    if not request.params['index'].isdigit():
        request.response.status = 400
        return {'status': 'index must be number'}
    page = Page.select(request, request.params['uuid'])
    index = int(request.params['index'])
    verdict = permission(request, page, key_label='key')
    if verdict['status'] == 'OK':
        settings = page.load().settings
        protein = json.loads(settings['proteinJSON'])
        if index > len(protein):
            request.response.status = 400
            return {'status': f'index exceeds {len(protein)}'}
        p = protein[index]
        pdb = settings['pdb']
        if p['type'] == 'rcsb': #rcsb PDB code
            return HTTPFound(location=f"https://files.rcsb.org/download/{p['value']}.cif")
        elif p['type'] == 'file': #external file
            return HTTPFound(location=p['value'])
        elif isinstance(pdb, str):
            log.warning(f'{page} has a pre-beta PDB!??')
            return pdb
        else:
            return pdb[0][1] #pdb is
    else:
        return verdict

@view_config(route_name='save_zip', renderer="string")
def save_zip(request):
    raise NotImplementedError

