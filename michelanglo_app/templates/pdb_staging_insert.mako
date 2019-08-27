<h3>Step 2 <small class="text-muted">Configure initial view</small></h3>
<p>Choose how the view of the protein should look like when page first loads (initial view) by either using the view-building interface or by editing the tag directly. See <a href="/docs/markup" target="_blank">documentation</a> for more information.</p>
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

<%include file="markup/markup_builder_select_modal.mako"/>
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