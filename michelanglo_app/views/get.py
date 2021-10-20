from pyramid.view import view_config
from pyramid.renderers import render_to_response
from ..models import Page, User, Doi, Publication
import os

import logging
log = logging.getLogger(__name__)
from .common_methods import is_malformed, Comms
from ..scheduler import Entasker

from . import custom_messages, votes

#### note that a few non-setting get json funs are actually hiding in name.py.
@view_config(route_name='get')
def get_ajax(request):
    malformed = is_malformed(request, 'item')
    if malformed:
        return {'status': malformed}

    def log_it():
        log.warn(f'{User.get_username(request)} was refused {request.params["item"]}, code: {request.response.status}')

    user = request.user
    modals = {'register': "../templates/login/register_modalcont.mako",
            'login': "../templates/login/login_modalcont.mako",
            'forgot': "../templates/login/forgot_modalcont.mako",
            'logout': "../templates/login/logout_modalcont.mako",
            'password': "../templates/login/password_modalcont.mako"}
    ###### get the user page list.
    if request.params['item'] == 'pages':
        if not user:
            request.response.status = 401
            log_it()
            return render_to_response("../templates/part_error.mako", {'error': '401'}, request)
        elif user.role == 'admin':
            target = request.dbsession.query(User).filter_by(name=request.POST['username']).one()
            return render_to_response("../templates/login/pages.mako", {'user': target}, request)
        elif request.POST['username'] == user.name:
            return render_to_response("../templates/login/pages.mako", {'user': request.user}, request)
        else:
            request.response.status = 403
            log_it()
            return render_to_response("../templates/part_error.mako", {'error': '403'}, request)
    ####### get the modals
    elif request.params['item'] in  modals.keys():
        return render_to_response(modals[request.params['item']], { 'user': request.user}, request)
    ####### get the implementation code.
    elif request.params['item'] == 'implement':
        ## should non editors be able to see this? I assume that if they get the page uuid right they should.
        page = Page.select(request.dbsession, request.params['page'])
        if not page:
            return render_to_response("../templates/part_error.mako", {'error': '404'}, request)
        elif not page.existant:
            return render_to_response("../templates/part_error.mako", {'error': '410'}, request)
        elif page.encrypted and 'encryption_key' not in request.params:
            return render_to_response("../templates/part_error.mako", {'error': '403'}, request)
        elif page.encrypted and 'encryption_key' in request.params:
            page.key = request.params['encryption_key']
        else:
            pass #
        settings = page.load().settings
        return render_to_response("../templates/results/implement.mako", settings, request)
    elif request.params['item'] == 'swissmodel':
        url = request.params['url']
        if url.find('https://swissmodel.expasy.org/') != 0:
            request.response.status = 403
            return {'status': 'Not a swissmodel url'}
        else:
            return request.get(url).text()
    else:
        request.response.status = 400
        log_it()
        return render_to_response("../templates/part_error.mako", {'error': '400'}, request)

@view_config(route_name='get_pages', renderer='json')
def get_pages(request):
    """
    Get pages for API purposes
    :param request:
    :return:
    """
    user = request.user
    log.info(f'{User.get_username(request)} request API view of pages')
    data = {}
    to_list = lambda x: [p.identifier for p in x]  ## crap name. converts the objects to names only.
    pages_folder = os.path.join(request.registry.settings['michelanglo.user_data_folder'], 'pages')
    data['public'] = to_list(request.dbsession.query(Page).filter(Page.privacy != 'private').all())
    data['all'] = 'RESTRICTED'
    if not user:
        data['owned'] = 'not logged in'
        data['visited'] = 'not logged in'
        data['error'] = 'not logged in'
        return data
    data['owned'] = to_list(user.owned.select(request.dbsession))
    data['visited'] = to_list(user.visited.select(request.dbsession))
    if user.role == 'admin':   ### ULTRABACK DOOR.
        data['all'] = {'unencrypted_files': [p.replace('.p','') for p in os.listdir(pages_folder) if os.path.splitext(p)[1] == '.p'],
                       'encrypted_files': [p.replace('.ep','') for p in os.listdir(pages_folder) if os.path.splitext(p)[1] == '.ep'],
                       'unencrypted_entries': [p.identifier for p in request.dbsession.query(Page) if p.existant and not p.encrypted],
                       'encrypted_entries': [p.identifier for p in request.dbsession.query(Page) if p.existant and p.encrypted],
                       'deleted_entries': [p.identifier for p in request.dbsession.query(Page) if not p.existant]}
    return data

