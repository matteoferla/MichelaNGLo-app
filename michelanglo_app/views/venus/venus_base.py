from __future__ import annotations

import time
from abc import abstractmethod
from typing import Optional, Any

# ProteinCore organism human uniprot2pdb
from michelanglo_protein import Variant

from .venus_text import contents as contents
from ..common_methods import is_malformed
from ..custom_message import custom_messages
from ..uniprot_data import *
from ...models import User  ##needed solely for log.

# venus parts common to regular venus and multiple mutant version.

log = logging.getLogger(__name__)
# from pprint import PrettyPrinter
# pprint = PrettyPrinter().pprint

### This is a weird way to solve the status 206 issue.
# no longer required??
from ..buffer import system_storage


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
    suppress_errors = True

    def __init__(self, request):
        self.request = request
        self.reply = {'status': 'success',  # filled by the steps and kept even if an error is raised.
                      'warnings': [],
                      'time_taken': 0
                      }
        if self.handle:
            self.reply['job_id'] = self.handle
        # status=error, error=single-word, msg=long
        self._tick = float('nan')  # required for self.reply['time_taken']
        self._tick_ns = time.time_ns()
        self.time_taken = 0.
        # ## User requested debug mode!
        if 'debug' in self.request.params and self.request.params['debug']:
            self.suppress_errors = False
            log.info('Debug mode requested!')
            # The following is dangerous. Comment out if needed...
            from michelanglo_protein.analyse import StructureAnalyser
            StructureAnalyser.error_on_missing_conservation = True

    @abstractmethod
    def get_user_modelling_options(self):
        pass  # overridden.

    def start_timer(self):
        self._tick = time.time()

    def stop_timer(self):
        assert str(self._tick) != 'nan', 'Timer not started'
        tock = time.time()
        tick = self._tick
        self.time_taken += tock - tick
        self._tick = time.time()
        self.reply['time_taken'] += self.time_taken

    def get_elapsed_ns(self) -> float:
        tock = time.time_ns()
        return tock - self._tick_ns

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

    # management

    @property
    def handle(self):
        """
        The subterfuge isn't that required: this is not written to disk
        """
        if 'job_id' in self.request.params:
            return str(self.request.params['job_id'])
        if 'mutation' not in self.request.params or 'uniprot' not in self.request.params:
            return None
        if str(self.request.params['uniprot']) == '9606' or str(self.request.params['mutation']) == '9606':
            raise ValueError('Chrome autofill')  # this is uncaught
        settings = self.get_user_modelling_options()
        concatenation = (
                self.request.params['uniprot'] +
                self.request.params['mutation'] +
                '-'.join(map(str, settings.values()))
        )
        log.debug(f'request handle: {str(hash(concatenation))}')
        return str(hash(concatenation))

    def has(self, key: Optional[str] = None) -> bool:
        # checks whether the protein object has a filled value (not the reply!)
        if self.handle not in system_storage:  # this is not already done
            return False
        elif key is None:
            return True
        elif not hasattr(system_storage[self.handle], key):
            return False
        elif getattr(system_storage[self.handle], key) is None:
            return False
        else:
            return True
