import os, json, imageio, pickle
from .models import Page
from sqlalchemy import engine_from_config
from sqlalchemy.orm import sessionmaker
from sqlalchemy.sql.expression import and_
import transaction
from apscheduler.schedulers.background import BackgroundScheduler
from .views._common_methods import notify_admin

from datetime import datetime,timedelta

import logging
log = logging.getLogger('apscheduler')


def includeme(config):
    #scheduler.days_delete_unedited = 30
    #scheduler.days_delete_untouched = 365
    settings = config.get_settings()
    scheduler = BackgroundScheduler()

    # adding settings to kill_task...
    scheduler.add_job(kill_task, 'interval', days=1, args=[settings['scheduler.days_delete_unedited'], settings['scheduler.days_delete_untouched']])
    scheduler.add_job(monitor_task, 'interval', days=30)
    scheduler.add_job(monitor_task, 'date', run_date=datetime.now() + timedelta(minutes=1)) #run monitor_task once, in a minute.

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
        for page in sesh.query(Page).filter(and_(Page.exists == True, Page.edited == False, Page.timestamp < unedited_time)):
            log.info(f'Deleting unedited page {page.identifier} by {page}')
            n+=1
            page.delete()
        untouched_time = datetime.now() - timedelta(days=int(days_delete_untouched))
        for page in sesh.query(Page).filter(and_(Page.exists == True, Page.timestamp < untouched_time)):
            log.info(f'Deleting abbandonned page {page.identifier} ({page.timestamp})')
            page.delete()
            n+=1
        notify_admin(f'Deleted {n} pages in cleanup.')

def monitor_task():
    sesh = get_session()
    with transaction.manager:
        for page in sesh.query(Page).filter(and_(Page.exists == True, Page.protected == True)):
            log.info(f'Monitoring {page}.')
            state = []
            try:
                if os.system(f'node michelanglo_app/monitor.js {page.identifier} tmp_'):
                    raise ValueError(f'monitor crashed: node michelanglo_app/monitor.js {page.identifier} tmp_')
                details = json.load(open(os.path.join('michelanglo_app','user-data-monitor', page.identifier+'.json')))
                for i in range(len(details)):
                    ref = os.path.join('michelanglo_app','user-data-monitor', f'{page.identifier}-{i}.png')
                    new = os.path.join('michelanglo_app','user-data-monitor', f'tmp_{page.identifier}-{i}.png')
                    assert os.path.exists(ref), 'Reference image does not exist'
                    assert os.path.exists(new), 'Generated image does not exist'
                    ref_img = imageio.imread(ref).flatten()
                    new_img = imageio.imread(new).flatten()
                    if ref_img.shape != new_img.shape:
                        state.append(False)
                    elif sum(ref_img == new_img) / len(ref_img) > 0.99:
                        state.append(True)
                    else:
                        state.append(False)
                        msg = f'Page monitoring unsuccessful for {page.identifier} image {i}'
                        notify_admin(msg)
            except Exception as err:
                        msg = f'Page monitoring unsuccessful for {page.identifier} {err}'
                        log.warning(msg)
                        notify_admin(msg)
            else:
                log.info(f'Page monitoring successful for {page.identifier}')
            pickle.dump(state, open(os.path.join('michelanglo_app', 'user-data-monitor', f'verdict_{page.identifier}.p'), 'wb'))
