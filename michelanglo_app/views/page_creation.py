from pyramid.view import view_config
from pyramid.renderers import render_to_response
import traceback
from ..models import Page, User
from ..models.trashcan import get_trashcan
from protein import Structure
from ..transplier import PyMolTranspiler
import uuid
import shutil
import os
import io
import re
import json
import requests

PyMolTranspiler.tmp = os.path.join('michelanglo_app', 'temp')

from ._common_methods import is_js_true, is_malformed, PDBMeta, get_uuid
import logging

log = logging.getLogger(__name__)


def demo_file(request):
    """
    Needed for convert_pse. Paranoid way to prevent user sending a spurious demo file name (e.g. ~/.ssh/).
    """
    demos = os.listdir(os.path.join('michelanglo_app', 'demo'))
    if request.params['demo_filename'] in demos:
        return os.path.join('michelanglo_app', 'demo', request.params['demo_filename'])
    else:
        raise Exception('Non existant demo file requested. Possible attack!')


def save_file(request, extension, field='file'):
    filename = os.path.join('michelanglo_app', 'temp', '{0}.{1}'.format(get_uuid(request), extension))
    with open(filename, 'wb') as output_file:
        if isinstance(request.params[field], str):  ###API user made a mess.
            log.warning(f'user uploaded a str not a file!')
            output_file.write(request.params[field].encode('utf-8'))
        else:
            request.params[field].file.seek(0)
            shutil.copyfileobj(request.params[field].file, output_file)
    return filename


########################################################################################
#### Page <> User DB

def stringify_protein_description(settings):
    ### kicks in at the anonymous/user submission step.
    descr = ''
    if 'descriptors' in settings:
        # {'peptide': [f'{first_resi}-{last_resi}:{chain}', ..], 'hetero': [f'[{resn}]{resi}:{chain}', ..]}
        template = '<span class="prolink" data-toggle="protein" data-target="viewport" data-focus="{focus}" data-selection="{selection}">{label}</span>'
        descr += '\n\n### peptide and nucleic acid chains\n\n'
        if 'peptide' in settings['descriptors'] and settings['descriptors']['peptide']:
            for p, n in settings['descriptors']['peptide']:
                if n:
                    descr += '* ' + template.format(focus='domain', selection=p, label=f'{n} ({p})') + '\n'
                else:
                    descr += '* ' + template.format(focus='domain', selection=p, label=p) + '\n'
        if 'hetero' in settings['descriptors']:
            waterless = [(p, n) for p, n in settings['descriptors']['hetero'] if
                         p.find('HOH') == -1 and p.find('WAT') == -1]
            if waterless:  # {('ORO and :A', None), ('SO4 and :A', None), etc.
                descr += '\n\n### ligands\n\n'
                for p, n in waterless:
                    if n:
                        descr += '* ' + template.format(focus='residue', selection=p, label=f'{n} ({p})') + '\n'
                    else:
                        descr += '* ' + template.format(focus='residue', selection=p, label=p) + '\n'
        if 'text' in settings['descriptors'] and settings['descriptors']['text']:
            descr += settings['descriptors']['text']
    return descr


def anonymous_submission(request, settings, pagename):
    settings['authors'] = ['anonymous']
    settings['freelyeditable'] = True
    settings['description'] = '## Description\n\n' + \
                              'Only <a href="#" class="text-secondary" data-toggle="modal" data-target="#login">logged-in users</a>' + \
                              ' can edit data pages.\n\nUnedited pages are deleted after a month, while other pages are deleted if unopened within a year.\n\n' + \
                              stringify_protein_description(settings)
    trashcan = get_trashcan(request)
    trashcan.owned.add(pagename)
    request.dbsession.add(trashcan)


def user_submission(request, settings, pagename):
    user = request.user
    user.owned.add(pagename)
    settings[
        "description"] = '## Description\n\nEditable text. press pen to edit (permissions permitting).\n\nUnedited pages are deleted after a month, while other pages are deleted if unopened within a year.\n\n' + stringify_protein_description(
        settings)
    settings["authors"] = [user.name]
    request.dbsession.add(user)
    settings['editors'] = [user.name]


def commit_submission(request, settings, pagename):
    if request.user:
        user_submission(request, settings, pagename)
    else:
        anonymous_submission(request, settings, pagename)
    p = Page(pagename)
    p.edited = False
    settings['is_unseen'] = True
    p.save(settings).commit(request)

