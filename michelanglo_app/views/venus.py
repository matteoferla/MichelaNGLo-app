__description___ = """

"""

###########
# venus_create is in page_creation.py

from .uniprot_data import *
#ProteinCore organism human uniprot2pdb
from michelanglo_protein import ProteinAnalyser, Mutation, ProteinCore

from ..models import User ##needed solely for log.
from .common_methods import is_malformed
from . import custom_messages

import random
from pyramid.view import view_config, view_defaults
from pyramid.renderers import render_to_response


import json, os, logging
log = logging.getLogger(__name__)
from pprint import PrettyPrinter
pprint = PrettyPrinter().pprint

### This is a weird way to solve the status 206 issue.
from .buffer import system_storage

def jsonable(self):
    def deobjectify(x):
        if isinstance(x, dict):
            return {k: deobjectify(x[k]) for k in x}
        elif isinstance(x, list) or isinstance(x, set):
            return [deobjectify(v) for v in x]
        elif isinstance(x, int) or isinstance(x, float):
            return x
        else:
            return str(x) # really ought to deal with falseys.
    return {a: deobjectify(getattr(self, a, '')) for a in self.__dict__}

############################### Analyse the mutation
@view_defaults(route_name='venus')
class Venus:

    def __init__(self, request):
        self.request = request


    @property
    def handle(self):
        return self.request.params['uniprot'] + self.request.params['mutation']

    ############################### server main page
    @view_config(renderer="../templates/venus/venus_main.mako")
    def main_view(self):
        return {'project': 'VENUS',
                'user': self.request.user,
                'bootstrap': 4,
                'current_page': 'venus',
                'custom_messages': json.dumps(custom_messages),
                'meta_title': 'Michelaɴɢʟo: sculpting protein views on webpages without coding.',
                'meta_description': 'Convert PyMOL files, upload PDB files or submit PDB codes and ' + \
                                    'create a webpage to edit, share or implement standalone on your site',
                'meta_image': '/static/tim_barrel.png',
                'meta_url': 'https://michelanglo.sgc.ox.ac.uk/'
                }

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
        :return:
        """
        ### check valid
        malformed = is_malformed(self.request, 'uniprot', 'species', 'mutation')
        if malformed:
            return {'status': malformed}
        if 'step' not in self.request.params:
            log.info(f'Full analysis requested by {User.get_username(self.request)}')
            return {**self.protein_step(),
                    **self.mutation_step(),
                    **self.structural_step(),
                    **self.ddG_step(),
                    **self.ddG_gnomad_step()}
        if self.request.params['step'] == 'protein':
            return self.protein_step()
        elif self.request.params['step'] == 'mutation':
            return self.mutation_step()
        elif self.request.params['step'] == 'structural':
            return self.structural_step()
        elif self.request.params['step'] == 'ddG':
            return self.ddG_step()
        elif self.request.params['step'] == 'ddG_gnomad':
            return self.ddG_gnomad_step()
        elif self.request.params['step'] == 'fv':
            ## this is the same as get_uniprot but does not redundantly redownload the data.
            if self.handle not in system_storage:
                self.protein_step()
            protein = system_storage[self.handle]
            return render_to_response("../templates/results/features.js.mako",
                                      {'protein': protein, 'featureView': '#fv', 'include_pdb': False}, self.request)
        elif self.request.params['step'] == 'extra':
            malformed = is_malformed(self.request, 'extra', 'algorithm')
            if malformed:
                return {'status': malformed}
            return self.extra_step(mutation=self.request.params['extra'], algorithm=self.request.params['algorithm'])
        else:
            self.request.response.status = 422
            return {'status': 'error', 'error': 'Unknown step'}

    ### STEP 1
    def protein_step(self):
        log.info(f'Step 1 analysis requested by {User.get_username(self.request)}')
        uniprot = self.request.params['uniprot']
        taxid = self.request.params['species']
        mutation_text = self.request.params['mutation']
        ## Get analysis from memory if possible.
        handle = uniprot + mutation_text
        # if handle in system_storage:
        #     protein = system_storage[handle]
        #     return {'protein': jsonable(protein), 'status': 'success'}
        ## Do analysis
        mutation = Mutation(mutation_text)
        protein = ProteinAnalyser(uniprot=uniprot, taxid=taxid)
        try:
            protein.load()
        except FutureWarning:
            log.error(f'There was no pickle for uniprot {uniprot} taxid {taxid}. TREMBL code via API?')
            # protein.__dict__ = ProteinGatherer(uniprot=uniprot, taxid=taxid).get_uniprot().__dict__
        protein.mutation = mutation
        if not protein.check_mutation():
            log.info('protein mutation discrepancy error')
            return {'error': 'mutation', 'msg': protein.mutation_discrepancy(), 'status': 'error'}
        else:
            system_storage[handle] = protein
            return {'protein': jsonable(protein), 'status': 'success'}

    ### STEP 2
    def mutation_step(self):
        """
        Runs protein.predict_effect()
        """
        log.info(f'Step 2 analysis requested by {User.get_username(self.request)}')
        ## has the previous step been done?
        if self.handle not in system_storage:
            status = self.protein_step()
            if 'error' in status:
                return status
        # if protein.mutation has already run??
        # no shortcut useful.
        protein = system_storage[self.handle]
        protein.predict_effect()
        featpos = protein.get_features_at_position(protein.mutation.residue_index)
        featnear = protein.get_features_near_position(protein.mutation.residue_index)
        return {'mutation': {**jsonable(protein.mutation),
                             'features_at_mutation': featpos,
                             'features_near_mutation': featnear,
                             'position_as_protein_percent': round(
                                 protein.mutation.residue_index / len(protein) * 100),
                             'gnomAD_near_mutation': protein.get_gnomAD_near_position()},
                'status': 'success'}

    ### STEP 3
    def structural_step(self):
        """
        runs protein.analyse_structure()
        """
        log.info(f'Step 3 analysis requested by {User.get_username(self.request)}')
        if self.handle not in system_storage:
            status = self.protein_step()
            if 'error' in status:
                return status
            status = self.mutation_step()
            if 'error' in status:
                return status
            status = self.structural_step()
            if 'error' in status:
                return status
        protein = system_storage[self.handle]
        if hasattr(protein, 'structural') and protein.structural is not None:
            return {'structural': jsonable(protein.structural),
                    'status': 'success'}
        try:
            protein.analyse_structure()
            if protein.structural:
                return {'structural': jsonable(protein.structural),
                        'status': 'success'}
            else:
                log.info('No structural data available')
                return {'status': 'terminated', 'error': 'No crystal structures or models available.',
                        'msg': 'Structrual analyses cannot be performed.'}
        except NotImplementedError as err:  # Exception
            log.warning(f'Structural analysis failed {err} {type(err).__name__}.')
            return {'status': 'error'}

    ## Step 4
    def ddG_step(self):
        log.info(f'Step 4 analysis requested by {User.get_username(self.request)}')
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
            self.log_if_error('extra_step', analysis)
            return {'status': 'error', 'error': 'pyrosetta step', 'msg': analysis['error']}
        else:
            return {'ddG': analysis}  # {ddG: float, scores: Dict[str, float], native:str, mutant:str, rmsd:int}

    ## Step 5
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
        if 'error' in analysis:
            self.log_if_error('ddG_gnomad_step', analysis)
            return {'status': 'error', 'error': 'pyrosetta step', 'msg': analysis['error']}
        else:
            return {'gnomAD_ddG': analysis}

    def extra_step(self, mutation, algorithm):
        if self.handle not in system_storage:
            status = self.ddG_step()
            if 'error' in status:
                return status
        protein = system_storage[self.handle]
        log.info(f'Extra analysis ({algorithm}) requested by {User.get_username(self.request)}')
        response = protein.analyse_other_FF(mutation=mutation, algorithm=algorithm, spit_process=True)
        self.log_if_error('extra_step', response)
        return response

    def log_if_error(self, operation,response):
        if isinstance(response, dict):
            if 'error' in response and 'msg' in response:
                log.warning(f'Error during {operation}: {response["error"]} ({response["msg"]})')
            elif 'error' in response:
                log.warning(f'Error during {operation}: {response["error"]}')


