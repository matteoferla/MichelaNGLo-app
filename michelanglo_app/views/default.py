from pyramid.view import view_config, notfound_view_config
from pyramid.renderers import render_to_response
import os
from ._common_methods import get_username



### make folder if exists.
if os.path.isdir(os.path.join('michelanglo_app','temp')):
    for file in os.listdir(os.path.join('michelanglo_app','temp')):
        os.remove(os.path.join('michelanglo_app','temp',file))
else:
    os.mkdir(os.path.join('michelanglo_app','temp'))

import logging
log = logging.getLogger(__name__)

@notfound_view_config(renderer="../templates/404.mako")
@view_config(route_name='admin', renderer='../templates/admin.mako', http_cache=0)
@view_config(route_name='gallery', renderer="../templates/gallery.mako")
@view_config(route_name='custom', renderer="../templates/custom.mako")
@view_config(route_name='home', renderer="../templates/welcome.mako")
@view_config(route_name='home_text', renderer="../templates/welcome_text.mako")
@view_config(route_name='pymol', renderer="../templates/pymol_converter.mako")
@view_config(route_name='main_docs', renderer="../templates/docs.mako")
@view_config(route_name='docs', renderer="../templates/docs.mako")
@view_config(route_name='pdb', renderer="../templates/pdb_converter.mako")
def my_view(request):
    user = request.user
    # ?bootstrap=materials is basically for the userdata_view only.
    if 'bootstrap' in request.params:
        bootstrap = request.params['bootstrap']
    else:
        bootstrap = 4
    # some special parts...
    if request.matched_route is None:
        log.warn(f'Could not match {request.url} for {get_username(request)}')
        page = '404'
        # up the log status if its illegal
    elif request.matched_route.name == 'admin' and (not user or (user and user.role != 'admin')):
        log.warn(f'Non admin user ({get_username(request)}) attempted to view admin page')
        page = request.matched_route.name
    else:
        log.info(f'page {request.matched_route.name} ({request.matchdict}) for {get_username(request)}')
        page = request.matched_route.name

    # done
    # main clash imagetoggle markup request.matchdict['id']
    reply = {'project': 'Michalanglo',
                'user': user,
                'bootstrap': bootstrap,
                'current_page': page,
                'meta_title': 'Michelaɴɢʟo: sculpting protein views on webpages without coding.',
                'meta_description': 'Convert PyMOL files, upload PDB files or submit PDB codes and '+\
                                    'create a webpage to edit, share or implement standalone on your site',
                'meta_image': '/static/tim_barrel.png',
                'meta_url': 'https://michelanglo.sgc.ox.ac.uk/'
            }
    if page != 'docs':
        return reply
    else:
        if request.matchdict['id'] == 'clash':
            return render_to_response("../templates/docs/clash.mako", reply, request)
        elif request.matchdict['id'] == 'markup':
            return render_to_response("../templates/docs/markup.mako", reply, request)
        elif request.matchdict['id'] == 'implementations':
            return render_to_response("../templates/docs/implementations.mako", reply, request)
        elif request.matchdict['id'] == 'imagetoggle' or request.matchdict['id'] == 'image':
            return render_to_response("../templates/docs/image.mako", reply, request)
        elif request.matchdict['id'] == 'api':
            return render_to_response("../templates/docs/api.mako", reply, request)
        elif request.matchdict['id'] == 'users' or request.matchdict['id'] == 'pages':
            return render_to_response("../templates/docs/users_n_pages.mako", reply, request)
        else:
            return reply

@view_config(route_name='status', renderer='json')
def status_view(request):
    return {'status': 'OK'}
