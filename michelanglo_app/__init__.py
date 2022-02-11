######### sentry.io logging


import os
from _collections import OrderedDict
from collections import deque, defaultdict
from .data_folder_setup import setup_folders, setup_comms
from .env_override import override_environmentally, environmental2config
from pyramid.config import Configurator
from pyramid.session import SignedCookieSessionFactory
from pyramid.router import Router

# from .sentry import setup_sentry
# Sentry used to be free for academic/open source stuff... but no longer.
# however Slack messages work well enough.


def main(global_config: OrderedDict, **settings) -> Router:
    """ This function returns a Pyramid WSGI application.
    """
    override_environmentally(settings)
    settings['caught_errors'] = deque([], maxlen=10)  # list of dict username, time error routename
    settings['votes'] = defaultdict(lambda: {'up': 0, 'down': 0})
    #setup_sentry(settings['sentry.data_source_name'])
    setup_folders(user_data_folder=settings['michelanglo.user_data_folder'],
                  protein_data_folder=settings['michelanglo.protein_data_folder'])
    config = Configurator(settings=settings)
    my_session_factory = SignedCookieSessionFactory(settings['auth.secret'])
    config.set_session_factory(my_session_factory)
    config.include('.models')
    config.include('pyramid_mako')
    config.include('.routes')
    config.include('.security')
    config.include('.scheduler')
    config.scan()
    # not sure if these have to be to run this after routes:
    setup_comms(slack_webhook=settings['slack.webhook'],
                server_email=settings['michelanglo.server_email'],
                admin_email=settings['michelanglo.admin_email'])
    return config.make_wsgi_app()

##################################
# import signal
#
# def sig_handler(signum, frame):
#     print("segfault caught")
#
# signal.signal(signal.SIGSEGV, sig_handler)
