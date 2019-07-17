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

PyMolTranspiler.tmp = os.path.join('michelanglo_app', 'temp')

from ._common_methods import is_js_true, get_username, is_malformed
import logging
log = logging.getLogger(__name__)

def demo_file(request):
    """
    Needed for ajax_convert. Paranoid way to prevent user sending a spurious demo file name (e.g. ~/.ssh/).
    """
    demos=os.listdir(os.path.join('michelanglo_app', 'demo'))
    if request.params['demo_file'] in demos:
        return os.path.join('michelanglo_app', 'demo', request.params['demo_file'])
    else:
        raise Exception('Non existant demo file requested. Possible attack!')

def save_file(request, extension, field='file'):
    filename=os.path.join('michelanglo_app', 'temp','{0}.{1}'.format(get_uuid(),extension))
    request.params[field].file.seek(0)
    with open(filename, 'wb') as output_file:
        shutil.copyfileobj(request.params[field].file, output_file)
    return filename

########################################################################################
#### Page <> User DB

def anonymous_submission(request, settings, pagename):
    settings['authors'] = ['anonymous']
    settings['freelyeditable'] = True
    settings['description'] = '## Description\n\n' +\
              'Only <a href="#" class="text-secondary" data-toggle="modal" data-target="#login">logged-in users</a>'+\
              ' can edit data pages.\n\nThis page will be deleted in 24 hours.'
    trashcan = get_trashcan(request)
    trashcan.add_owned_page(pagename)
    request.dbsession.add(trashcan)
    
def user_submission(request, settings, pagename):
    user = request.user
    user.add_owned_page(pagename)
    settings['author'] = [user.name]
    request.dbsession.add(user)
    settings['editors'] = [user.name]
    
def commit_submission(request, settings, pagename):
    if request.user:
        user_submission(request, settings, pagename)
    else:
        anonymous_submission(request, settings, pagename)
    Page(pagename).save(settings)

def get_uuid():
    identifier = str(uuid.uuid4())
    if identifier in os.listdir(os.path.join('michelanglo_app', 'user-data')):
        log.error('UUID collision!!!')
        return get_uuid() #one in a ten-quintillion!
    return identifier

########################################################################################
### VIEWS

