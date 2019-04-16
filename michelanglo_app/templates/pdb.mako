<%namespace file="layout_components/labels.mako" name="info"/>
<%inherit file="layout_components/layout_w_card.mako"/>
<%block name="buttons">
            <%include file="layout_components/menu_buttons.mako" args='tour=False'/>
</%block>
<%block name="title">
            &mdash; PDB
</%block>
<%block name="subtitle">
            Convert a PDB file or code to an interactive NGL viewport
</%block>


<%block name="body">
<ul class="list-group list-group-flush">
            <li class="list-group-item">
                <h3>Step 1 <small class="text-muted">Load structure</small></h3>
                <p>For greater control see <a href="pymol">PyMOL converter</a>.</p>
                <div class="row">
                    <div class="col-12 col-md-5">

                        <div class="input-group mb-3" data-toggle="tooltip"
                                     title="4 letter PDB code">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text">PDB code</span>
                                    </div>
                                    <input type="text" class="form-control" id="pdb" autocomplete="new-password">
                                    <div class="invalid-feedback" id="error_pdb">Weird PDB code</div>
                                    <div class="input-group-append">
                                        <button class="btn btn-success" type="button" id="code_load">Load</button>
                                    </div>

                                </div>

                    </div>
                    <div class="col-12 col-md-1">
                        <p> or </p>
                    </div>
                    <div class="col-12 col-md-5 ">

                            <div class="input-group" data-toggle="tooltip" title="Upload your PDB file">
                              <div class="input-group-prepend">
                                <span class="input-group-text" id="upload_addon_pdb">Upload PDB</span>
                              </div>
                              <div class="custom-file">
                                <input type="file" class="custom-file-input" id="upload_pdb" aria-describedby="upload_addon_pdb" accept=".pdb">
                                <label class="custom-file-label" for="upload_pdb">Choose file</label>
                              </div>
                            </div>
                            <div class="invalid-feedback" id="error_upload_pdb">Please upload a valid pdb file.</div>
                    </div>
                </div>
            </li>
                    <li class="list-group-item" id="staging" style="display: none;">
                <h3>Step 2 <small class="text-muted">Configure initial view</small></h3>
                    <div class="row">
                    <div class="col-6"><div id="viewport" style="width: 100%; height: 0; padding-bottom: 100%;"></div>
                    </div>
                    <div class="col-6">
                        <p>Choose how the starting view of the protein should look like.</p>


                        <div class="input-group mb-3">
                          <div class="input-group-prepend">
                            <span class="input-group-text" id="viewcode-label">Viewport code</span>
                          </div>
                          <textarea rows=5 type="text" class="form-control" aria-label="Viewport code" aria-describedby="viewcode-label" id="viewcode">
                              </textarea>
                              <div class="input-group-append d-flex flex-column" role="group">
                            <button type="button" class="btn btn-info rounded-right mb-2" data-toggle="modal" data-target="#markup_modal" style="height: 3.9rem;"><i class="far fa-hammer"></i> Build link code</button>
                            <button type="button" class="btn btn-primary rounded-right" id="create" style="height: 3.9rem;"><i class="far fa-pencil-ruler"></i> Make page</button>
                              </div>
                        </div>
                    </div>
                    </div>
            </li>
</ul>
</%block>

<%block name='modals'>
    <%include file="markup/markup_builder_modal.mako"/>
</%block>

<%block name='script'>

    <script type="text/javascript">
        <%include file="markup/markup_builder_modal.js"/>

    $('#code_load').click(function () {
        window.mode = 'code'; //file | code
        $('.is-invalid').removeClass('is-invalid');
        $('.is-valid').removeClass('is-valid');
        $('.invalid-feedback').hide();
        if ($('#pdb').val().length !== 4) {
            $('#pdb').addClass('is-invalid');
            $('#error_pdb').show();
            return false;
        }
        $('#staging').show();
        window.myData = undefined;
        NGL.stageIds = {};
        $('#viewcode').text('<div role="NGL" data-load="'+$('#pdb').val()+'" ></div>');
        NGL.specialOps.multiLoader('viewport',[{'type': 'rcsb','value': $('#pdb').val()}]);
        NGL.specialOps.showTitle('viewport', 'Loaded: '+ $('#pdb').val() );
    });

    $('#upload_pdb').change(function () {
        window.mode = 'file'; //file | code
        // check if good.
        var extension = '.pdb';
        var filename=$(this).val().split('\\').slice(-1)[0];
        if (!! $(this).val()) { //valid upload
            if ($(this).val().toLowerCase().search(extension) != -1) {
            $(this).addClass('is-valid');
            $(this).removeClass('is-invalid');
            $('#error_upload_pdb').hide();
        }
        else { //invalid upload
            $(id).removeClass('is-valid');
            $(id).addClass('is-invalid');
            $('#error_upload_pdb').show();
        }
        $('#upload_pdb+.custom-file-label').html(filename);
        } // else? nothing added. user chickened out.
        // load.
        $('#staging').show();
        window.myData = undefined;
        NGL.stageIds = {};
        $('#viewcode').text('<div role="NGL" data-proteins=\'[{"type": "data", "value": "pdbString", "isVariable": true}]\'></div>');
        NGL.specialOps.multiLoader('viewport',[{'type': 'file','value': $('#upload_pdb')[0].files[0]}]);
        NGL.specialOps.showTitle('viewport', 'Loaded: '+ $('#pdb').val() );

    });

    $('#results').append('<button type="button" class="btn btn-success mb-2" aria-label="Close" data-dismiss="modal">Use created link</button>');

    $('#markup_modal').on('hidden.bs.modal', function (e) {
        var code = $('#results code').text().split('>')[0].replace('data-toggle="protein"','');
        if (window.mode === 'code') {code = code.replace('<a href="#viewport"','<div role="NGL" data-load="'+$('#pdb').val()+'" ')+'></div>';}
        else {code = code.replace('<a href="#viewport"',
                '<div role="NGL" data-proteins=\'[{"type": "data", "value": "pdb", "isVariable": true}]\'')+'></div>';}
      $('#viewcode').html(code);
    });

    $('#create').click(function () {
        //hard reset to proove all runs fine
        $('#viewport').detach();
        window.myData = undefined;
        NGL.stageIds = {};
        // get data.
        var data = new FormData();
        data.append('mode',window.mode); //file | code
        if (window.mode === 'code') {data.append('pdb',$('#pdb').val());}
        else {data.append('file',$('#upload_pdb')[0].files[0]);}
        data.append('viewcode',$('#viewcode').text()); //needs two to make it list.
        //ajax it.
        ops.addToast('submitting','Submission','Submission in progress.','bg-info');
        $.ajax({
            type: "POST",
            url: "ajax_pdb",
            processData: false,
            enctype: "multipart/form-data",
            cache: false,
            contentType: false,
            data:  data
        }).done(function (msg) {
                ops.addToast('jobcompletion','Conversion complete','The data has been converted successfully.','bg-success');
                console.log(msg);
                window.location.href = "/data/"+msg.page;
            })
            .fail(function () {
                ops.addToast('jobcompletion','Conversion failed','The data did not convert correctly.','bg-danger');
            });
    });


    </script>
</%block>
