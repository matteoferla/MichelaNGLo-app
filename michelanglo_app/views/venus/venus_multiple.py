from __future__ import annotations
# venus multiple mutants
# does not use michelanglo_app.views.buffer.system_storage


from ..uniprot_data import *
# ProteinCore organism human uniprot2pdb
from michelanglo_protein import ProteinAnalyser, Mutation, ProteinCore, Structure

from ...models import User, Page  ##needed solely for log.
from ..common_methods import is_malformed, notify_admin, get_pdb_block_from_request, is_alphafold_taxon
from ..user_management import permission
from ..custom_message import custom_messages
from mako.template import Template

from typing import Optional, Any, List, Union, Tuple, Dict
import random
from pyramid.view import view_config, view_defaults
from pyramid.renderers import render_to_response
import pyramid.httpexceptions as exc

import json, os, logging, operator

log = logging.getLogger(__name__)
# from pprint import PrettyPrinter
# pprint = PrettyPrinter().pprint

from .venus_base import VenusException, VenusBase

########################################################################################################################

@view_config(route_name='venus_multiple', renderer="../../templates/venus/venus_multiple.mako")
def venus_multiple_view(request):
    return {'user': request.user, 'mutation_mode': 'multi', **VenusBase.generic_data}


@view_defaults(route_name='venus_multianalyse')
class MultiVenus(VenusBase):

    def __init__(self, request):
        super().__init__(request)  # self.request and self.reply
        # whereas Venus is Stateful (stores data), Venus_multi is restful (does not store data)
        self.protein = None  # str
        self.uniprot = None  # str
        self.taxid = None  # str
        self.mutations = None  # List[Mutation]
        self.structure = None  # Union[None, str]

    @view_config(renderer="json")
    def analyse(self):
        log.info(f'Multivenus requested by {User.get_username(self.request)}')
        try:
            self.assert_malformed('uniprot', 'species', 'mutations')
            self.uniprot = self.request.params['uniprot']
            self.taxid = self.request.params['species']
            self.mutations = [Mutation(m) for m in self.request.params['mutations'].split()]
            self.protein = self.load_protein()  # ProteinAnalyser
            self.structure = self.load_structure()  # Union[Structure, None]
            self.check_mutations()
            choices = self.sort_models() #Dict[Structure, List[str]]
            self.reply['choices'] = choices
            self.reply['urls'] = self.get_urls()
            self.reply['fv'] = self.make_fv()
        except VenusException as err:
            log.info(err)
        except Exception as err:
            if self.reply['status'] != 'error':
                # this is a new one.
                self.reply['status'] = 'error'
                self.reply['error'] = 'analysis'
                self.reply['msg'] = str(err)
            log.warning(f'Multivenus error {err.__class__.__name__}: {err}')
            # notify_admin(f'Multivenus error {err.__class__.__name__}: {err}')
        return self.reply

    def load_protein(self) -> ProteinAnalyser:
        protein = ProteinAnalyser(uniprot=self.uniprot, taxid=self.taxid)
        protein.load()
        # self.reply['protein'] = self.jsonable(protein)
        return protein

    def load_structure(self) -> Union[Structure, None]:
        if 'pdbblock' in self.request.params:
            pdbblock = self.request.params['pdbblock']
            raise NotImplementedError
            structure = Structure(title, 'Custom', 0, 9999, title,
                                  type='custom', chain="A", offset=0, coordinates=pdbblock)
            structure.is_satisfactory(protein.mutation.residue_index)
            return structure
        else:
            return None

    def check_mutations(self):
        discrepancies = {mutation: self.check_mutation(mutation) for mutation in self.mutations}
        discrepancies = {mutation: discrepancy for mutation, discrepancy in discrepancies.items() if
                         discrepancy is not None}
        if len(discrepancies) != 0:
            discrepancy = '\n'.join([f'{mutation}: {discrepancies[mutation]}.' for mutation in discrepancies])
            self.reply = {'error': 'mutation', 'msg': discrepancy, 'status': 'error'}
            raise VenusException(discrepancy)

    def check_mutation(self, mutation: Mutation) -> Union[str, None]:
        ## Do analysis
        self.protein.mutation = mutation
        # assess
        if not self.protein.check_mutation():
            log.info('protein mutation discrepancy error')
            discrepancy = self.protein.mutation_discrepancy()
            return discrepancy
        else:
            return None

    def sort_models(self) -> Dict[str, List[str]]:
        """
        ``protein.analyse_structure(structure)`` in venus calls ``get_best_model``.
        This checks a single variant.
        """
        presence = {}
        for group in (self.protein.pdbs, self.protein.swissmodel):
            for model in group:  # model is a structure object.
                presence[model.id] = [str(mutation) for mutation in self.mutations if model.includes(mutation.residue_index)]
        sorter = lambda t: len(t[1]) + (0.1 if len(t[0]) == 6 else 0) # sort by number of mutants covered, plus bonus for PDB
        presence = sorted(presence.items(), key=sorter, reverse=True)  # List[tuple]
        return dict(presence)

    def get_urls(self) -> Dict[str, str]:
        return {model.id: model.url for model in self.protein.swissmodel}


    def make_fv(self) -> str:
        # workpath is app.
        filename = os.path.join(os.path.dirname(__file__), '..', '..', "templates/results/features.js.mako")
        template = Template(filename=filename)
        return template.render(protein=self.protein,
                                 featureView= '#fv',
                                 include_pdb=True,
                                 alphafolded = is_alphafold_taxon(self.taxid)
                               )

