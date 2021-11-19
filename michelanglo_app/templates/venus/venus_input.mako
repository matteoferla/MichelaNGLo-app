<%
# this is a very silly grammatical change.
if mutation_mode == 'main':
    mut_label = 'AA mutation'
    mut_title = 'A protein mutation within the canonical transcript of the chosen gene (e.g. p.A20W). The "p." is redundant, but tolerated'
elif mutation_mode == 'multi':
     mut_label = 'AA mutations'
     mut_title = 'A series of protein mutations within the canonical transcript of the chosen gene (e.g. p.A20W). The "p." is redundant, but tolerated. Space, comma, semicolon or tab separated.'
else:
    raise Exception('No mode!')

range_settings = [
                    ('swiss_oligomer_identity_cutoff',
                     'Cutoff for SwissModel identity (oligomer)',
                     dict(min=0, max=100, default=40, step=1),
                     'SwissModel has the advantage over EBI-AlphaFold2 in that the protein may be in a homo/hetero-oligomeric state, with a ligand. However, if the distance is too great the benefit is lost'
                     ),
                    ('swiss_monomer_identity_cutoff',
                     'Cutoff for SwissModel identity (monomer)',
                     dict(min=0, max=100, default=70, step=1),
                     'This cutoff comes into play if the SwissModel isn\'t an oligomer and may or may have a ligand',
                     ),
                    ('swiss_oligomer_qmean_cutoff',
                     'Cutoff for SwissModel quality (qMean) (oligomer)',
                     dict(min=-5, max=5, default=-2, step=0.5),
                     'qMean is the SwissModel metric of naturality of the pose: below -2 is bad and may have weird torsions'
                     ),
                    ('swiss_monomer_qmean_cutoff',
                     'Cutoff for SwissModel quality (qMean) (monomer)',
                     dict(min=-5, max=5, default=-2, step=0.5),
                     'Same as for oligomer'
                     ),
                    ('cycles',
                     'FastRelax cycles',
                     dict(min=1, max=5, default=2, step=1),
                     'How many cycles of minimisation to perform, each cycle adds some 15 seconds to the operations.'
                     ),
                    ('radius',
                     'FastRelax C-beta neighbourhood radius',
                     dict(min=8, max=15, default=12, step=1),
                     'The neighbourhood is defined as the residues that have a given distance from the cetral atom: this is not an atom-to-atom value as these would depend on the sidechain conformation and identity'
                     )
                ]

booleans = [
            ('The score can be calculate from the whole protein, including the residues beyond the neighbourhood that is energy minimised '+\
            ' or only the neighbourhood (=this option checked). '+
            'The former gives lower median absolute errors, but the latter always results in a zero ∆∆G for a silent mutation. '+
            'The cause of the difference is that some structures may have highly disfavoured residues conformations just beyond the neighbourhood'+\
            ' that the boundary of the mobile residue neighbourhood could find a minimum for.',
            'neighbour_only_score',
            '',
            'Neighbourhood only score'
            ),
            ('Add Rosetta constraints (restraints) to maintain interactions across the boundary of the mobile residue neighbourhood, '+\
            'because if there is something really bad beyond it may throw off the calculations —see "Neighbourhood only score"',
            'outer_constrained',
            '',
            'Constrained outer shell'
            ),
            ('Removing ligands will make the calculations more accurate, but the presence of a ligand is an essential piece of info',
            'remove_ligands',
            '',
            'Remove ligands'
            ),
            ('Multiple chains slow down things and may not be the biology assembly',
            'single_chain',
            '',
            'Single chain'
            ),
            ('Certain features, such as PyRosetta, PhosphoSitePlus and ELM are not under a MIT/Apache licence '+\
            'and have complex legalese for commercial users.',
            'academic',
            'checked',
            'Academic user'
            )]

%>


