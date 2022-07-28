import json, pickle
import markdown, re, datetime

from pyramid.view import view_config
from pyramid.renderers import render_to_response
from ..models import Page, User, Doi
from pyramid.response import FileResponse
from .user_management import permission
from pyramid.httpexceptions import HTTPFound

import logging, json, os
log = logging.getLogger(__name__)

from typing import Dict, List, Tuple, Union, Any

from . import custom_messages
from .common_methods import is_malformed, is_js_true
from .buffer import system_storage

@view_config(route_name='userdata', renderer="../templates/user_protein.mako")
def userdata_view(request):
    pagename = request.matchdict['id']
    return get_userdata(request, pagename)

@view_config(route_name='redirect', renderer="../templates/user_protein.mako")
def redirect_view(request):
    """
    Changed to be a hard redirect.
    :param request:
    :return:
    """
    pagename = Doi.reroute(request, request.matchdict['id'])
    if pagename is not None:
        log.info(f'{User.get_username(request)} is looking at a r-page "{request.matchdict["id"]}" ({pagename})')
        return get_userdata(request, pagename)
    else:
        log.info(f'{User.get_username(request)} is looking at a r-page "{request.matchdict["id"]}" that does not exist.')
        request.response.status_int = 400
        response_settings = {'project': 'Michelanglo', 'user': request.user,
                             'page': pagename,
                             'custom_messages': json.dumps(custom_messages),
                             'meta_title': 'Michelaɴɢʟo: sculpting protein views on webpages without coding.',
                             'meta_description': 'Convert PyMOL files, upload PDB files or submit PDB codes and ' + \
                                                 'create a webpage to edit, share or implement standalone on your site',
                             'meta_image': '/static/tim_barrel.png',
                             'meta_url': 'https://michelanglo.sgc.ox.ac.uk/'
                             }
        return render_to_response("../templates/404.mako", response_settings, request)

def get_userdata(request, pagename):
    log.info(f'{User.get_username(request)} is looking at a page {pagename}')
    page = Page.select(request.dbsession, pagename)
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
                             'title': 'Error',
                             'custom_messages': json.dumps(custom_messages),
                             'meta_title': 'Michelaɴɢʟo: sculpting protein views on webpages without coding.',
                             'meta_description': 'Convert PyMOL files, upload PDB files or submit PDB codes and ' + \
                                                 'create a webpage to edit, share or implement standalone on your site',
                             'meta_image': '/static/tim_barrel.png',
                             'meta_url': 'https://michelanglo.sgc.ox.ac.uk/'
                             }
        if request.response.status_int == 410:
            return render_to_response("../templates/410.mako", response_settings, request)
        elif request.response.status_int in (401, 403): #unknown or forbidden
            return render_to_response("../templates/encrypted.mako", response_settings, request)
        else:
            return render_to_response("../templates/404.mako", response_settings, request)
    else:
        ## yay! you are not a terrorist!
        settings = page.settings
        if settings['page'] != page.identifier:
            log.error(f"This should not have happened: loading {page.identifier} gave {settings['page']}")
        settings['public'] = page.privacy  # Legacy fix.
        if page.encrypted:
            settings['encryption_key'] = request.params['key']   ### For the Mako!
            settings['key'] = request.params['key']  #to be fixed...
            settings['encrypted'] = True
        else:
            settings['encryption_key'] = None
            settings['key'] = None
            settings['encrypted'] = False
        # first time flag
        if 'is_unseen' not in settings:
            settings['is_unseen'] = False
            settings['firsttime'] = False
        elif settings['is_unseen']:
            settings['firsttime'] = True
            settings['is_unseen'] = False # switch it off.
            settings['votes'] = dict(request.registry.settings['votes'])
            page.save(settings)
        else:
            settings['is_unseen'] = False
            settings['firsttime'] = False
        ### add new values
        if 'freelyeditable' not in settings:
            settings['freelyeditable'] = False
        if 'revisions' not in settings:
            settings['revisions'] = []
        user = request.user
        settings['user'] = user
        # touch it. Although loading touches it. This is like double tapping.
        page.timestamp = datetime.datetime.utcnow()
        # log visit
        if user:
            if pagename not in user.owned.pages:
                user.visited.add(pagename)
                settings['visitors'].append(user.name)
                page.save(settings)
            if settings['freelyeditable']:
                settings['editable'] = True
            elif user.role == 'admin':
                # this means admin does not leave a trace upon inspection. Fine for admin bots. Bad human admin.
                settings['editable'] = True
            elif pagename in user.owned.pages:
                settings['editable'] = True
            elif pagename in user.owned.pages:
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
        # default values in layout.mako args.
        if 'offline' in request.params:
            settings['offline'] = True
            settings['remote'] = True
            settings['no_user'] = True
            settings['no_analytics'] = True
            settings['no_buttons'] = True
        elif 'remote' in request.params:
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
            for r in settings['revisions']:
                r['time'] = str(r['time'])  #patch. please delete me soon.
            return render_to_response("json", settings, request)
        else:
            settings['meta_title'] = 'Michelaɴɢʟo user-created page: ' + settings['title']
            settings['meta_description'] = settings['description'][:150]
            settings['meta_image'] = f'https://michelanglo.sgc.ox.ac.uk/thumb/{page.identifier}'
            settings['meta_url'] = 'https://michelanglo.sgc.ox.ac.uk/data/' + page.identifier
            settings['custom_messages'] = json.dumps(custom_messages)
            settings['structure_info'] = json.loads(settings['proteinJSON'])  ## regenerate each time for safety!
            # backwards compatibility
            if not settings['descr_mdowned']:
                #settings['descr_mdowned'] = page.sanitise_HTML(markdown.markdown(settings['description']))
                settings['descr_mdowned'] = markdown.markdown(settings['description'])
            rex = re.search('^\<h2\>(.*?)\<\/h2\>', settings['descr_mdowned'])
            if rex:
                settings['descr_header'] = '<div class="card-header"><h3 class="card-title">' + rex.group(1) + '</h3></div>'
                settings['descr_mdowned'] = re.sub('^\<h2\>(.*?)\<\/h2\>', '', settings['descr_mdowned'])
            else:
                settings['descr_header'] = ''
            # asynchronous PDB loading. Bad if first page has an overlay.
            settings['async_pdbnames'] = []
            if 'async_pdb' in settings and settings['async_pdb'] and len(settings['pdb']) > 1:
                for name, block in settings['pdb'][1:]:
                    print(settings['page']+name)
                    system_storage[settings['page']+name] = block
                    settings['async_pdbnames'].append(name)
                settings['pdb'] = [settings['pdb'][0]]
            else:
                settings['async_pdb'] = False
            # return
            return settings   ## renders via the "../templates/user_protein.mako"



