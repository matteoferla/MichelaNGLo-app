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

from ._common_methods import is_js_true, get_username
import logging
log = logging.getLogger(__name__)

def demo_file(request):
    """
    Needed for ajax_convert. Paranoid way to prevent user sending a spurious demo file name (e.g. ~/.ssh/).
    """
    demos=os.listdir(os.path.join('michelanglo_app', 'demo'))
    if request.POST['demo_file'] in demos:
        return os.path.join('michelanglo_app', 'demo', request.POST['demo_file'])
    else:
        raise Exception('Non existant demo file requested. Possible attack!')

def save_file(request, extension):
    filename=os.path.join('michelanglo_app', 'temp','{0}.{1}'.format(uuid.uuid4(),extension))
    request.POST['file'].file.seek(0)
    with open(filename, 'wb') as output_file:
        shutil.copyfileobj(request.POST['file'].file, output_file)
    return filename



@view_config(route_name='ajax_convert', renderer="json")
def ajax_convert(request):
    user = request.user
    log.info('Conversion of PyMol requested.')
    request.session['status'] = make_msg('Checking data', 'The data has been recieved and is being checked')
    try:
        minor_error='' #does nothing atm.

        ## assertions
        if not 'pdb_string' in request.POST and not request.POST['pdb']:
            response = {'error': 'danger', 'error_title': 'No PDB code', 'error_msg': 'A PDB code is required to make the NGL viewer show a protein.','snippet':'','validation':''}
            log.warn(response)
            request.session['status'] = make_msg(response['error_title'],response['error_msg'],'error','bg-danger')
            return response
        elif request.POST['mode'] == 'out' and not request.POST['pymol_output']:
            response={'error': 'danger', 'error_title': 'No PyMOL code', 'error_msg': 'PyMOL code is required to make the NGL viewer show a protein.','snippet':'','validation':''}
            log.warn(response)
            request.session['status'] = make_msg(response['error_title'], response['error_msg'], 'error', 'bg-danger')
            return response
        elif request.POST['mode'] == 'file' and not (('demo_file' in request.POST and request.POST['demo_file']) or ('file' in request.POST and request.POST['file'].filename)):
            response = {'error': 'danger', 'error_title': 'No PSE file', 'error_msg': 'A PyMOL file to make the NGL viewer show a protein.','snippet':'','validation':''}
            log.warn(response)
            request.session['status'] = make_msg(response['error_title'], response['error_msg'], 'error', 'bg-danger')
            return response

        ## set settings
        settings = {'viewport': request.POST['viewport_id'],#'tabbed': int(request.POST['indent']),
                    'image': is_js_true(request.POST['image']),
                    'uniform_non_carbon':is_js_true(request.POST['uniform_non_carbon']),
                    'verbose': False,
                    'validation': True,
                    'stick_format': request.POST['stick_format'],
                    'save': True,
                    'backgroundcolor': 'white'}

        # parse data dependding on mode.
        request.session['status'] = make_msg('Conversion', 'Conversion in progress')
        ## case 1: user submitted output
        if request.POST['mode'] == 'out':
            view = ''
            reps = ''
            data = request.POST['pymol_output'].split('PyMOL>')
            for block in data:
                if 'get_view' in block:
                    view = block
                elif 'iterate' in block:  # strickly lowercase as it ends in _I_terate
                    reps = block
                elif not block:
                    pass  # empty line.
                else:
                    minor_error = 'Unknown block: ' + block
            trans = PyMolTranspiler(view=view, representation=reps, pdb=request.POST['pdb'], **settings)
        ## case 2: user uses pse
        elif request.POST['mode'] == 'file':
            ## case 2b: DEMO mode.
            if 'demo_file' in request.POST:
                filename=demo_file(request) #prevention against attacks
            ## case 2a: file mode.
            else:
                filename = save_file(request,'pse')
            trans = PyMolTranspiler(file=filename, **settings)
            request.session['file'] = filename
            if 'pdb_string' in request.POST:
                trans.raw_pdb = open(filename.replace('.pse','.pdb')).read()
            else:
                trans.pdb = request.POST['pdb']
        else:
            log.warn(f'Unknown mode requested by {get_username(request)}.')
            return {'snippet': 'Please stop trying to hack the server', 'error_title': 'A major error arose', 'error': 'danger', 'error_msg': 'The code failed to run serverside. Most likely malicius','viewport':settings['viewport']}


        # deal with user permissions.
        code = 1
        request.session['status'] = make_msg('Permissions', 'Finalising user permissions')
        pagename=str(uuid.uuid4())
        if user:
            user.add_owned_page(pagename)
            settings['author'] = [user.name]
        else:
            user = get_trashcan(request)
            user.add_owned_page(pagename)
            settings['author'] = ['Anonymous']
        request.dbsession.add(user)

        # create output
        request.session['status'] = make_msg('Load function', 'Making load function')
        settings['loadfun'] = trans.get_loadfun_js(tag_wrapped=True, **settings)
        if trans.raw_pdb:
            settings['proteinJSON'] = '[{"type": "data", "value": "pdb", "isVariable": true, "loadFx": "loadfun"}]'
            settings['pdb'] = '\n'.join(trans.ss)+'\n'+trans.raw_pdb
        elif len(trans.pdb) == 4:
            settings['proteinJSON'] = '[{{"type": "rcsb", "value": "{0}", "loadFx": "loadfun"}}]'.format(trans.pdb)
        else:
            settings['proteinJSON'] = '[{{"type": "file", "value": "{0}", "loadFx": "loadfun"}}]'.format(trans.pdb)

        # save sharable page data
        settings['editors'] = [user.name]
        request.session['status'] = make_msg('Saving', 'Storing data for retrieval.')
        Page(pagename).save(settings)
        request.session['status'] = make_msg('Loading results', 'Conversion is being loaded',condition='complete', color='bg-info')
        return {'page': pagename}
    except:
        log.exception('serious error in page creation from PyMol')
        request.response.status = 500
        request.session['status'] = make_msg('A server-side error arose', 'The code failed to run serverside.','error','bg-danger')
        return {'error': 'error'}


