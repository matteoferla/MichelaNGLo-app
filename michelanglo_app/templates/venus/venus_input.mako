<%
    # this is a very silly grammatical change.
    if mutation_mode == 'main':
        mut_label = 'Mutation'
        mut_title = 'A protein mutation within the canonical transcript of the chosen gene (e.g. p.A20W). The "p." is redundant, but tolerated'
    elif mutation_mode == 'multi':
         mut_label = 'Mutations'
         mut_title = 'A series of protein mutations within the canonical transcript of the chosen gene (e.g. p.A20W). The "p." is redundant, but tolerated. Space, comma, semicolon or tab separated.'
    else:
        raise Exception('No mode!')

    range_settings = [
                        ('swiss_oligomer_identity_cutoff',
                         'Cutoff for SwissModel identity (oligomer)',
                         dict(min=0, max=100, default=20, step=1)
                         ),
                        ('swiss_monomer_identity_cutoff',
                         'Cutoff for SwissModel identity (monomer)',
                         dict(min=0, max=100, default=20, step=1)
                         ),
                        ('swiss_oligomer_qmean_cutoff',
                         'Cutoff for SwissModel quality (qMean) (oligomer)',
                         dict(min=-5, max=5, default=-2, step=0.5)
                         ),
                        ('swiss_monomer_qmean_cutoff',
                         'Cutoff for SwissModel quality (qMean) (monomer)',
                         dict(min=-5, max=5, default=-2, step=0.5)
                         )
                    ]

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
            <div class="row">
                % for id_name, name in [('allow_pdb','PDB structures'), ('allow_swiss','SwissModel threaded models'), ('allow_alphafold','AlphaFold2 models')]:
                    <div class="col-4">
                        <div class="input-group" data-toggle="tooltip"
                             title="Disabling prevents VENUS from using ${name}, otherwise they may be used if best">
                            <div class="input-group-prepend">
                                <div class="input-group-text">
                                    <div class="custom-control custom-switch">
                                        <input type="checkbox" id="${id_name}" class="custom-control-input" checked>
                                        <label class="custom-control-label" for="${id_name}">Use ${name}</label>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                %endfor
                % for id_name, label, values in range_settings:
                    <div class="col-6">
                    <div class="input-group my-3">
                        <div class="input-group-prepend">
                            <span class="input-group-text" id="${id_name}_add"><small>${label|n}</small></span>
                        </div>
                        <input type="range"
                                   min="${values['min']}"
                                   max="${values['max']}"
                                   value="${values['default']}"
                                   step="${values['step']}"
                                   id="${id_name}"
                                   class="form-control-range" aria-label="RANGE"
                                   aria-describedby="${id_name}_add"
                                   oninput="this.nextElementSibling.value = this.value"
                            >
                        <output class="input-group-append">
                            ${values['default']}
                        </output>
                    </div>
                </div>
                %endfor

                ### row end:
            </div>


        </div>
    </div>

    <div class="col-12 col-lg-2">
        % if user and user.role == 'admin':
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