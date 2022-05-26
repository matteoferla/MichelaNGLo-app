# this is no longer called from the main app
# sentry changed their plans

import os, sentry_sdk
from typing import *
from sentry_sdk.integrations.pyramid import PyramidIntegration


def setup_sentry(data_source_name:str) -> Union[None, ContextManager[Any]]:
    if data_source_name is None:
        return
    return sentry_sdk.init(
                         dsn=data_source_name,
                         integrations=[PyramidIntegration()]
                        )