########################################################################################
### VIEWS
@view_config(route_name='convert_pse', renderer="json")
def convert_pse(request):
    user = request.user
    log.info('Conversion of PyMol requested.')
    request.session['status'] = make_msg('Checking data', 'The data has been received and is being checked')
    try:
        malformed = is_malformed(request, 'uniform_non_carbon', 'stick_format')
        if malformed:
            return {'status': malformed}
        if 'demo_filename' not in request.params and 'file' not in request.params:
            request.response.status = 422
            log.warn(f'{User.get_username(request)} malformed request due to missing demo_filename or file')
            return f'Missing field (either demo_filename or file are compulsory)'
        ## set settings
        settings = {'viewport': 'viewport',  # 'tabbed': int(request.params['indent']),
                    'image': None,
                    'uniform_non_carbon': is_js_true(request.params['uniform_non_carbon']),
                    'verbose': False,
                    'validation': True,
                    'stick_format': request.params['stick_format'],
                    'save': True,
                    'backgroundcolor': 'white',
                    'location_viewport': 'left',
                    'columns_viewport': 9,
                    'columns_text': 3}
        # parse data dependding on mode.
        request.session['status'] = make_msg('Conversion', 'Conversion in progress')
        ## case 1: user submitted output
        ##### mode no longer supported
        ## case 2: user uses pse
        ## case 2b: DEMO mode.
        if 'demo_filename' in request.params:
            mode = 'demo'
            filename = demo_file(request)  # prevention against attacks
        ## case 2a: file mode.
        else:
            mode = 'file'
            malformed = is_malformed(request, 'file', 'pdb')
            if malformed:
                return {'status': malformed}
            filename = save_file(request, 'pse')
        trans = PyMolTranspiler(file=filename, job=User.get_username(request), **settings)
        if mode == 'demo' or not is_js_true(request.params[
                                                'pdb']):  ## pdb_string checkbox is true means that it adds the coordinates in the JS and not pdb code is given
            with open(os.path.join(trans.tmp, os.path.split(filename)[1].replace('.pse', '.pdb'))) as fh:
                trans.raw_pdb = fh.read()
        else:
            trans.pdb = request.params['pdb']
        request.session['file'] = filename
        # deal with user permissions.
        code = 1
        request.session['status'] = make_msg('Permissions', 'Finalising user permissions')
        pagename = get_uuid(request)
        # create output
        settings['pdb'] = []
        request.session['status'] = make_msg('Load function', 'Making load function')
        settings['loadfun'] = trans.get_loadfun_js(tag_wrapped=True, **settings)
        settings['descriptors'] = trans.description
        if trans.raw_pdb:
            settings['proteinJSON'] = '[{"type": "data", "value": "pdb", "isVariable": true, "loadFx": "loadfun"}]'
            settings['pdb'] = [
                ('pdb', '\n'.join(trans.ss) + '\n' + trans.raw_pdb)]  # note that this used to be a string,
        elif len(trans.pdb) == 4:
            settings['proteinJSON'] = '[{{"type": "rcsb", "value": "{0}", "loadFx": "loadfun"}}]'.format(trans.pdb)
        else:
            settings['proteinJSON'] = '[{{"type": "file", "value": "{0}", "loadFx": "loadfun"}}]'.format(trans.pdb)
        settings['title'] = 'User submitted structure (from PyMOL file)'
        commit_submission(request, settings, pagename)
        # save sharable page data
        request.session['status'] = make_msg('Saving', 'Storing data for retrieval.')
        request.session['status'] = make_msg('Loading results', 'Conversion is being loaded', condition='complete',
                                             color='bg-info')
        return {'page': pagename}
    except Exception as err:
        log.exception(f'serious error in page creation from PyMol: {err}')
        request.response.status = 500
        request.session['status'] = make_msg('A server-side error arose', 'The code failed to run serverside.', 'error',
                                             'bg-danger')
        return {'status': 'error'}


@view_config(route_name='convert_mesh', renderer="../templates/custom.result.mako")
def convert_mesh(request):
    log.info(f'Mesh conversion requested by {User.get_username(request)}')
    if 'demo_file' in request.params:
        filename = demo_file(request)  # prevention against attacks
        fh = open(filename)
    else:
        request.params['file'].file.seek(0)
        fh = io.StringIO(request.params['file'].file.read().decode("utf8"), newline=None)
    if 'scale' in request.params:
        scale = float(request.params['scale'])
    else:
        scale = 0
    if 'centroid' in request.params and request.params['centroid'] in ('unaltered', 'origin', 'center'):
        centroid_mode = request.params['centroid']
    else:
        centroid_mode = 'unaltered'
    if 'origin' in request.params and request.params['centroid'] == 'origin':
        origin = request.params['origin'].split(',')
    else:
        origin = None
    mesh = PyMolTranspiler.convert_mesh(fh, scale, centroid_mode, origin)
    return {'mesh': mesh}


