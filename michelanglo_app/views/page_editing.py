from pyramid.view import view_config
from pyramid.renderers import render_to_response
from ..models.pages import Page
from ..models.user import User
from ..models.trashcan import get_trashcan
from .user_management import permission
from ..transplier import PyMolTranspiler
import os
import json, re

from ._common_methods import is_js_true,  is_malformed

import logging
log = logging.getLogger(__name__)

def sanitise_name(suggested_name, default, structure_info):
    # structure_info is proteinJSON as dict.
    suggested_name = re.sub('\W', '', suggested_name)
    suggested_name = re.sub('$\d', '', suggested_name)
    if len(suggested_name) == 0:  ## bad name
        return default
    elif suggested_name in [p['value'] for p in structure_info if 'value' in p]: #name taken
        return default
    else:
        return suggested_name

@view_config(route_name='edit_user-page', renderer='json')
def edit(request):
    log.info(f'Page edit requested by {User.get_username(request)}')
    malformed = is_malformed(request, 'page', 'encryption', 'public', 'confidential','freelyeditable')
    if malformed:
        return {'status': malformed}
    # get ready
    page = Page.select(request, request.params['page'])
    verdict = permission(request, page, 'edit', key_label='encryption_key')
    if verdict['status'] != 'OK':
        return verdict
    else:
        # you have been approved.
        user = request.user
        # add author if user was an upgraded to editor by the original author. There are three lists: authors (can and have edited, editors can edit, visitors visit.
        if user.name not in page.settings['authors']:
            page.settings['authors'].append(user.name)
        if page.identifier not in user.owned.pages:
            user.owned.add(page.identifier)
        if 'anonymous' in page.settings['authors']:
            # got it out of trashcan.
            page.settings['authors'].remove('anonymous')
            get_trashcan(request).owned.remove(page.identifier)
        # make a backup
        if 'revisions' not in page.settings:
            page.settings['revisions'] = []
        page.settings['revisions'].append({'user': user.name, 'time': str(page.timestamp), 'text': page.settings['description']})
        # only admins and friends can edit html fully
        if user.role in ('admin', 'friend'):
            for key in ('loadfun', 'title', 'description'):
                if key in request.params:
                    page.settings[key] = request.params[key]
            if 'pdb' in request.params:
                try:
                    page.settings['pdb'] = json.loads(request.params['pdb'])
                except:
                    page.settings['pdb'] = request.params['pdb']
        else:  # regular users have to be sanitised
            for key in ('title', 'description'):
                if key in request.params:
                    page.settings[key] = Page.sanitise_HTML(request.params[key])
        page.settings['confidential'] = is_js_true(request.params['confidential'])
        if page.privacy == '' or page.privacy is None:
            page.privacy = 'private'
            log.warn('A page had no privacy setting. How?')
        if user.role == 'admin' and request.params['public'] not in (None, False, True, 'false','true'):
            ## only admin can set to anything that is not private | public
            page.privacy = request.params['public'].lower()
        elif is_js_true(request.params['public']):
            if page.privacy not in ('public', 'private'):
                pass # keep page privacy. admin set it to published or sgc.
            else:
                page.privacy = 'public'
        else:
            page.privacy = 'private'
        page.settings['public'] = page.is_public()
        if not page.is_public():
            page.settings['freelyeditable'] = is_js_true(request.params['freelyeditable'])
        else:
            page.settings['freelyeditable'] = False
            # new_editors
        if 'new_editors' in request.params and request.params['new_editors']:
            for new_editor in json.loads((request.params['new_editors'])):
                target = request.dbsession.query(User).filter_by(name=new_editor).first()
                if target:
                    target.owned.add(page.identifier)
                    request.dbsession.add(target)
                    page.settings['editors'].append(target.name)  ##useless!
                else:
                    log.warning(f'This is impossible...{new_editor} does not exist.')
        # encrypt
        if not page.encrypted and is_js_true(request.params['encryption']):  # to be encrypted
            page.delete()
            page.key = request.params['encryption_key'].encode('utf-8')
            page.encrypted = True
        elif page.encrypted and not is_js_true(request.params['encryption']):  # to be dencrypted
            page.delete()
            page.key = None
            page.encrypted = False
        else:  # no change
            pass
        if 'model' in request.params:
            page.settings['model'] = is_js_true('model')
        # alter ratio
        if 'columns_viewport' in request.params:
            page.settings['columns_viewport'] = int(request.params['columns_viewport'])
            page.settings['columns_text'] = int(request.params['columns_text'])
        if 'location_viewport' in request.params:
            page.settings['location_viewport'] = request.params['location_viewport']
        if 'proteinJSON' in request.params:
            page.settings['proteinJSON'] = request.params['proteinJSON']
        if 'image' in request.params:
            if is_js_true(request.params['image']):
                page.settings['image'] = request.params['image']
            else:
                page.settings['image'] = False
        # save
        page.edited = True
        page.title = page.settings['title']
        page.save().commit(request)



