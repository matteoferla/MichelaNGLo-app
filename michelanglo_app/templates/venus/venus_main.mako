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
    ### nothing.
</%block>

<%block name="main">
        <p>Add text here. See <a href="/docs/venus">documentation</a>.</p>
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
            #################### ALERTS
    <div class="alert alert-warning alert-dismissible fade show my-3" role="alert">
  This page is still being built, therefore some features may not work. Do feel free to contact me (Matteo) for any queries: I always welcome feedback be it on purpose or not. (<i class="far fa-comments"></i> button on the top right).
        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
    </div>
    <div class="alert alert-info  alert-dismissible fade show" role="alert">
        This is for academic use only and not intended to be used commercially. Conclusions drawn are suggestions and not diagnostic.
        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
    </div>



</%block>

<%block name='after_main'>
    <%include file="venus_result_section.mako"/>
</%block>

<%block name='modals'>
    ### This adds #structureless_modal
    <%include file="venus_no_structure.mako"/>
</%block>

<%block name='script'>
<script type="text/javascript">
    $(document).ready(function () {
        <%include file="../name.js"/>
        <%include file="../results/uniprot_modal.js"/>
        <%include file="venus.js"/>
    });
    ####include file="../markup/markup_builder_modal.js"/>
    window.interactive_builder = () => undefined; //burn the call.
</script>
    <link rel="stylesheet" href="/static/feature.css" async>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.17/d3.js"></script>
    ###<script src="https://cdn.rawgit.com/calipho-sib/feature-viewer/v1.0.0/dist/feature-viewer.min.js"></script>
    <script src="/static/ThirdParty/feature-viewer.js" async></script>
</%block>