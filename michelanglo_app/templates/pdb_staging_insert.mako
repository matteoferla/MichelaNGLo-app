## inserted into pdb_converter.mako and name.mako.
## JS is unique to each of these and is the .js version of these files.

<h3>Step 2 <small class="text-muted">Configure initial view</small></h3>
<p>Choose how the view of the protein should look like when page first loads (initial view) by either using the view-building interface or by editing the tag directly. See <a href="/docs/markup" target="_blank">documentation</a> for more information.</p>

############## ALERTS
<div id="renumber_alert" class="alert alert-danger alert-dismissable fade" role="alert">
    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
    <span aria-hidden="true">&times;</span>
  </button>
    <h5 class="alert-heading">Residue numbering mismatch</h5>
    The residue numbers in the PDB file and those in Uniprot differ for <span id="renumber_details">some chains</span> <span data-toggle="tooltip" title="The reasons for this stem from the crystallisation requirements, such as a fragment of the whole protein is expressed and crystallised, fusion protein etc. Herein by offset it is intended the number to be added to the PDB residue index to get the Uniprot index, namely say a fragment spanning residues 100-200 was crystallised and the structure deposited started at 1, there would be an offset of 99, wherein residue 100 in the full protein sequence is residue 1 in the structure. Simply put, if you care about the protein residues as they are for the whole protein the check the box (most likely case). "><i class="far fa-question-circle"></i></span> <br/>
    Click this to make the residues in the structure to match Uniprot (irreversible): <button type="button" class="btn btn-success" id="renumber">Renumber</button>
</div>

<div id="model_alert" class="alert alert-warning alert-dismissable fade" role="alert">
    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
    <span aria-hidden="true">&times;</span>
  </button>
    <h5 class="alert-heading">Predicted model</h5>
    This structure is from Swiss-Model. It is a computational model generated by threaded against a crystallised structure (<a href="https://swissmodel.expasy.org/docs/help#new_project" target="_blank">Swissmodel docs <i class="far fa-external-link"></i></a>). It may be incorrect. E.g. missing ligands or broken cysteine bonds.
</div>

<div id="naturalise_alert" class="alert alert-warning alert-dismissable fade" role="alert">
    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
    <span aria-hidden="true">&times;</span>
  </button>
    <h5 class="alert-heading">Engineered residues</h5>
    <p>The protein contains engineered residues (<span id="naturalise_details"></span>) <span data-toggle="tooltip" title="Engineered residues came in different forms and this protein may have one of the following. (1) To help solve the phasing problem, instead of methionine, selenomethionines (MSE) is used (this will appear as M1X formatted mutations). (2) mutations to improve crystallisation or (3) mutations that prevent catalysis. Do note that the latter of these categories may cause clashes with ligands if present."><i class="far fa-question-circle"></i></span>. Click this to make the residues in the structure to match Uniprot (irreversible): <button type="button" class="btn btn-success" id="naturalise">Fix</button></p>
