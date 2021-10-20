######### sentry.io logging


import os
from _collections import OrderedDict

from .data_folder_setup import setup_folders
from .env_override import override_environmentally, environmental2config
from .sentry import setup_sentry
from pyramid.config import Configurator
from pyramid.session import SignedCookieSessionFactory
from pyramid.router import Router


def main(global_config: OrderedDict, **settings) -> Router:
    """ This function returns a Pyramid WSGI application.
    """
    override_environmentally(settings)
    setup_sentry(settings['sentry.data_source_name'])
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
    return config.make_wsgi_app()

##################################
# import signal
#
# def sig_handler(signum, frame):
#     print("segfault caught")
#
# signal.signal(signal.SIGSEGV, sig_handler)
