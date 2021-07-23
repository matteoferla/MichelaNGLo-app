import os, requests, logging, re, unicodedata, uuid, shutil, json
from ..models import User, Page
from michelanglo_transpiler import PyMolTranspiler
from michelanglo_protein import Structure, global_settings
from . import valid_extensions
from .uniprot_data import uniprot2name
from pyramid.request import Request
log = logging.getLogger(__name__)
from typing import Union
### The latter two are utterly stupid usage.
from Bio.PDB.MMCIF2Dict import MMCIF2Dict
import io

## convert booleans and settings
def is_js_true(value:str):
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
    if 'SLACK_WEBHOOK' not in os.environ:
        log.critical(f'SLACK_WEBHOOK is absent! Cannot send message {msg}')
        return
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



import smtplib
from email.mime.text import MIMEText

def email(text, recipient, subject='[Michelanglo] Notification'):
    if "SERVER_EMAIL" not in os.environ:
        log.warning('There is not mailing system configured.')
    else:
        smtp = smtplib.SMTP()
        smtp.connect('localhost')
        msg = MIMEText(text)
        msg['Subject'] = subject
        msg['From'] = os.environ["SERVER_EMAIL"]
        msg['To'] = recipient
        msg.add_header('reply-to', os.environ["ADMIN_EMAIL"])
        smtp.send_message(msg)
        smtp.quit()

def is_malformed(request, *args) -> Union[None, str]:
    """
    Verify that the request.params is valid. returns None if it is valid. Else returns why.
    :param request:
    :param args:
    :return: msg
    """
    missing = [k for k in args if k not in request.params and f'{k}[]' not in request.params]
    if missing:
        request.response.status = 422
        log.warning(f'{User.get_username(request)} malformed request due to missing {missing}')
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

        return {'peptide': peptide, 'hetero': hetero, 'ref': get_references(self.code)}


def get_references(code):
    try:
        code = code.replace('based upon', '').strip().split('.')[0]
        if len(code) == 0:
            return ''
        elif 'alphafold' in code:
            return 'Model derived from EBI AlphaFold2 '+\
                   '<a href="https://www.nature.com/articles/s41586-021-03819-2" target="_blank">'+\
                   'Jumper, J., Evans, R., Pritzel, A. et al. Highly accurate protein structure prediction with AlphaFold. Nature (2021).'+\
                   '</a>'
        elif 'swissmodel' in code or len(code) == 24:
            return 'Model derived from SWISSMODEL <a href="https://academic.oup.com/nar/article/46/W1/W296/5000024" target="_blank">'+\
                   'Waterhouse, A., Bertoni, M., Bienert, S., Studer, G., Tauriello, G., Gumienny, R., Heer, F.T., de Beer, T.A.P., Rempfer, C., Bordoli, L., Lepore, R., Schwede, T.'+\
                   ' (2018) SWISS-MODEL: homology modelling of protein structures and complexes. <i>Nucleic Acids Res.</i> <b>46(W1)</b>, W296-W303.</a>'
        else:
            reply = requests.get(f'https://www.ebi.ac.uk/pdbe/api/pdb/entry/publications/{code}').json()
            if reply:
                citations = []
                for ref in reply[code.lower()]:
                    authors = ', '.join([author["full_name"] for author in ref["author_list"]])
                    if ref["doi"] is None:
                            continue
                    try:
                        jname = ref["journal_info"]["ISO_abbreviation"] if ref["journal_info"]["ISO_abbreviation"] is not None else ref["journal_info"]["pdb_abbreviation"]
                        issue = ref["journal_info"]["issue"] if ref["journal_info"]["issue"] is not None else ''
                        pages = ref["journal_info"]["pages"] if ref["journal_info"]["pages"] is not None else ''
                        journal = f'({ref["journal_info"]["year"]}) {ref["title"]} <i>{jname}</i> <b>{issue}</b> {pages}'
                    except:
                        journal = 'NA'
                    citations.append(f'Structure {code} was reported in <a target="_blank" href="https://dx.doi.org/{ref["doi"]}">{authors} {journal}</a>')
                return '<br/>'.join(citations)
            else:
                return ''
    except Exception as error:
        msg = f'get_reference {error.__class__.__name__} - {error} for "{code}"'
        log.error(msg)
        notify_admin(msg)
    
    
def save_file(request, extension, field='file'):
    """
    Saves the file without doing anything to it.
    """
    filename = os.path.join('michelanglo_app', 'temp', '{0}.{1}'.format(get_uuid(request), extension))
    with open(filename, 'wb') as output_file:
        if isinstance(request.params[field], str):  ###API user made a mess.
            log.warning(f'user uploaded a str not a file!')
            output_file.write(request.params[field].encode('utf-8'))
        else:
            request.params[field].file.seek(0)
            shutil.copyfileobj(request.params[field].file, output_file)
    return filename

