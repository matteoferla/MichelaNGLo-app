__description___ = """
This page loads the data from the protein-data module as is used by both name.py and venus.py

global_settings is initialised in folder setup
"""

import os, json
from michelanglo_protein import ProteinCore, global_settings, Structure
from michelanglo_protein.generate import ProteinGatherer
import logging
log = logging.getLogger(__name__)

## the folder dictionary has the cross ref files.
try:
    organism = json.load(open(os.path.join(global_settings.dictionary_folder,'organism.json')))
    human = json.load(open(os.path.join(global_settings.dictionary_folder, 'taxid9606-names2uniprot.json')))
    uniprot2pdb = json.load(open(os.path.join(global_settings.dictionary_folder, 'uniprot2pdb.json')))
    uniprot2name = json.load(open(os.path.join(global_settings.dictionary_folder,'uniprot2name.json')))
    uniprot2species = json.load(open(os.path.join(global_settings.dictionary_folder,'uniprot2species.json')))
except FileNotFoundError:
    organism = {}
    human = {}
    uniprot2pdb = {}
    uniprot2name = {}
    uniprot2species = {}
    log.error('Data files do not exist. Running in data-less mode. Did you know about this?')
