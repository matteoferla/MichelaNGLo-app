from __future__ import annotations

import random
import traceback
from time import sleep
from typing import Optional, List

from michelanglo_protein import ProteinAnalyser, Mutation, ProteinCore, Structure, is_alphafold_taxon  # noqa
from michelanglo_transpiler import PyMolTranspiler  # used solely for temp folder
from pyramid.renderers import render_to_response
from pyramid.view import view_config, view_defaults

from .venus_base import VenusException, VenusBase
from ..common_methods import Comms
from ..common_methods import get_pdb_block_from_request
from ..uniprot_data import *
from ..buffer import system_storage
from ...models import User  # needed solely for log.

log = logging.getLogger(__name__)


# ====================== Analyse the mutation ======================
# venus parts common to regular venus and multiple mutant version.
@view_defaults(route_name='venus')
class Venus(VenusBase):

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
        try:
            self.assert_malformed('uniprot', 'species', 'mutation')
            if 'step' not in self.request.params:
                step = None
            else:
                step = self.request.params['step']
            return self.do_step(step)
        except VenusException as err:
            # this is right at the top:
            # it should not be conditional to `self.suppress_errors`
            if self.suppress_errors:
                log.info(f'VenusException: {err}')
            else:
                log.warning(f'VenusException: {err} under debug mode')
            return self.reply
        except Exception as err:
            if self.reply['status'] != 'error':
                # this is a new one.
                self.reply['status'] = 'error'
                self.reply['error'] = 'analysis'
                self.reply['msg'] = str(err)
            log.warning(f'Venus error {err.__class__.__name__}: {err}')
            if 'Malformed error' not in str(err):
                Comms.notify_admin(f'Venus error {err.__class__.__name__}: {err}')
                log.debug(traceback.format_exc())
            return self.reply

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
            return self.reply
        # ajax
        elif step in self.steps.keys():
            # these have replies that stack
            self.steps[step]()
            return self.reply
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

    # ===== STEP 1 =======
    def protein_step(self):
        """
        Check mutations are valid
        """
        self.start_timer()
        if self.has():  # this is already done?
            protein = system_storage[self.handle]
        else:
            log.info(f'Step 1 analysis requested by {User.get_username(self.request)}')
            uniprot = self.request.params['uniprot']
            taxid = self.request.params['species']
            mutation_text = self.request.params['mutation']
            # ## Do analysis
            mutation = Mutation(mutation_text)
            protein = ProteinAnalyser(uniprot=uniprot,
                                      taxid=taxid)
            assert protein.exists(), f'{uniprot} of {taxid} is absent'
            protein.load()
            protein.mutation = mutation
            setattr(protein, 'current_step_complete', False)  # venus specific
        # assess
        if not protein.check_mutation():
            log.info('protein mutation discrepancy error')
            discrepancy = protein.mutation_discrepancy()
            self.reply = {**self.reply,
                          'error':  'mutation',
                          'msg':    discrepancy,
                          'status': 'error'}
            raise VenusException(discrepancy)
        else:
            system_storage[self.handle] = protein
            self.reply['protein'] = self.jsonable(protein)
        protein.current_step_complete = True
        self.stop_timer()

    # ======= STEP 2 =======
    def mutation_step(self) -> None:
        """
        Runs protein.predict_effect()
        """
        self.start_timer()
        log.info(f'Step 2 analysis requested by {User.get_username(self.request)}')
        # ## has the previous step been done?
        if not self.has():
            self.protein_step()
        # if protein.mutation has already run it still does it again...
        # no shortcut useful.
        protein = system_storage[self.handle]
        protein.current_step_complete = False
        protein.predict_effect()
        featpos = protein.get_features_at_position(protein.mutation.residue_index)
        featnear = protein.get_features_near_position(protein.mutation.residue_index)
        pos_percent = round(protein.mutation.residue_index / len(protein) * 100)
        self.reply['mutation'] = {**self.jsonable(protein.mutation),
                                  'features_at_mutation':        featpos,
                                  'features_near_mutation':      featnear,
                                  'position_as_protein_percent': pos_percent,
                                  'gnomAD_near_mutation':        protein.get_gnomAD_near_position()}
        protein.current_step_complete = True
        self.stop_timer()

    # ======= STEP 3 =======
    def structural_step(self, structure=None, retrieve=True):
        """
        runs protein.analyse_structure() iteratively until it works.
        """
        self.start_timer()
        log.info(f'Step 3 analysis requested by {User.get_username(self.request)}')
        # previous done?
        if not self.has():
            self.mutation_step()
        protein = system_storage[self.handle]
        # this is slightly odd because structural None is either not done or no model
        if self.has('structural'):
            self.reply['structural'] = self.jsonable(protein.structural)
            self.reply['has_structure'] = True
        elif protein.current_step_complete is False:
            while protein.current_step_complete is False:  # polling
                log.debug('Waiting for structural_step')
                sleep(5)
            return self.structural_step(structure, retrieve)  # retry
        else:
            # this step has not been run before
            protein.current_step_complete = False
            if structure is not None:  # user submitted structure.
                protein.analyse_structure(structure=structure,
                                          **self.get_user_modelling_options()
                                          )
            else:
                self.structural_workings(protein, retrieve)
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
        protein.current_step_complete = True
        self.stop_timer()

    # ===== Step 4 =====
    def ddG_step(self): # noqa ddG is not camelcase but abbreviation which is PEP8 compliant.
        self.start_timer()
        log.info(f'Step 4 analysis requested by {User.get_username(self.request)}')
        # ------- get protein
        if self.handle not in system_storage:
            for fun in (self.protein_step, self.mutation_step, self.structural_step):
                fun()
                if 'error' in self.reply:
                    return self.reply
        protein = system_storage[self.handle]
        # -------- analyse
        if self.has('energetics'):
            analysis = protein.energetics
        elif protein.current_step_complete is False:
            while protein.current_step_complete is False:  # polling
                log.debug('Waiting for ddG_step')
                sleep(5)
            return self.ddG_step()  # retry
        else:
            protein.current_step_complete = False
            applicable_keys = ('scorefxn_name', 'outer_constrained', 'remove_ligands',
                               'neighbour_only_score',
                               'scaling_factor', 'prevent_acceptance_of_incrementor',
                               'single_chain', 'radius', 'cycles')
            user_options = self.get_user_modelling_options()
            options = {k: v for k, v in user_options.items() if k in applicable_keys}
            # radius and cycle minima are applied already
            analysis = protein.analyse_FF(**options, spit_process=True)
        if analysis is None:
            self.log_if_error('pyrosetta step', 'likely segfault')
        elif 'error' in analysis:
            self.log_if_error('pyrosetta step', analysis)
        else:
            self.reply['ddG'] = analysis
            # {ddG: float, scores: Dict[str, float], native:str, mutant:str, rmsd:int}
        protein.current_step_complete = True
        self.stop_timer()

    # ====== Step 5 ======
    def ddG_gnomad_step(self):
        log.info(f'Step 5 analysis requested by {User.get_username(self.request)}')
        if self.handle not in system_storage:
            self.protein_step()
            if 'error' in self.reply:
                return self.reply['error']
            self.mutation_step()
            if 'error' in self.reply:
                return self.reply['error']
        protein = system_storage[self.handle]
        if self.has('energetics_gnomAD'):
            analysis = protein.energetics_gnomAD
        elif protein.current_step_complete is False:
            while protein.current_step_complete is False:  # polling
                log.debug('Waiting for ddG_gnomad_step')
                sleep(5)
            return self.ddG_gnomad_step()  # retry
        else:
            protein.current_step_complete = False
            applicable_keys = ('scorefxn_name', 'outer_constrained', 'remove_ligands',
                               'scaling_factor',
                               'single_chain', 'cycles', 'radius')
            options = {k: v for k, v in self.get_user_modelling_options().items() if k in applicable_keys}
            # speedy
            options['cycles'] = 1
            options['radius'] = min(6, options['radius'] if 'radius' in options else 6)
            analysis = protein.analyse_gnomad_FF(**options, spit_process=True)
        if analysis is None:
            analysis = dict(error='likely segfault', msg='likely segfault')
        if 'error' in analysis:  # it is a failure.
            self.log_if_error('ddG_gnomad_step', analysis)
            self.reply['status'] = 'error'
            self.reply['error'] = 'pyrosetta step'
            self.reply['msg'] = analysis['error']
        else:
            self.reply['gnomAD_ddG'] = analysis
        protein.current_step_complete = True

    # ======= STEP EXTRA =======
    def extra_step(self, mutation, algorithm):
        if self.has():
            self.ddG_step()
        protein = system_storage[self.handle]
        protein.current_step_complete = False
        log.info(f'Extra analysis ({algorithm}) requested by {User.get_username(self.request)}')
        applicable_keys = ('scorefxn_name', 'outer_constrained', 'remove_ligands',
                           'scaling_factor',
                           'single_chain', 'cycles', 'radius')
        options = {k: v for k, v in self.get_user_modelling_options().items() if k in applicable_keys}
        self.reply = {**self.reply,
                      **protein.analyse_other_FF(**options, mutation=mutation, algorithm=algorithm, spit_process=True)}
        self.log_if_error('extra_step')
        protein.current_step_complete = True

    # ========= STEP EXTRA2 =========
    def phospho_step(self):
        if self.has():
            self.ddG_step()
        protein = system_storage[self.handle]
        protein.current_step_complete = False
        log.info(f'Phosphorylation requested by {User.get_username(self.request)}')
        coordinates = protein.phosphorylate_FF(spit_process=True)
        if isinstance(coordinates, str):
            self.reply['coordinates'] = coordinates
        elif isinstance(coordinates, dict):
            self.reply = {**self.reply, **coordinates}  # it is an error msg!
        else:
            self.reply = {**self.reply, 'status': 'error', 'error': 'Unknown', 'msg': 'No coordinates returned'}
        self.log_if_error('phospho_step')
        protein.current_step_complete = True

    # ========= CHANGE STEP =========
    def change_to_file(self, block, name, params: List[str] = ()):
        # params is either None or a list of topology files
        if self.has():
            self.mutation_step()
        protein = system_storage[self.handle]
        protein.structural = None
        protein.energetics = None
        protein.current_step_complete = False
        protein.rosetta_params_filenames = params
        title, ext = os.path.splitext(name)
        structure = Structure(title, 'Custom', 0, 9999, title,
                              type='custom', chain="A", offset=0, coordinates=block)
        structure.is_satisfactory(protein.mutation.residue_index)
        self.structural_step(structure=structure)
        protein.current_step_complete = True
        return self.reply

    # ----- inner methods ----------------------------------------------------------------------------------------------

    def get_user_modelling_options(self):
        """
        User dictated choices.

        Note `debug` is in the VenusBase.__init__

        """
        user_modelling_options = {'allow_pdb':       True,
                                  'allow_swiss':     True,
                                  'allow_alphafold': True,
                                  'scaling_factor':  0.239,  # this is the kJ/mol <--> kcal/mol "mystery" value
                                  'no_conservation': False,  # Consurf SSL issue --> True
                                  }

        # ------ booleans
        for key in ['allow_pdb',
                    'allow_swiss',
                    'allow_alphafold',
                    'outer_constrained',
                    'neighbour_only_score',
                    'prevent_acceptance_of_incrementor',
                    'remove_ligands',
                    'single_chain',
                    'scaling_factor']:
            if key not in self.request.params:
                pass
            else:
                user_modelling_options[key] = self.request.params[key] not in (False, 0, 'false', '0')
        # ------ floats
        for key in ['swiss_oligomer_identity_cutoff', 'swiss_monomer_identity_cutoff',
                    'swiss_oligomer_qmean_cutoff', 'swiss_monomer_qmean_cutoff']:
            if key not in self.request.params:
                pass  # defaults from defaults in protein class. This must be an API call.
            else:
                user_modelling_options[key] = float(self.request.params[key])
        # ----- for ddG calculations.
        for key, minimum, maximum in (('cycles', 1, 5), ('radius', 8, 15)):
            if key in self.request.params:
                user_modelling_options[key] = max(minimum, min(maximum, int(self.request.params[key])))
            else:
                user_modelling_options[key] = minimum
                log.debug(f'No {key} provided...')
        # scorefxn... More are okay... but I really do not wish for users to randomly use these.
        allowed_names = ('ref2015', 'beta_july15', 'beta_nov16',
                         'ref2015_cart', 'beta_july15_cart', 'beta_nov16_cart')
        if 'scorefxn_name' in self.request.params and self.request.params['scorefxn_name'] in allowed_names:
            user_modelling_options['scorefxn_name'] = self.request.params['scorefxn_name']
        if 'custom_filename' in self.request.params:
            # this is required to make the hash unique.
            user_modelling_options['custom_filename'] = self.request.params['custom_filename']
        return user_modelling_options

    def structural_workings(self, protein, retrieve):
        """
        Inner function of step 3 structural_step
        """
        user_modelling_options = self.get_user_modelling_options()
        # try options
        # do not use the stored values of pdbs, but get the swissmodel ones (more uptodate)
        if retrieve:
            # if it is not a valid species nothing happens.
            # if the gene is not valid... then this record is wrong.
            protein.add_alphafold2()  # protein::alphafold2_retrieval::FromAlphaFold2
            # swissmodel
            try:
                if user_modelling_options['allow_pdb'] or user_modelling_options['allow_swiss']:
                    protein.retrieve_structures_from_swissmodel()  # protein::swissmodel_retrieval::FromSwissmodel
            except Exception as error:
                if not self.suppress_errors:
                    raise error
                msg = f'Swissmodel retrieval step failed: {error.__class__.__name__}: {error}'
                log.critical(msg)
                Comms.notify_admin(msg)
                self.reply['warnings'].append('Retrieval of latest PDB data failed (admin notified). ' +
                                              'Falling back onto stored data.')
        chosen_structure = None
        try:
            chosen_structure = protein.get_best_model(**user_modelling_options)
            # IMPORTANT PART ****************************************************
            # ------------- find the best and analyse it
            protein.analyse_structure(structure=chosen_structure,
                                      **user_modelling_options)
            # *******************************************************************
        except Exception as error:
            if not self.suppress_errors or chosen_structure is None:
                raise error
            # ConnectionError: # failed to download model...
            if protein.swissmodel.count(chosen_structure) != 0:
                protein.swissmodel.remove(chosen_structure)
                source = 'Swissmodel'
            elif protein.pdbs.count(chosen_structure) != 0:
                protein.pdbs.remove(chosen_structure)
                source = 'RCSB PDB'
            elif protein.alphafold2.count(chosen_structure) != 0:
                protein.alphafold2.remove(chosen_structure)
                source = 'AlphaFold2'
                msg = 'AlphaFold2 model was problematic'
                log.critical(msg)  # ideally should message admin.
            else:
                raise ValueError('structure from mystery source')
            # ---- logging
            if isinstance(error, ConnectionError):
                msg = f'{source} {chosen_structure} could not be downloaded'
                log.info(msg)
                self.reply['warnings'].append(msg)
            elif isinstance(error, ValueError):
                msg = f'Residue missing in structure ({source}): {chosen_structure.code} ({error})'
                log.info(msg)
                self.reply['warnings'].append(msg)
            else:
                # this should not happen in step 3.
                # causes: PDB given was a fake. How does that happen?
                # causes: the PBD given was too big. e.g. 7MQ8
                msg = f'Major issue ({error.__class__.__name__}) with model {chosen_structure.code} ({error})'
                self.reply['warnings'].append(msg)
                log.warning(msg)
                Comms.notify_admin(msg)
            # ---- repeat
            self.structural_step(retrieve=False)

    def save_params(self) -> List[str]:
        """
        Confusingly, by params I mean Rosetta topology files
        This could be done without saving to disk (cf. rdkit_to_params module)... One day will be fixed.

        saves params : str to params as filenames
        """
        if 'params' in self.request.params:
            params = self.request.params['params']
        elif 'params[]' in self.request.params:
            params = self.request.params.getall('params')
        else:
            params = []
        temp_folder = PyMolTranspiler.temporary_folder
        # TODO In many places the data is stored in the module!
        # In module page there is biggest offender.
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
