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
import json, re

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
        page.key = request.params['encryption_key'].encode('uft-8')
        page.path = page.encrypted_path
    # load data
    settings = page.load()
    if not settings:
        request.response.status = 404
        log.warn(f'{get_username(request)} requested a missing page')
        return {'status': 'page not found'}
    ## cehck permissions
    if not user or not (page.identifier in user.get_owned_pages() or user.role == 'admin' or settings['freelyeditable']): ## only owners and admins can edit.
        request.response.status = 403
        log.warn(f'{get_username(request)} is not autharised to edit page')
        return {'status': 'not authorised'}
    else:
        #add author if user was an upgraded to editor by the original author. There are three lists: authors (can and have edited, editors can edit, visitors visit.
        if user.name not in settings['authors']:
            settings['authors'].append(user.name)
        # only admins and friends can edit html fully
        if user.role in ('admin', 'friend'):
            for key in ('loadfun', 'title', 'description'):
                if key in request.params:
                    settings[key] = request.params[key]
            if 'pdb' in request.params:
                try:
                    settings['pdb'] = json.loads(request.params['pdb'])
                except:
                    settings['pdb'] = request.params['pdb']
        else: # regular users have to be sanitised
            for key in ('title', 'description'):
                if key in request.params:
                    settings[key] = Page.sanitise_HTML(request.params[key])
        settings['confidential'] = is_js_true(request.params['confidential'])
        public_from_private= 'public' in settings and not settings['public'] and is_js_true(request.params['public']) #was private public but is now.
        public_from_nothing= 'public' not in settings and is_js_true(request.params['public']) #was not decalred but is now.
        private_from_public = 'public' in settings and settings['public'] and not is_js_true(request.params['public'])
        if public_from_private or public_from_nothing:
            public = get_public(request)
            public.add_visited_page(page.identifier)
            request.dbsession.add(public)
        elif not is_js_true(request.params['public']):
            public = get_public(request)
            if page.identifier in public.get_visited_pages():
                public.remove_visited_page(page.identifier)
                request.dbsession.add(public)
        else:
            pass
        settings['public'] = is_js_true(request.params['public'])
        if not settings['public']:
            settings['freelyeditable'] = is_js_true(request.params['freelyeditable'])
        else:
            settings['freelyeditable'] = False
            #new_editors
        if 'new_editors' in request.params and request.params['new_editors']:
            for new_editor in json.loads((request.params['new_editors'])):
                target = request.dbsession.query(User).filter_by(name=new_editor).one()
                if target:
                    target.add_owned_page(page.identifier)
                    request.dbsession.add(target)
                    settings['editors'].append(target.name)
                else:
                    print('This is impossible...', new_editor, ' does not exist.')
        #encrypt
        if not page.is_password_protected() and request.params['encryption'] == 'true': # to be encrypted
            page.delete()
            page.key = request.params['encryption_key'].encode('utf-8')
            page.path = page.encrypted_path
        elif page.is_password_protected() and request.params['encryption'] == 'false':  #to be dencrypted
            page.delete()
            page.key = None
            page.path = page.unencrypted_path
        else: # no change
            pass
        #alter ratio
        if 'columns_viewport' in request.params:
            settings['columns_viewport'] = int(request.params['columns_viewport'])
            settings['columns_text'] = int(request.params['columns_text'])
        if 'location_viewport' in request.params:
            settings['location_viewport'] = request.params['location_viewport']
        if 'proteinJSON' in request.params:
            settings['proteinJSON'] = request.params['proteinJSON']
        if 'image' in request.params:
            settings['image'] = request.params['image']
        #save
        page.save(settings)
        return {'success': 1}

@view_config(route_name='combine_user-page', renderer='json')
def combined(request):
    log.info(f'{get_username(request)} is requesting to merge page')
    if any([k not in request.params for k in ('target_page','donor_page','task','name')]):
        request.response.status = 403
        log.warn(f'{get_username(request)} malformed request')
        return {'status': 'malformed request: target_page, donor_page and task are required'}
    target_page = Page(request.params['target_page'])
    donor_page = Page(request.params['donor_page'])
    task = Page(request.params['task'])
    name = request.params['name']
    user = request.user
    if not user:
        request.response.status = 403
        log.warn(f'{get_username(request)} is not autharised to edit page')
        return {'status': 'unregistered'}
    ownership = user.get_owned_pages()
    ## check permissions
    if target_page.identifier not in ownership and not user.role == 'admin':  ## only owners can edit
        #to do sort corner case of settings['freelyeditable']
        request.response.status = 403
        log.warn(f'{get_username(request)} tried but failed to delete page')
        return {'status': 'Not owner'}
    #do stuff
    for page, role in ((target_page,'target'), (donor_page,'donor')):
        # check if encrypted
        if page.is_password_protected():
            page.key = request.params[f'{role}_encryption_key'].encode('uft-8')
            page.path = page.encrypted_path
        page.load()
        if not page.settings:
            request.response.status = 404
            log.warn(f'{get_username(request)} requested a missing {role} page')
            return {'status': f'{role} page not found'}
    #common
    if re.match('^\w+$', name) == None:
        request.response.status = 400
        log.warn(f'{get_username(request)} wanted to add a function name that was not alphanumeric.')
        return {'status': f'function name is not alphanumeric.'}
    #fun
    target_page.settings['loadfun'] += '\n' + donor_page.settings['loadfun'].replace('function loadfun', f'function loadfun{name}') + '\n'
    # copies only the method
    if task == 'method':
        target_page.settings['description'] += f'\nView from from {donor_page.identifier} added as {name}.' + \
                                               f'E.g. <span class="prolink" data-target="#viewport" data-toggle="protein" data-view="{name}">Show to new view</span>'
    else: #both
        #proteinJSON
        addenda = json.loads(donor_page.settings['proteinJSON'])
        alteranda = json.loads(target_page.settings['proteinJSON'])
        addenda[0]['loadFx'] = f'loadfun{name}'
        addenda[0]['value'] = f'pdb{name}'
        target_page.settings['proteinJSON'] = json.dumps(alteranda + addenda)
        #pdb
        if addenda[0]['type'] == 'data':
            if 'pdb' in target_page.settings and target_page.settings['pdb']:
                if isinstance(target_page.settings['pdb'],str): #backwards compatibiity hack
                    target_page.settings['pdb'] = [('pdb', target_page.settings['pdb'])]
            else:
                target_page.settings['pdb'] = []
            target_page.settings['pdb'].append((f'pdb{name}', donor_page.settings['pdb']))
        #loadfun
        target_page.settings['description'] += f'\nPage data from {donor_page.identifier} added as {name}.'+\
                                               f'E.g. <span class="prolink" data-target="#viewport" data-toggle="protein" data-load="{name}" data-view="reset">Show new protein</span>'
    target_page.save()
    return {'status': 'success'}

