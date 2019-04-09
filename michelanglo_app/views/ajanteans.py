from pyramid.view import view_config
from pyramid.renderers import render_to_response
import traceback
from PyMOL_to_NGL import PyMolTranspiler
from ..pages import Page
from ..models import User
from ..trashcan import get_trashcan, get_public
import uuid
import shutil
import os
import io
import json
import time

#from pprint import PrettyPrinter
#pprint = PrettyPrinter()

## convert booleans and settings
def is_js_true(value):  # booleans get converted into strings in json.
    if not value or value == 'false':
        return False
    else:
        return True

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
    request.session['status'] = make_msg('Checking data', 'The data has been recieved and is being checked')
    try:
        minor_error='' #does nothing atm.

        ## assertions
        if not 'pdb_string' in request.POST and not request.POST['pdb']:
            response = {'error': 'danger', 'error_title': 'No PDB code', 'error_msg': 'A PDB code is required to make the NGL viewer show a protein.','snippet':'','validation':''}
            request.session['status'] = make_msg(response['error_title'],response['error_msg'],'error','bg-danger')
            return response
        elif request.POST['mode'] == 'out' and not request.POST['pymol_output']:
            response={'error': 'danger', 'error_title': 'No PyMOL code', 'error_msg': 'PyMOL code is required to make the NGL viewer show a protein.','snippet':'','validation':''}
            request.session['status'] = make_msg(response['error_title'], response['error_msg'], 'error', 'bg-danger')
            return response
        elif request.POST['mode'] == 'file' and not (('demo_file' in request.POST and request.POST['demo_file']) or ('file' in request.POST and request.POST['file'].filename)):
            response = {'error': 'danger', 'error_title': 'No PSE file', 'error_msg': 'A PyMOL file to make the NGL viewer show a protein.','snippet':'','validation':''}
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
        print('**************')
        print(traceback.format_exc())
        request.response.status = 500
        request.session['status'] = make_msg('A server-side error arose', 'The code failed to run serverside:<br/><pre><code>'+traceback.format_exc()+'</code></pre>','error','bg-danger')
        return {'error': 'error'}

@view_config(route_name='ajax_custom', renderer="../templates/custom.result.mako")
def ajax_custom(request):
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
    #make_static_html(**settings)
    print(pagename)
    return {'page': pagename}

@view_config(route_name='edit_user-page', renderer='json')
def edit(request):
    # get ready
    page = Page(request.POST['page'])
    user = request.user
    ## cehck permissions
    if not user or not (page.identifier in user.get_owned_pages() or user.role == 'admin'): ## only owners and admins can edit.
        request.response.status = 403
        return {'error': 'not authorised'}
    else:
        # check if encrypted
        if page.is_password_protected():
            page.key = request.POST['encryption_key'].encode('uft-8')
            page.path = page.encrypted_path
        #load data
        settings = page.load()
        if not settings:
            request.response.status = 404
            return {'error': 'page not found'}
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
        publicised1= 'public' in settings and not settings['public'] and is_js_true(request.POST['public']) #was private public but is now.
        publicised2= 'public' not in settings and is_js_true(request.POST['public']) #was not decalred but is now.
        if publicised1 or publicised2:
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
    page = Page(request.POST['page'])
    user = request.user
    ownership = user.get_owned_pages()
    ## cehck permissions
    if page.identifier not in ownership and not (user and user.role == 'admin'): ## only owners can delete
        request.response.status = 403
        return {'status': 'Not owner'}
    else:
        page.delete()
        return {'status': 'success'}


@view_config(route_name='get')
def get_ajax(request):
    user = request.user
    ###### get the user page list.
    if request.params['item'] == 'pages':
        if not user:
            request.response.status = 403
            return render_to_response("../templates/404.mako", {'project': 'Michelanglo', 'user': request.user}, request)
        elif user.role == 'admin':
            target = request.dbsession.query(User).filter_by(name=request.POST['username']).one()
            return render_to_response("../templates/login/pages.mako", {'project': 'Michelanglo', 'user': target}, request)
        elif request.POST['username'] == user.name:
            return render_to_response("../templates/login/pages.mako", {'project': 'Michelanglo', 'user': request.user}, request)
        else:
            request.response.status = 403
            return render_to_response("../templates/404.mako", {'project': 'Michelanglo', 'user': request.user}, request)
    ####### get the implementation code.
    elif request.params['item'] == 'implement':
        ## should non editors be able to see this??
        page = Page(request.params['page'])
        if 'key' in request.params:
            page = Page(request.params['page'], request.params['key'])
        else:
            page = Page(request.params['page'])
        settings = page.load()
        return render_to_response("../templates/results/implement.mako", settings, request)





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
                'title'     : 'Uploading',
                'body'      : 'The network is slower that normal.',
                'color'     : 'bg-warning'}
    return request.session['status']


def make_msg(title, body, condition='running', color=''):
    return {'condition' : condition,
            'title'     : title,
            'body'      : body,
            'color'     : color}