@view_config(route_name='combine_user-page', renderer='json')
def combined(request):
    malformed = is_malformed(request, 'target_page','donor_page','task','name')
    if malformed:
        return {'status': malformed}
    target_page = Page.select(request, request.params['target_page'])
    donor_page = Page.select(request, request.params['donor_page'])
    log.info(f'{User.get_username(request)} is requesting to merge page {donor_page} to {target_page}')
    task = Page(request.params['task'])
    target_verdict = permission(request, target_page, 'edit', key_label='target_encryption_key')
    if target_verdict['status'] != 'OK':
        return target_verdict
    donor_verdict = permission(request, donor_page, 'view', key_label='donor_encryption_key')
    if target_verdict['status'] != 'OK':
        return donor_verdict
    ### user is legal! also rememeber that load happens in verdict
    #common
    addenda = json.loads(donor_page.settings['proteinJSON'])
    alteranda = json.loads(target_page.settings['proteinJSON'])
    if "value" in addenda[0]:
        name = sanitise_name(request.params['name'], addenda[0]["value"], alteranda)
    else: ##this will crash if the merger name is already taken.
        name = f'merger_{len(alteranda)}'
    user = request.user
    #fun
    if task == 'method':
        fun_name = name
    else:
        fun_name = f'{name}Fx'
    ## deal with fun.
    end_sequence = '\n//////FUNCTION-END\n'
    if 'loadfun' in donor_page.settings and donor_page.settings['loadfun']:  # it has a loadFx for sure.
        donated = donor_page.settings['loadfun'].split(end_sequence)[0]
        donated = donated.replace(f'function {addenda[0]["loadFx"]}', f'window["{fun_name}"] = function ')
        donated = donated.replace(f'window["{addenda[0]["loadFx"]}"] = function ', f'window["{fun_name}"] = function ')
        target_page.settings['loadfun'] += end_sequence + donated + '\n'
    elif 'data_other' in donor_page.settings and donor_page.settings['data_other']:  # it has custom data in the NGL
        ### god, this is aweful!
        donated = f'''window["{fun_name}"] = function () {{let dummy = $(`<span {donor_page.settings['data_other']}></span>`); dummy.protein(); dummy.click(); }};'''
        target_page.settings['loadfun'] += end_sequence + donated + '\n'
        addenda[0]['loadFx'] = fun_name
    else:
        pass
    # copies only the method
    if task == 'method':
        target_page.settings['description'] += f'\nView from <a href="/data/{donor_page.identifier}">{donor_page.title}</a> added as {fun_name}.' + \
                                               f'E.g. <span class="prolink" data-target="#viewport" data-toggle="protein" data-view="{fun_name}">Show to new view</span>'
    else: #both
        #proteinJSON
        if addenda[0]['type'] == 'data':
            addenda[0]['loadFx'] = fun_name
            addenda[0]['value'] = name
        elif addenda[0]['type'] == 'rcsb':
            name = addenda[0]['value']
        else: ## URL CASE!
            pass
        target_page.settings['proteinJSON'] = json.dumps(alteranda + [addenda[0]])
        #pdb backwards compatibility fix.
        if 'pdb' in target_page.settings:
            if target_page.settings['pdb'] and isinstance(target_page.settings['pdb'],str): #backwards compatibiity hack
                target_page.settings['pdb'] = [('pdb', target_page.settings['pdb'])]
        else:
            target_page.settings['pdb'] = []
        ## add pdb
        if addenda[0]['type'] == 'data':
            target_page.settings['pdb'].append((name, donor_page.settings['pdb'][0][1]))
        #description
        target_page.settings['description'] += f'\n\nPage structure from <a href="/data/{donor_page.identifier}">{donor_page.title}</a> added as {name} and view as {fun_name}.'+\
                                               f'E.g. <span class="prolink" data-target="#viewport" data-toggle="protein" data-load="{name}" data-view="reset">Show new protein</span>'

    target_page.edited = True
    target_page.save().commit(request)
    return {'status': 'success'}

