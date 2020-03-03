
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
