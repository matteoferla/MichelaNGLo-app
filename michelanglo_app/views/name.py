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
        return {'descriptions': ' <br/> '.join([PDBMeta(entry).describe() for entry in pdbs])}
    else:
        request.response.status = 400
        return {'status': 'unknown cmd'}


class PDBMeta:
    """
    Herein by chain the chain letter is meant, while the data of the chain is called entity... terrible.
    """
    def __init__(self, entry):
        self.code, self.chain = entry.split('_')
        reply = requests.get(f'http://www.ebi.ac.uk/pdbe/api/pdb/entry/molecules/{self.code}').json()
        self.data = reply[self.code.lower()]

    def get_data_by_chain(self, chain=None):
        if not chain:
            chain = self.chain
        return [entity for entity in self.data if chain in entity['in_chains']][0]

    def get_range_by_chain(self, chain=None):
        if not chain:
            chain = self.chain
        entity = self.get_data_by_chain(chain)
        return self.get_range_by_entity(entity)

    def get_range_by_entity(self, entity):
        if 'source' in entity:
            mappings = entity['source'][0]['mappings']
            if len(entity['source'][0]['mappings']) > 1:
                raise ValueError('MULTIPLE MAPPINGS?!')
            s = mappings[0]['start']['residue_number']
            e = mappings[0]['end']['residue_number']
            return (s, e)
        else:
            raise ValueError('This is not a peptide')

    def get_proteins(self):
        return [entity for entity in self.data if self.is_peptide(entity)]

    def get_nonproteins(self):
        return [entity for entity in self.data if not self.is_peptide(entity)]

    def is_peptide(self, entity):
        return entity['molecule_type'] == 'polypeptide(L)'

    def describe_entity(self, entity):
        if self.is_peptide(entity):
            return f'{"/".join(entity["molecule_name"])} as chain {"/".join(entity["in_chains"])} [{"-".join([str(n) for n in self.get_range_by_entity(entity)])}]'
        else:
            return f'{"/".join(entity["molecule_name"])} in chain {"/".join(entity["in_chains"])}'

    def describe(self, delimiter=' + '):
        descr = delimiter.join([self.describe_entity(entity) for entity in self.get_proteins()])
        descr += delimiter.join([self.describe_entity(entity) for entity in self.get_nonproteins()])
        return f'<span class="prolink" name="pdb" data-code="{self.code}" data-chain="{self.chain}">{self.code}</span> ({descr})'
