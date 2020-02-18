"""
This file contains all the routes used by pdb_staging_insert.js to pre-modify a file.
"""

from pyramid.view import view_config
from michelanglo_transpiler import PyMolTranspiler
import os
import re
import requests
from . import valid_extensions

PyMolTranspiler.tmp = os.path.join('michelanglo_app', 'temp')

from .common_methods import is_js_true, is_malformed, PDBMeta, get_uuid, save_file, save_coordinates, get_chain_definitions, get_pdb_code, get_pdb_block, get_history
import logging

log = logging.getLogger(__name__)

########################################## views
@view_config(route_name='renumber', renderer="json")
def renumber(request):
    malformed = is_malformed(request, 'pdb')
    if malformed:
        return {'status': malformed}
    pdb = get_pdb_block(request)
    definitions = get_chain_definitions(request)
    history = get_history(request)
    trans = PyMolTranspiler().renumber(pdb, definitions)
    for current_chain_def in definitions:
        current_chain_def['applied_offset'] = current_chain_def['offset']
        #current_chain_def['x'] += current_chain_def['offset']
        #current_chain_def['y'] += current_chain_def['offset']
        #current_chain_def['range'] = f"{current_chain_def['x']}-{current_chain_def['y']}"
        current_chain_def['offset'] = 0
    history['changes'] += 'Renamed. '
    return {'pdb': trans.pdb_block,
            'definitions': definitions,
            'history': history}


@view_config(route_name='premutate', renderer="json")  # as in mutate a structure before page creation.
def premutate(request):
    malformed = is_malformed(request, 'pdb', 'mutations', 'chain', 'format')
    if malformed:
        return {'status': malformed}
    ## variant of mutate...
    pdb = get_pdb_block(request)
    definitions = get_chain_definitions(request)
    history = get_history(request)
    history['changes']+=f'Mutated. '
    if 'chain' in request.params:
        chain = request.params['chain']
        chains = None
    elif 'chain[]' in request.params:
        chain = None
        chains = request.params.getall('chain[]')
    else:
        raise ValueError
    if 'mutations' in request.params:
        mutations = request.params['mutations'].split()
    elif 'mutations[]' in request.params:
        mutations = request.params.getall('mutations[]')
    else:
        raise ValueError
    try:
        trans = PyMolTranspiler().mutate_block(block=pdb, mutations=mutations, chain=chain, chains=chains)
        return {'pdb': trans.pdb_block,
                'definitions': definitions,
                'history': history}
    except ValueError:
        request.response.status = 422
        return {'status': f'Invalid mutations'}

@view_config(route_name='remove_chains', renderer="json")
def removal(request):
    malformed = is_malformed(request, 'pdb', 'chains')
    if malformed:
        return {'status': malformed}
    ## variant of mutate...
    pdb = get_pdb_block(request)
    definitions = get_chain_definitions(request)
    history = get_history(request)
    history['changes'] += f'Chains removed. '
    chains = request.params['chains'].split()
    trans = PyMolTranspiler().chain_removal_block(block=pdb, chains=chains)
    for i in reversed(range(len(definitions))):
        if definitions[i]['chain'] in chains:
            definitions.pop(i)
    return {'pdb': trans.pdb_block,
            'definitions': definitions,
            'history': history}

@view_config(route_name='dehydrate', renderer="json") #as in dehydrate a structure before page creation.
def dehydrate(request):
    malformed = is_malformed(request, 'pdb', 'water', 'ligand', 'format')
    if malformed:
        return {'status': malformed}
    pdb = get_pdb_block(request)
    definitions = get_chain_definitions(request)
    history = get_history(request)
    history['changes'] += f'Dehydrated. '
    try:
        water = is_js_true(request.params['water'])
        ligand = is_js_true(request.params['ligand'])
        if not (water or ligand):
            raise ValueError
        trans = PyMolTranspiler().dehydrate_block(block=pdb, water=water, ligand=ligand)
        return {'pdb': trans.pdb_block,
                'definitions': definitions,
                'history': history}
    except ValueError:
        request.response.status = 422
        return {'status': f'Nothing to delete'}






#
#
#
# def operation(request, pdb, fun_code, fun_file, **kargs):
#     """
#     This method is called by premutate and removal, neither changes anything serverside.
#     """
#     # get_uuid is not really needed as it does not go to DB.
#     filename = os.path.join('michelanglo_app', 'temp', f'{uuid.uuid4()}.pdb')
#     ## type is determined
#     pdb = get_pdb_block(request)
#     if hasattr(pdb, 'filename'):
#         #this is a special case wherein the uses has sent a file upload.
#         #for now it is simply saved and annotated and reopened.
#         #totally wasteful but for now none of the methods upload a file.
#         trans = save_coordinates(request, mod_fx=None)
#         block = trans.raw_pdb()  ### xxxxxxxx
#         print(block)
#         raise NotImplementedError
#     else:
#
#         if len(pdb) == 4: ##PDB code.
#             code = pdb
#             fun_code(pdb, filename, **kargs)
#         elif len(pdb.strip()) == 0:
#             request.response.status = 422
#             return {'status': f'Empty PDB string?!'}
#         else: #string
#             if re.match('https://swissmodel.expasy.org', pdb): ## swissmodel
#                 pdb = requests.get(pdb).text
#             with open(filename, 'w') as fh:
#                 fh.write(pdb)
#             fun_file(filename,  filename, **kargs)
#         with open(filename, 'r') as fh:
#             block = fh.read()
#         os.remove(filename)
#     if len(pdb) == 4:
#         return {'pdb': f'REMARK 100 THIS ENTRY IS ALTERED FROM {pdb}.\n' +block}
#     elif 'REMARK 100 THIS ENTRY' in block:
#         code = re.match('REMARK 100 THIS ENTRY IS \w+ FROM (\w+).', pdb).group(1)
#         return {'pdb': f'REMARK 100 THIS ENTRY IS ALTERED FROM {code}.\n' + block}
#     else:
#         return {'pdb': block}