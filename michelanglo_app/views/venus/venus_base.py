from __future__ import annotations
# venus parts common to regular venus and multiple mutant version.


from michelanglo_app.views.uniprot_data import *
# ProteinCore organism human uniprot2pdb
from michelanglo_protein import ProteinAnalyser, Mutation, ProteinCore, Structure

from michelanglo_app.models import User, Page  ##needed solely for log.
from michelanglo_app.views.common_methods import is_malformed, notify_admin, get_pdb_block_from_request
from michelanglo_app.views.user_management import permission
from michelanglo_app.views import custom_messages

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
from michelanglo_app.views.buffer import system_storage


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
                    'meta_url': 'https://michelanglo.sgc.ox.ac.uk/'
                    }

    def __init__(self, request):
        self.request = request
        self.reply = {'status': 'success', 'warnings': [], 'time_taken': 0}  # filled by the steps and kept even if an error is raised.
        # status=error, error=single-word, msg=long
        self._tick = float('nan')  # required for self.reply['time_taken']

    def start_timer(self):
        self._tick = time.time()

    def stop_timer(self):
        assert str(self._tick) != 'nan', 'Timer not started'
        tock = time.time()
        tick = self._tick
        self._tick = float('nan')
        self.reply['time_taken'] += tock - tick

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
            raise ValueError('This response is not an dict?!?')

    def jsonable(self, obj: Any):
        def deobjectify(x):
            if isinstance(x, dict):
                return {k: deobjectify(x[k]) for k in x}
            elif isinstance(x, list) or isinstance(x, set):
                return [deobjectify(v) for v in x]
            elif isinstance(x, int) or isinstance(x, float):
                return x
            else:
                return str(x)  # really ought to deal with falseys.

        return {a: deobjectify(getattr(obj, a, '')) for a in obj.__dict__}