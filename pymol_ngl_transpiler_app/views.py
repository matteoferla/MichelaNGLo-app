from pyramid.view import view_config
import traceback
from PyMOL_to_NGL import PyMolTranspiler
import uuid
import shutil
import os
import mako
from pyramid.response import FileResponse

print(os.getcwd())
if os.path.isdir(os.path.join('pymol_ngl_transpiler_app','temp')):
    for file in os.listdir(os.path.join('pymol_ngl_transpiler_app','temp')):
        os.remove(os.path.join('pymol_ngl_transpiler_app','temp',file))
else:
    os.mkdir(os.path.join('pymol_ngl_transpiler_app','temp'))


@view_config(route_name='home', renderer="templates/main.mako")
def my_view(request):
    return {'project': 'PyMOL_NGL_transpiler_app'}

@view_config(route_name='ajax_convert', renderer="templates/result.mako")
def ajax_convert(request):
    try:
        minor_error=''
        ## assertions
        if not 'pdb_string' in request.POST and not request.POST['pdb']:
            return {'error': 'danger', 'error_title': 'No PDB code', 'error_msg': 'A PDB code is required to make the NGL viewer show a protein.','snippet':'','validation':''}
        elif request.POST['mode'] == 'out' and not request.POST['pymol_output']:
            return {'error': 'danger', 'error_title': 'No PyMOL code', 'error_msg': 'PyMOL code is required to make the NGL viewer show a protein.','snippet':'','validation':''}
        elif request.POST['mode'] == 'file' and not request.POST['file'].filename:
            return {'error': 'danger', 'error_title': 'No PSE file', 'error_msg': 'A PyMOL file to make the NGL viewer show a protein.','snippet':'','validation':''}

        ## convert booleans and settings
        def is_js_true(value): # booleans get converted into strings in json.
            if not value or value == 'false':
                return False
            else:
                return True

        settings = {'tabbed': int(request.POST['indent']),
                    'viewport': request.POST['viewport_id'],
                    'image': is_js_true(request.POST['image']),
                    'uniform_non_carbon':is_js_true(request.POST['uniform_non_carbon']),
                    'verbose': False,
                    'validation': False,
                    'stick': request.POST['stick']}

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
        elif request.POST['mode'] == 'file':
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
        snippet_run=trans.mako_js(**{**settings, 'image': False})
        # sharable page
        try:
            make_static_page(request, snippet_run, page)
        except Exception as err:
            page=''
            minor_error='Could not generate sharable static page ({0})'.format(err)
        # return
        if minor_error:
            return {'snippet': code, 'error': 'warning', 'error_msg':minor_error, 'error_title':'A minor error arose','validation':trans.validation_text, 'viewport':settings['viewport'], 'page': page}
        else:
            return {'snippet': code, 'snippet_run':snippet_run,'validation':trans.validation_text, 'viewport':settings['viewport'], 'page': page}

    except:
        print(traceback.format_exc())
        return {'snippet': traceback.format_exc(), 'snippet_run':'','error_title':'A major error arose', 'error': 'danger','error_msg':'The code failed to run serverside','validation':'', 'viewport':settings['viewport']}


def make_static_page(request, code, page, description='Editable text. press pen to edit.',title='User submitted structure'):
    open(os.path.join('pymol_ngl_transpiler_app','user', page+'.html'), 'w', newline='\n').write(
        mako.template.Template(filename=os.path.join('pymol_ngl_transpiler_app','templates','user_protein.mako'),
                               format_exceptions=True,
                               lookup=mako.lookup.TemplateLookup(directories=[os.getcwd()])
        ).render_unicode(code=code, request=request, description=description, title=title))


@view_config(route_name='edit_user-page', renderer='json')
def edit(request):
    print(request.POST)
    make_static_page(request, request.POST['code'], request.POST['page'], request.POST['description'], request.POST['title'])
    return {'success': 1}

@view_config(route_name='save_pdb')
def save_pdb(request):
    filename=request.session['file']
    raise NotImplementedError
    return FileResponse(filename, content_disposition='attachment; filename="{}"'.format(request.POST['name']))

@view_config(route_name='save_zip')
def save_zip(request):
    raise NotImplementedError
