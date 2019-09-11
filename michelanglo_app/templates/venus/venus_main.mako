## route name: /name
## this view is for Gene name/accession id to pdb
<%namespace file="layout_components/labels.mako" name="info"/>
<%inherit file="layout_components/layout_w_card.mako"/>
<%block name="buttons">
            <%include file="layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>
<%block name="title">
            &mdash; VENUS MOD
</%block>
<%block name="subtitle">
            ???????????
</%block>

<%block name="main">
    <p>TEST.</p>
    <div class="row">
        <div class="col-12 col-lg-5">
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

        <div class="col-12 col-lg-5">
            <div class="input-group mb-3" data-toggle="tooltip"
                                     title="A gene name, protein name or Uniprot accession.">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text">Gene/protein name</span>
                                    </div>
                                    <input type="text" class="form-control rounded-right" id="gene" autocomplete="new-password">
                                    <div class="invalid-feedback" id="error_gene">Unrecognised name</div>
                                    <div class="valid-feedback" id="uniprot">Error</div>
                                </div>
        </div>
        <div class="col-12 col-lg-2">
            <button type="button" class="btn btn-outline-primary w-100" id="pdb_fetch" style="display: none;">Analyse</button>
        </div>
    </div>

</%block>

<%block name='modals'>
    <%include file="markup/markup_builder_modal.mako"/>
</%block>

<%block name='script'>
<script type="text/javascript">
    $(document).ready(function () {
        <%include file="name.js"/>
        <%include file="markup/markup_builder_modal.js"/>
        <%include file="pdb_staging_insert.js"/>
    });
</script>
    <link rel="stylesheet" href="https://www.matteoferla.com//feature-viewer/css/style.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.17/d3.js"></script>
    <script src="https://cdn.rawgit.com/calipho-sib/feature-viewer/v1.0.0/dist/feature-viewer.min.js"></script>
</%block>