@view_config(route_name='convert_pdb', renderer="json")
def convert_pdb(request):
    # mode = code | file
    log.info(f'PDB page creation requested by {User.get_username(request)}')
    malformed = is_malformed(request, 'viewcode', 'mode', 'pdb')
    if malformed:
        return {'status': malformed}
    pagename = get_uuid(request)
    viewcode = request.params['viewcode']
    data_other = re.sub(r'<\w+ (.*?)>.*', r'\1', viewcode).replace('data-toggle="protein"','').replace('data-toggle=\'protein\'','').replace('data-toggle=protein','')
    if not request.user or request.user.role not in ('admin', 'friend'):
        data_other = clean_data_other(data_other)
    settings = {'data_other': data_other,
                'page': pagename, 'editable': True,
                'backgroundcolor': 'white', 'validation': None, 'js': None, 'pdb': [], 'loadfun': ''}
    if request.params['mode'] == 'code':
        pdb = request.params['pdb']
        if len(pdb) == 4:
            settings['proteinJSON'] = '[{{"type": "rcsb", "value": "{0}"}}]'.format(pdb)  # PDB code.
            settings['descriptors'] = PDBMeta(pdb).describe()
            settings['title'] = f'User created page (PDB: {pdb})'
        else:
            settings['proteinJSON'] = '[{{"type": "file", "value": "{0}"}}]'.format(pdb)  # url
            settings['title'] = 'User submitted structure (from external PDB)'
            settings['descriptors'] = {'text': f'PDB loaded from [{pdb}](source <i class="far fa-external-link"></i>)'}
            if 'https://swissmodel.expasy.org' in pdb:
                settings['model'] = True
    elif request.params['mode'] == 'renumbered':
        ### same as file but with mod.
        settings['proteinJSON'] = '[{"type": "data", "value": "pdb", "isVariable": true}]'
        pdb_data = request.params['pdb'].replace("'",'').replace('"','') #XSS treat.
        settings['pdb'] = [('pdb', pdb_data)]
        settings['js'] = 'external'
        rex = re.match('REMARK 100 THIS ENTRY IS (\w+) FROM (\w+)\.', pdb_data)
        if rex:
            code = rex.group(2)
            ### this is mad wasteful. TO DO Fix.
            definitions = Structure(id=code, description='', x=0, y=0, code=code).lookup_sifts().chain_definitions
            settings['descriptors'] = {'peptide': [(':'+d['chain'], f"{d['uniprot']} [offset by {d['offset']}]") for d in definitions]}
            settings['title'] = f'User created page (PDB: {code} {rex.group(1)})'
        else:
            settings['title'] = f'User created page'
    else: #file
        settings['proteinJSON'] = '[{"type": "data", "value": "pdb", "isVariable": true}]'
        filename = save_file(request, 'pdb', field='pdb')
        trans = PyMolTranspiler.load_pdb(file=filename)
        os.remove(filename)
        if 'HELIX' in trans.raw_pdb or 'SHEET' in trans.raw_pdb:
            settings['pdb'] = [('pdb', trans.raw_pdb)]
        else:
            settings['pdb'] = [('pdb', '\n'.join(trans.ss)+'\n'+trans.raw_pdb)]
        settings['js'] = 'external'
        settings['title'] = 'User submitted structure (from uploaded PDB)'
    commit_submission(request, settings, pagename)
    return {'page': pagename}

def clean_data_other(data_other):
    return Page.sanitise_HTML(f'<span {data_other}></span>').replace('<span ','').replace('></span>','')

@view_config(route_name='renumber', renderer="json")
def renumber(request):
    #PDB code only
    malformed = is_malformed(request, 'pdb')
    if malformed:
        return {'status': malformed}
    pdb = request.params['pdb']
    if len(pdb) != 4 or re.search('\W', pdb) is not None: ## renumber is for PDB structures only. There is no point otherwise.
        request.response.status = 422
        return {'status': f'{pdb} is not PDB code'}
    definitions = Structure(id=pdb, description='', x=0, y=0, code=pdb).lookup_sifts().chain_definitions
    trans = PyMolTranspiler.renumber(pdb, definitions)
    return {'pdb': f'REMARK 100 THIS ENTRY IS RENUMBERED FROM {pdb}.\n' +
                   '\n'.join(trans.ss) +
                   '\n'+trans.raw_pdb}

