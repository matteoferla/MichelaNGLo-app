<%namespace file="labels.mako" name="info"/>
<%inherit file="layout_w_card.mako"/>
<%block name="buttons">
            <%include file="menu_buttons.mako" args='tour=False'/>
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
                <p>For greater control see <a href="pymol">PyMOL converter</a>.</p>
                <div class="row">
                    <div class="col-12 col-md-5">

                        <div class="input-group mb-3" data-toggle="tooltip"
                                     title="${info.attr.pdb|n}">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text">PDB code</span>
                                    </div>
                                    <input type="text" class="form-control" id="pdb">
                                    <div class="invalid-feedback" id="error_pdb">Weird PDB code</div>
                                    <div class="input-group-append">
                                        <button class="btn btn-primary" type="button" id="code_load">Load</button>
                                    </div>

                                </div>

                    </div>
                    <div class="col-12 col-md-1">
                        <p> or </p>
                    </div>
                    <div class="col-12 col-md-5">

                            <div class="input-group" data-toggle="tooltip" title="Upload your PDB file">
                              <div class="input-group-prepend">
                                <span class="input-group-text" id="upload_addon_pdb">Upload PDB</span>
                              </div>
                              <div class="custom-file">
                                <input type="file" class="custom-file-input" id="upload_pdb" aria-describedby="upload_addon_pdb" accept=".pdb, .cif">
                                <label class="custom-file-label" for="upload_pdb" style="margin-right: 60px;">Choose file</label>
                                  ### fix the styling.
                                <button class="btn btn-primary" type="button" id="upload_load">Load</button>
                              </div>
                            </div>
                            <div class="invalid-feedback" id="error_upload_pdb">Please upload a valid pdb file.</div>
                    </div>
                </div>
            </li>
</ul>
</%block>
<%block name='script'>
    <script type="text/javascript">
    $('#code_load').click(function () {
        $('.is-invalid').removeClass('is-invalid');
        $('.is-valid').removeClass('is-valid');
        $('.invalid-feedback').hide();
        if ($('#pdb').val().length !== 4) {
            $('#pdb').addClass('is-invalid');
            $('#error_pdb').show();
            return false;
        }
        //pass;
    });

    $('#upload_load').click();
    </script>
</%block>
