
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
%>


<div class="row">
        <div class="col-12 col-lg-4">
            <div class="input-group mb-3" data-toggle="tooltip"
                                     title="Species">
                <div class="input-group-prepend">
                    <span class="input-group-text">Species</span>
                </div>
                <input type="text" class="form-control rounded-right" id="species" autocomplete="new-password" value="human">
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
                                    <input type="text" class="form-control rounded-right" id="gene" autocomplete="new-password">
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
                                <input type="text" class="form-control rounded-right" id="mutation" autocomplete="new-password">
                                <div class="invalid-feedback" id="error_mutation">Unrecognised mutation</div>
                                <div class="valid-feedback" id="mutation_valid">Error</div>
                            </div>
        </div>

        <div class="col-12 offset-lg-4 col-lg-4">
            <button type="button" class="btn btn-outline-primary w-100" id="venus_calc" style="display: none;">Analyse</button>
        </div>
    </div>