def save_coordinates(request, mod_fx=None):
    """
    Saves the request['pdb'] file. Does not accept str.
    """
    extension = request.params['pdb'].filename.split('.')[-1]
    if extension not in valid_extensions:
        log.warning(f'Odd format in pdb upload: {extension} {valid_extensions}')
        extension = 'pdb'
    filename = save_file(request, extension, field='pdb')
    trans = PyMolTranspiler().load_pdb(file=filename, mod_fx=mod_fx)
    os.remove(filename)
    if extension != 'pdb':
        os.remove(filename.replace(extension, 'pdb'))
    return trans

def get_chain_definitions(source: Union[Request,str]):
    """
    In parts of the code (backend) it is called definition. in the frontend it is descriptions.
    It accepts either a 4 letter code or a request object.
    """
    def get_from_code(code):
        code = code.split('_')[0]
        if len(code) == 4:
            definitions = Structure(id=code, description='', x=0, y=0, code=code).lookup_sifts().chain_definitions
            for d in definitions:
                if d['name'] is None and d['uniprot'] in uniprot2name:
                    d['name'] = uniprot2name[d['uniprot']]
            return definitions
        else:
            return []

    if isinstance(source, str):
        return get_from_code(source)
    elif isinstance(source, Request):
        request = source
        if 'definitions' in request.params:
            definitions = json.loads(request.params['definitions'])
        elif len(request.params['pdb']) == 4:
            definitions = get_from_code(request.params['pdb'])
        elif 'format' in request.params and request.params['format'] == 'cif':
            try:
                data = MMCIF2Dict(io.StringIO(request.params['pdb']))
                forced_list = lambda v: v if isinstance(v, list) else [v]
                chains = forced_list(data['_entity_poly.pdbx_strand_id'])
                species = forced_list(data['_entity_src_gen.pdbx_gene_src_ncbi_taxonomy_id'])
                name = forced_list(data['_entity_src_gen.pdbx_gene_src_gene'])
                details = []
                for i, c in enumerate(chains):
                    n = name[i].split(',')[0]
                    assert species[i].isdigit()
                    uniprot = json.load(open(os.path.join(global_settings.dictionary_folder, f'taxid{species[i]}-names2uniprot.json')))[n]
                    for x in c.split(','):
                        details.append({'chain': x,
                                        'name': n,
                                        'offset': 0,
                                        'uniprot': uniprot})
                return details
            except:
                return []
        else:
            #raise ValueError('Neither a pdb code or a definition json')
            return []
        return definitions
    else:
        raise TypeError

whitelist = ['https://swissmodel.expasy.org',
             'https://www.well.ox.ac.uk',
             'https://alphafold.ebi.ac.uk/files/',
             'https://raw.githubusercontent.com/',
             ]
def get_pdb_block_from_str(text):
    if len(text) == 4:
        return requests.get(f'https://files.rcsb.org/download/{text.upper()}.pdb').text
    elif len(text.strip()) == 0:
        raise ValueError('Empty PDB string?!')
    elif any([re.match(white, text) for white in whitelist]):
        return requests.get(text).text
    elif 'ATOM' in text or 'HETATM' in text: # already a PDB
        return text
    elif 'http' in text:
        raise ValueError(f'Unknown web address {text}. Please email admin to add to approved URLs')
    else:
        raise ValueError(f'Unknown type of PDB block {text}')

def get_pdb_block_from_request(request):
    if isinstance(request.params['pdb'], str):  # string
        text = request.params['pdb']
        ## see if it's mmCIF
        if 'format' in request.params:
            if request.params['format'].lower() == 'pdb':
                return get_pdb_block_from_str(text)
            elif request.params['format'].lower() not in valid_extensions:
                log.warning(f'Odd format in pdb upload: {request.params["format"]} {valid_extensions}')
                return get_pdb_block_from_str(text)
            else:  ## mmCIF save_file is abivalent to file or str
                filename = save_file(request, request.params['format'].lower(), field='pdb')
                return PyMolTranspiler().load_pdb(file=filename).pdb_block
        else:
            return get_pdb_block_from_str(text)
    elif hasattr(request.params['pdb'], "filename"):  # file
        return save_coordinates(request).pdb_block  # has its own check to deal with mmCIF.
    else:
        raise TypeError

def get_pdb_block(source):
    """
    This may do an unneccassry round trip.
    The output is a PDB block. Do not call if you want to keep using a pdb code.
    """
    ##
    if isinstance(source, str):
        text = source
        return get_pdb_block_from_str(text).replace('`','').replace('\\','').replace('$','')
    elif isinstance(source, Request):
        request = source
        return get_pdb_block_from_request(request).replace('`','').replace('\\','').replace('$','')
    else:
        raise TypeError

def get_pdb_code(request):
    if 'pdb' in request.params:
        pdb = request.params['pdb']
        if isinstance(pdb, str):  # string
            if len(pdb.strip()) == 4:
                return pdb.strip().upper()
            elif 'swissmodel' in pdb:
                return pdb
        elif hasattr(pdb, "filename"):
            return os.path.splitext(pdb.filename)[0].strip()
        else:
            pass
    if 'history' in request.params:
        return json.loads(request.params['history'])['code']
    return ''

def get_history(request):
    if 'history' in request.params:
        history = json.loads(request.params['history'])
    else:
        code = get_pdb_code(request)
        history = {'code': code, 'changes': ''}
    return history