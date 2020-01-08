from ._common_methods import *
from pyramid.view import view_config
from pyramid.renderers import render_to_response

from .uniprot_data import *
#ProteinCore organism human uniprot2pdb

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
        name = request.params['name'].strip()
        if not name: #empty name
            return {'options': 'many'}
        elif name in organism: #name exists!
            return {'taxid': organism[name]}
        elif name.title() in organism: #name exists and is formatted differently
            return {'taxid': organism[name.title()]}
        elif len(name) < 4: #too short.
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
            genedex = json.load(open(os.path.join(ProteinCore.settings.dictionary_folder, f'taxid{species}-names2uniprot.json')))
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
            if len(options):
                return {'options': options}
            elif gene[1:].isdigit():  # likely Uniprot id. What the hell, user.
                uni = json.load(open(os.path.join(ProteinCore.settings.dictionary_folder, 'uniprot2species.json')))
                if gene.upper() in uni:
                    tax = uni[gene.upper()]
                    return {'species_correction': [o for o,i in organism.items() if i == tax]}
            else:
                return {'options': []}
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
        malformed = is_malformed(request, 'pdb')
        if malformed:
            return {'status': malformed}
        pdb = request.params['pdb']
        log.info(f'{User.get_username(request)} wants pdb info')
        if 1 == 0: #via PDBe. PDBMeta is in common methods
            try:
                return PDBMeta(entry).describe()
            except KeyError:
                return {'status': "removed protein"}
        else:
            definitions = Structure(id=pdb, description='', x=0, y=0, code=pdb).lookup_sifts().chain_definitions
            return {'pdb': pdb, 'chains': definitions}
    ####### get_uniprot: uniprot > feature map as a js to excecute
    elif request.params['item'] == 'get_uniprot':
        malformed = is_malformed(request, 'uniprot', 'species')
        if malformed:
            return {'status': malformed}
        uniprot = request.params['uniprot']
        taxid = request.params['species']
        log.info(f'{User.get_username(request)} wants uniprot data')

        try:
            protein = ProteinCore(uniprot=uniprot, taxid=taxid).load()
        except:
            log.error(f'There was no pickle for uniprot {uniprot} taxid {taxid}. TREMBL code via API??')
            try:
                protein = ProteinGatherer(uniprot=uniprot, taxid=taxid).parse_uniprot()
            except:
                request.response.status = 410 #malformed
                return {'status': 'Unknown Uniprot code.'}
        return render_to_response("../templates/results/features.js.mako", {'protein': protein}, request)
    ######### get_name: uniprot > json of name
    elif request.params['item'] == 'get_name':   ### a smaller version...
        malformed = is_malformed(request, 'uniprot', 'species')
        if malformed:
            return {'status': malformed}
        uniprot = request.params['uniprot']
        taxid = request.params['species']
        log.info(f'{User.get_username(request)} wants uniprot data')
        try:
            protein = ProteinCore(uniprot=uniprot, taxid=taxid).load()
        except: # to do fix this.
            return {'uniprot': uniprot, 'gene_name': '???', 'recommended_name': 'different species',
                    'length': -1}
        return {'uniprot': uniprot, 'gene_name': protein.gene_name, 'recommended_name': protein.recommended_name, 'length': len(protein)}
    else:
        request.response.status = 400
        return {'status': 'unknown cmd'}