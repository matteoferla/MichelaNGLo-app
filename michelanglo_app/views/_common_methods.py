import os, requests, logging, re, unicodedata, uuid
from ..models import User, Page
from michelanglo_transpiler import PyMolTranspiler
log = logging.getLogger(__name__)

## convert booleans and settings
def is_js_true(value):
    """
    booleans get converted into strings in json. This fixes that.
    """
    if not value or value in ('false', 'False', False, 'No','no', 'F','null', 'off', 0, ''):
        return False
    else:  ## while also return True if its a number or string.
        return True

def get_uuid(request):
    identifier = str(uuid.uuid4())
    if identifier in [p.identifier for p in request.dbsession.query(Page)]:
        log.error('UUID collision!!!')
        return get_uuid(request)  # one in a ten-quintillion!
    return identifier

def notify_admin(msg):
    """
    Send message to a slack webhook
    :param msg:
    :return:
    """
    # sanitise.
    msg = unicodedata.normalize('NFKD',msg).encode('ascii','ignore').decode('ascii')
    msg = re.sub('[^\w\s\-.,;?!@#()\[\]]','', msg)
    r = requests.post(url=os.environ['SLACK_WEBHOOK'],
                      headers={'Content-type': 'application/json'},
                      data=f"{{'text': '{msg}'}}")
    if r.status_code == 200 and r.content == b'ok':
        return True
    else:
        log.error(f'{msg} failed to send (code: {r.status_code}, {r.content}).')
        return False


def is_malformed(request, *args):
    """
    Verify that the request.params is valid. returns None if it is valid. Else returns why.
    :param request:
    :param args:
    :return:
    """
    missing = [k for k in args if k not in request.params and f'{k}[]' not in request.params]
    if missing:
        request.response.status = 422
        log.warn(f'{User.get_username(request)} malformed request due to missing {missing}')
        return f'Missing field ({missing})'
    else:
        return None


class PDBMeta:
    """
    Query the PDBe for what the code parts are.
    Herein by chain the chain letter is meant, while the data of the chain is called entity... terrible.
    """
    def __init__(self, entry):
        if entry.find('_') != -1:
            self.code, self.chain = entry.split('_')
        else:
            self.code = entry
            self.chain = '?'
        reply = requests.get(f'http://www.ebi.ac.uk/pdbe/api/pdb/entry/molecules/{self.code}').json()
        if reply:
            self.data = reply[self.code.lower()]
        else:
            self.data = []

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
            if len(entity['source']):
                mappings = entity['source'][0]['mappings']
                if len(entity['source'][0]['mappings']) > 1:
                    raise ValueError('MULTIPLE MAPPINGS?!')
                s = mappings[0]['start']['residue_number']
                e = mappings[0]['end']['residue_number']
                return (s, e)
            else: ## synthetic.
                return (1, len(entity['sequence']))
        else:
            raise ValueError('This is not a peptide')

    def get_proteins(self):
        return [entity for entity in self.data if self.is_peptide(entity)]

    def get_nonproteins(self):
        return [entity for entity in self.data if not self.is_peptide(entity)]

    def is_peptide(self, entity):
        return entity['molecule_type'] == 'polypeptide(L)'

    def wordy_describe_entity(self, entity):
        if self.is_peptide(entity):
            return f'{"/".join(entity["molecule_name"])} as chain {"/".join(entity["in_chains"])} [{"-".join([str(n) for n in self.get_range_by_entity(entity)])}]'
        else:
            return f'{"/".join(entity["molecule_name"])} in chain {"/".join(entity["in_chains"])}'

    def is_boring_ligand(self, entity):
        if 'chem_comp_ids' not in entity:
            return True #this entity isnt even a thing
        elif len(entity['chem_comp_ids']) == 0:
            return True #this entity isnt even a thing
        else:
            return entity['chem_comp_ids'][0] in PyMolTranspiler.boring_ligand or entity['chem_comp_ids'][0] in ('WAT', 'HOH', 'TP3')

    def wordy_describe(self, delimiter=' + '):
        descr = delimiter.join([self.wordy_describe_entity(entity) for entity in self.get_proteins()])
        descr += ' &mdash; ' + delimiter.join([self.wordy_describe_entity(entity) for entity in self.get_nonproteins() if not self.is_boring_ligand(entity)])
        return f'<span class="prolink" name="pdb" data-code="{self.code}" data-chain="{self.chain}">{self.code}</span> ({descr})'

    def describe(self):
        peptide = [(f'{"-".join([str(n) for n in self.get_range_by_entity(entity)])}:{chain}',
                    "/".join(entity["molecule_name"])) for entity in self.get_proteins() for chain in
                   entity["in_chains"]]
        hetero = [(f'{entity["chem_comp_ids"][0]} and :{chain}',
                   "/".join(entity["molecule_name"])) for entity in self.get_nonproteins() for chain in
                  entity["in_chains"] if not self.is_boring_ligand(entity)]
        return {'peptide': peptide, 'hetero': hetero}
