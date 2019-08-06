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
    <div class="row">
        <div class="col-12">
            <div class="input-group mb-3" data-toggle="tooltip"
                                     title="A human gene name, protein name or Uniprot accession.">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text">Human gene/protein name</span>
                                    </div>
                                    <input type="text" class="form-control" id="name" autocomplete="new-password">
                                    <div class="invalid-feedback" id="error_pdb">Unrecognised name</div>
                                    <div class="input-group-append">
                                        <button class="btn btn-success" type="button" id="name_fetch" onclick="alert('To be finished.');">Go</button>
                                    </div>

                                </div>

            <div class="input-group mb-3" data-toggle="tooltip"
                                     title="Non-human Uniprot accession">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text">Non-human uniprot acc id</span>
                                    </div>
                                    <input type="text" class="form-control" id="name" autocomplete="new-password">
                                    <div class="invalid-feedback" id="error_pdb">Unrecognised name</div>
                                    <div class="input-group-append">
                                        <button class="btn btn-success" type="button" id="name_fetch" onclick="alert('To be finished.');">Go</button>
                                    </div>

                                </div>
            <p>For further steps see <a href="/docs/gene">documentation</a>.</p>
        </div>
    </div>

</%block>