__description___ = """

"""

from .uniprot_data import *
#ProteinCore organism human uniprot2pdb
from protein import ProteinAnalyser, Mutation, ProteinCore

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
        name = random.choice(human.keys())
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

############################### Analyse the mutation
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

@view_config(route_name='venus_analyse', renderer="../templates/venus/venus_results.mako")
def analyse_view(request):
    """
    View that does the analysis. Formerly returned html now returns json.
    :param request:
    :return:
    """
    log.info(f'Analysis requested by {User.get_username(request)}')
    malformed = is_malformed(request, 'step', 'uniprot', 'species', 'mutation')
    if malformed:
        return {'status': malformed}
    if request.params['step'] == 'start':
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
            return {'error': 'mutation', 'msg': protein.mutation_discrepancy()}
        else:
            handle = request.params['uniprot'] + request.params['mutation']
            system_storage[handle] = protein
            return {'protein': protein, 'home': '/'}


            protein.predict_effect()
            try:
                protein.analyse_structure()
            except Exception as err:
                log.warning(f'Structural analysis failed {err}.')
                pass



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