@view_config(route_name='ajax_custom', renderer="../templates/custom.result.mako")
def ajax_custom(request):
    log.info(f'Mesh conversion requested by {get_username(request)}')
    if 'demo_file' in request.POST:
        filename = demo_file(request)  # prevention against attacks
        fh = open(filename)
    else:
        request.POST['file'].file.seek(0)
        fh = io.StringIO(request.POST['file'].file.read().decode("utf8"), newline=None)
    mesh = []
    o_name = ''
    scale_factor = 0
    vertices = []
    trilist = []
    sum_centroid = [0,0,0]
    min_size = [0,0,0]
    max_size = [0,0,0]
    centroid = [0, 0, 0]
    for row in fh:
        if row[0] == 'o':
            if o_name:
                mesh.append({'o_name':o_name,'triangles':trilist})
                vertices = []
                trilist = []
                scale_factor = 0
                sum_centroid = [0,0,0]
                min_size = [0,0,0]
                max_size = [0,0,0]
            o_name = row.rstrip().replace('o ','')
        elif row[0] == 'v':
            vertex = [float(e) for e in row.split()[1:]]
            vertices.append(vertex)
            for ax in range(3):
                sum_centroid[ax] += vertex[ax]
                min_size[ax] = min(min_size[ax], vertex[ax])
                max_size[ax] = max(max_size[ax], vertex[ax])
        elif row[0] == 'f':
            if scale_factor == 0: #first face.27.7  24.5
                # euclid = sum([(max_size[ax]-min_size[ax])**2 for ax in range(3)])**0.5
                scale_factor = float(request.POST['scale']) / max([abs(max_size[ax] - min_size[ax]) for ax in range(3)])
                if request.POST['centroid'] == 'origin':
                    centroid = [sum_centroid[ax]/len(vertices) for ax in range(3)]
                elif request.POST['centroid'] == 'unaltered':
                    centroid = [0, 0, 0]
                elif request.POST['centroid'] == 'custom':
                    origin = request.POST['origin'].split(',')
                    centroid = [sum_centroid[ax] / len(vertices) - float(origin[ax])/scale_factor  for ax in range(3)]  #the user gives scaled origin!
                else:
                    raise ValueError('Invalid request')

            new_face = [e.split('/')[0] for e in row.split()[1:]]
            if (len(new_face) != 3):
                pass
            trilist.extend([int((vertices[int(i) - 1][ax]-centroid[ax])*scale_factor*100)/100 for i in new_face[0:3] for ax in range(3)])
    mesh.append({'o_name': o_name, 'triangles': trilist})
    return {'mesh': mesh}


@view_config(route_name='ajax_pdb', renderer="json")
def ajax_pdb(request):
    log.info(f'PDB page creation requested by {get_username(request)}')
    pagename = str(uuid.uuid4())
    settings = {'data_other': request.POST['viewcode'].replace('<div', '').replace('</div>', '').replace('<', '').replace('>', ''),
                'page': pagename, 'editable': True,
                'backgroundcolor': 'white', 'validation': None, 'js': None, 'pdb': '', 'loadfun': ''}
    if request.POST['mode'] == 'code':
        if len(request.POST['pdb']) == 4:
            settings['proteinJSON'] = '[{{"type": "rcsb", "value": "{0}"}}]'.format(request.POST['pdb'])
        else:
            settings['proteinJSON'] = '[{{"type": "file", "value": "{0}"}}]'.format(request.POST['pdb'])
    else:
        settings['proteinJSON'] = '[{"type": "data", "value": "pdb", "isVariable": true}]'
        filename = save_file(request,'pdb')
        trans = PyMolTranspiler.load_pdb(file=filename)
        settings['pdb'] = '\n'.join(trans.ss) + '\n' + trans.raw_pdb
        settings['js'] = 'external'
    if request.user:
        settings['authors'] = [request.user.name]
        request.user.add_owned_page(pagename)
        request.dbsession.add(request.user)
    else:
        settings['authors'] = ['anonymous']
        settings['description'] = 'Only <a href="#" class="text-secondary" data-toggle="modal" data-target="#login">logged-in users</a> can edit data pages. This page will be deleted in 24 hours.'
        trashcan = get_trashcan(request)
        trashcan.add_owned_page(pagename)
        request.dbsession.add(trashcan)
    Page(pagename).save(settings)
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
        request.session['status'] = {'condition' : 'error',
                            'title'     : 'Error',
                            'body'      : 'The requested job was not found.',
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
