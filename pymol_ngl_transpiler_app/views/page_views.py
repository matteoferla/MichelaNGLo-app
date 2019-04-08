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
@view_config(route_name='markup', renderer="../templates/markup.mako")
@view_config(route_name='admin', renderer='../templates/admin.mako', http_cache=0)
@view_config(route_name='gallery', renderer="../templates/gallery.mako")
@view_config(route_name='clash', renderer="../templates/clash.mako")
@view_config(route_name='custom', renderer="../templates/custom.mako")
@view_config(route_name='home', renderer="../templates/welcome.mako")
@view_config(route_name='pymol', renderer="../templates/main.mako")
@view_config(route_name='docs', renderer="../templates/docs.mako")
@view_config(route_name='sandbox', renderer="../templates/sandbox.mako")
@view_config(route_name='imagetoggle', renderer="../templates/image.mako")
@view_config(route_name='pdb', renderer="../templates/pdb.mako")
def my_view(request):
    user = request.user
    # ?bootstrap=materials is basically for the userdata_view only.
    if 'bootstrap' in request.params:
        bootstrap = request.params['bootstrap']
    else:
        bootstrap = 4
    return {'project': 'Michalanglo',
            'user': user,
            'bootstrap': bootstrap}


from ..pages import Page

@view_config(route_name='userdata', renderer="../templates/user_protein.mako")
def userdata_view(request):

    def tickup_tries(): #try counter for encryption
        if 'tries' in request.session:
            request.session['tries'] = int(request.session['tries']) + 1
        else:
            request.session['tries'] = 0  ## first go

    pagename = request.matchdict['id']
    page = Page(pagename)
    ### deal with encryption
    if page.is_password_protected() and 'key' in request.params: # encrypted and key given
        page.key = request.params['key'].encode('utf-8')
        page.path = page.encrypted_path
        try:
            settings = page.load()
            settings['encryption'] = True
            settings['encryption_key'] = request.params['key']
        except ValueError: ##got it wrong
            tickup_tries()
            response_settings = {'project': 'Michelanglo', 'user': request.user, 'tries': request.session['tries'], 'page': pagename}
            return render_to_response("../templates/encrypted.mako", response_settings, request)
    elif page.is_password_protected() and 'key' not in request.params:  # encrypted and no key given
        tickup_tries()
        response_settings = {'project': 'Michelanglo', 'user': request.user, 'tries': request.session['tries'], 'page': pagename}
        return render_to_response("../templates/encrypted.mako", response_settings, request)
    else:
        settings = page.load()
        settings['encryption'] = False
    ### add new values
    settings['user'] = request.user
    user = request.user
    if user:
        if user.role == 'admin':
            settings['editable'] = True
        elif pagename in user.get_owned_pages():
            settings['editable'] = True
        elif pagename in user.get_visited_pages():
            settings['editable'] = False
        else:
            user.add_visited_page(pagename)
            request.dbsession.add(user)
            settings['visitors'].append(user.name)
            page.save()
            settings['editable'] = False
    else:
        settings['editable'] = False
    ### extras?
    if 'remote' in request.params:
        settings['remote'] = True
    if 'bootstrap' in request.params:
        settings['bootstrap'] = request.params['bootstrap']
    if 'no_user'  in request.params:
        settings['no_user'] = True
    else:
        settings['no_user'] = False
    if 'no_buttons' in request.params:
        settings['no_buttons'] = True
    else:
        settings['no_buttons'] = False
    settings['no_analytics'] = True
    if not 'columns_viewport' in settings:
        settings['columns_viewport'] = 9
        settings['columns_text'] = 3
    return settings




@view_config(route_name='save_pdb', renderer='string')
def save_pdb(request):
    page = Page(request.params['uuid'])
    if 'key' in request.params:
        page.key = request.params['key'].encode('utf-8')
    return page.load()['pdb']

@view_config(route_name='save_zip', renderer="string")
def save_zip(request):
    raise NotImplementedError
