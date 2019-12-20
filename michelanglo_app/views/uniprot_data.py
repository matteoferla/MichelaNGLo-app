__description___ = """
This page loads the data from the protein-data module as is used by both name.py and venus.py
"""

import os, json
from protein import ProteinCore, global_settings, Structure
from protein.generate import ProteinGatherer
import logging
log = logging.getLogger(__name__)

global_settings.startup(os.environ['PROTEIN_DATA'])

## the folder dictionary has the cross ref files.
try:
    organism = json.load(open(os.path.join(global_settings.dictionary_folder,'organism.json')))
    human = json.load(open(os.path.join(global_settings.dictionary_folder, 'taxid9606-names2uniprot.json')))
    uniprot2pdb = json.load(open(os.path.join(global_settings.dictionary_folder, 'uniprot2pdb.json')))
except FileNotFoundError:
    organism = {}
    human = {}
    uniprot2pdb = {}
    log.error('Data files do not exist. Running in data-less mode. Did you know about this?')