@view_config(route_name='premutate', renderer="json") #as in mutate a structure before page creation.
def premutate(request):
    malformed = is_malformed(request, 'pdb', 'mutations', 'chain')
    if malformed:
        return {'status': malformed}
    ## variant of mutate...
    pdb = request.params['pdb']
    chain = request.params['chain']
    mutations = request.params['mutations'].split()
    filename = os.path.join('michelanglo_app', 'temp', f'{uuid.uuid4()}.pdb') #get_uuid is not really needed as it does not go to DB.
    ## type is determined
    if len(pdb) == 4: ##PDB code.
        code = pdb
        PyMolTranspiler.mutate_code(pdb, filename, mutations, chain)
    elif len(pdb.strip()) == 0:
        request.response.status = 422
        return {'status': f'Empty PDB string?!'}
    else:
        if re.match('https://swissmodel.expasy.org', pdb): ## swissmodel
            pdb = requests.get(pdb).text
        with open(filename, 'w') as fh:
            fh.write(pdb)
        PyMolTranspiler.mutate_file(filename, filename, mutations, chain)
    with open(filename, 'r') as fh:
        block = fh.read()
    os.remove(filename)
    if len(pdb) == 4:
        return {'pdb': f'REMARK 100 THIS ENTRY IS ALTERED FROM {code}.\n' +block}
    else:
        return {'pdb': block}

@view_config(route_name='convert_pdb_w_sdf', renderer="json")
def with_sdf(request):
    malformed = is_malformed(request, 'apo')
    if malformed:
        return {'status': malformed}
    pagename = get_uuid(request)
    pdbfile = save_file(request, 'pdb', field='apo')
    ### deal with sdf
    sdfdex = []
    for k in request.params.keys():
        if k in ('apo', 'viewcode'):
            continue
        else:
            print('debug', k)
            sdffile = save_file(request, 'sdf', k)
            sdfdex.append({'name': re.sub('[^\w_]','',k.replace(' ','_')),
                           'block': PyMolTranspiler.sdf_to_pdb(sdffile, pdbfile)})
    if sdfdex == []:
        return {'status': 'No SDF files'}
    loadfun = 'const ligands = '+json.dumps(sdfdex)+';'
    loadfun += '''
    window.generate_ligands = () => {
        if (window.myData === undefined) {setTimeout(window.generate_ligands, 100); console.log('wait');}
        else {
            ligands.forEach((v,i) => {
                window[v.name] = apo.replace(/END\\n?/,'TER\\n') + v.block;
            });
        }
    }
    window.generate_ligands();
    '''
    ligand_defs = ','.join([f'{{"type": "data", "value": "{e["name"]}", "isVariable": true}}' for e in sdfdex])
    prolink = '* <span class="prolink" data-toggle="protein" data-load="{i}" data-selection="UNK" data-focus="residue">Ligand: {i}</span>\n'
    descr = 'These are the models in this page. To make your own prolinks, do note that the ligand is called "UNK" for selection purposes.\n\n.'+\
            '* <span class="prolink" data-toggle="protein" data-load="apo" data-view="auto">Apo structure</span>\n'+\
            ''.join([prolink.format(i=e['name']) for e in sdfdex])
    ### viewcode!
    if 'viewcode' in request.params:
        viewcode = request.params['viewcode']
        data_other = re.sub(r'<\w+ (.*?)>.*', r'\1', viewcode).replace('data-toggle="protein"', '')\
                                                              .replace('data-toggle=\'protein\'', '')\
                                                              .replace('data-toggle=protein', '')
        if not request.user or request.user.role not in ('admin', 'friend'):
            data_other = clean_data_other(data_other)
    else:
        data_other = ''
    ### settings
    settings = {'data_other': data_other,
                'page': pagename, 'editable': True,
                'backgroundcolor': 'white',
                'validation': None, 'js': None, 'pdb': [], 'loadfun': loadfun,
                'proteinJSON': '[{"type": "data", "value": "apo", "isVariable": true}, ' + ligand_defs + ']',
                'descriptors': {'text': descr}}
    trans = PyMolTranspiler.load_pdb(file=pdbfile)
    os.remove(pdbfile)
    settings['pdb'] = [('apo', '\n'.join(trans.ss) + '\n' + trans.raw_pdb.lstrip())]
    settings['title'] = 'User submitted structure (from uploaded PDB+SDF)'
    commit_submission(request, settings, pagename)
    return {'page': pagename}

@view_config(route_name='task_check', renderer="json")
def status_check_view(request):
    """
    status = {'condition' : request.session['status']['condition'],
                'title'     : request.session['status']['title'],
                'body'      : request.session['status']['body'],
                'color'     : request.session['status']['color']}
    :param request:
    :return:
    """

    msg = PyMolTranspiler.current_task
    if 'idle' in msg:
        return {'condition': 'running',
                'title': 'Running',
                'body': 'Conversion in progress &mdash;final touches',
                'color': 'bg-warning'}
    elif User.get_username(request) in msg:
        return {'condition': 'running',
                'title': 'Running',
                'body': msg,
                'color': 'bg-secondary'}
    else:
        return {'condition': 'running',
                'title': 'Quewing',
                'body': 'There is another job ahead of yours: this will take a few seconds.',
                'color': 'bg-warning'}


def make_msg(title, body, condition='running', color=''):
    return {'condition': condition,
            'title': title,
            'body': body,
            'color': color}