@view_config(route_name='async_pdb', renderer="string")
def async_pdb(request):
    """
    This is not redundant with save. This is meant to be a quick async loading.
    """
    malformed = is_malformed(request, 'identifier', 'name')
    if malformed:
        request.response.status_int = 400
        return ''
    identifier = request.params['identifier']
    name = request.params['name']
    if identifier+name in system_storage: # it did not expired.
        block = system_storage[identifier + name]
        del system_storage[identifier + name]
        return block
    else:
        get_userdata(request, identifier)
        if identifier + name in system_storage: #this should not happend!
            log.warning(f'{User.get_username(request)} is looking at a page whose cache was deleted (Impossible)')
            block = system_storage[identifier + name]
            del system_storage[identifier + name]
            return block
        else: # nope. It is wrong.
            log.info(f'{User.get_username(request)} requested an incorrect pdb {identifier} + {name}')
            request.response.status_int = 404
            return ''


@view_config(route_name='monitor', renderer="../templates/monitor.mako")
def monitor(request):
    pagename = request.matchdict['id']
    page = Page.select(request.dbsession, pagename)
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
    monitor_folder = os.path.join(request.registry.settings['michelanglo.user_data_folder'], 'monitor')
    if verdict['status'] != 'OK':
        request.response.status_int = 400
        return render_to_response("../templates/404.mako", response_settings, request)
    elif 'image' in request.params:
            if 'current' in request.params and is_js_true(request.params['current']):
                file = os.path.join(monitor_folder, f"tmp_{page.identifier}-{request.params['image']}.png")
            else:
                file = os.path.join(monitor_folder,f"{page.identifier}-{request.params['image']}.png")
            if page.protected and os.path.exists(file):
                return FileResponse(file)
            else:
                print(file, os.path.exists(file))
                return FileResponse(os.path.join('michelanglo_app', 'static', 'broken.gif'))
    elif not page.protected:
        return {'status': 'unprotected', **response_settings}
    else:
        labelfile = os.path.join(monitor_folder, page.identifier+'.json')
        ## this is not within hth pickle as nodejs makes it.
        verdictfile = os.path.join(monitor_folder, 'verdict_'+page.identifier+'.p')
        if os.path.exists(labelfile):
            labels = json.load(open(labelfile))
            if os.path.exists(verdictfile):
                validity = pickle.load(open(verdictfile, 'rb'))
                return {'status': 'monitoring',
                        'labels': labels,
                        'validity': validity,
                        **response_settings}
            else:
                return {'status': 'monitoring',
                        'labels': labels,
                        'validity': [None for l in labels],
                        **response_settings}
        else:
            return {'status': 'generating',
                    **response_settings}

