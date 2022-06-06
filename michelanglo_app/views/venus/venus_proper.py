from __future__ import annotations

import random
import traceback
from time import sleep
from typing import Optional, List
from types import TracebackType

from michelanglo_protein import ProteinAnalyser, Mutation, ProteinCore, Structure, is_alphafold_taxon  # noqa
from michelanglo_transpiler import PyMolTranspiler  # used solely for temp folder
from pyramid.renderers import render_to_response
from pyramid.view import view_config, view_defaults

from .venus_base import VenusException, VenusBase
from .venus_steps import VenusSteps
from ..common_methods import Comms
from ..common_methods import get_pdb_block_from_request
from ..uniprot_data import *
from ..buffer import system_storage
from ...models import User  # needed solely for log.
from ..buffer import venus_stats, StatsType

log = logging.getLogger(__name__)


# ====================== Analyse the mutation ======================
# venus parts common to regular venus and multiple mutant version.
@view_defaults(route_name='venus')
class Venus(VenusSteps):

    # ---------- server main page ----------
    @view_config(renderer="../../templates/venus/venus_main.mako")
    def main_view(self):
        return {'user':          self.request.user,
                'mutation_mode': 'main',
                **self.generic_data}

    # ---------- Give a random view that will give a protein ----------
    @view_config(route_name='venus_random', renderer="json")
    def random_view(self):
        while True:
            name = random.choice(list(human.keys()))
            uniprot = human[name]
            protein = ProteinCore(taxid=9606, uniprot=uniprot).load()
            if protein.pdbs:
                pdb = random.choice(protein.pdbs)
            elif protein.swissmodel:
                pdb = random.choice(protein.swissmodel)
            else:
                continue
            try:
                i = random.randint(pdb.x, pdb.y)
                # the to_resn cannot be the same as original or *
                to_resn = random.choice(list(set(Mutation.aa_list) - {'*', protein.sequence[i - 1]}))
                return {'name':     name, 'uniprot': uniprot, 'taxid': '9606', 'species': 'human',
                        'mutation': f'p.{protein.sequence[i - 1]}{i}{to_resn}'}
            except IndexError:
                log.error(f'Impossible... pdb.x out of bounds in unicode for gene {uniprot}')
                continue

    @view_config(route_name='venus_debug', renderer="../../templates/venus/venus_debug.mako")
    def debug(self):
        return {'user': self.request.user, 'mutation_mode': 'main', **self.generic_data}

    #  ================= Analyse =================
    @view_config(route_name='venus_analyse', renderer="json")
    def analyse(self) -> dict:
        """
        View that does the analysis. Formerly returned html now returns json.
        The request has to contain each of following 'step', 'uniprot', 'species', 'mutation' fields.
        /venus_analyse?species=9606&uniprot=Q96C12&mutation=p.V123F&step=protein
        step can be protein
        Species is taxid. Human is 9606.
        """
        # ## check valid
        identifier = hash(self)  # used only for logging: handle has protein specific info
        # chalk up for global stats
        if identifier not in venus_stats:
            # StatsType
            venus_stats[identifier] = {'running': True,
                                       'start': 0,
                                       'stop': float('nan'),
                                       'status': 'unknown',
                                       'error': '',
                                       'step': 'malformed'}
        try:

            self.assert_malformed('uniprot', 'species', 'mutation')
            if 'step' not in self.request.params:
                step = None
            else:
                step = self.request.params['step']
            venus_stats[identifier]['step'] = step
            output = self.do_step(step)  # for features step it is not a dict!
        except VenusException as error:
            # this is right at the top:
            # it should not be conditional to `self.suppress_errors`
            # as this is user requested...
            log.info(f'VenusException: {error}')
            traceback: TracebackType = error.__traceback__
            if traceback:
                log.debug(f'Traceback: {traceback.tb_frame.f_code.co_name} - ' +
                          f'{traceback.tb_frame.f_code.co_filename}:{traceback.tb_lineno}')
            venus_stats[identifier]['error'] = str(error)
            output = self.reply
        except Exception as error:
            if self.reply['status'] != 'error':
                # this is a new one.
                self.reply['status'] = 'error'
                self.reply['error'] = 'analysis'
                self.reply['msg'] = str(error)
                output = self.reply
            log.warning(f'Venus error {error.__class__.__name__}: {error}')
            if 'Malformed error' not in str(error):
                Comms.notify_admin(f'The error is not malformed:  {error.__class__.__name__}: {error}')
                traceback: TracebackType = error.__traceback__
                log.debug(f'Traceback: {traceback.tb_frame.f_code.co_name} - ' +
                          f'{traceback.tb_frame.f_code.co_filename}:{traceback.tb_lineno}')
            venus_stats[identifier]['error'] = str(error)
            output = self.reply
        venus_stats[identifier]['running'] = False
        # does not use `stop_timer` just in case there is a problem:
        venus_stats[identifier]['stop'] = self.get_elapsed_ns()
        if isinstance(output, dict) and 'status' in output:
            venus_stats[identifier]['status'] = output['status']
        else:  # features does not return a dictionary...
            venus_stats[identifier]['status'] = 'not-applicable'
        return output  # aka self.reply in all cases bar features

    # ------ Steps -----------------------------------------------------------------------------------------------------

    @property
    def steps(self):
        # this is strictly an instance attribute not a class one.
        return {'protein':    self.protein_step,
                'mutation':   self.mutation_step,
                'structural': self.structural_step,
                'ddG':        self.ddG_step,
                'ddG_gnomad': self.ddG_gnomad_step}

    def do_step(self, step):
        # a likely API call
        if step is None:
            log.info(f'Full analysis requested by {User.get_username(self.request)}')
            # run all steps
            [fxn() for name, fxn in self.steps.items()]
        # ajax
        elif step in self.steps.keys():
            # these have replies that stack
            self.steps[step]()
        elif step == 'fv':
            # this is the same as get_uniprot but does not redundantly redownload the data.
            if not self.has():
                self.protein_step()
            protein = system_storage[self.handle]
            return render_to_response(os.path.join("..", "..", "templates", "results", "features.js.mako"),
                                      {'protein':     protein,
                                       'featureView': '#fv',
                                       'include_pdb': False,
                                       'alphafolded': is_alphafold_taxon(self.request.params['species'])
                                       },
                                      self.request)
        elif step == 'extra':
            self.assert_malformed('extra', 'algorithm')
            self.extra_step(mutation=self.request.params['extra'], algorithm=self.request.params['algorithm'])
        elif step == 'phosphorylate':
            self.phospho_step()
        elif step == 'customfile':
            self.assert_malformed('pdb', 'filename')
            pdb = get_pdb_block_from_request(self.request)
            params = self.save_params()
            self.change_to_file(pdb, self.request.params['filename'], params)
        else:
            self.request.response.status = 422
            self.reply = {'status': 'error', 'error': 'Unknown step'}
        return self.reply
