__description___ = """

"""

###########
# venus_create is in page_creation.py

from .uniprot_data import *
#ProteinCore organism human uniprot2pdb
from michelanglo_protein import ProteinAnalyser, Mutation, ProteinCore, Structure

from ..models import User, Page ##needed solely for log.
from .common_methods import is_malformed, notify_admin, get_pdb_block_from_request
from .user_management import permission
from . import custom_messages

from typing import Optional, Any, List, Union
import random
from pyramid.view import view_config, view_defaults
from pyramid.renderers import render_to_response
import pyramid.httpexceptions as exc


import json, os, logging
log = logging.getLogger(__name__)
# from pprint import PrettyPrinter
# pprint = PrettyPrinter().pprint

### This is a weird way to solve the status 206 issue.
from .buffer import system_storage

######################

class VenusException(Exception):
    pass

generic_data = {'project': 'VENUS',
            #'user': None,
            'bootstrap': 4,
            'current_page': 'venus',
            'custom_messages': json.dumps(custom_messages),
            'meta_title': 'Michelaɴɢʟo: sculpting protein views on webpages without coding.',
            'meta_description': 'Convert PyMOL files, upload PDB files or submit PDB codes and ' + \
                                'create a webpage to edit, share or implement standalone on your site',
            'meta_image': '/static/tim_barrel.png',
            'meta_url': 'https://michelanglo.sgc.ox.ac.uk/'
            }


class VenusBase:
    """
    Methods common to both venus and multivenus...
    """

    def __init__(self, request):
        self.request = request
        self.reply = {'status': 'success'} # filled by the steps and kept even if an error is raised.
        # status=error, error=single-word, msg=long

    def assert_malformed(self, *args):
        malformed = is_malformed(self.request, *args)
        if malformed:
            self.reply['status'] = 'error'
            self.reply['error']= 'malformed request'
            self.reply['msg']= malformed
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
                return None # not an error.
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


############################### Analyse the mutation
@view_defaults(route_name='venus')
class Venus(VenusBase):

    @property
    def handle(self):
        return self.request.params['uniprot'] + self.request.params['mutation']

    ############################### server main page
    @view_config(renderer="../templates/venus/venus_main.mako")
    def main_view(self):
        return {'user': self.request.user, 'mutation_mode': 'main', **generic_data}

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
            i = random.randint(pdb.x, pdb.y)
            try:
                return {'name': name, 'uniprot': uniprot, 'taxid': '9606', 'species': 'human',
                        'mutation': f'p.{protein.sequence[i - 1]}{i}{random.choice(Mutation.aa_list)}'}
            except IndexError:
                log.error(f'Impossible... pdb.x out of bounds in unicode for gene {uniprot}')
                continue

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
            return self.reply

    def has(self, key: Optional[str]=None) -> bool:
        # checks whether the protein object has a filled value (not the reply!)
        if self.handle not in system_storage: # this is already done
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
            map(lambda f: f(), self.steps)  #run all steps
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
            return render_to_response("../templates/results/features.js.mako",
                                      {'protein': protein, 'featureView': '#fv', 'include_pdb': False}, self.request)
        elif step == 'extra':
            self.assert_malformed('extra', 'algorithm')
            self.extra_step(mutation=self.request.params['extra'], algorithm=self.request.params['algorithm'])
            return self.reply
        elif step== 'phosphorylate':
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
        if self.has(): # this is already done (very unlikely/
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
            self.reply = {'error': 'mutation', 'msg': discrepancy, 'status': 'error'}
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
        self.reply['mutation'] = {**self.jsonable(protein.mutation),
                             'features_at_mutation': featpos,
                             'features_near_mutation': featnear,
                             'position_as_protein_percent': round(
                                 protein.mutation.residue_index / len(protein) * 100),
                             'gnomAD_near_mutation': protein.get_gnomAD_near_position()}

        ### STEP 3
    def structural_step(self, structure=None):
        """
        runs protein.analyse_structure()
        """
        log.info(f'Step 3 analysis requested by {User.get_username(self.request)}')
        # previous done?
        if not self.has():
            self.mutation_step()
        elif self.has('structural'):
            protein = system_storage[self.handle]
        else:
            protein = system_storage[self.handle]
            protein.analyse_structure(structure)
        if protein.structural:
            self.reply['structural'] = self.jsonable(protein.structural)
            self.reply['has_structure'] = True
        else:
            log.info('No structural data available')
            self.reply['status'] = 'terminated'
            self.reply['error'] = 'No crystal structures or models available.'
            self.reply['msg'] = 'Structrual analyses cannot be performed.'
            self.reply['has_structure']=False
            raise VenusException(self.reply['msg'])

    ### Step 4
    def ddG_step(self):
        log.info(f'Step 4 analysis requested by {User.get_username(self.request)}')
        # previous done?
        if not self.has():
            self.structural_step()
        elif self.has('energetics'):
            protein = system_storage[self.handle]
            analysis = protein.energetics
        else:
            protein = system_storage[self.handle]
            analysis = protein.analyse_FF()


        if self.handle not in system_storage:
            status = self.protein_step()
            if 'error' in status:
                return status
            status = self.mutation_step()
            if 'error' in status:
                return status
        protein = system_storage[self.handle]
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
        if 'error' in analysis: # it is a failure.
            self.log_if_error('ddG_gnomad_step', analysis)
            self.reply['status']='error'
            self.reply['error']='pyrosetta step'
            self.reply['msg']=analysis['error']
        else:
            self.reply['gnomAD_ddG'] = analysis

    ### STEP EXTRA
    def extra_step(self, mutation, algorithm):
        if self.has():
            self.ddG_step()
        protein = system_storage[self.handle]
        log.info(f'Extra analysis ({algorithm}) requested by {User.get_username(self.request)}')
        self.reply = protein.analyse_other_FF(mutation=mutation, algorithm=algorithm, spit_process=True)
        self.log_if_error('extra_step')

    ### STEP EXTRA2
    def phospho_step(self):
        if self.has():
            self.ddG_step()
        protein = system_storage[self.handle]
        log.info(f'Phosphorylation requested by {User.get_username(self.request)}')
        coordinates = protein.phosphorylate_FF(spit_process=True)
        if isinstance(coordinates, str):
            self.reply = {'coordinates': coordinates}
        elif isinstance(coordinates, dict):
            self.reply = coordinates # it is an error msg!
        else:
            self.reply = {'status': 'error', 'error': 'Unknown', 'msg': 'No coordinates returned'}
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
                              type='custom',chain="A",offset=0, coordinates=block)
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
        for param in params: # it should be paramses
            n = len(os.listdir(temp_folder))
            file = os.path.join(temp_folder, f'{n:0>3}.params')
            with open(file, 'w') as w:
                w.write(param)
            files.append(file)
        return files


