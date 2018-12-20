from pyramid.view import view_config
import traceback
from PyMOL_to_NGL import PyMolTranspiler
import uuid
import shutil
import os
from pyramid.response import FileResponse

print(os.getcwd())
if os.path.join('pymol_ngl_transpiler_app','temp'):
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
        if not 'pdb_string' in request.params and not request.params['pdb']:
            return {'error': 'danger', 'error_title': 'No PDB code', 'error_msg': 'A PDB code is required to make the NGL viewer show a protein.','snippet':'','validation':''}
        elif request.params['mode'] == 'out' and not request.POST['pymol_output']:
            return {'error': 'danger', 'error_title': 'No PyMOL code', 'error_msg': 'PyMOL code is required to make the NGL viewer show a protein.','snippet':'','validation':''}
        elif request.params['mode'] == 'file' and not request.POST['file'].filename:
            return {'error': 'danger', 'error_title': 'No PSE file', 'error_msg': 'A PyMOL file to make the NGL viewer show a protein.','snippet':'','validation':''}
        # convert booleans
        if not request.POST['uniform_non_carbon'] or request.POST['uniform_non_carbon'] == 'false':
            uniform_non_carbon=False
        else:
            uniform_non_carbon = True
        indent=int(request.POST['indent'])
        # parse data
        if request.params['mode'] == 'out':
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
            trans = PyMolTranspiler(verbose=False, validation=False, view=view, representation=reps, pdb=request.POST['pdb'])
        elif request.params['mode'] == 'file':
            filename=os.path.join('pymol_ngl_transpiler_app', 'temp','{0}.pse'.format(uuid.uuid4()))
            request.POST['file'].file.seek(0)
            with open(filename, 'wb') as output_file:
                shutil.copyfileobj(request.POST['file'].file, output_file)
            trans = PyMolTranspiler(verbose=False, validation=False, file=filename)
            request.session['file'] = filename
            if 'pdb_string' in request.params:
                trans.raw_pdb = open(filename.replace('.pse','.pdb')).read()
            else:
                trans.pdb = request.POST['pdb']
        else:
            return {'snippet': 'Please stop trying to hack the server', 'snippet_run': '', 'error_title': 'A major error arose', 'error': 'danger', 'error_msg': 'The code failed to run serverside. Most likely malicius', 'validation': ''}
        # make output
        code = trans.get_html(ngl=request.POST['cdn'], uniform_non_carbon=uniform_non_carbon, tabbed=int(indent))
        if minor_error:
            return {'snippet': code, 'error': 'warning', 'error_msg':minor_error, 'error_title':'A minor error arose','validation':trans.validation_text}
        else:
            return {'snippet': code, 'snippet_run':trans.get_js(uniform_non_carbon=uniform_non_carbon), 'error': False,'validation':trans.validation_text}
    except:
        print(traceback.format_exc())
        return {'snippet': traceback.format_exc(), 'snippet_run':'','error_title':'A major error arose', 'error': 'danger','error_msg':'The code failed to run serverside','validation':''}

@view_config(route_name='save_pdb')
def save_pdb(request):
    filename=request.session['file']
    return FileResponse(filename,content_disposition='attachment; filename="{}"'.format(request.params['name']))