@view_config(route_name='delete_user-page', renderer='json')
def delete(request):
    # get ready
    malformed = is_malformed(request, 'page')
    if malformed:
        return {'status': malformed}
    page = Page.select(request, request.params['page'])
    log.info(f'{User.get_username(request)} is requesting to delete page {page}')
    verdict = permission(request, page, 'del', key_label='encryption_key')
    if verdict['status'] != 'OK':
        return verdict
    elif page.protected:
        return {'status': 'cannot delete protected page.'}
    else:
        page.delete().commit(request)
        if not page.exists:
            return {'status': 'success'}
        else:
            return {'status': 'file missing'}

@view_config(route_name='mutate', renderer='json')
def mutate(request):
    #''page', 'key'?, 'chain', 'mutations'
    malformed = is_malformed(request, 'page','model','chain','mutations', 'name')
    if malformed:
        return {'status': malformed}
    page = Page.select(request, request.params['page'])
    log.info(f'{User.get_username(request)} is making mutants page {page}')
    user = request.user
    verdict = permission(request, page, 'del', key_label='encryption_key')
    if verdict['status'] != 'OK':
        return verdict
    else:
        settings = page.settings
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
            ## this is a super corner case. I am not sure at all how to proceed. Clickbait?
            return {'status','cannot create mutations from URL for security reasons'}
        with open(filename, 'r') as fh:
            seq = fh.read()
        new_variable = sanitise_name(request.params['name'], f"mutant_{len(all_protein_data)}", all_protein_data)
        all_protein_data.append({"type": "data",
                                 "value": new_variable,
                                 "isVariable": "true"})
        settings['proteinJSON'] = json.dumps(all_protein_data)
        settings['pdb'].append((new_variable, seq))
        new_model = len(all_protein_data) - 1
        settings['description'] += f'\n\nProtein variants generated for model #{model} ({all_protein_data[model]["value"] if "value" in all_protein_data[model] else "no name given"}) as model #{new_model} ({new_variable}).\n\n'
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
    """
    admin only method.
    old_page: uuid, new_page: string
    """
    #verdict = permission(...? Nah. Admin only!
    if not request.user or request.user.role != 'admin':
        request.response.status = 403
        log.warn(f'{User.get_username(request)} is not autharised to rename page')
        return {'status': 'not authorised'}
    else:
        malformed = is_malformed(request, 'old_page', 'new_page')
        if malformed:
            return {'status': malformed}
        old_name = request.params['old_page']
        new_name = re.sub('\W','', request.params['new_page'])
        if 'key' in request.params:
            key = request.params['encryption_key']
        else:
            key = None
        old_page = Page(old_name, key=key)
        settings = old_page.load().settings
        new_page = Page(new_name, key=key)
        new_page.save(settings).commit(request)
        return {'status': 'success', 'page': new_name}
