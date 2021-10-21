import os
from typing import *

# the environmental names differ.
environmental2config = dict(MICHELANGLO_PROTEIN_DATA='michelanglo.protein_data_folder',
                     MICHELANGLO_USER_DATA='michelanglo.user_data_folder',
                     MICHELANGLO_SECRETCODE='michelanglo.secretcode',
                     MICHELANGLO_SQL_URL='sqlalchemy.url',
                     MICHELANGLO_SENTRY_DNS='sentry.data_source_name',
                     PUPPETEER_CHROME='puppeteer.executablepath', # will crash puppeteer if absent.
                     SLACK_WEBHOOK='slack.webhook',
                     MICHELANGLO_ADMIN_EMAIL='michelanglo.admin_email',
                     MICHELANGLO_SERVER_EMAIL='michelanglo.server_email',
                     )

def override_environmentally(settings: Dict) -> None:
    for sys_env_name, config_name in environmental2config.items():
        title = f'Environment variable {sys_env_name} (config name {config_name})'
        if sys_env_name in os.environ:
            print(f'{title}: present, changing from {settings[config_name]} to {os.environ[sys_env_name]}')
            settings[config_name] = os.environ[sys_env_name]
        elif settings[config_name] == '':
            settings[config_name] = None
            print(f'{title}: sticking with None')
        else:
            print(f'{title}: sticking with {settings[config_name]}')