########################################################################################################################

@view_config(route_name='venus_multiple', renderer="../templates/venus/venus_multiple.mako")
def venus_multiple_view(request):
    return {'user': request.user, 'mutation_mode': 'multi', **generic_data}

@view_defaults(route_name='venus_multianalyse')
class MultiVenus(VenusBase):

    def __init__(self, request):
        super().__init__(request) #self.request and self.reply
        # whereas Venus is Stateful (stores data), Venus_multi is restful (does not store data)
        self.protein = None
        self.uniprot = None
        self.taxid = None
        self.mutations = None
        self.structure = None

    @view_config(renderer="json")
    def analyse(self):
        log.info(f'Multivenus requested by {User.get_username(self.request)}')
        try:
            self.assert_malformed('uniprot', 'species', 'mutations')
            self.uniprot = self.request.params['uniprot']
            self.taxid = self.request.params['species']
            self.mutations = self.request.params['mutations'].split()
            self.protein = self.load_protein() # ProteinAnalyser
            self.structure = self.load_structure() #Union[Structure, None]
            self.check_mutations()
            self.find_best() # does nothing.
        except VenusException:
            pass
        return self.reply

    def load_protein(self) -> ProteinAnalyser:
        protein = ProteinAnalyser(uniprot=self.uniprot, taxid=self.taxid)
        protein.load()
        self.reply['protein'] = self.jsonable(protein)
        return protein

    def load_structure(self) -> Union[Structure, None]:
        if 'pdbblock' in self.request.params:
            pdbblock = self.request.params['pdbblock']
            raise NotImplementedError
            structure = Structure(title, 'Custom', 0, 9999, title,
                                  type='custom', chain="A", offset=0, coordinates=pdbblock)
            structure.is_satisfactory(protein.mutation.residue_index)
            return structure
        else:
            return None

    def check_mutations(self):
        discrepancies = {mutation: self.check_mutation(mutation) for mutation in self.mutations}
        discrepancies = {mutation: discrepancy for mutation, discrepancy in discrepancies.items() if discrepancy is not None}
        if len(discrepancies) != 0:
            discrepancy = '\n'.join([f'{mutation}: {discrepancies[mutation]}.' for mutation in discrepancies])
            self.reply = {'error': 'mutation', 'msg': discrepancy, 'status': 'error'}
            raise VenusException(discrepancy)

    def check_mutation(self, mutation: str) -> Union[str, None]:
        ## Do analysis
        self.protein.mutation = Mutation(mutation)
        # assess
        if not self.protein.check_mutation():
            log.info('protein mutation discrepancy error')
            discrepancy = self.protein.mutation_discrepancy()
            return discrepancy
        else:
            return None

    def find_best(self):
        pass
        # self.protein.analyse_structure(self.structure)
        # get_best_model...
        # for l in (self.pdbs, self.swissmodel):
        #     if l:
        #         good = []
        #         for model in l:  # model is a structure object.
        #             if model.includes(self.mutation.residue_index):
        #                 good.append(model)
        #         if good:
        #             good.sort(key=lambda x: x.resolution)
        #             return good[0]
        #         else:  # no models with mutation.
        #             pass
        #     else:  # no models in group
        #         pass
        # return None


