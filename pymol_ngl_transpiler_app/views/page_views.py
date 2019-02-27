from pyramid.view import view_config, notfound_view_config
from pyramid.renderers import render_to_response
import os
from pyramid.response import FileResponse
password='protein'

if os.path.isdir(os.path.join('pymol_ngl_transpiler_app','temp')):
    for file in os.listdir(os.path.join('pymol_ngl_transpiler_app','temp')):
        os.remove(os.path.join('pymol_ngl_transpiler_app','temp',file))
else:
    os.mkdir(os.path.join('pymol_ngl_transpiler_app','temp'))

@notfound_view_config(renderer="../templates/404.mako")
@view_config(route_name='clash', renderer="../templates/clash.mako")
@view_config(route_name='custom', renderer="../templates/custom.mako")
@view_config(route_name='home', renderer="../templates/main.mako")
@view_config(route_name='docs', renderer="../templates/docs.mako")
@view_config(route_name='sandbox', renderer="../templates/sandbox.mako")
def my_view(request):
    return {'project': 'PyMOL_NGL_transpiler_app'}


@view_config(route_name='markup', renderer="../templates/markup.mako")
def markup_view(request):
    settings = {'project': 'PyMOL_NGL_transpiler_app'} #useless for now.
    if request.GET and 'version' in request.GET and request.GET['version'] == 'old':
        return render_to_response("../templates/markup_old.mako",settings, request)
    return settings

@view_config(route_name='save_pdb')
def save_pdb(request):
    filename=request.session['file']
    raise NotImplementedError
    return FileResponse(filename, content_disposition='attachment; filename="{}"'.format(request.POST['name']))

@view_config(route_name='save_zip')
def save_zip(request):
    raise NotImplementedError


@view_config(route_name='admin', renderer='../templates/private.mako', http_cache=0)
def admin_callable(request):
    status='This area is not for users. Sorry.'
    if 'admin' in request.session and request.session['admin']:
        admin=True
    else:
        admin=False
    if 'password' in request.POST:
        if request.POST['password'] == password:
            print('Granted')
            request.session['admin'] = True
            admin=True
            status = 'The password is right. How did you get this message?'
        else:
            print('wrong...{}'.format(request.POST['password']))
            admin = False
            status='禁 Warning: Password wrong!'
    else:
        status=''
    if admin:
        return {'admin': True, 'status': ''}
    else:
        return {'admin': False, 'status': status}
