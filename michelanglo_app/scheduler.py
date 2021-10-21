import os, json, imageio, pickle
from .models import Page, User, Doi
from sqlalchemy import engine_from_config
from sqlalchemy.orm import sessionmaker
from sqlalchemy.sql.expression import and_
import transaction
from apscheduler.schedulers.background import BackgroundScheduler
from .views.common_methods import Comms
from michelanglo_transpiler import GlobalPyMOL
from mako.template import Template

from datetime import datetime, timedelta

from .views.buffer import system_storage

import logging

log = logging.getLogger('apscheduler')

# ==============================  MAIN  ================================================================================

def includeme(config):
    settings = config.get_settings()
    Entasker.sql_url = settings['sqlalchemy.url']
    Entasker.user_data_folder = settings['michelanglo.user_data_folder']
    #Entasker.port = '8088'  # hardcoded because I am not sure I can find out the port...
    Entasker.puppeteer_chrome = settings["puppeteer.executablepath"]

    scheduler = BackgroundScheduler()
    # =============== PERIODIC TASKS ===============
    scheduler.add_job(Entasker.kill_task, 'interval', days=1, args=[int(settings['scheduler.days_delete_unedited']),
                                                                    int(settings['scheduler.days_delete_untouched'])])
    scheduler.add_job(Entasker.monitor_task, 'interval', days=30)
    scheduler.add_job(Entasker.daily_task, 'interval', days=1)
    scheduler.add_job(Entasker.spam_task, 'interval', days=30, args=[int(settings['scheduler.days_delete_untouched'])])
    scheduler.add_job(Entasker.unjam_task, 'interval', hours=1)
    scheduler.add_job(Entasker.clear_buffer_task, 'interval', hours=6)
    # =============== START UP TASKS ===============
    scheduler.add_job(Entasker.monitor_task, 'date', run_date=datetime.now() + timedelta(minutes=60))
    # scheduler.add_job(sanitycheck_task, 'date', run_date=datetime.now() + timedelta(minutes=2))
    # =============== GO! ===============
    scheduler.start()

# ==============================   TASKS  ==============================================================================

