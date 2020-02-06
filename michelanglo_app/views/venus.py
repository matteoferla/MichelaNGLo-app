__description___ = """

"""

###########
# venus_create is in page_creation.py

from .uniprot_data import *
#ProteinCore organism human uniprot2pdb
from michelanglo_protein import ProteinAnalyser, Mutation, ProteinCore

from ..models import User ##needed solely for log.
from ._common_methods import is_malformed
from . import custom_messages

import random
from pyramid.view import view_config
from pyramid.renderers import render_to_response


import json, os, logging
log = logging.getLogger(__name__)
from pprint import PrettyPrinter
pprint = PrettyPrinter().pprint

### This is a weird way to solve the status 206 issue.
system_storage = {}

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
        mutation = Mutation(request.params['mutation'])
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
            handle = request.params['uniprot'] + request.params['mutation']
            system_storage[handle] = protein
            return {'protein': jsonable(protein), 'status': 'success'}
    ### STEP 2
    def mutation_step():
        handle = request.params['uniprot'] + request.params['mutation']
        if handle not in system_storage:
            status = protein_step()
            if 'error' in status:
                return status
        protein = system_storage[handle]
        protein.predict_effect()
        return {'mutation': {**jsonable(protein.mutation),
                             'features_near_mutation': protein.get_features_near_position(protein.mutation.residue_index),
                             'position_as_protein_percent': round(protein.mutation.residue_index/len(protein)*100),
                             'gnomAD_near_mutation': protein.get_gnomAD_near_position()},
                'status': 'success'}
    ### STEP 3
    def structural_step():
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
        return {'ddG': protein.analyse_FF()} #{ddG: float, scores: Dict[str, float], native:str, mutant:str, rmsd:int}



    ### check valid
    log.info(f'Analysis requested by {User.get_username(request)}')
    malformed = is_malformed(request, 'uniprot', 'species', 'mutation')
    if malformed:
        return {'status': malformed}
    if 'step' not in request.params:
        return {**protein_step(), **mutation_step(), **structural_step()}
    if request.params['step'] == 'protein':
        return protein_step()
    elif request.params['step'] == 'mutation':
        return mutation_step()
    elif request.params['step'] == 'structural':
        return structural_step()
    elif request.params['step'] == 'ddG':
        return ddG_step()
    elif request.params['step'] == 'fv': ## this is the same as get_uniprot but does not redundantly redownload the data.
        handle = request.params['uniprot'] + request.params['mutation']
        if handle not in system_storage:
            protein_step()
        protein = system_storage[handle]
        return render_to_response("../templates/results/features.js.mako", {'protein': protein, 'featureView': '#fv', 'include_pdb': False}, request)
    else:
        return {'status': 'error', 'error': 'Unknown step'}


"""
@view_config(route_name='venus_analyse', renderer="../templates/venus/venus_results.mako")
def analyse_view(request):
    log.info(f'Analysis requested by {User.get_username(request)}')
    malformed = is_malformed(request, 'uniprot', 'species', 'mutation')
    if malformed:
        return {'status': malformed}
    uniprot = request.params['uniprot']
    taxid = request.params['species']
    mutation = Mutation(request.params['mutation'])
    protein = ProteinAnalyser(uniprot=uniprot, taxid=taxid)
    try:
        protein.load()
    except:
        log.error(f'There was no pickle for uniprot {uniprot} taxid {taxid}. TREMBL code via API?')
        protein.__dict__ = ProteinGatherer(uniprot=uniprot, taxid=taxid).get_uniprot().__dict__
    protein.mutation = mutation
    if not protein.check_mutation():
        log.info('protein mutation discrepancy error')
        return render_to_response("json", {'error': 'mutation', 'msg': protein.mutation_discrepancy()}, request)
    else:
        protein.predict_effect()
        try:
            protein.analyse_structure()
        except Exception as err:
            log.warning(f'Structural analysis failed {err}.')
            pass
        return {'protein': protein, 'home': '/'}
"""





