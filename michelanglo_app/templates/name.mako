## route name: /name
## this view is for Gene name/accession id to pdb
<%namespace file="layout_components/labels.mako" name="info"/>
<%inherit file="layout_components/layout_w_card.mako"/>
<%block name="buttons">
            <%include file="layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>
<%block name="title">
            &mdash; Name to PDB
</%block>
<%block name="subtitle">
            Get a model of a protein by querying a name
</%block>

<%block name="main">
    <p>This convenient form simply searches for PDBs that match your protein, while for a more comprehensive search use the <a href="https://www.rcsb.org/" target="_blank">PDB database <i class="far fa-external-link"></i></a>.<br/>
        If you already know the PDB code of your protein see <a href="/pdb">PDB conversion page</a>.
        <br/>
        For more information about choosing a model see <a href="/docs/gene">documentation</a>.</p>
    <div class="row">
        <div class="col-12 col-lg-5">
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

        <div class="col-12 col-lg-5">
            <div class="input-group mb-3" data-toggle="tooltip"
                                     title="A gene name, protein name or Uniprot accession.">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text">Gene/protein name</span>
                                    </div>
                                    <input type="text" class="form-control rounded-right" id="gene" autocomplete="off">
                                    <div class="invalid-feedback" id="error_gene">Unrecognised name</div>
                                    <div class="valid-feedback" id="uniprot">Error</div>
                                </div>
        </div>
        <div class="col-12 col-lg-2">
            <button type="button" class="btn btn-outline-primary w-100" id="pdb_fetch" style="display: none;">Fetch</button>
        </div>



        </div>
    <div class="row">
        <div id="fv_label" class="col-12" style="display: none;">
        <h5>Info</h5>
        <p>Data loaded for <b><span id="label_protName"><i class="fas fa-spinner fa-spin"></i></span></b></p>
        <h5>Length</h5>
            <p>Two pieces of information are presented here to help you choose: the first is the length of the protein and the second is the partners if any in the structure.</p>

            <div class="alert alert-info" role="alert">
                <i class="far fa-hand-pointer"></i> Clicking on an entry in the PDB or Swissmodel tracks (if structures are present) will load that protein structure.
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                  </button>
            </div>
        </div>
        <div class="col-12">
            <div id="fv"></div>
        </div>
        <div id="matches_label" class="col-12"  style="display: none;">
        <h5>Binding partners</h5>
            <p>Proteins can be crystallised with ligands or binding partners and it is often beneficial to choose a specific one.</p>
            <div class="alert alert-info" role="alert">
                <i class="far fa-hand-pointer"></i> Clicking on a row of the table will load that protein structure.
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                  </button>
            </div>

            <div id="partner_table"></div>
        </div>

        <div class="col-12" id="ext_links">

        </div>
    </div>
    <div id="staging" style="display: none;">
        <%include file="pdb_staging_insert.mako"/>
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
    <link rel="stylesheet" href="/static/feature.css" async>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.17/d3.js"></script>
    <script src="https://cdn.rawgit.com/calipho-sib/feature-viewer/v1.0.0/dist/feature-viewer.min.js" async></script>
</%block>