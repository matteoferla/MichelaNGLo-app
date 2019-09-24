<%namespace file="layout_components/labels.mako" name="info"/>
<%inherit file="layout_components/layout_w_card.mako"/>
<%block name="buttons">
            <%include file="layout_components/vertical_menu_buttons.mako" args='tour=False'/>
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
                <p>For greater control see <a href="pymol">PyMOL converter</a>. If in need of a demo, you could try the PDB code <a href="#" onclick="$('#pdb').val('1UBQ')">1UBQ</a> (ubiquitin) as it has a fun helix to look down at 22-34 or <a href="#" onclick="$('#pdb').val('1GFL')">1GFL</a> (wild type GFP), which has a chromophore at 65-67:A.</p>
                <div class="row">
                    <div class="col-12 col-md-5">

                        <div class="input-group mb-3" data-toggle="tooltip"
                                     title="4 letter PDB code.">
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
                        <%include file="pdb_staging_insert.mako"/>
            </li>
</ul>
</%block>

<%block name='modals'>
    <%include file="markup/markup_builder_modal.mako"/>
</%block>

<%block name='script'>

    <script type="text/javascript">
        <%include file="markup/markup_builder_modal.js"/>


    window.start_stage_two = () => {
        $('#staging').show();
        window.myData = undefined;
        NGL.stageIds = {};
        $('#viewport').html('');
    };

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
        start_stage_two();
        window.pdbCode = $('#pdb').val();
        $('#viewcode').text('<div role="NGL" data-load="'+$('#pdb').val()+'" ></div>');
        NGL.specialOps.multiLoader('viewport',[{'type': 'rcsb','value': pdbCode}]);
        NGL.specialOps.showTitle('viewport', 'Loaded: '+ pdbCode );
        renumber_alerter(pdbCode);
        interactive_builder();
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
        start_stage_two();
        let pdb = $('#pdb').val();
        $('#viewcode').text('<div role="NGL" data-proteins=\'[{"type": "data", "value": "pdbString", "isVariable": true}]\'></div>');
        NGL.specialOps.multiLoader('viewport',[{'type': 'file','value': $('#upload_pdb')[0].files[0]}]);
        NGL.specialOps.showTitle('viewport', 'Loaded: '+ pdb );
        interactive_builder();
    });

    <%include file="pdb_staging_insert.js"/>

    </script>
</%block>