"""
        return render_to_response('json', {'error': msg}, request)
        error_response(protein.mutation_discrepancy(mutation))
    ### wait for all to finish
    protein.complete()
    protein.predict_effect(mutation)
    request.session['status']['step'] = 'complete'
    return {'protein': protein, 'mutation': protein.mutation}
except NotImplementedError as err:
    #traceback.print_exc(limit=3, file=sys.stdout)
    log.exception('Analysis error')
    return error_response(str(err)+' gave a '+err.__name__)
    











    def error_response(msg):
        request.session['status']['step'] = 'complete'
        log.warn(f'error during analysis {msg}')
        return render_to_response('json', {'error': msg}, request)

    if 'status' in request.session and request.session['status']['step'] != 'complete':
        return error_response('You have an ongoing analysis already for {g} {m}, which is at {s} step.'.format(g=request.session['status']['gene'],
                                                                                                          m=request.session['status']['mutation'],
                                                                                                          s=request.session['status']['step']))
    else:
        request.session['status'] = {'gene': '<parsing gene>', 'step': 'starting', 'mutation': '<parsing mutation>'}  # step = starting | complete | failed
    try:
        if request.POST['gene'] not in namedex:
            return error_response('The gene name is not valid.')
        ### load protein
        uniprot = namedex[request.POST['gene']]
        request.session['status']['gene'] = uniprot
        protein = ProteinLite(uniprot=uniprot).load() ## this only fails in dev mode with too few genes
        ### parse mutations
        mutation = Mutation(request.POST['mutation'])
        request.session['status']['mutation'] = str(mutation)
        if not protein.check_mutation(mutation):
            log.warn('protein mutation discrepancy error')
            return error_response(protein.mutation_discrepancy(mutation))
        ### wait for all to finish
        protein.complete()
        protein.predict_effect(mutation)
        request.session['status']['step'] = 'complete'
        return {'protein': protein, 'mutation': protein.mutation}
    except NotImplementedError as err:
        #traceback.print_exc(limit=3, file=sys.stdout)
        log.exception('Analysis error')
        return error_response(str(err)+' gave a '+err.__name__)











namedex = json.load(open('data/human_prot_namedex.json', 'r'))
#seqdex = json.load(open('data/human_prot_seqdex.json', 'r'))
#genedex = json.load(open('data/human_prot_genedex.json', 'r'))







@view_config(route_name='analyse', renderer="../templates/results.mako")
def analyse_view(request):

    if request.user:
        log.info(f'analysis for user {request.user.name}')
    else:
        log.info(f'analysis for unregisted user')

    def error_response(msg):
        request.session['status']['step'] = 'complete'
        log.warn(f'error during analysis {msg}')
        return render_to_response('json', {'error': msg}, request)

    if 'status' in request.session and request.session['status']['step'] != 'complete':
        return error_response('You have an ongoing analysis already for {g} {m}, which is at {s} step.'.format(g=request.session['status']['gene'],
                                                                                                          m=request.session['status']['mutation'],
                                                                                                          s=request.session['status']['step']))
    else:
        request.session['status'] = {'gene': '<parsing gene>', 'step': 'starting', 'mutation': '<parsing mutation>'}  # step = starting | complete | failed
    try:
        if request.POST['gene'] not in namedex:
            return error_response('The gene name is not valid.')
        ### load protein
        uniprot = namedex[request.POST['gene']]
        request.session['status']['gene'] = uniprot
        protein = ProteinLite(uniprot=uniprot).load() ## this only fails in dev mode with too few genes
        ### parse mutations
        mutation = Mutation(request.POST['mutation'])
        request.session['status']['mutation'] = str(mutation)
        if not protein.check_mutation(mutation):
            log.warn('protein mutation discrepancy error')
            return error_response(protein.mutation_discrepancy(mutation))
        ### wait for all to finish
        protein.complete()
        protein.predict_effect(mutation)
        request.session['status']['step'] = 'complete'
        return {'protein': protein, 'mutation': protein.mutation}
    except NotImplementedError as err:
        #traceback.print_exc(limit=3, file=sys.stdout)
        log.exception('Analysis error')
        return error_response(str(err)+' gave a '+err.__name__)


############################### Check status


@view_config(route_name='task_check', renderer="json")
def status_check_view(request):
    if 'status' not in request.session:
        log.warn('missing job error')
        return {'error': 'No job found'}
    elif request.session['status']['step'] != 'complete':
        return {'status': 'You have an ongoing analysis for {g} {m}, which is at {s} step.'.format(g=request.session['status']['gene'],
                                                                                                   m=request.session['status']['mutation'],
                                                                                                   s=request.session['status']['step'])}
    else:
        return {'status': 'Analysis for {g} {m} is complete.'.format(g=request.session['status']['gene'],
                                                                     m=request.session['status']['mutation']),
                'complete': True}



"""








