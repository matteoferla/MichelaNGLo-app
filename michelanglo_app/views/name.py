from ._common_methods import *
from pyramid.view import view_config
from pyramid.renderers import render_to_response
import json, os
from protein.generate import ProteinGatherer
ProteinGatherer.settings.init(os.environ['PROTEIN_DATA'])
## the folder dictionary has the cross ref files.
organism = json.load(open(os.path.join(ProteinGatherer.settings.dictionary_folder,'organism.json')))
human = json.load(open(os.path.join(ProteinGatherer.settings.dictionary_folder, 'taxid9606-names2uniprot.json')))
uniprot2pdb = json.load(open(os.path.join(ProteinGatherer.settings.dictionary_folder, 'uniprot2pdb.json')))

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
        elif len(name) < 4:
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
            genedex = json.load(open(os.path.join('..', 'Michelanglo-data', 'gene2uniprot', f'taxid{species}-names2uniprot.json')))
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
        elif len(gene) > 2:
            lowname = gene.lower()
            options = [k for k in genedex if lowname in k.lower()]
            return {'options': options}
        else:
            return {'invalid': True}
    elif request.params['item'] == 'get_pdbs':
        ### gets the metadata for a given PDB list
        malformed = is_malformed(request, 'entries', 'uniprot')
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
    elif request.params['item'] == 'get_pdb':
        ### gets the metadata for a given PDB code
        malformed = is_malformed(request, 'entry')
        if malformed:
            return {'status': malformed}
        entry = request.params['entry']
        log.info(f'{User.get_username(request)} wants pdb info')
        #PDBMeta is in common methods
        try:
            return PDBMeta(entry).describe()
        except KeyError:
            return {'status': "removed protein"}
    elif request.params['item'] == 'get_uniprot':
        malformed = is_malformed(request, 'uniprot', 'species')
        if malformed:
            return {'status': malformed}
        uniprot = request.params['uniprot']
        taxid = request.params['species']
        log.info(f'{User.get_username(request)} wants uniprot data')
        protein = ProteinGatherer(uniprot=uniprot, taxid=taxid)
        try:
            protein.load()
        except:
            log.warn(f'There was no pickle for uniprot {uniprot} taxid {taxid}')
            protein.get_uniprot()
        return render_to_response("../templates/results/features.js.mako", {'protein': protein}, request)
    else:
        request.response.status = 400
        return {'status': 'unknown cmd'}