@view_config(route_name='delete_user-page', renderer='json')
def delete(request):
    # get ready
    log.info(f'{get_username(request)} is requesting to delete page')
    page = Page(request.params['page'])
    user = request.user
    if not user:
        request.response.status = 403
        log.warn(f'{get_username(request)} is not autharised to edit page')
        return {'status': 'not authorised'}
    ownership = user.get_owned_pages()
    ## cehck permissions
    if page.identifier not in ownership and user.role != 'admin': ## only owners can delete
        request.response.status = 403
        log.warn(f'{get_username(request)} tried but failed to delete page')
        return {'status': 'Not owner'}
    else:
        page.delete()
        return {'status': 'success'}

@view_config(route_name='mutate', renderer='json')
def mutate(request):
    #''page', 'key'?, 'chain', 'mutations'
    log.info(f'{get_username(request)} is making mutants page')
    if not all([k in request.params for k in ('page','model','chain','mutations')]):
        request.response.status = 400
        return {'status': f'Missing field ({[k for k in ("page model chain mutations".split()) if k not in request.params]})'}
    page = Page(request.params['page'])
    user = request.user
    if not user:
        request.response.status = 403
        log.warn(f'{get_username(request)} is not autharised to edit page')
        return {'status': 'not authorised'}
    ownership = user.get_owned_pages()
    ## cehck permissions
    if page.identifier not in ownership and user.role != 'admin':  ## only owners can delete/mutate
        request.response.status = 403
        log.warn(f'{get_username(request)} tried but failed to mutate page')
        return {'status': 'Not owner'}
    else:
        if 'key' in request.params:
            page.key = request.params['key'].encode('utf-8')
        settings = page.load()
        #protein = settings['pdb'][]
        model = int(request.params['model'])
        chain = request.params['chain']
        mutations = request.params['mutations'].split()
        all_protein_data = json.loads(settings['proteinJSON'])
        protein_data = json.loads(settings['proteinJSON'])[model]
        filename = os.path.join('michelanglo_app', 'temp', f'{page.identifier}.mut.pdb')
        if protein_data['type'] == 'data':
            if protein_data['isVariable'] is True or protein_data['isVariable'] == 'true':
                seq = [p[1] for p in settings['pdb'] if p[0] == protein_data['value']][0]
            else:
                seq = protein_data['value']
            with open(filename, 'w') as fh:
                fh.write(seq)
            PyMolTranspiler.mutate_file(filename, filename, mutations, chain)
        elif protein_data['type'] == 'rcsb':
            PyMolTranspiler.mutate_code(protein_data['value'], filename, mutations, chain)
        else:
            request.response.status = 406
            return {'status','cannot create mutations from URL for security reasons'}
        with open(filename, 'r') as fh:
            seq = fh.read()
        new_variable = f"mutant_{len(json.loads(settings['proteinJSON']))}"
        all_protein_data.append({"type": "data",
                                 "value": new_variable,
                                 "isVariable": "true"})
        settings['proteinJSON'] = json.dumps(all_protein_data)
        settings['pdb'].append((new_variable, seq))
        new_model = len(all_protein_data) - 1
        settings['description'] += f'Protein variants generated for model #{model} as model #{new_model}.\n\n'
        common = '<span class="prolink" data-toggle="protein" data-hetero="true"'
        for mutant in mutations:
            n = re.search("(\d+)", mutant).group(1)
            settings['description'] += f'* __{mutant}__ '+\
                                       f'({common}  data-focus="residue" data-title="{mutant} wild type" data-load="{model} " data-selection="{n}:{chain}">wild type</span>'+\
                                       f'/{common}  data-focus="clash" data-title="{mutant} mutant" data-load="{new_model} " data-selection="{n}:{chain}">mutant</span>)\n'
        page.save(settings)
        return {'status': 'success'}


@view_config(route_name='rename_user-page', renderer='json')
def rename(request):
    if not request.user or request.user.role == 'admin':
        request.response.status = 403
        log.warn(f'{get_username(request)} is not autharised to rename page')
        return {'status': 'not authorised'}
    else:
        old = request.params['old_page']
        new = request.params['new_page']
        if 'key' in request.params:
            page = Page(old,key=request.params['key'])
        else:
            page = Page(old)
        page.load()
        page.identifier = new
        page.save()
        return {'status': 'success'}
