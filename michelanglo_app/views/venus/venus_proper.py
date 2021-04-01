from __future__ import annotations
# venus parts common to regular venus and multiple mutant version.


from ..uniprot_data import *
# ProteinCore organism human uniprot2pdb
from michelanglo_protein import ProteinAnalyser, Mutation, ProteinCore, Structure

from ...models import User, Page  ##needed solely for log.
from ..common_methods import is_malformed, notify_admin, get_pdb_block_from_request
from ..user_management import permission
from .. import custom_messages

from typing import Optional, Any, List, Union, Tuple, Dict
import random, traceback, sys
from pyramid.view import view_config, view_defaults
from pyramid.renderers import render_to_response
from ..common_methods import notify_admin
import pyramid.httpexceptions as exc

import json, os, logging, operator

log = logging.getLogger(__name__)
# from pprint import PrettyPrinter
# pprint = PrettyPrinter().pprint

### This is a weird way to solve the status 206 issue.
from michelanglo_app.views.buffer import system_storage

from .venus_base import VenusException, VenusBase


############################### Analyse the mutation
@view_defaults(route_name='venus')
class Venus(VenusBase):

    @property
    def handle(self):
        return self.request.params['uniprot'] + self.request.params['mutation']

    ############################### server main page
    @view_config(renderer="../../templates/venus/venus_main.mako")
    def main_view(self):
        return {'user': self.request.user, 'mutation_mode': 'main', **self.generic_data}

    ############################### Give a random view that will give a protein
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
                return {'name': name, 'uniprot': uniprot, 'taxid': '9606', 'species': 'human',
                        'mutation': f'p.{protein.sequence[i - 1]}{i}{to_resn}'}
            except IndexError:
                log.error(f'Impossible... pdb.x out of bounds in unicode for gene {uniprot}')
                continue

    @view_config(route_name='venus_debug', renderer="../../templates/venus/venus_debug.mako")
    def debug(self):
        return {'user': self.request.user, 'mutation_mode': 'main', **self.generic_data}

    ############################### Analyse
    @view_config(route_name='venus_analyse', renderer="json")
    def analyse(self):
        """
        View that does the analysis. Formerly returned html now returns json.
        The request has to contain each of following 'step', 'uniprot', 'species', 'mutation' fields.
        /venus_analyse?species=9606&uniprot=Q96C12&mutation=p.V123F&step=protein
        step can be protein
        Species is taxid. Human is 9606.

        :param request:
        :return: self.reply
        """
        ### check valid
        try:
            self.assert_malformed('uniprot', 'species', 'mutation')
            if 'step' not in self.request.params:
                step = None
            else:
                step = self.request.params['step']
            return self.do_step(step)
        except VenusException as err:
            log.info(err)
            return self.reply
        except Exception as err:
            if self.reply['status'] != 'error':
                # this is a new one.
                self.reply['status'] = 'error'
                self.reply['error'] = 'analysis'
                self.reply['msg'] = str(err)
            log.warning(f'Venus error {err.__class__.__name__}: {err}')
            notify_admin(f'Venus error {err.__class__.__name__}: {err}')
            log.debug(traceback.format_exc())
            return self.reply

    def has(self, key: Optional[str] = None) -> bool:
        # checks whether the protein object has a filled value (not the reply!)
        if self.handle not in system_storage:  # this is already done
            return False
        elif key is None:
            return True
        elif not hasattr(system_storage[self.handle], key):
            return False
        elif getattr(system_storage[self.handle], key) is None:
            return False
        else:
            return True

    @property
    def steps(self):
        return {'protein': self.protein_step,
                'mutation': self.mutation_step,
                'structural': self.structural_step,
                'ddG': self.ddG_step,
                'ddG_gnomad': self.ddG_gnomad_step}

    def do_step(self, step):
        # a likely API call
        if step is None:
            log.info(f'Full analysis requested by {User.get_username(self.request)}')
            map(lambda f: f(), self.steps)  # run all steps
            return self.reply
        # ajax
        elif step in self.steps.keys():
            # these have replies that stack
            self.steps[step]()
            return self.reply
        elif step == 'fv':
            ## this is the same as get_uniprot but does not redundantly redownload the data.
            if not self.has():
                self.protein_step()
            protein = system_storage[self.handle]
            return render_to_response(os.path.join("..", "..", "templates", "results", "features.js.mako"),
                                      {'protein': protein, 'featureView': '#fv', 'include_pdb': False}, self.request)
        elif step == 'extra':
            self.assert_malformed('extra', 'algorithm')
            self.extra_step(mutation=self.request.params['extra'], algorithm=self.request.params['algorithm'])
            return self.reply
        elif step == 'phosphorylate':
            self.phospho_step()
            return self.reply
        elif step == 'customfile':
            self.assert_malformed('pdb', 'filename')
            pdb = get_pdb_block_from_request(self.request)
            params = self.save_params()
            self.change_to_file(pdb, self.request.params['filename'], params)
            return self.reply
        else:
            self.request.response.status = 422
            return {'status': 'error', 'error': 'Unknown step'}

    ### STEP 1
    def protein_step(self):
        """
        Check mutations are valid
        """
        if self.has():  # this is already done (very unlikely/
            protein = system_storage[self.handle]
        else:
            log.info(f'Step 1 analysis requested by {User.get_username(self.request)}')
            uniprot = self.request.params['uniprot']
            taxid = self.request.params['species']
            mutation_text = self.request.params['mutation']
            ## Do analysis
            mutation = Mutation(mutation_text)
            protein = ProteinAnalyser(uniprot=uniprot, taxid=taxid)
            protein.load()
            protein.mutation = mutation
        # assess
        if not protein.check_mutation():
            log.info('protein mutation discrepancy error')
            discrepancy = protein.mutation_discrepancy()
            self.reply = {**self.reply, 'error': 'mutation', 'msg': discrepancy, 'status': 'error'}
            raise VenusException(discrepancy)
        else:
            system_storage[self.handle] = protein
            self.reply['protein'] = self.jsonable(protein)

    ### STEP 2
    def mutation_step(self):
        """
        Runs protein.predict_effect()
        """
        log.info(f'Step 2 analysis requested by {User.get_username(self.request)}')
        ## has the previous step been done?
        if not self.has():
            self.protein_step()
        # if protein.mutation has already run??
        # no shortcut useful.
        protein = system_storage[self.handle]
        protein.predict_effect()
        featpos = protein.get_features_at_position(protein.mutation.residue_index)
        featnear = protein.get_features_near_position(protein.mutation.residue_index)
        pos_percent = round(protein.mutation.residue_index / len(protein) * 100)
        self.reply['mutation'] = {**self.jsonable(protein.mutation),
                                  'features_at_mutation': featpos,
                                  'features_near_mutation': featnear,
                                  'position_as_protein_percent': pos_percent,
                                  'gnomAD_near_mutation': protein.get_gnomAD_near_position()}

        ### STEP 3

    def structural_step(self, structure=None):
        """
        runs protein.analyse_structure() iteratively until it works.
        """
        log.info(f'Step 3 analysis requested by {User.get_username(self.request)}')
        # previous done?
        if not self.has():
            self.mutation_step()
        protein = system_storage[self.handle]
        if not self.has('structural'):
            if structure is not None:
                protein.analyse_structure(structure)
            else:
                # do not use the stored values of pdbs, but get the swissmodel ones:
                try:
                    protein.retrieve_structures_from_swissmodel()
                except Exception as error:
                    msg = f'Swissmodel retrieval failed: {error.__class__.__name__}: {error}'
                    log.critical(msg)
                    notify_admin(msg)
                    self.reply['warnings'].append('Retrieval of latest PDB data failed (admin notified). '+
                                                  'Falling back onto stored data.')
                try:
                    protein.analyse_structure()
                except Exception as error: #ConnectionError: # failed to download model  # deubg
                    broken_structure = best = protein.get_best_model()
                    # ---- remove
                    if protein.swissmodel.count(broken_structure) != 0:
                        i = protein.swissmodel.index(broken_structure)
                        del protein.swissmodel[i]
                        source = 'Swissmodel'
                    elif protein.pdbs.count(broken_structure) != 0:
                        i = protein.pdbs.index(broken_structure)
                        del protein.pdbs[i]
                        source = 'RCSB PDB'
                    else:
                        raise ValueError('structure from mystery source')
                    # ---- logging
                    if isinstance(error, ConnectionError):
                        msg = f'{source} {broken_structure} could not be downloaded'
                        log.info(msg)
                        self.reply['warnings'].append(msg)
                    elif isinstance(error, ValueError):
                        msg = f'Residue missing in structure ({source}): {broken_structure.code} ({error})'
                        log.info(msg)
                        self.reply['warnings'].append(msg)
                    else: # this should not happen in step 3.
                        msg = f'Major issue ({error.__class__.__name__}) with model {broken_structure.code} ({error})'
                        self.reply['warnings'].append(msg)
                        log.critical(msg)
                        notify_admin(msg)
                    # ---- repeat
                    self.structural_step()
        if protein.structural:
            self.reply['structural'] = self.jsonable(protein.structural)
            self.reply['has_structure'] = True
        else:
            log.info('No structural data available')
            self.reply['status'] = 'terminated'
            self.reply['error'] = 'No crystal structures or models available.'
            self.reply['msg'] = 'Structrual analyses cannot be performed.'
            self.reply['has_structure'] = False
            raise VenusException(self.reply['msg'])

    ### Step 4
    def ddG_step(self):
        log.info(f'Step 4 analysis requested by {User.get_username(self.request)}')
        # ------- get protein
        if self.handle not in system_storage:
            status = self.protein_step()
            if 'error' in status:
                return status
            status = self.mutation_step()
            if 'error' in status:
                return status
        protein = system_storage[self.handle]
        # -------- analyse
        if hasattr(protein, 'energetics') and protein.energetics is not None:
            analysis = protein.energetics
        else:
            analysis = protein.analyse_FF()
        if 'error' in analysis:
            self.log_if_error('pyrosetta step', analysis)
        else:
            self.reply['ddG'] = analysis
            # {ddG: float, scores: Dict[str, float], native:str, mutant:str, rmsd:int}

    ### Step 5
    def ddG_gnomad_step(self):
        log.info(f'Step 5 analysis requested by {User.get_username(self.request)}')
        if self.handle not in system_storage:
            status = self.protein_step()
            if 'error' in status:
                return status
            status = self.mutation_step()
            if 'error' in status:
                return status
        protein = system_storage[self.handle]
        if hasattr(protein, 'energetics_gnomAD') and protein.energetics_gnomAD is not None:
            analysis = protein.energetics_gnomAD
        else:
            analysis = protein.analyse_gnomad_FF()
        if 'error' in analysis:  # it is a failure.
            self.log_if_error('ddG_gnomad_step', analysis)
            self.reply['status'] = 'error'
            self.reply['error'] = 'pyrosetta step'
            self.reply['msg'] = analysis['error']
        else:
            self.reply['gnomAD_ddG'] = analysis

    ### STEP EXTRA
    def extra_step(self, mutation, algorithm):
        if self.has():
            self.ddG_step()
        protein = system_storage[self.handle]
        log.info(f'Extra analysis ({algorithm}) requested by {User.get_username(self.request)}')
        self.reply = {**self.reply, **protein.analyse_other_FF(mutation=mutation, algorithm=algorithm, spit_process=True)}
        self.log_if_error('extra_step')

    ### STEP EXTRA2
    def phospho_step(self):
        if self.has():
            self.ddG_step()
        protein = system_storage[self.handle]
        log.info(f'Phosphorylation requested by {User.get_username(self.request)}')
        coordinates = protein.phosphorylate_FF(spit_process=True)
        if isinstance(coordinates, str):
            self.reply['coordinates'] = coordinates
        elif isinstance(coordinates, dict):
            self.reply = {**self.reply, **coordinates}  # it is an error msg!
        else:
            self.reply = {**self.reply, 'status': 'error', 'error': 'Unknown', 'msg': 'No coordinates returned'}
        self.log_if_error('phospho_step')

    ### CHANGE STEP
    def change_to_file(self, block, name, params: List[str] = ()):
        # params is either None or a list of topology files
        if self.has():
            self.mutation_step()
        protein = system_storage[self.handle]
        protein.structural = None
        protein.energetics = None
        protein.rosetta_params_filenames = params
        title, ext = os.path.splitext(name)
        structure = Structure(title, 'Custom', 0, 9999, title,
                              type='custom', chain="A", offset=0, coordinates=block)
        structure.is_satisfactory(protein.mutation.residue_index)
        self.structural_step(structure=structure)
        return self.reply

    def save_params(self) -> List[str]:
        """
        Confusingly, by params I mean Rosetta topology files
        saves params : str to params as filenames
        """
        if 'params' in self.request.params:
            params = self.request.params['params']
        elif 'params[]' in self.request.params:
            params = self.request.params.getall('params')
        else:
            params = []
        temp_folder = os.path.join('michelanglo_app', 'temp')
        if not os.path.exists(temp_folder):
            os.mkdir(temp_folder)
        files = []
        for param in params:  # it should be paramses
            n = len(os.listdir(temp_folder))
            file = os.path.join(temp_folder, f'{n:0>3}.params')
            with open(file, 'w') as w:
                w.write(param)
            files.append(file)
        return files