<div class="row">
    <div class="col-12 col-lg-4">
        <div class="input-group mb-3" data-toggle="tooltip"
             title="Species">
            <div class="input-group-prepend">
                <span class="input-group-text">Species</span>
            </div>
            <input type="text" class="form-control rounded-right" id="species" autocomplete="off" value="human">
            <div class="invalid-feedback" id="error_species">Unrecognised name</div>
            <div class="valid-feedback" id="taxid">Error</div>
        </div>
    </div>

    <div class="col-12 col-lg-4">
        <div class="input-group mb-3" data-toggle="tooltip"
             title="A gene name, protein name or Uniprot accession.">
            <div class="input-group-prepend">
                <span class="input-group-text">Gene/prot. name</span>
            </div>
            <input type="text" class="form-control rounded-right" id="gene" autocomplete="off">
            <div class="invalid-feedback" id="error_gene">Unrecognised name</div>
            <div class="valid-feedback" id="uniprot">Error</div>
        </div>
    </div>

    <div class="col-12 col-lg-4">
        <div class="input-group mb-3" data-toggle="tooltip"
             title="${mut_title}">
            <div class="input-group-prepend">
                                    <span class="input-group-text">
                                        ${mut_label}
                                    </span>
            </div>
            <input type="text" class="form-control rounded-right" id="mutation" autocomplete="off">
            <div class="invalid-feedback" id="error_mutation">Unrecognised mutation</div>
            <div class="valid-feedback" id="mutation_valid">Error</div>
        </div>
    </div>

    <div class="col-12">
        <div class="mx-2 my-1 p-2 border rounded bg-light collapse" id="advanced">
            <h5>Advanced options</h5>
            <p>In most cases it is not necessary to alter these settings.
                For description <a href="/docs/venus_model">see documentation</a>.</p>
            <div class="row">
                <div class="col-6">
                <button type="button" class="btn btn-info m-2" id="change_model_btn"
                                data-toggle="modal" data-target="#change_modal"
                        ><i class="far fa-upload"></i> Upload own model
                        </button>
                </div>

                % for id_name, name in [('allow_pdb','PDB structures'), ('allow_swiss','SwissModel threaded models'), ('allow_alphafold','AlphaFold2 models')]:
                    <div class="col-6">
                        <div class="input-group" data-toggle="tooltip"
                             title="Disabling prevents VENUS from using ${name}, otherwise they may be used if best">
                            <div class="input-group-text w-100">
                                <div class="custom-control custom-switch">
                                    <input type="checkbox" id="${id_name}" class="custom-control-input" checked>
                                    <label class="custom-control-label" for="${id_name}">Use ${name}</label>
                                </div>
                            </div>
                        </div>
                    </div>
                %endfor
                % for id_name, label, values, tooltip in range_settings:
                    <div class="col-6">
                    <div class="input-group my-3" data-toggle="tooltip" title="${tooltip}">
                        <div class="input-group-text w-100">
                            <span id="${id_name}_add"><small>${label}</small>&nbsp;</span>
                            <input type="range"
                                       min="${values['min']}"
                                       max="${values['max']}"
                                       value="${values['default']}"
                                       step="${values['step']}"
                                       id="${id_name}"
                                       class="form-control-range" aria-label="RANGE"
                                       aria-describedby="${id_name}_add"
                                       oninput="this.nextElementSibling.value = this.value"
                                >&nbsp;
                            <output>
                                ${values['default']}
                            </output>
                        </div>
                    </div>
                </div>
                %endfor
                <div class="col-6">

                <div class="input-group mb-3">
                  <div class="input-group-prepend">
                    <label class="input-group-text" for="scorefxn_name">Scorefunction</label>
                  </div>
                  <select class="custom-select" id="scorefxn_name">
                    <option selected value="ref2015">ref2015</option>
                      %for scorefxn in ('beta_july15', 'beta_nov16', 'ref2015_cart', 'beta_july15_cart', 'beta_nov16_cart'):
                        <option value="${scorefxn}">${scorefxn}</option>
                      %endfor
                  </select>
                </div>
                ### booleans
                </div>
                ### row end:
            </div>
            <div class="row">
                %for title, id_name, checked, label in booleans:
                    <div class="col-6">
                        <div class="input-group my-3" data-toggle="tooltip"
                             title="${title}">
                            <div class="input-group-text w-100">
                                <div class="custom-control custom-switch">
                                    <input type="checkbox" id="${id_name}" class="custom-control-input" ${checked}>
                                    <label class="custom-control-label" for="${id_name}">${label}</label>
                                </div>
                            </div>
                        </div>
                    </div>
                %endfor
            </div>


        </div>
    </div>

    <div class="col-12 col-lg-2">
        %if mutation_mode == 'main':
        <a class="btn btn-outline-info" data-toggle="collapse" href="#advanced" role="button" aria-expanded="false"
               aria-controls="advanced">
                <i class="far fa-cogs"></i> Advanced
        </a>
        %endif
    </div>
    <div class="col-12 offset-lg-2 col-lg-4">
        <button type="button" class="btn btn-outline-primary w-100" id="venus_calc" style="display: none;">Analyse
        </button>
    </div>
</div>