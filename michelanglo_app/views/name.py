from ._common_methods import *
from pyramid.view import view_config
import json, os
print('Michelanglo-data is at present hard coded as ../Michelanglo-data')
organism = json.load(open(os.path.join('..', 'Michelanglo-data','organism.json')))
human = json.load(open(os.path.join('..', 'Michelanglo-data', 'gene2uniprot', 'taxid9606-names2uniprot.json')))
uniprot2pdb = json.load(open(os.path.join('..', 'Michelanglo-data', 'uniprot2pdb.json')))

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
        if species == 9606:
            genedex = human
        else:
            genedex = json.load(open(os.path.join('..', 'Michelanglo-data', 'gene2pdb', f'tax{species}_prot_namedex.json')))
        if gene in genedex:
            u = genedex[gene]
            if u in uniprot2pdb:
                return {'uniprot': u, 'pdbs': uniprot2pdb[u]}
            else:
                return {'uniprot': u, 'pdbs': []}
        elif gene.upper() in genedex:
            g = gene.upper()
            u = genedex[g]
            if u in uniprot2pdb:
                return {'uniprot': u, 'corrected_gene': g, 'pdbs': uniprot2pdb[u]}
            else:
                return {'uniprot': u, 'corrected_gene': g, 'pdbs': []}
        elif gene.title() in genedex:
            g = gene.title()
            u = genedex[g]
            if u in uniprot2pdb:
                return {'uniprot': u, 'corrected_gene': g, 'pdbs': uniprot2pdb[u]}
            else:
                return {'uniprot': u, 'corrected_gene': g, 'pdbs': []}
        else:
            return {'invalid': True}
    elif request.params['item'] == 'get_pdbs':
        malformed = is_malformed(request, 'entries')
        if malformed:
            return {'status': malformed}
        pdbs = request.params.getall('entries[]')
        log.info(f'{User.get_username(request)} wants pdb list')
        #PDBMeta is in common methods
        details = []
        for entry in pdbs:
            try:
                details.append(PDBMeta(entry).wordy_describe())
            except KeyError:
                pass # this protein was removed. We shalt speak of it.
        return {'descriptions': ' <br/> '.join(details)}
    else:
        request.response.status = 400
        return {'status': 'unknown cmd'}