## route name: /name
## this view is for Gene name/accession id to pdb
<%namespace file="../layout_components/labels.mako" name="info"/>
<%inherit file="../layout_components/layout_w_card.mako"/>
<%block name="buttons">
            <%include file="../layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>
<%block name="title">
            &mdash; VENUS
</%block>
<%block name="subtitle">
    Assessing the effect of amino acid variants have on structure
</%block>

<%block name="alert">
    <div class="alert alert-warning" role="alert">
  This page is still being built, therefore some features may not work.
    </div>
</%block>

<%block name="main">
        <p>Add text here.</p>
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
                                     title="A protein mutation within the canonical transcript of the chosen gene (e.g. p.A20W)">
                                <div class="input-group-prepend">
                                    <span class="input-group-text">Mutation</span>
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
</%block>

<%block name='after_main'>

<div class="container-fluid" id="results">
    <div style="width:47vw; position:fixed; top:7rem; bottom: 24px; right: 24px;">
                    <div class="card shadow-sm">
                        <div class="card-header"><h5 class="card-title">
                            <i class="far fa-cubes"></i> Structure
                        </h5></div>
                      <div class="card-body">
                        <div id="viewport" style="width:100%; height: 0; padding-bottom: 100%;">
                        </div>
                      </div>
                    </div>
                </div>
    <div class="row">
                <!-- Main text -->
                <div class="offset-3 col-6 mb-4 py-4">
                    <div class="card shadow-sm bg-light">
                        <div class="card-body  text-center">
                            <div class="btn-group" role="group" aria-label="Basic example">
                              <button type="button" class="btn btn-outline-warning" id="new_analysis">
                                  <i class="far fa-undo  fa-lg"></i> Analyse another
                              </button>
                                <button class="btn btn-outline-secondary" type="button" id="feedback-btn" data-toggle="modal" data-target="#modal_feedback">
                                    <i class="far fa-star"></i> Feedback
                                </button>
                                <button class="btn btn-outline-primary" type="button" id="report-btn" data-toggle="modal" data-target="#report">
                                    <i class="far fa-clipboard-list fa-lg"></i> Create a sharable page (Michelaɴɢʟo)
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
    </div>


    <div class="row">
                <!-- Feature -->
                <div class="col-6 mb-4 pl-4">
                    <div class="card shadow-sm">
                        <div class="card-header"><h5 class="card-title">
                            <i class="far fa-dna"></i> Features
                        </h5><h6 class="card-subtitle mb-2 text-muted">
                            (Click on a feature to visualise it on the structure)
                        </h6></div>

                        ###################### arrow ###################################


                      <div class="card-body">
                        <div class="arrow-right"></div><div class="arrow-right2"></div>

                          ###################### end of arrow ###################################

                        <div id="fv"></div>

                          <div>
                              <button class="btn btn-outline-secondary bindersCollapse collapse show" data-toggle="collapse" data-target=".bindersCollapse"><i class="far fa-eye"></i> Show PDB structure details</button>
                              <button class="btn btn-outline-secondary bindersCollapse collapse" data-toggle="collapse" data-target=".bindersCollapse"><i class="far fa-eye-slash"></i> Hide PDB structure details</button>
                          </div>
                          <div id="matches_collapse" class="col-12 collapse bindersCollapse">
                            <p>Proteins can be crystallised with ligands or binding partners and it is often beneficial to choose a specific one.</p>
                            <div id="partner_table"></div>
                        </div>
                      </div>
                    </div>
                </div>
            </div>

    <div class="row">
                <div class="col-6 mb-4 pl-4">
                    <div class="card shadow-sm">
                        <div class="card-header">
                            <h3 class="card-title" id="result_title">
                                <i class="far fa-dna fa-spin"></i> Loading
                            </h3>
                            <h6 class="card-subtitle mb-2 text-muted">
                                Predicted effects
                            </h6>
                        </div>

                        ###################### lines ###################################

                      <div class="card-body">
                          <div class="arrow-right"></div><div class="arrow-right2">
                          </div>
                      <ul class="list-group list-group-flush" id="results_list">
                      </ul>
                      </div>
                      </div>
                    </div>
    </div>
</div>
</%block>

<%block name='modals'>
</%block>

<%block name='script'>
<script type="text/javascript">
    $(document).ready(function () {
        <%include file="../name.js"/>
        const vbtn = $('#venus_calc');
        $('#mutation').keyup(e => {if ($(e.target).val().search(/\d+/) !== -1 && uniprotValue !== 'ERROR') {
                                                vbtn.show();
                                                $('#error_mutation').hide();
                                                $(e.target).removeClass('is-invalid');
                                                if (event.keyCode === 13) vbtn.click();
                                        } else {vbtn.hide();}
                                    });
        vbtn.click(e => {
            if (taxidValue === 'ERROR') {$('#error_species').show(); return 0;}
            if (uniprotValue === 'ERROR') {$('#error_gene').show(); return 0;}
            if ($('#mutation').val().search(/\d+/) === -1) {$('#error_mutation').show(); return 0;}

                $.ajax({
        type: "POST",
        url: "venus_analyse",
        data:  {uniprot: uniprotValue,
                species: taxidValue,
                mutation: $('#mutation').val()}
    })
        .done(function (msg) {
            if (msg.error) {
                $('#error_'+msg.error).show();
                $('#'+msg.error).addClass('is-invalid');
                ops.addToast('error','Error - '+msg.error,'<i class="far fa-bug"></i> An issue arose analysing the results.<br/>'+msg.msg,'bg-warning');}
            else {
                $('#retrieval_card').hide(1000);
            $('#input_card').hide(1000);
            $('main').append(msg);
            $('#new_analysis').show();
            $('#report-btn').show();
            }
        })
        .fail(ops.addErrorToast);
        });
    });
    ####include file="../markup/markup_builder_modal.js"/>
    window.interactive_builder = () => undefined; //burn the call.
</script>
    <link rel="stylesheet" href="https://www.matteoferla.com//feature-viewer/css/style.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.17/d3.js"></script>
    <script src="https://cdn.rawgit.com/calipho-sib/feature-viewer/v1.0.0/dist/feature-viewer.min.js"></script>
</%block>