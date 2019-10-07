import os, json, imageio, pickle
from .models import Page, User, Doi
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

    #### PERIODIC TASKS ####################################################
    scheduler.add_job(kill_task, 'interval', days=1, args=[settings['scheduler.days_delete_unedited'], settings['scheduler.days_delete_untouched']])
    scheduler.add_job(monitor_task, 'interval', days=30)
    scheduler.add_job(daily_task, 'interval', days=1)
    #### START UP TASKS ####################################################
    scheduler.add_job(monitor_task, 'date', run_date=datetime.now() + timedelta(minutes=60))
    #scheduler.add_job(sanitycheck_task, 'date', run_date=datetime.now() + timedelta(minutes=2))
    #### GO! ####################################################
    scheduler.start()


def get_session(): ## not request bound.
    engine = engine_from_config({'sqlalchemy.url': os.environ['SQL_URL'], 'sqlalchemy.echo': 'False'},
                                prefix='sqlalchemy.')
    Session = sessionmaker(bind=engine)
    return Session()

def daily_task():
    ## odds and ends
    # change all new users to basic users.
    sesh = get_session()
    with transaction.manager:
        for row in sesh.query(User).filter_by(role='new'):
            row.role = 'basic'
    sesh.commit()
    # PDB?

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
            if page.protected or sesh.query(Doi).filter(Doi.long == page.identifier).first() is not None:
                continue
            log.info(f'Deleting abbandonned page {page.identifier} ({page.timestamp})')
            try:
                page.delete()
            except FileNotFoundError:
                ## file has been deleted manually!?
                ## this is a pretty major incident.
                page.exists = False
                log.warning(f'{page.identifier} does not exist.')
                notify_admin(f'{page.identifier} does not exist.')
            n+=1
        notify_admin(f'Deleted {n} pages in cleanup.')
    sesh.commit()

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

def sanitycheck_task():
    #verify that the database pages table and the pickles files are consistent.
    #why? In case I add a pickle manually.
    #actually how would I do that? It would require rsync the data to /temp and then moving it as the correct user.
    #it would be way easier to fix it by API.
    #also, who would win in case of conflict?
    #I need to think about this more.
    pass

