######### sentry.io logging


import sentry_sdk, os
from sentry_sdk.integrations.pyramid import PyramidIntegration

if 'SENTRY_DNS_MICHELANGLO' in os.environ:
    #this is not in the config file due to security as this github repo is public.
    sentry_sdk.init(
     dsn=os.environ['SENTRY_DNS_MICHELANGLO'],
     integrations=[PyramidIntegration()]
    )

from pyramid.config import Configurator
from pyramid.session import SignedCookieSessionFactory

def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    config = Configurator(settings=settings)
    my_session_factory = SignedCookieSessionFactory('TIM barrels') ##temporary data
    config.set_session_factory(my_session_factory)
    config.include('.models')
    config.include('pyramid_mako')
    config.include('.routes')
    config.include('.security')
    config.include('.scheduler')
    config.scan()
    return config.make_wsgi_app()
