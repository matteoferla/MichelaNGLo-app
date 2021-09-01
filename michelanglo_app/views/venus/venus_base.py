from __future__ import annotations
# venus parts common to regular venus and multiple mutant version.


from ..uniprot_data import *
# ProteinCore organism human uniprot2pdb
from michelanglo_protein import ProteinAnalyser, Mutation, ProteinCore, Structure, Variant

from ...models import User, Page  ##needed solely for log.
from ..common_methods import is_malformed, notify_admin, get_pdb_block_from_request
from ..user_management import permission
from ..custom_message import custom_messages
from .venus_text import contents as contents

from typing import Optional, Any, List, Union, Tuple, Dict
import random
from pyramid.view import view_config, view_defaults
from pyramid.renderers import render_to_response
import pyramid.httpexceptions as exc

import json, os, logging, operator, time

log = logging.getLogger(__name__)
# from pprint import PrettyPrinter
# pprint = PrettyPrinter().pprint

### This is a weird way to solve the status 206 issue.
# no longer required??
from ..buffer import system_storage


# ------------- DEBUG -------------------------------------------
# this should and will probably be brought to the app.py config
suppress_errors = True

from michelanglo_protein.analyse import StructureAnalyser
# do not raise error on missing conservation
StructureAnalyser.error_on_missing_conservation = not suppress_errors

# ----------------------------------------------------------------

######################

class VenusException(Exception):
    pass

class VenusBase:
    """
    Methods common to both venus and multivenus...
    """
    generic_data = {'project': 'VENUS',
                    # 'user': None,
                    'bootstrap': 4,
                    'current_page': 'venus',
                    'custom_messages': json.dumps(custom_messages),
                    'meta_title': 'Michelaɴɢʟo: sculpting protein views on webpages without coding.',
                    'meta_description': 'Convert PyMOL files, upload PDB files or submit PDB codes and ' + \
                                        'create a webpage to edit, share or implement standalone on your site',
                    'meta_image': '/static/tim_barrel.png',
                    'meta_url': 'https://michelanglo.sgc.ox.ac.uk/',
                    'contents': contents
                    }
    suppress_errors = suppress_errors

    def __init__(self, request):
        self.request = request
        self.reply = {'status': 'success',   # filled by the steps and kept even if an error is raised.
                      'warnings': [],
                      'time_taken': 0
        }
        if self.handle:
            self.reply['job_id'] = self.handle
        # status=error, error=single-word, msg=long
        self._tick = float('nan')  # required for self.reply['time_taken']
        self.time_taken = 0.
        if 'debug' in self.request.params and self.request.params['debug']:
            self.suppress_errors = False
            log.info('Debug mode requested!')

    @property
    def handle(self):
        pass # overridden.

    def start_timer(self):
        self._tick = time.time()

    def stop_timer(self):
        assert str(self._tick) != 'nan', 'Timer not started'
        tock = time.time()
        tick = self._tick
        self.time_taken += tock - tick
        self._tick = time.time()
        self.reply['time_taken'] += self.time_taken

    def assert_malformed(self, *args):
        malformed = is_malformed(self.request, *args)
        if malformed:
            self.reply['status'] = 'error'
            self.reply['error'] = 'malformed request'
            self.reply['msg'] = malformed
            raise ValueError(f'Malformed error ({malformed}) by {User.get_username(self.request)}')
        else:
            return

    ### Other
    def log_if_error(self, operation, response=None):
        if response is None:
            response = self.reply
        if isinstance(response, dict):
            if 'error' in response and 'msg' in response:
                msg = f'Error during {operation}: {response["error"]} ({response["msg"]})'
            elif 'error' in response:
                msg = f'Error during {operation}: {response["error"]}'
            else:
                return None  # not an error.
            self.reply['status'] = 'error'
            self.reply['error'] = response['error']
            self.reply['msg'] = msg
            raise VenusException(msg)
        else:
            raise ValueError(f'This response ({type(response)}) is not an dict?!?')

    def jsonable(self, obj: Any):
        def deobjectify(x):
            if isinstance(x, dict):
                return {k: deobjectify(x[k]) for k in x}
            elif isinstance(x, list) or isinstance(x, set):
                return [deobjectify(v) for v in x]
            elif isinstance(x, int) or isinstance(x, float):
                return x
            elif isinstance(x, Structure):
                return x.to_dict(full=True)
            elif isinstance(x, Variant):
                return x.to_dict()
            else:
                return str(x)  # really ought to deal with falseys.

        return {a: deobjectify(getattr(obj, a, '')) for a in obj.__dict__}
