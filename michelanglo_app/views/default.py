from pyramid.view import view_config, notfound_view_config
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
@view_config(route_name='markup', renderer="../templates/markup.mako")
@view_config(route_name='admin', renderer='../templates/admin.mako', http_cache=0)
@view_config(route_name='gallery', renderer="../templates/gallery.mako")
@view_config(route_name='clash', renderer="../templates/clash.mako")
@view_config(route_name='custom', renderer="../templates/custom.mako")
@view_config(route_name='home', renderer="../templates/welcome.mako")
@view_config(route_name='pymol', renderer="../templates/pymol_converter.mako")
@view_config(route_name='docs', renderer="../templates/docs.mako")
@view_config(route_name='sandbox', renderer="../templates/sandbox.mako")
@view_config(route_name='imagetoggle', renderer="../templates/image.mako")
@view_config(route_name='pdb', renderer="../templates/pdb_converter.mako")
def my_view(request):
    user = request.user
    if request.matched_route is None:
        log.warn(f'Could not match {request.url} for {get_username(request)}')
        page = '404'
        # up the log status if its illegal
    elif request.matched_route.name == 'admin' and (not user or (user and user.role != 'admin')):
        log.warn(f'Non admin user ({get_username(request)}) attempted to view admin page')
        page = request.matched_route.name
    else:
        log.info(f'page {request.matched_route.name} for {get_username(request)}')
        page = request.matched_route.name
    # ?bootstrap=materials is basically for the userdata_view only.
    if 'bootstrap' in request.params:
        bootstrap = request.params['bootstrap']
    else:
        bootstrap = 4
    # done
    return {'project': 'Michalanglo',
            'user': user,
            'bootstrap': bootstrap,
            'current_page': page}


@view_config(route_name='status', renderer='json')
def status_view(request):
    return {'status': 'OK'}
