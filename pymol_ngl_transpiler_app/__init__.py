from pyramid.config import Configurator
from pyramid.session import SignedCookieSessionFactory


def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    config = Configurator(settings=settings)
    my_session_factory = SignedCookieSessionFactory('TIM barrels')
    config.set_session_factory(my_session_factory)
    config.include('.models')
    config.include('pyramid_mako')
    config.include('.routes')
    config.include('.security')
    config.scan()
    return config.make_wsgi_app()
