from pyramid.view import view_config, notfound_view_config, view_defaults
from pyramid.renderers import render_to_response
from pyramid.response import FileResponse
import os, json, time
from ..models import User, Page
from . import custom_messages, valid_extensions

from .buffer import system_storage

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



@view_defaults(route_name='home')
class DefaultViews:
    def __init__(self, request):
        self.request = request
        self.user = request.user
        self.page = self.get_page()
        self.reply = {'project': 'Michalanglo',
                'user': self.user,
                'bootstrap': self.bootstrap,
                'current_page': self.page,
                'custom_messages': json.dumps(custom_messages),   # global
                'meta_title': 'Michelaɴɢʟo: sculpting protein views on webpages without coding.',
                'meta_description': 'Convert PyMOL files, upload PDB files or submit PDB codes and '+\
                                    'create a webpage to edit, share or implement standalone on your site',
                'meta_image': '/static/tim_barrel.png',
                'meta_url': 'https://michelanglo.sgc.ox.ac.uk/',
                'valid_extensions': valid_extensions   # global
            }

    @property
    def bootstrap(self):
        # ?bootstrap=materials is basically for the userdata_view only.
        if 'bootstrap' in self.request.params:
            return self.request.params['bootstrap']
        else:
            return 4

    def get_page(self) -> str:
        if self.request.matched_route is None:
            return '404'
        else:
            matched = "(" + self.request.matchdict["id"] + ")" if self.request.matchdict and "id" in self.request.matchdict else ""
            log.info(f'page {self.request.matched_route.name} {matched} for {User.get_username(self.request)}')
            return self.request.matched_route.name

    @view_config(route_name='home', renderer="../templates/welcome.mako")
    @view_config(route_name='michelanglo', renderer="../templates/welcome.mako")
    @view_config(route_name='home_gimmicky', renderer="../templates/welcome_gimmicky.mako")
    @view_config(route_name='custom', renderer="../templates/custom.mako")
    @view_config(route_name='home_text', renderer="../templates/welcome_text.mako")
    @view_config(route_name='pymol', renderer="../templates/pymol_converter.mako")
    @view_config(route_name='pdb', renderer="../templates/pdb_converter.mako")
    @view_config(route_name='name', renderer="../templates/name.mako")
    def main(self):
        return self.reply

    @view_config(route_name='docs', renderer="../templates/docs.mako")
    @view_config(route_name='main_docs', renderer="../templates/docs.mako")
    def docs(self):
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
        if 'id' in self.request.matchdict and self.request.matchdict['id'] in template.keys():
            rid = self.request.matchdict['id']
            return render_to_response(f"../templates/docs/{template[rid]}.mako", self.reply, self.request)
        else:  # renderer="../templates/docs.mako" default
            return self.reply

    @view_config(route_name='gallery', renderer="../templates/gallery.mako")
    def gallery(self):
        self.reply['pages'] = self.request.dbsession.query(Page) \
                                    .filter(Page.privacy != 'private') \
                                    .filter(Page.existant == True) \
                                    .all()
        self.reply['sottotitolo'] = 'Here are links to created pages flagged as public'
        return self.reply

    @view_config(route_name='personal', renderer="../templates/gallery.mako")
    def personal(self):
        if self.user:
            self.reply['pages'] = self.user.owned.select(self.request.dbsession)
            self.reply['sottotitolo'] = 'Here are links to pages edited by you'
        else:
            return render_to_response("../templates/registration_virtues.mako", self.reply, self.request)
        return self.reply

    @view_config(route_name='admin', renderer='../templates/admin.mako', http_cache=0)
    def admin(self):
        if not self.user or (self.user and self.user.role != 'admin'):
            log.warning(f'Non admin user ({User.get_username(self.request)}) attempted to view admin page')
            self.request.response.status = 401
            return self.reply
        else:
            self.reply['users'] = self.request.dbsession.query(User).all()
            return self.reply

    @view_config(route_name='status', renderer='json')
    def status_view(self):
        return {'status': 'OK'}

    @view_config(route_name="favicon", renderer="json")  # why is static method not working is werid.
    def favicon_view(self):
        icon = os.path.join("michelanglo_app", "static", "favicon.ico")
        return FileResponse(icon, request=self.request)

    @view_config(route_name="robots", renderer='string')
    def robots(self):
        """
        All robots welcome. Hacker bots get blocked with 40x status delay and fail2ban.
        """
        return 'User-Agent: *\nDisallow:\nAllow: /'

# -------
# this view does not work in DefaultViews
from pyramid.exceptions import URLDecodeError
from pyramid.view import exception_view_config

from pyramid.request import Request

@exception_view_config(context=URLDecodeError, renderer='json')
def attack(context, request):
    request.response.status = 418
    request.environ['PATH_INFO'] = 'HACKING-ATTEMPT'
    time.sleep(0.5)
    return {'status': 404}

@notfound_view_config(renderer="../templates/404.mako")
def fourzerofour(request):
    username = User.get_username(request)
    log.warning(f'Could not match {request.url} for {username}')
    request.response.status = 404
    # delay response by 500 ms.
    time.sleep(0.5)
    # no need to co-opt the buffer:
    # if f'404-{username}' in system_storage:
    #     system_storage[f'404-{username}'] += 1
    #     time.sleep(system_storage[f'404-{username}'])  # wait a second or more to reply.
    # else:
    #     system_storage[f'404-{username}'] = 0
    return DefaultViews(request).reply