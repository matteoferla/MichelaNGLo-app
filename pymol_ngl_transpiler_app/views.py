from pyramid.view import view_config
import traceback
from PyMOL_to_NGL import PyMolTranspiler


@view_config(route_name='home', renderer="templates/main.mako")
def my_view(request):
    return {'project': 'PyMOL_NGL_transpiler_app'}

@view_config(route_name='ajax_convert', renderer="templates/result.mako")
def ajax_convert(request):
    try:
        minor_error=''
        ## assertions
        if not request.POST['pdb']:
            return {'error': 'danger', 'error_title': 'No PDB code', 'error_msg': 'A PDB code is required to make the NGL viewer show a protein.','snippet':'','validation':''}
        elif not request.POST['pymol_output']:
            return {'error': 'danger', 'error_title': 'No PyMOL code', 'error_msg': 'PyMOL code is required to make the NGL viewer show a protein.','snippet':'','validation':''}
        # convert booleans
        if not request.POST['uniform_non_carbon'] or request.POST['uniform_non_carbon'] == 'false':
            uniform_non_carbon=False
        else:
            uniform_non_carbon = True
        indent=int(request.POST['indent'])
        # make results
        trans = PyMolTranspiler(False,False)
        trans.pdb = request.POST['pdb']
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
        trans.convert_view(view)
        trans.convert_representation(reps)
        code = trans.get_html(ngl=request.POST['cdn'], uniform_non_carbon=uniform_non_carbon, tabbed=int(indent))
        if minor_error:
            return {'snippet': code, 'error': 'warning', 'error_msg':minor_error, 'error_title':'A minor error arose','validation':trans.validation_text}
        else:
            return {'snippet': code, 'snippet_run':trans.get_js(uniform_non_carbon=uniform_non_carbon), 'error': False,'validation':trans.validation_text}
    except:
        print(traceback.format_exc())
        return {'snippet': traceback.format_exc(), 'snippet_run':'','error_title':'A major error arose', 'error': 'danger','error_msg':'The code failed to run serverside','validation':''}