</div>
############## MAIN BLOCK
<div class="row">
    <div class="col-6" id="viewportHolder">
        %if request.path != '/venus_multiple':
        <div id="viewport" style="width: 100%; height: 0; padding-bottom: 100%;"></div>
        %else:
        ## pass
        %endif
    </div>
        <div class="col-6">
            <h4>Initial view</h4>
            <%include file="markup/markup_builder_content.mako"/>
            <br/>
            <h4>Other</h4>
            <div>
            <span data-toggle="tooltip" title="Create point mutations in this structure. The mutations are generated via the PyMOL mutagenesis fuction and alter side chain only.">
                <button type="button" class="btn btn-outline-info mb-3" data-toggle="collapse" data-target="#mutate_collapse" id="mutate_collapse_btn"><i class="far fa-biohazard"></i> Make mutations</button>
           </span>
            <span data-toggle="tooltip" title="Choose chains to delete">
                <button type="button" class="btn btn-outline-info mb-3" data-toggle="collapse" data-target="#delete_collapse" id="delete_collapse_btn"><i class="far fa-trash"></i> Remove parts</button>
           </span>
           <span data-toggle="tooltip" title="Remove water and selected ligands">
                <button type="button" class="btn btn-outline-info mb-3" data-toggle="collapse" data-target="#dehydrate_collapse" id="dehydrate_collapse_btn"><i class="far fa-tint"></i> Remove waters</button>
           </span>
            </div>
            <div class="collapse bg-light rounded p-3 border" id="mutate_collapse">
                <h5>Mutagenesis</h5>
                <p class="mb-3">The mutations will be in the main structure after the page is created. If the mutated residue is shown in the initial view, it is suggested to use <a href="#markup_form" onclick="$('#clash').parent().click();">'clash' focus mode</a>.
                    To show first the wild type structure on page loading but allow the visitor to toggle to a mutation, create a page with no mutations and then add them in the edit menu.</p>
                ### straight copypaste
                <div class="input-group mb-3">
                  <div class="input-group-prepend">
                    <span class="input-group-text" id="mutate_chain_label">Chain</span>
                  </div>
                  <input type="text" class="form-control" placeholder="A" aria-label="A" aria-describedby="mutate_chain_label" id="mutate_chain">
                </div>
                <div class="input-group" data-toggle="tooltip" title="Space or newline separated. <code>M1W D20D</code> for example.The residue must exist on the structure. NB. The first aa is not checked, so it is up to you to get the residue right.">
                  <div class="input-group-prepend">
                    <span class="input-group-text">List of mutations</span>
                  </div>
                  <textarea class="form-control" aria-label="With textarea" id="mutate_mutations"></textarea>
                </div>
                <button id="mutate" class="btn btn-success w-100">Mutate</button>
                </div>
            <div class="collapse bg-light rounded p-3 border" id="delete_collapse">
                <h5>Chain removal</h5>
                <p class="mb-3">The asymmetric state of crystal structures do not always reflect the oligomerisation of the protein or there may be unneeded chains.</p>
                ### straight copypaste
                <div class="input-group mb-3">
                  <div class="input-group-prepend">
                    <span class="input-group-text" id="delete_chain_label">Chain</span>
                  </div>
                  <input type="text" class="form-control" aria-describedby="delete_chain_label" id="delete_chains" placeholder="chain ids">
                </div>
                <button id="delete" class="btn btn-success w-100">Delete</button>
                </div>
            <div class="collapse bg-light rounded p-3 border" id="dehydrate_collapse">
                <h5>Remove waters and ligands</h5>
                <p class="mb-3">Crystallographic waters are that kept in an ordered position by the protein. Often chemicals that aid in crystallisation are similarly found. Natural ligands will not be removed (<i>cf.</i> <a href="https://blog.matteoferla.com/2019/11/go-away-glycerol.html" target="_blank">blacklist</a>).</p>
                <div clss="row" id="ligandlist">
                    <div class="col-12 mb-2">
                    <div class="border rounded bg-light p-2">
                        <div class="custom-control custom-switch">
                          <input class="custom-control-input"  id="water_toggle" type="checkbox" >
                            <label class="custom-control-label" for="water_toggle">Remove <span class="prolink" data-target="viewport" data-radius="-1" data-toggle="protein" data-focus="residue" data-selection="water">waters</span></label>
                        </div>
                    </div>
                </div>
                    <div class="col-12 mb-2">
                        <div class="border rounded bg-light p-2">
                        <div     class="custom-control custom-switch">
                          <input class="custom-control-input"  id="artefact_toggle" type="checkbox" >
                          <label class="custom-control-label" for="artefact_toggle">Remove <span class="prolink" data-target="viewport" data-radius="-1" data-toggle="protein" data-focus="residue" data-selection="ligand">crystallisation compounds</span></label>
                        </div>
                    </div>
                    </div>
                </div>
                 <button id="dehydrate" class="btn btn-success w-100">Remove selected</button>
                </div>
        </div>
        </div>
<h3>Step 3 <small class="text-muted">Create</small></h3>

            <p>Create page. Note that chosen initial view cannot be changed once created.</p>
    <div class="row">
        <div class="col-2 offset-2">
            <button type="button" class="btn btn-primary  w-100" id="create" style="height: 3.9rem;"><i class="far fa-pencil-ruler"></i> Make page</button>
        </div>
    </div>

## The following is not used as the content (markup_builder_content) is added in the grid.
##%include file="markup/markup_builder_select_modal.mako"/
<!---

            <div class="input-group mb-3">
              <div class="input-group-prepend">
                <span class="input-group-text" id="viewcode-label">Viewport code</span>
              </div>
                <button type="button" class="btn btn-outline-info rounded-0" data-toggle="modal" data-target="#markup_modal"><i class="far fa-hammer"></i> Use view<br/>builder</button>
            </div>
            <textarea rows=5 type="text" class="form-control" aria-label="Viewport code" aria-describedby="viewcode-label" id="viewcode" style="display: none;">
                  </textarea>




    $('#results').append('<button type="button" class="btn btn-success mb-2" aria-label="Close" data-dismiss="modal">Use created link</button>');

$('#markup_modal').on('hidden.bs.modal', function (e) {
    var code = $('#results code').text().split('>')[0].replace('data-toggle="protein"','');
    if (window.mode === 'code') {code = code.replace('<a href="#viewport"','<div role="NGL" data-load="'+$('#pdb').val()+'" ')+'></div>';}
    else {code = code.replace('<a href="#viewport"',
            '<div role="NGL" data-proteins=\'[{"type": "data", "value": "pdb", "isVariable": true}]\'')+'></div>';}
  $('#viewcode').html(code);
});

                  -->