@view_config(route_name='set', renderer='json')
def set_ajax(request):
    """
    Admin only operations. In future this may change to ``admin`` (TODO)

    :param request: must contain 'item' key.

    * item = msg. set a message based on the value of the keys 'title','descr','bg'
    * item = clear_msg. clear msg
    * item = terminate. kills the mother thread. requires the key 'code' containing the same value as the env variable SECRETCODE
    * item = protection. protects page 'page'
    * item = deprotection. guess what this does...
    * item = shorten. 'short' 'long' results in setting up /r/short redirect to /data/long

    :return: json ('status' as one key)
    """
    # Case: not Admin
    if not request.user or request.user.role != 'admin':
        request.response.status = 403
        log.warning(f'{User.get_username(request)} was refused setting.')
        return {'status': 'forbidden'}
    # Case: malformed
    malformed = is_malformed(request, 'item')
    if malformed:
        return {'status': malformed}
    if request.params['item'] == 'msg':
        malformed = is_malformed(request, 'title','descr','bg')
        if malformed:
            return {'status': malformed}
        custom_messages.append({el: request.params[el] for el in ('title','descr','bg')})
        log.info(f'{User.get_username(request)} set a new custom message.')
        return {'status': 'success'}
    elif request.params['item'] == 'clear_msg':
        log.info(f'{User.get_username(request)} cleared custom messages.')
        while custom_messages:
            custom_messages.pop()
        return {'status': 'success'}
    elif request.params['item'] == 'terminate':
        if 'code' in request.params and request.params['code'] == os.environ['SECRETCODE']:
            log.warning(f'{User.get_username(request)} terminated the app')
            Comms.notify_admin(f'{User.get_username(request)} terminated the app')
            # is this the most graceful way of kill itself?
            # raise SystemExit does the same, but raises an error.
            # ToDo find out how to wait until there are no task!
            os.system('kill `lsof -t -i:8088`')
        else:
            log.warning(f'{User.get_username(request)} tried to terminate the app')
            Comms.notify_admin(f'{User.get_username(request)} tried to terminate the app')
            return {'status': 'wrong secret code.'}
    elif request.params['item'] == 'protection':
        pagename = request.params['page']
        log.info(f'{User.get_username(request)} changed the monitoring of page {pagename}.')
        page = Page.select(request.dbsession, pagename)
        if not page.protected: # protected pages are minotored
            # anticipate scheduler
            michelanglo_app_folder = os.path.split(os.path.split(__file__)[0])[0]
            cmd = ' '.join([f'USER_DATA={request.registry.settings["michelanglo.user_data_folder"]}',
                            'PORT=8088',
                            f'PUPPETEER_CHROME={request.registry.settings["puppeteer.executablePath"]}',
                            f'node {michelanglo_app_folder}/monitor.js {page.identifier}'])
            if os.system(cmd):
                return {'status': 'protection failed. Contact Admin'}
        page.protected = True
        return {'status': 'protected successfully'}
    elif request.params['item'] == 'deprotection':
        pagename = request.params['page']
        log.info(f'{User.get_username(request)} changed the monitoring of page {pagename}.')
        page = Page.select(request.dbsession, pagename)
        page.protected = False
        monitor_folder = os.path.join(request.registry.settings["michelanglo.user_data_folder"], 'monitor')
        for file in os.listdir(monitor_folder):
            if file.find(pagename) == 0:
                os.remove(os.path.join(monitor_folder, file))
        return {'status': 'deprotected successfully'}
    elif request.params['item'] == 'shorten':
        malformed = is_malformed(request, 'long', 'short')
        if malformed:
            return {'status': malformed}
        longname = request.params['long']
        shortname = request.params['short']
        long = Page.select(request.dbsession, longname)
        if request.dbsession.query(Doi).filter(Doi.short == shortname).first() is not None:
            return {'status': f'{shortname} taken already.'}
        redirect = Doi(long=longname, short=shortname)
        request.dbsession.add(redirect)
        log.info(f'{User.get_username(request)} made shorter page {longname} as {shortname}.')
        return {'status': 'success', 'long': longname, 'short': shortname}
    elif request.params['item'] == 'publication':
        malformed = is_malformed(request, 'identifier', 'url')
        # options include ('identifier', 'url', 'authors', 'year', 'title', 'journal', 'issue')
        if malformed:
            return {'status': malformed}
        publication = Publication.from_request(request)
    elif request.params['item'] == 'task':
        malformed = is_malformed(request, 'task')
        if malformed:
            return {'status': malformed}
        taskname = request.params['task']
        try:
            Entasker.run(taskname)
            log.info(f'Admin directed task {taskname} completed.')
            return {'status': 'success'}
        except Exception as error:
            log.warning(f'Admin directed task {taskname} failed - {error.__class__.__name__}: {error}')
            return {'status': 'error', 'msg': f'{error.__class__.__name__}: {error}'}
    else:
        return {'status': 'unknown cmd'}



@view_config(route_name='vote', renderer='json')
def vote(request):
    malformed = is_malformed(request, 'topic', 'direction')
    if malformed:
        return {'status': malformed}
    topic = request.params['topic'][:100]
    direction = request.params['direction']
    if not isinstance(topic, str) or direction not in ('up', 'down'):
        return {'status': 'behave.'}
    votes[topic][direction] += 1
    return {'status': 'Thanks for the feedback'}



