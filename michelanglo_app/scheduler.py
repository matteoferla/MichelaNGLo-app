import os
from .models import Page
from sqlalchemy import engine_from_config
from sqlalchemy.orm import sessionmaker
from sqlalchemy.sql.expression import and_
import transaction
from apscheduler.schedulers.background import BackgroundScheduler
from .views._common_methods import notify_admin

from datetime import datetime,timedelta

import logging
log = logging.getLogger(__name__)


def includeme(config):
    #scheduler.days_delete_unedited = 30
    #scheduler.days_delete_untouched = 365
    settings = config.get_settings()
    scheduler = BackgroundScheduler()

    # adding settings to kill_task...
    killfactory = lambda: kill_task(settings['scheduler.days_delete_unedited'], settings['scheduler.days_delete_untouched'])
    scheduler.add_job(killfactory, 'interval', days=1)

    monitor_task()
    scheduler.add_job(monitor_task, 'interval', days=30)

    scheduler.start()

def get_session(): ## not request bound.
    engine = engine_from_config({'sqlalchemy.url': os.environ['SQL_URL'], 'sqlalchemy.echo': 'False'},
                                prefix='sqlalchemy.')
    Session = sessionmaker(bind=engine)
    return Session()

def spam_task(days_delete_unedited, days_delete_untouched):
    notify_admin(f'{days_delete_unedited} and {days_delete_untouched}')

def kill_task(days_delete_unedited, days_delete_untouched):
    sesh = get_session()
    with transaction.manager:
        unedited_time = datetime.now() - timedelta(days=int(days_delete_unedited))
        n = 0
        for page in sesh.query(Page).filter(and_(Page.exists is True, Page.edited is False, Page.timestamp < unedited_time)):
            log.info(f'Deleting unedited page {page.identifier} by {page}')
            n+=1
            #page.delete()
        untouched_time = datetime.now() - timedelta(days=int(days_delete_untouched))
        for page in sesh.query(Page).filter(and_(Page.exists is True, Page.timestamp < untouched_time)):
            log.info(f'Deleting abbandonned page {page.identifier} ({page.timestamp})')
            # page.delete()
            n+=1
        notify_admin(f'Deleted {n} pages in cleanup.')

def monitor_task():
    sesh = get_session()
    with transaction.manager:
        for page in sesh.query(Page).filter(and_(Page.exists is True, Page.protected is True)):
            log.info(f'Monitoring {page}.')
    #notify_admin(f'Page monitoring successful.')
