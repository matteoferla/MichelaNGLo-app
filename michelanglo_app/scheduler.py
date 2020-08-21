import os, json, imageio, pickle
from .models import Page, User, Doi
from sqlalchemy import engine_from_config
from sqlalchemy.orm import sessionmaker
from sqlalchemy.sql.expression import and_
import transaction
from apscheduler.schedulers.background import BackgroundScheduler
from .views.common_methods import notify_admin, email
from michelanglo_transpiler import GlobalPyMOL

from datetime import datetime, timedelta

from .views.buffer import system_storage

import logging

log = logging.getLogger('apscheduler')


# ==============================  MAIN  ================================================================================

def includeme(config):
    # scheduler.days_delete_unedited = 30
    # scheduler.days_delete_untouched = 365
    settings = config.get_settings()
    scheduler = BackgroundScheduler()

    # =============== PERIODIC TASKS ===============
    # temporarily off!! TODO reactivate on Thurday
    scheduler.add_job(kill_task, 'interval', days=1, args=[int(settings['scheduler.days_delete_unedited']),
                                                           int(settings['scheduler.days_delete_untouched'])])
    scheduler.add_job(monitor_task, 'interval', days=30)
    scheduler.add_job(daily_task, 'interval', days=1)
    scheduler.add_job(spam_task, 'interval', days=7, args=[int(settings['scheduler.days_delete_unedited'])])
    scheduler.add_job(unjam_task, 'interval', hours=1)
    scheduler.add_job(clear_buffer_task, 'interval', hours=6)
    # =============== START UP TASKS ===============
    scheduler.add_job(monitor_task, 'date', run_date=datetime.now() + timedelta(minutes=60))
    # scheduler.add_job(sanitycheck_task, 'date', run_date=datetime.now() + timedelta(minutes=2))
    # =============== GO! ===============
    scheduler.start()


def get_session():  ## not request bound.
    engine = engine_from_config({'sqlalchemy.url': os.environ['SQL_URL'], 'sqlalchemy.echo': 'False'},
                                prefix='sqlalchemy.')
    Session = sessionmaker(bind=engine)
    return Session()


# ==============================   TASKS  ==============================================================================

def daily_task():
    # odds and ends
    # change all new users to basic users.
    sesh = get_session()
    with transaction.manager:
        for row in sesh.query(User).filter_by(role='new'):
            row.role = 'basic'
    sesh.commit()
    # PDB?


def spam_task(days_delete_untouched: int):
    forewarn_time = 14
    sesh = get_session()
    with transaction.manager:
        for user in sesh.query(User):
            delitura = [page for page in user.owned.select(sesh) if
                        page.edited and (page.safe_age + forewarn_time) > int(days_delete_untouched)]
            if not delitura:
                continue  # nothing in peril
            elif '@' not in user.email:
                continue  # do not contact
            else:
                docs = 'https://michelanglo.sgc.ox.ac.uk/docs/users'
                dtexts = [
                    f'* https://michelanglo.sgc.ox.ac.uk/data/{page.identifier} — {page.title} ({page.age} days since last visit)'
                    for page in delitura]
                text = f'Dear user {user.name},\n' + \
                       f'There are {len(delitura)} Michelanglo pages edited by you ' + \
                       f'which have not been visited in a while and the deletion policy of Michelanglo is that ' + \
                       f'any page with no visits since {days_delete_untouched} are deleted (as stated in {docs}).\n' + \
                       f'Consequently the following edited unprotected private pages are scheduled for deletion, ' + \
                       f'unless visited:'+ '\n'.join(dtexts) + '\n' + \
                       f'To delete unwanted pages normally, press the edit pencil and then ' + \
                       'the red delete button at the bottom of the modal.' + \
                       f'Thank you,\nMatteo (Michelanglo admin)\n'
                try:
                    email(text, user.email, 'Michelanglo page expiry notice')
                    msg = f'{user.name} ({user.email}) was notified of {len(delitura)} pages expiring.'
                    notify_admin(msg)
                    log.info(msg)
                except Exception as error:
                    msg = f'Failed at emailing {user.name} ({user.email}) about {len(delitura)} pages expiring ' + \
                          f'because of {type(error).__name__} {str(error)}.'
                    notify_admin(msg)
                    log.warning(msg)


def kill_task(days_delete_unedited: int, days_delete_untouched: int):
    sesh = get_session()
    with transaction.manager:
        n = 0
        for page in sesh.query(Page).filter(
                and_(Page.existant == True,
                     Page.edited == False)):  # deletable.

            if page.age < int(days_delete_unedited):
                continue  # too young
            else:  # delete.
                log.info(f'Deleting unedited page {page.identifier} by {page}')
                n += 1
                page.delete()
        for page in sesh.query(Page).filter(and_(Page.existant == True,
                                                 Page.protected == False,
                                                 Page.privacy == 'private')):
            if page.age < int(days_delete_untouched):
                continue  # too young
            elif sesh.query(Doi).filter(Doi.long == page.identifier).first() is not None:
                notify_admin(f'{page.identifier} is untouched but has a doi.')
                continue  # doi
            else:
                log.info(f'Deleting abandoned page {page.identifier} ({page.timestamp})')
                try:
                    page.delete()
                except FileNotFoundError:
                    # file has been deleted manually!?
                    # this is a pretty major incident.
                    page.existant = False
                    log.warning(f'{page.identifier} does not exist.')
                    notify_admin(f'{page.identifier} does not exist.')
                n += 1
        notify_admin(f'Deleted {n} pages in cleanup.')
    sesh.commit()


def clear_buffer_task():
    system_storage.delete_before(6)  # delete stuff over 6 hours old.


def monitor_task():
    sesh = get_session()
    with transaction.manager:
        for page in sesh.query(Page).filter(and_(Page.existant == True, Page.protected == True)):
            log.info(f'Monitoring {page}.')
            state = []
            try:
                if os.system(f'node michelanglo_app/monitor.js {page.identifier} tmp_'):
                    raise ValueError(f'monitor crashed: node michelanglo_app/monitor.js {page.identifier} tmp_')
                details = json.load(
                    open(os.path.join('michelanglo_app', 'user-data-monitor', page.identifier + '.json')))
                for i in range(len(details)):
                    ref = os.path.join('michelanglo_app', 'user-data-monitor', f'{page.identifier}-{i}.png')
                    new = os.path.join('michelanglo_app', 'user-data-monitor', f'tmp_{page.identifier}-{i}.png')
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
            pickle.dump(state,
                        open(os.path.join('michelanglo_app', 'user-data-monitor', f'verdict_{page.identifier}.p'),
                             'wb'))


def sanitycheck_task():
    # verify that the database pages table and the pickles files are consistent.
    # why? In case I add a pickle manually.
    # actually how would I do that? It would require rsync the data to /temp and then moving it as the correct user.
    # it would be way easier to fix it by API.
    # also, who would win in case of conflict?
    # I need to think about this more.
    pass


def unjam_task():
    """
    The context manager already deals with this. But this is just to prevent the context manager from dealing with this.
    """
    gp = GlobalPyMOL()
    if gp.pylock.acquire(timeout=120):
        gp.pylock.release()
    else:
        gp.kill()
