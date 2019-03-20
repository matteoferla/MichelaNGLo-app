from pyramid.view import view_config
import traceback
from PyMOL_to_NGL import PyMolTranspiler
import uuid
import shutil
import os
import mako
import io

#from pprint import PrettyPrinter
#pprint = PrettyPrinter()

def demo_file(request):
    demos=os.listdir(os.path.join('pymol_ngl_transpiler_app', 'demo'))
    if request.POST['demo_file'] in demos:
        return os.path.join('pymol_ngl_transpiler_app', 'demo', request.POST['demo_file'])
    else:
        raise Exception('Non existant demo file requested. Possible attack!')


@view_config(route_name='ajax_convert', renderer="../templates/main.result.mako")
def ajax_convert(request):
    try:
        minor_error=''
        ## assertions
        if not 'pdb_string' in request.POST and not request.POST['pdb']:
            return {'error': 'danger', 'error_title': 'No PDB code', 'error_msg': 'A PDB code is required to make the NGL viewer show a protein.','snippet':'','validation':''}
        elif request.POST['mode'] == 'out' and not request.POST['pymol_output']:
            return {'error': 'danger', 'error_title': 'No PyMOL code', 'error_msg': 'PyMOL code is required to make the NGL viewer show a protein.','snippet':'','validation':''}
        elif request.POST['mode'] == 'file' and not (('demo_file' in request.POST and request.POST['demo_file']) or ('file' in request.POST and request.POST['file'].filename)):
            return {'error': 'danger', 'error_title': 'No PSE file', 'error_msg': 'A PyMOL file to make the NGL viewer show a protein.','snippet':'','validation':''}

        ## convert booleans and settings
        def is_js_true(value): # booleans get converted into strings in json.
            if not value or value == 'false':
                return False
            else:
                return True
        settings = {'viewport': request.POST['viewport_id'],#'tabbed': int(request.POST['indent']),
                    'image': is_js_true(request.POST['image']),
                    'uniform_non_carbon':is_js_true(request.POST['uniform_non_carbon']),
                    'verbose': False,
                    'validation': True,
                    'stick': request.POST['stick'],
                    'save': request.POST['save'],
                    'backgroundcolor': 'white'}

        # parse data
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
            settings['loadfun'] = trans.get_loadfun_js(viewport=request.POST['viewport_id'], tag_wrapped=True)
        elif request.POST['mode'] == 'file':
            if 'demo_file' in request.POST:
                filename=demo_file(request) #prevention against attacks
            else:
                filename=os.path.join('pymol_ngl_transpiler_app', 'temp','{0}.pse'.format(uuid.uuid4()))
                request.POST['file'].file.seek(0)
                with open(filename, 'wb') as output_file:
                    shutil.copyfileobj(request.POST['file'].file, output_file)
            trans = PyMolTranspiler(file=filename, **settings)
            request.session['file'] = filename
            if 'pdb_string' in request.POST:
                trans.raw_pdb = open(filename.replace('.pse','.pdb')).read()
            else:
                trans.pdb = request.POST['pdb']
        else:
            return {'snippet': 'Please stop trying to hack the server', 'error_title': 'A major error arose', 'error': 'danger', 'error_msg': 'The code failed to run serverside. Most likely malicius','viewport':settings['viewport']}
        # make output
        code = trans.get_html(ngl=request.POST['cdn'], **settings)
        page=str(uuid.uuid4())
        snippet_run=trans.code
        settings['loadfun'] = trans.get_loadfun_js(viewport=request.POST['viewport_id'])
        if trans.raw_pdb:
            settings['proteinJSON'] = '[{"type": "data", "value": "pdb", "isVariable": true, "loadFx": "loadfun"}]'
            settings['pdb'] = '\n'.join(trans.ss)+'\n'+trans.raw_pdb
        elif len(trans.pdb) == 4:
            settings['proteinJSON'] = '[{{"type": "rcsb", "value": "{0}", "loadFx": "loadfun"}}]'.format(trans.pdb)
        else:
            settings['proteinJSON'] = '[{{"type": "file", "value": "{0}", "loadFx": "loadfun"}}]'.format(trans.pdb)
        # sharable page
        try:
            make_static_page(request, snippet_run, page)
        except Exception as err:
            page=''
            minor_error='Could not generate sharable static page ({0})'.format(err)
        # return

        if minor_error:
            return {'snippet': code, 'error': 'warning', 'error_msg':minor_error, 'error_title':'A minor error arose','validation':trans.validation_text, 'page': page, **settings}
        else:
            return {'snippet': code, 'snippet_run':snippet_run,'validation':trans.validation_text, 'page': page, **settings}

    except:
        print('**************')
        print(traceback.format_exc())
        return {'snippet': traceback.format_exc(), 'snippet_run':'','error_title':'A major error arose', 'error': 'danger','error_msg':'The code failed to run serverside','validation':''}

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


@view_config(route_name='edit_user-page', renderer='json')
def edit(request):
    print(request.POST)
    make_static_page(request, request.POST['code'], request.POST['page'], request.POST['description'], request.POST['title'], request.POST['residues'])
    return {'success': 1}



##################### dependent methods
def make_static_page(request, code, page, description='Editable text. press pen to edit.',title='User submitted structure',residues=''):
    open(os.path.join('pymol_ngl_transpiler_app','user', page+'.html'), 'w', newline='\n').write(
        mako.template.Template(filename=os.path.join('pymol_ngl_transpiler_app','templates','user_protein.mako'),
                               format_exceptions=True,
                               lookup=mako.lookup.TemplateLookup(directories=[os.getcwd()])
        ).render_unicode(code=code, request=request, description=description, title=title, residues=residues))