class Entasker:

    sql_url = ''  # filled by scheduler.includeme builder function
    user_data_folder = ''
    port = '8088'
    puppeteer_chrome = ''

    def __init__(self):
        # not request bound.
        engine = engine_from_config({'sqlalchemy.url': self.sql_url,
                                     'sqlalchemy.echo': 'False'},
                                    prefix='sqlalchemy.')
        Session = sessionmaker(bind=engine)
        self.session = Session()

    @classmethod
    def run(cls, taskname: str):
        tasks = dict(kill=cls.kill_task,
                     monitor=cls.monitor_task,
                     daily=cls.daily_task,
                     spam=cls.spam_task,
                     unjam=cls.unjam_task,
                     clear_buffer=cls.clear_buffer_task
                     )
        if taskname in tasks:
            tasks[taskname]()
        else:
            raise ValueError(f'No idea what task {taskname} is. {taskname.keys()}')

    @classmethod
    def daily_task(cls):
        # odds and ends
        # change all new users to basic users.
        self = cls()
        with transaction.manager:
            for row in self.session.query(User).filter_by(role='new'):
                row.role = 'basic'
        self.session.commit()
        # PDB?

    @classmethod
    def spam_task(cls, days_delete_untouched: int = 365, forewarn_time: int = 20):
        self = cls()
        with transaction.manager:
            for user in self.session.query(User):
                delitura = [page for page in user.owned.select(self.session) if
                            page.edited and (page.safe_age + forewarn_time) > int(days_delete_untouched)]
                # page.age < int(days_delete_untouched)
                if not delitura:
                    continue  # nothing in peril
                elif user.email is None or '@' not in user.email:
                    # do not contact
                    msg = f'{user.name} (no email) could not notified of {len(delitura)} pages expiring.'
                    Comms.notify_admin(msg)
                    log.info(msg)
                else:
                    docs = 'https://michelanglo.sgc.ox.ac.uk/docs/users'
                    dtexts = [
                        f'* https://michelanglo.sgc.ox.ac.uk/data/{page.identifier} — {page.title} ({page.age} days since last visit)'
                        for page in delitura]
                    text = f'Dear user {user.name},\n' + \
                           f'There are {len(delitura)} Michelanglo pages edited by you ' + \
                           f'which have not been visited in a while and the deletion policy of Michelanglo is that ' + \
                           f'any page with no visits since {days_delete_untouched} are deleted (as stated in {docs}).\n' + \
                           f'Consequently the following edited unprotected private pages are scheduled for deletion within {forewarn_time} days, ' + \
                           f'unless visited:\n'+ '\n'.join(dtexts) + '\n' + \
                           f'(To delete unwanted pages normally, press the edit pencil and then ' + \
                           'the red delete button at the bottom of the modal.)\n' + \
                           f'(To see what pages are about to expire ' + \
                           'go to your personal gallery via the menu button and look for a clock icon at the bottom of some cards.)\n' + \
                           f'Thank you,\nMatteo (Michelanglo admin)\n'
                    try:
                        Comms.email(text, user.email, 'Michelanglo page expiry notice') #
                        msg = f'{user.name} ({user.email}) was notified of {len(delitura)} pages expiring.'
                        Comms.notify_admin(msg)
                        log.info(msg)
                    except Exception as error:
                        msg = f'Failed at emailing {user.name} ({user.email}) about {len(delitura)} pages expiring ' + \
                              f'because of {type(error).__name__} {str(error)}.'
                        Comms.notify_admin(msg)
                        log.warning(msg)

    @classmethod
    def kill_task(cls, days_delete_unedited: int=30, days_delete_untouched: int=365):
        self = cls()
        with transaction.manager:
            n = 0
            for page in self.session.query(Page).filter(
                    and_(Page.existant == True,
                         Page.edited == False)):  # deletable.

                if page.age < int(days_delete_unedited):
                    continue  # too young
                else:  # delete.
                    log.info(f'Deleting unedited page {page.identifier} by {page}')
                    n += 1
                    page.delete()
            for page in self.session.query(Page).filter(and_(Page.existant == True,
                                                     Page.protected == False,
                                                     Page.privacy == 'private')):
                if page.age < int(days_delete_untouched):
                    continue  # too young
                elif self.session.query(Doi).filter(Doi.long == page.identifier).first() is not None:
                    Comms.notify_admin(f'{page.identifier} is untouched but has a doi.')
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
                        Comms.notify_admin(f'{page.identifier} does not exist.')
                    n += 1
            Comms.notify_admin(f'Deleted {n} pages in cleanup.')
        self.session.commit()

    @classmethod
    def clear_buffer_task(cls, delete_time: int = 6):
        system_storage.delete_before(delete_time)  # delete stuff over 6 hours old.

    @classmethod
    def monitor_task(cls):
        self = cls()
        with transaction.manager:
            for page in self.session.query(Page).filter(and_(Page.existant == True, Page.protected == True)):
                log.info(f'Monitoring {page}.')
                state = []
                try:
                    # under most conditions the following should be `michelanglo_app`
                    michelanglo_app_folder = os.path.split(__file__)[0]
                    cmd = ' '.join([f'USER_DATA={cls.user_data_folder}',
                                    f'PORT={cls.port}',
                                    f'PUPPETEER_CHROME={cls.puppeteer_chrome}',
                                    f'node {michelanglo_app_folder}/monitor.js {page.identifier} tmp_'])
                    if os.system(cmd):  # exit status != 0
                        raise ValueError(f'monitor crashed: {cmd}')
                    details = json.load(
                        open(os.path.join(cls.user_data_folder, 'monitor', page.identifier + '.json')))
                    for i in range(len(details)):
                        ref = os.path.join(cls.user_data_folder, 'monitor', f'{page.identifier}-{i}.png')
                        new = os.path.join(cls.user_data_folder, 'monitor', f'tmp_{page.identifier}-{i}.png')
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
                            Comms.notify_admin(msg)
                except Exception as err:
                    msg = f'Page monitoring unsuccessful for {page.identifier} {err}'
                    log.warning(msg)
                    Comms.notify_admin(msg)
                else:
                    log.info(f'Page monitoring successful for {page.identifier}')
                pickle.dump(state,
                            open(os.path.join(cls.user_data_folder, 'monitor', f'verdict_{page.identifier}.p'),
                                 'wb'))

    @classmethod
    def unjam_task(cls):
        """
        The context manager already deals with this. But this is just to prevent the context manager from dealing with this.
        """
        gp = GlobalPyMOL()
        if gp.pylock.acquire(timeout=120):
            gp.pylock.release()
        else:
            gp.kill()

    @classmethod
    def sanitycheck_task(cls):
        # verify that the database pages table and the pickles files are consistent.
        # why? In case I add a pickle manually.
        # actually how would I do that? It would require rsync the data to /temp and then moving it as the correct user.
        # it would be way easier to fix it by API.
        # also, who would win in case of conflict?
        # I need to think about this more.
        pass