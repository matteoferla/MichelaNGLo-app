from ._common_methods import *
from pyramid.view import view_config
import json, os

organism = json.load(open(os.path.join('michelanglo_app','orgdex.json')))

@view_config(route_name='choose_pdb', renderer='json')
def choose_pdb(request):
    """

    :param request: item = match species | match gene; name: species str to be matched; get {species: taxid; gene: str)
    :return:
    """
    malformed = is_malformed(request, 'item')
    if malformed:
        return {'status': malformed}
    if request.params['item'] == 'match species':
        malformed = is_malformed(request, 'name')
        if malformed:
            return {'status': malformed}
        name = request.params['name']
        if not name:
            return {'options': 'many'}
        elif name in organism:
            return {'taxid': organism[name]}
        elif name.title() in organism:
            return {'taxid': organism[name.title()]}
        elif len(name) < 5:
            return {'options': 'many'}
        else:
            lowname = name.lower()
            options = [k for k in organism if lowname in k.lower()]
            return {'options': options}
    elif request.params['item'] == 'match gene':
        malformed = is_malformed(request, 'species', 'gene')
        if malformed:
            return {'status': malformed}
        species = int(request.params['species'])
        gene = str(request.params['gene'])
        if not gene:
            return {'invalid': True}
        genedex = json.load(open(os.path.join('..', 'Michelanglo-data', 'gene2pdb', f'tax{species}_prot_namedex.json')))
        if gene in genedex:
            return {'pdbs': genedex[gene]}
        elif gene.upper() in genedex:
            g = gene.upper()
            return {'pdbs': genedex[g], 'corrected_gene': g}
        elif gene.title() in genedex:
            g = gene.title()
            return {'pdbs': genedex[g], 'corrected_gene': g}
        else:
            return {'invalid': True}
    else:
        request.response.status = 400
        return {'status': 'unknown cmd'}

