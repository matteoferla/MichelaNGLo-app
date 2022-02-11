from pyramid.view import view_config
from ..models import Page, User
from ..models.trashcan import get_trashcan
from michelanglo_transpiler import PyMolTranspiler
import os
import io
import re
import json

from .common_methods import is_js_true,\
                             is_malformed,\
                             PDBMeta,\
                             get_uuid, \
                             save_file,\
                             save_coordinates,\
                             get_chain_definitions, \
                             get_history, \
                             get_references, \
                             get_pdb_block
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
            descr += '\n\n' + settings['descriptors']['text']
        if 'ref' in settings['descriptors'] and settings['descriptors']['ref']:
            descr += '\n### References\n'+settings['descriptors']['ref']
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
        malformed = is_malformed(request, 'uniform_non_carbon', 'stick_format', 'combine_objects')
        if malformed:
            return {'status': malformed}
        if 'demo_filename' not in request.params and 'file' not in request.params:
            request.response.status = 422
            log.warning(f'{User.get_username(request)} malformed request due to missing demo_filename or file')
            return f'Missing field (either demo_filename or file are compulsory)'
        ## set settings
        settings = {'viewport': 'viewport',  # 'tabbed': int(request.params['indent']),
                    'image': None,
                    'uniform_non_carbon': is_js_true(request.params['uniform_non_carbon']),
                    'verbose': False,
                    'validation': True,
                    'stick_format': request.params['stick_format'],
                    'combine_objects': is_js_true(request.params['combine_objects']),
                    'save': True,
                    'async_pdb': is_js_true(request.params['combine_objects']), # async pdb will mess up overlays!
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
        ### GO!
        log.debug('About to call the transpiler!')
        log.debug(filename)
        trans = PyMolTranspiler(job=User.get_username(request)).transpile(file=filename, **settings)
        ### save the PDB data?
        if mode == 'demo' or not is_js_true(request.params['pdb']):
            trans.pdb = None # yes save it.
        else:
            trans.pdb = request.params['pdb'] # PDB code to use
        request.session['file'] = filename
        # deal with user permissions.
        code = 1
        request.session['status'] = make_msg('Permissions', 'Finalising user permissions')
        pagename = get_uuid(request)
        # create output
        settings['title'] = 'User submitted structure (from PyMOL file)'
        settings['descriptors'] = trans.description
        # save proteinJSON
        protein_info = []
        settings['pdb'] = []
        if not trans.pdb: # PDB not provided.
            for name in trans.pdbblocks:
                settings['pdb'].append((name, trans.pdbblocks[name]))
                protein_info.append({"type": "data", "value": name, "isVariable": True, "loadFx": f"load{name}"})
        elif len(trans.pdb) == 4:
            settings['descriptors']['ref'] = get_references(trans.pdb)
            for name in trans.pdbblocks:
                protein_info.append({"type": "rcsb",
                           "value": trans.pdb,
                           "loadFx": f"load{name}",
                           'history': 'from PyMOL',
                           "chain_definitions": get_chain_definitions(request)
                           })
                # there should be only one!
        else:
            protein_info = [{"type": "url", "value": trans.pdb, "loadFx": "loadfun"}]
        ## load fun
        request.session['status'] = make_msg('Load function', 'Making load function')
        # load fun should not be a string....
        settings['loadfun'] = '\n\n' + '\n\n'.join(trans.loadfuns.values()) + '\n\n'
        if len(trans.pdbblocks) == 1:  # settings['combine_objects'] == True is a single model
            pass
        else:
            first = list(trans.pdbblocks.keys())[0]
            middle = ''
            for name in trans.loadfuns:
                if name == first:
                    continue
                middle += f'''
                        protein.stage.loadFile(new Blob([window['{name}'], {{type: 'text/plain'}}]),
                                                {{ext: 'pdb', firstModelOnly: true}})
                                     .then(window['load{name}']);
                        '''
            settings['loadfun'] += 'function loadfun (protein) { window["load' + first + '"](protein);' + middle + '}'
            protein_info[0]['loadFx'] = 'loadfun'
        settings['proteinJSON'] = json.dumps(protein_info)
        commit_submission(request, settings, pagename)
        # save sharable page data
        request.session['status'] = make_msg('Saving', 'Storing data for retrieval.')
        request.session['status'] = make_msg('Loading results', 'Conversion is being loaded', condition='complete',
                                             color='bg-info')
        return {'page': pagename}
    except Exception as err:
        log.error(f'serious error in page creation from PyMol: {err}')
        request.response.status = 500
        request.session['status'] = make_msg('A server-side error arose', 'The code failed to run serverside.', 'error',
                                             'bg-danger')
        return {'status': 'error'}


@view_config(route_name='convert_mesh', renderer="../templates/custom.result.mako")
def convert_mesh(request):
    log.info(f'Mesh conversion requested by {User.get_username(request)}')
    if 'demo_filename' in request.params:
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
    try:
        mesh = PyMolTranspiler.convert_mesh(fh, scale, centroid_mode, origin)
        return {'mesh': mesh}
    except Exception as error:
        return {'status': 'error', 'msg': f'{error.__class__.__name__}: {error}. (Most errors are because the mesh is not triangulated: hover over file input for more).'}

@view_config(route_name='convert_pdb', renderer="json")
def convert_pdb(request):
    # mode = code | file
    ##### Check is good
    log.info(f'PDB page creation requested by {User.get_username(request)}')
    malformed = is_malformed(request, 'viewcode', 'mode', 'pdb')
    if malformed:
        return {'status': malformed}
    ##### Get the details
    pagename = get_uuid(request)
    viewcode = request.params['viewcode']
    data_other = re.sub(r'<\w+ (.*?)>.*', r'\1', viewcode)\
                    .replace('data-toggle="protein"','')\
                    .replace('data-toggle=\'protein\'','')\
                    .replace('data-toggle=protein','')
    if not request.user or request.user.role not in ('admin', 'friend'):
        data_other = clean_data_other(data_other)
    settings = {'data_other': data_other,
                'async_pdb': True,
                'page': pagename, 'editable': True, 'descriptors': {},
                'backgroundcolor': 'white', 'validation': None, 'js': None, 'pdb': [], 'loadfun': ''}
    extension = 'pdb'
    pdb = request.params['pdb']
    history = get_history(request)
    definitions = get_chain_definitions(request)
    #### determine wheat we have
    if request.params['mode'] == 'code':
        if len(pdb) == 4:
            settings['descriptors'] = PDBMeta(pdb).describe()
            settings['proteinJSON'] = json.dumps([{'type': 'rcsb',
                                                   'value': pdb,
                                                   'chain_definitions': definitions,
                                                   'history': history}])
            ### The difference between chain_definition and PDBMeta is that the latter has ligand info, but not Uniprot.
            settings['title'] = f'User created page (PDB: {pdb})'
        else:  #type url means external file.
            settings['proteinJSON'] = json.dumps([{'type': 'url',
                                                   'value': pdb,
                                                   'chain_definitions': definitions,
                                                   'history': history}])
            settings['title'] = 'User submitted structure (from external PDB)'
            settings['descriptors'] = {'text': f'PDB loaded from [source <i class="far fa-external-link"></i>]({pdb})'}
            if is_model(pdb):
                settings['model'] = True
                settings['descriptors']['ref'] = get_references(pdb)
    elif request.params['mode'] in ('renumbered', 'file'):
        ### same as file but with mod.
        settings['proteinJSON'] = json.dumps([{'type': 'data',
                                               'value': 'startingProtBlock',
                                               'isVariable': 'true',
                                               'chain_definitions': definitions,
                                               'history': history}])
        pdb_data = get_pdb_block(request)
        settings['pdb'] = [('startingProtBlock', pdb_data)]
        settings['js'] = 'external'
        if history['changes']:
            settings['descriptors']['text'] = f'\n## Changes\n {history["changes"]}'
            if "swissmodel" in history["code"]:
                code = 'SWISSMODEL'
                settings['descriptors']['text'] += f'\n\n##Source\nPDB loaded from [Swissmodel <i class="far fa-external-link"></i>]({history["code"]})'
            else:
                code = history["code"]
            settings['title'] = f'User created page (PDB: {code} {history["changes"]})'
            settings['descriptors']['ref'] = get_references(history["code"])
        else:
            settings['title'] = f'User created page'
        if definitions:
            settings['descriptors']['peptide'] = [(f":{d['chain']}", f"{d['name']} [offset by {d['offset']}]") for d in definitions]
    elif hasattr(request.params['pdb'], 'filename'):
        settings['proteinJSON'] = '[{"type": "data", "value": "pdb", "isVariable": true}]'
        trans = save_coordinates(request)
        settings['pdb'] = [('pdb', trans.raw_pdb)]
        settings['js'] = 'external'
        settings['title'] = 'User submitted structure (from uploaded PDB)'
    else:
        log.error(f'I have no idea what is uploaded as `pdb`. type: {type(pdb)} {pdb}')
    commit_submission(request, settings, pagename)
    return {'page': pagename}

def is_model(code):
    if 'https://swissmodel.expasy.org' in code:
        return True
    elif 'https://alphafold.ebi.ac.uk/files/' in code:
        return True
    else:
        return False

############################## Make the page for venus.
@view_config(route_name='venus_create', renderer="json")
def create_venus(request):
    """
    request params: uniprot, species, mutation, text, code, wt_block (=pdb block), mut_block (=pdb block), block, definitions, history
    """
    # Get data.
    malformed = is_malformed(request, 'proteindata')
    if malformed:
        return {'status': malformed}
    log.info(f'VENUS page creation requested by {User.get_username(request)}')
    pagename = get_uuid(request)
    try:
        data = json.loads(request.params['proteindata'])
        # writing out the content for human sanity & error catching.
        uniprot = data['uniprot']
        species = data['species']
        mutation = data['mutation']
        code = data['code']
        text = data['text']
        proteins = data['protein']
        prolink = data['prolink']
    except Exception as error:
        request.response.status = 422
        msg = f'VENUS data error. {type(error).__name__}: {error}'
        log.warning(msg)
        return {'status': msg}

    #pdbblocks = [(p['value']) for p in proteins] to do split out for asycn loading!
    # add prolinks for models
    topper = f'This page contains the following models:\n\n'
    topper += ''.join([f'* <span class="prolink" data-load={i}>{p["name"]}</span>\n' for i, p in enumerate(proteins)])
    is_within = lambda n: any([p['name'] == n for p in proteins])
    if is_within('wt') and is_within('mutant'):
        topper +=f'''* <span class="prolink" 
                    data-target="#viewport" 
                    data-toggle="protein" 
                    data-load="wt" 
                    data-focus="overlay mutant" 
                    data-selection="{mutation[1:-1]}:A">
                    Overlay of wild-type and mutant</span>'''
    body = topper +'\n\n' + text
    # Prepare response.
    settings = {'data_other': ' '.join([f'data-{k}="{v}"' if type(v) in (str, list) else f'data-{k}={v}' for k, v in prolink.items()]),
                'title': f'VENUS generated page for {uniprot} ({species}) {mutation}',
                'page': pagename,
                'editable': True,
                'descriptors': {'ref': get_references(code),
                                'text': body},
                'backgroundcolor': 'white',
                'validation': None,
                'js': 'external',
                'model': is_model(code),
                'pdb': [],
                'loadfun': '',
                'columns_viewport': 5,
                'columns_text': 7,
                'location_viewport': 'right',
                'proteinJSON': json.dumps(proteins)
    }

    ## Special JS to always show mutation
    # to do.

    ## save and return
    commit_submission(request, settings, pagename)
    return {'page': pagename}

###################################
def clean_data_other(data_other):
    return Page.sanitise_HTML(f'<span {data_other}></span>').replace('<span ','').replace('></span>','')


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
                           'block': PyMolTranspiler().sdf_to_pdb(sdffile, pdbfile)})
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
    trans = PyMolTranspiler().load_pdb(file=pdbfile)
    os.remove(pdbfile)
    settings['pdb'] = [('apo', trans.pdb_block)]
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