@view_config(route_name='userthumb')
def thumbnail(request):
    pagename = request.matchdict['id']
    page = Page.select(request.dbsession, pagename)
    verdict = permission(request, page, 'view', key_label='key')
    # under most conditions the following should be `michelanglo_app`
    michelanglo_app_folder = os.path.split(os.path.split(__file__)[0])[0]
    cmd = ' '.join([f'USER_DATA={request.registry.settings["michelanglo.user_data_folder"]}',
                    'PORT=8088',
                    f'PUPPETEER_CHROME={request.registry.settings["puppeteer.executablepath"]}',
                    f'node {michelanglo_app_folder}/thumbnail.js {pagename}'])
    if verdict['status'] != 'OK' or not page.existant:
        request.response.status = 200 # we would block facebook and twitter otherwise as they redirect.
        response = FileResponse(os.path.join('michelanglo_app', 'static', 'tim_barrel.png'))
    elif os.path.exists(page.thumb_path):
        response = FileResponse(page.thumb_path)
    elif not os.system(cmd) and os.path.exists(page.thumb_path):  # system exit 0
        response = FileResponse(page.thumb_path)
    else:
        log.error(f'Thumbnail generation failed for {pagename}')
        response = FileResponse(os.path.join('michelanglo_app', 'static', 'tim_barrel.png'))
    response.headers.update({
        'Access-Control-Allow-Origin': '*',
    })
    response.encode_content(encoding='identity') #gzip is pointless on png
    return response

@view_config(route_name='save_pdb', renderer='json')
def save_pdb(request):
    """Should have been called download PDB file"""
    malformed = is_malformed(request, 'uuid', 'index')
    if malformed:
        return {'status': malformed}
    if isinstance(request.params['index'], str) and \
            request.params['index'] != '-1' and \
            not request.params['index'].isdigit():
        request.response.status = 400
        return {'status': 'index must be number',
                'error': f"{request.params['index']} ({type(request.params['index'])}) is not a digit"
                }
    page:Page = Page.select(request.dbsession, request.params['uuid'])
    index = int(request.params['index'])
    verdict = permission(request, page, key_label='key', mode='view')
    # invalid verdict
    if verdict['status'] != 'OK':
        return verdict
    # ## Return correct
    settings: Dict[str, Any] = page.load().settings
    # [{'type': 'data', 'value': 'xxx', 'isVariable': 'true', 'chain_definitions': [], 'history':{}]
    protein: List[Dict[str, Any]] = json.loads(settings['proteinJSON'])
    # Error case: no index
    if index == -1:
        return {'status': 'number of structures', 'number': len(protein), 'definitions': protein}
    # Error case: impossible index
    if index > len(protein):
        request.response.status = 400
        return {'status': f'index exceeds {len(protein)}'}
    # Case: valid index
    p = protein[index]
    # type pdb code
    if p['type'] == 'rcsb':  #rcsb PDB code
        return HTTPFound(location=f"https://files.rcsb.org/download/{p['value']}.cif")
    # type url
    if p['type'] == 'url':  #external file
        return HTTPFound(location=p['value'])
    # type old school
    if isinstance(settings['pdb'], str):
        log.warning(f'{page} has a pre-beta PDB!??')
        request.override_renderer = 'string'
        return settings['pdb']
    # normal case
    pdbs: Dict[str, str] = dict(settings['pdb'])  # name, pdb_block
    name = p['value']
    if name not in pdbs:
        request.response.status = 400
        return {'status': 'PDB not found', 'name': name}
    request.override_renderer = 'string'
    return pdbs[name]
