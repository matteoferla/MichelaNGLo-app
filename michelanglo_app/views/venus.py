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
from pyramid.view import view_config
from pyramid.renderers import render_to_response


import json, os, logging
log = logging.getLogger(__name__)
from pprint import PrettyPrinter
pprint = PrettyPrinter().pprint

### This is a weird way to solve the status 206 issue.
from .buffer import system_storage

@view_config(route_name='venus', renderer="../templates/venus/venus_main.mako")
def venus_view(request):
    return {'project': 'VENUS',
             'user': request.user,
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
def random_view(request):
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
                    'mutation': f'p.{protein.sequence[i-1]}{i}{random.choice(Mutation.aa_list)}'}
        except IndexError:
            log.error(f'Impossible... pdb.x out of bounds in unicode for gene {uniprot}')
            continue

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
@view_config(route_name='venus_analyse', renderer="json")
def analyse_view(request):
    """
    View that does the analysis. Formerly returned html now returns json.
    The request has to contain each of following 'step', 'uniprot', 'species', 'mutation' fields.
    /venus_analyse?species=9606&uniprot=Q96C12&mutation=p.V123F&step=protein
    step can be protein
    Species is taxid. Human is 9606.
    :param request:
    :return:
    """
    ### STEP 1
    def protein_step():
        uniprot = request.params['uniprot']
        taxid = request.params['species']
        mutation_text = request.params['mutation']
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
            #protein.__dict__ = ProteinGatherer(uniprot=uniprot, taxid=taxid).get_uniprot().__dict__
        protein.mutation = mutation
        if not protein.check_mutation():
            log.info('protein mutation discrepancy error')
            return {'error': 'mutation', 'msg': protein.mutation_discrepancy(), 'status': 'error'}
        else:
            system_storage[handle] = protein
            return {'protein': jsonable(protein), 'status': 'success'}
    ### STEP 2
    def mutation_step():
        """
        Runs protein.predict_effect()
        """
        handle = request.params['uniprot'] + request.params['mutation']
        ## has the previous step been done?
        if handle not in system_storage:
            status = protein_step()
            if 'error' in status:
                return status
        #if protein.mutation has already run??
        #no shortcut useful.
        protein = system_storage[handle]
        protein.predict_effect()
        featpos = protein.get_features_at_position(protein.mutation.residue_index)
        featnear = protein.get_features_near_position(protein.mutation.residue_index)
        return {'mutation': {**jsonable(protein.mutation),
                             'features_at_mutation': featpos,
                             'features_near_mutation': featnear,
                             'position_as_protein_percent': round(protein.mutation.residue_index/len(protein)*100),
                             'gnomAD_near_mutation': protein.get_gnomAD_near_position()},
                'status': 'success'}
    ### STEP 3
    def structural_step():
        """
        runs protein.analyse_structure()
        """
        handle = request.params['uniprot'] + request.params['mutation']
        if handle not in system_storage:
            status = protein_step()
            if 'error' in status:
                return status
            status = mutation_step()
            if 'error' in status:
                return status
            status = structural_step()
            if 'error' in status:
                return status
        protein = system_storage[handle]
        if hasattr(protein, 'structural') and protein.structural is not None:
            return {'structural': jsonable(protein.structural),
                    'status': 'success'}
        try:
            protein.analyse_structure()
            if protein.structural:
                return {'structural': jsonable(protein.structural),
                        'status': 'success'}
            else:
                return {'status': 'terminated', 'error': 'No crystal structures or models available.', 'msg': 'Structrual analyses cannot be performed.'}
        except NotImplementedError as err:  #Exception
            log.warning(f'Structural analysis failed {err} {type(err).__name__}.')
            return {'status': 'error'}

    ## Step 4
    def ddG_step():
        handle = request.params['uniprot'] + request.params['mutation']
        if handle not in system_storage:
            status = protein_step()
            if 'error' in status:
                return status
            status = mutation_step()
            if 'error' in status:
                return status
        protein = system_storage[handle]
        if hasattr(protein, 'energetics') and protein.energetics is not None:
            analysis = protein.energetics
        else:
            analysis = protein.analyse_FF()
        if 'error' in analysis:
            return {'status': 'error', 'error': 'pyrosetta step', 'msg': analysis['error']}
        else:
            return {'ddG': analysis} #{ddG: float, scores: Dict[str, float], native:str, mutant:str, rmsd:int}

    ## Step 5
    def ddG_gnomad_step():
        handle = request.params['uniprot'] + request.params['mutation']
        if handle not in system_storage:
            status = protein_step()
            if 'error' in status:
                return status
            status = mutation_step()
            if 'error' in status:
                return status
        protein = system_storage[handle]
        if hasattr(protein, 'energetics_gnomAD') and protein.energetics_gnomAD is not None:
            analysis = protein.energetics_gnomAD
        else:
            analysis = protein.analyse_gnomad_FF()
        if 'error' in analysis:
            return {'status': 'error', 'error': 'pyrosetta step', 'msg': analysis['error']}
        else:
            return {'gnomAD_ddG': analysis}


    ### check valid
    malformed = is_malformed(request, 'uniprot', 'species', 'mutation')
    if malformed:
        return {'status': malformed}
    if 'step' not in request.params:
        log.info(f'Full analysis requested by {User.get_username(request)}')
        return {**protein_step(),
                **mutation_step(),
                **structural_step(),
                **ddG_step(),
                **ddG_gnomad_step()}
    if request.params['step'] == 'protein':
        log.info(f'Step 1 analysis requested by {User.get_username(request)}')
        return protein_step()
    elif request.params['step'] == 'mutation':
        log.info(f'Step 2 analysis requested by {User.get_username(request)}')
        return mutation_step()
    elif request.params['step'] == 'structural':
        log.info(f'Step 3 analysis requested by {User.get_username(request)}')
        return structural_step()
    elif request.params['step'] == 'ddG':
        log.info(f'Step 4 analysis requested by {User.get_username(request)}')
        return ddG_step()
    elif request.params['step'] == 'ddG_gnomad':
        return ddG_gnomad_step()
    elif request.params['step'] == 'fv': ## this is the same as get_uniprot but does not redundantly redownload the data.
        handle = request.params['uniprot'] + request.params['mutation']
        if handle not in system_storage:
            protein_step()
        protein = system_storage[handle]
        return render_to_response("../templates/results/features.js.mako", {'protein': protein, 'featureView': '#fv', 'include_pdb': False}, request)
    else:
        return {'status': 'error', 'error': 'Unknown step'}