@view_config(route_name='ajax_convert', renderer="json")
def ajax_convert(request):
    user = request.user
    log.info('Conversion of PyMol requested.')
    request.session['status'] = make_msg('Checking data', 'The data has been recieved and is being checked')
    try:
        minor_error='' #does nothing atm.

        ## assertions
        if not 'pdb_string' in request.params and not request.params['pdb']:
            response = {'error': 'danger', 'error_title': 'No PDB code', 'error_msg': 'A PDB code is required to make the NGL viewer show a protein.','snippet':'','validation':''}
            log.warn(response)
            request.session['status'] = make_msg(response['error_title'],response['error_msg'],'error','bg-danger')
            return response
        elif request.params['mode'] == 'out' and not request.params['pymol_output']:
            response={'error': 'danger', 'error_title': 'No PyMOL code', 'error_msg': 'PyMOL code is required to make the NGL viewer show a protein.','snippet':'','validation':''}
            log.warn(response)
            request.session['status'] = make_msg(response['error_title'], response['error_msg'], 'error', 'bg-danger')
            return response
        elif request.params['mode'] == 'file' and not (('demo_file' in request.params and request.params['demo_file']) or ('file' in request.params and request.params['file'].filename)):
            response = {'error': 'danger', 'error_title': 'No PSE file', 'error_msg': 'A PyMOL file to make the NGL viewer show a protein.','snippet':'','validation':''}
            log.warn(response)
            request.session['status'] = make_msg(response['error_title'], response['error_msg'], 'error', 'bg-danger')
            return response

        ## set settings
        settings = {'viewport': 'viewport',#'tabbed': int(request.params['indent']),
                    'image': None,
                    'uniform_non_carbon':is_js_true(request.params['uniform_non_carbon']),
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
        if request.params['mode'] == 'out':
            view = ''
            reps = ''
            data = request.params['pymol_output'].split('PyMOL>')
            for block in data:
                if 'get_view' in block:
                    view = block
                elif 'iterate' in block:  # strickly lowercase as it ends in _I_terate
                    reps = block
                elif not block:
                    pass  # empty line.
                else:
                    minor_error = 'Unknown block: ' + block
            trans = PyMolTranspiler(view=view, representation=reps, pdb=request.params['pdb'], **settings)
        ## case 2: user uses pse
        elif request.params['mode'] == 'file':
            ## case 2b: DEMO mode.
            if 'demo_file' in request.params:
                filename=demo_file(request) #prevention against attacks
            ## case 2a: file mode.
            else:
                filename = save_file(request,'pse')
            trans = PyMolTranspiler(file=filename, **settings)
            request.session['file'] = filename
            if 'pdb_string' in request.params:
                with open(os.path.join(trans.tmp, os.path.split(filename)[1].replace('.pse','.pdb'))) as fh:
                    trans.raw_pdb = fh.read()
            else:
                trans.pdb = request.params['pdb']
        else:
            log.warn(f'Unknown mode requested by {get_username(request)}.')
            return {'snippet': 'Please stop trying to hack the server', 'error_title': 'A major error arose', 'error': 'danger', 'error_msg': 'The code failed to run serverside. Most likely malicius','viewport':settings['viewport']}


        # deal with user permissions.
        code = 1
        request.session['status'] = make_msg('Permissions', 'Finalising user permissions')
        pagename=get_uuid()
        # create output
        settings['pdb'] = []
        request.session['status'] = make_msg('Load function', 'Making load function')
        settings['loadfun'] = trans.get_loadfun_js(tag_wrapped=True, **settings)
        if trans.raw_pdb:
            settings['proteinJSON'] = '[{"type": "data", "value": "pdb", "isVariable": true, "loadFx": "loadfun"}]'
            settings['pdb'] = [('pdb', '\n'.join(trans.ss)+'\n'+trans.raw_pdb)] #note that this used to be a string,
        elif len(trans.pdb) == 4:
            settings['proteinJSON'] = '[{{"type": "rcsb", "value": "{0}", "loadFx": "loadfun"}}]'.format(trans.pdb)
        else:
            settings['proteinJSON'] = '[{{"type": "file", "value": "{0}", "loadFx": "loadfun"}}]'.format(trans.pdb)
        #user.
        if user:
            user_submission(request,settings,pagename)
        else:
            anonymous_submission(request, settings, pagename)
        Page(pagename).save(settings)
        # save sharable page data
        request.session['status'] = make_msg('Saving', 'Storing data for retrieval.')
        
        request.session['status'] = make_msg('Loading results', 'Conversion is being loaded',condition='complete', color='bg-info')
        return {'page': pagename}
    except:
        log.exception('serious error in page creation from PyMol')
        request.response.status = 500
        request.session['status'] = make_msg('A server-side error arose', 'The code failed to run serverside.','error','bg-danger')
        return {'status': 'error'}


@view_config(route_name='ajax_custom', renderer="../templates/custom.result.mako")
def ajax_custom(request):
    log.info(f'Mesh conversion requested by {get_username(request)}')
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
    if 'centroid' in request.params and request.params['centroid'] in ('unaltered','origin','center'):
        centroid_mode = request.params['centroid']
    else:
        centroid_mode = 'unaltered'
    if 'origin' in request.params and request.params['centroid'] == 'origin':
        origin = request.params['origin'].split(',')
    else:
        origin = None
    mesh = PyMolTranspiler.convert_mesh(fh, scale, centroid_mode, origin)
    return {'mesh': mesh}


@view_config(route_name='ajax_pdb', renderer="json")
def ajax_pdb(request):
    # mode = code | file
    log.info(f'PDB page creation requested by {get_username(request)}')
    malformed = is_malformed(request, 'viewcode', 'mode', 'pdb')
    if malformed:
        return {'status': malformed}
    pagename = str(uuid.uuid4())
    settings = {'data_other': request.params['viewcode'].replace('<div', '').replace('</div>', '').replace('<', '').replace('>', ''),
                'page': pagename, 'editable': True,
                'backgroundcolor': 'white', 'validation': None, 'js': None, 'pdb': [], 'loadfun': ''}
    if request.params['mode'] == 'code':
        if len(request.params['pdb']) == 4:
            settings['proteinJSON'] = '[{{"type": "rcsb", "value": "{0}"}}]'.format(request.params['pdb']) # PDB code.
        else:
            settings['proteinJSON'] = '[{{"type": "file", "value": "{0}"}}]'.format(request.params['pdb']) # url
    else:
        settings['proteinJSON'] = '[{"type": "data", "value": "pdb", "isVariable": true}]'
        filename = save_file(request,'pdb', field='pdb')
        print(settings['data_other'])
        trans = PyMolTranspiler.load_pdb(file=filename)
        settings['pdb'] = [('pdb', '\n'.join(trans.ss)+'\n'+trans.raw_pdb)]
        settings['js'] = 'external'
    commit_submission(request,settings,pagename)
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
    if 'status' not in request.session:
        ## prepare for next time
        request.session['status'] = {'condition' : 'running',
                                    'title'     : 'Starting',
                                    'body'      : 'The job is about to start (but is taking some time to do so).',
                                    'color'     : 'bg-warning'}
        return {'condition' : 'running',
                'title'     : 'Starting',
                'body'      : 'The job is about to start.',
                'color'     : 'bg-warning'}
    return request.session['status']




def make_msg(title, body, condition='running', color=''):
    return {'condition' : condition,
            'title'     : title,
            'body'      : body,
            'color'     : color}
