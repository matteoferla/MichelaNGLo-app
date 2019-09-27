## inserted into pdb_converter.mako and name.mako.
## JS is unique to each of these and is the .js version of these files.

<h3>Step 2 <small class="text-muted">Configure initial view</small></h3>
<p>Choose how the view of the protein should look like when page first loads (initial view) by either using the view-building interface or by editing the tag directly. See <a href="/docs/markup" target="_blank">documentation</a> for more information.</p>

<div id="renumber_alert" class="alert alert-warning alert-dismissable fade" role="alert">
    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
    <span aria-hidden="true">&times;</span>
  </button>
    <h5 class="alert-heading">Residue numbering mismatch</h5>
    The residue numbers in the PDB file and those in Uniprot differ for <span id="renumber_details">some chains</span> <span data-toggle="tooltip" title="The reasons for this stem from the crystallisation requirements, such as a fragment of the whole protein is expressed and crystallised, fusion protein etc. Herein by offset it is intended the number to be added to the PDB residue index to get the Uniprot index, namely say a fragment spanning residues 100-200 was crystallised and the structure deposited started at 1, there would be an offset of 99, wherein residue 100 in the full protein sequence is residue 1 in the structure. Simply put, if you care about the protein residues as they are for the whole protein the check the box (most likely case). "><i class="far fa-question-circle"></i></span> <br/>
    Press here to make the residues in the structure to match Uniprot (irreversible): <button type="button" class="btn btn-success" id="renumber">Renumber</button>
</div>

<div class="row">
        <div class="col-6"><div id="viewport" style="width: 100%; height: 0; padding-bottom: 100%;"></div>
        </div>
        <div class="col-6">
            <%include file="markup/markup_builder_content.mako"/>
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