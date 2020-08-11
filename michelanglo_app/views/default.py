from pyramid.view import view_config, notfound_view_config
from pyramid.renderers import render_to_response
from pyramid.response import FileResponse
import os, json
from ..models import User, Page
from . import custom_messages, valid_extensions

import logging
log = logging.getLogger(__name__)

### make folder if exists... MAKE SURE IT IS EXCLUDED FROM GIT!
for folder in ('user-data', 'user-data-thumb', 'user-data-monitor'):
    if not os.path.isdir(os.path.join('michelanglo_app',folder)):
        os.mkdir(os.path.join('michelanglo_app', folder))
if os.path.isdir(os.path.join('michelanglo_app','temp')):
    for file in os.listdir(os.path.join('michelanglo_app','temp')):
        os.remove(os.path.join('michelanglo_app','temp',file))
else:
    os.mkdir(os.path.join('michelanglo_app','temp'))

########################################################################
########################################################################

@notfound_view_config(renderer="../templates/404.mako")
@view_config(route_name='admin', renderer='../templates/admin.mako', http_cache=0)
@view_config(route_name='gallery', renderer="../templates/gallery.mako")
@view_config(route_name='personal', renderer="../templates/gallery.mako")
@view_config(route_name='custom', renderer="../templates/custom.mako")
@view_config(route_name='home', renderer="../templates/welcome.mako")
@view_config(route_name='home_gimmicky', renderer="../templates/welcome_gimmicky.mako")
@view_config(route_name='home_text', renderer="../templates/welcome_text.mako")
@view_config(route_name='pymol', renderer="../templates/pymol_converter.mako")
@view_config(route_name='main_docs', renderer="../templates/docs.mako")
@view_config(route_name='docs', renderer="../templates/docs.mako")
@view_config(route_name='pdb', renderer="../templates/pdb_converter.mako")
@view_config(route_name='name', renderer="../templates/name.mako")
def my_view(request):
    user = request.user
    # ?bootstrap=materials is basically for the userdata_view only.
    if 'bootstrap' in request.params:
        bootstrap = request.params['bootstrap']
    else:
        bootstrap = 4
    # some special parts...
    if request.matched_route is None:
        log.warning(f'Could not match {request.url} for {User.get_username(request)}')
        page = '404'
        request.response.status = 404
        # up the log status if its illegal
    elif request.matched_route.name == 'admin' and (not user or (user and user.role != 'admin')):
        log.warning(f'Non admin user ({User.get_username(request)}) attempted to view admin page')
        page = request.matched_route.name
        request.response.status = 401
    else:
        log.info(f'page {request.matched_route.name} {"("+request.matchdict["id"]+")" if request.matchdict and "id" in request.matchdict else ""} for {User.get_username(request)}')
        page = request.matched_route.name
    ## reply is stuff that fills the mako template.
    reply = {'project': 'Michalanglo',
                'user': user,
                'bootstrap': bootstrap,
                'current_page': page,
                'custom_messages': json.dumps(custom_messages),
                'meta_title': 'Michelaɴɢʟo: sculpting protein views on webpages without coding.',
                'meta_description': 'Convert PyMOL files, upload PDB files or submit PDB codes and '+\
                                    'create a webpage to edit, share or implement standalone on your site',
                'meta_image': '/static/tim_barrel.png',
                'meta_url': 'https://michelanglo.sgc.ox.ac.uk/',
                'valid_extensions': valid_extensions
            }
    if page == 'docs':
        return route_docs(request, reply)
    elif page == 'gallery':
        reply['pages'] = request.dbsession.query(Page)\
                                                    .filter(Page.privacy != 'private')\
                                                    .filter(Page.existant == True)\
                                                    .all()
        reply['sottotitolo'] = 'Here are links to created pages flagged as public'
        return reply
    elif page == 'personal':
        if user:
            reply['pages'] = user.owned.select(request.dbsession)
            reply['sottotitolo'] = 'Here are links to pages edited by you'
        else:
            return render_to_response("../templates/registration_virtues.mako", reply, request)
        return reply
    elif page == 'admin':
        reply['users'] = request.dbsession.query(User).all()
        return reply
    else:
        return reply




def route_docs(request, reply):

    template = {'clash': 'clash',
                'markup': 'markup',
                'implementations': 'implementations',
                'image': 'image',
                'imagetoggle': 'image',
                'gene': 'gene',
                'api': 'api',
                'cite': 'cite',
                'pages': 'users_n_pages',
                'users': 'users_n_pages',
                'venus': 'venus',
                'venus_energetics': 'venus_energetics',
                'venus_model': 'venus_model',
                'venus_urls': 'venus_urls',
                'video': 'video',
                'github': 'github'
                }

    if request.matchdict['id'] in template.keys():
        rid = request.matchdict['id']
        return render_to_response(f"../templates/docs/{template[rid]}.mako", reply, request)
    else: # renderer="../templates/docs.mako" default
        return reply

########################################################################

@view_config(route_name='status', renderer='json')
def status_view(request):
    return {'status': 'OK'}


@view_config(route_name="favicon") #why is static method not working is werid.
def favicon_view(request):
    icon = os.path.join("michelanglo_app", "static", "favicon.ico")
    return FileResponse(icon, request=request)

@view_config(route_name="robots", renderer='string')
def robots(request):
    return 'User-Agent: *\nDisallow:\nAllow: /'
