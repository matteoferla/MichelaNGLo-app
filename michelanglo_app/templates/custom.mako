<%inherit file="layout_components/layout_w_card.mako"/>
<%block name="buttons">
            <%include file="layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>
<%block name="title">
            &mdash; Mesh converter
</%block>
<%block name="subtitle">
            This tool converts a obj file into a NGL mesh for you
</%block>

#### main.
<ul class="list-group list-group-flush">
            <li class="list-group-item">
                <p>A mesh is a series of connected triangles that form a 3D surface. Once you have created or downloaded a mesh and saved it as obj file with triangular faces, you can use this page to convert it to a code for use with NGL.</p>
        <div class='row'>
            ## obj input
            <div class="col-lg-6 mb-3">
                <div class="input-group" data-toggle="tooltip" title="Upload your OBJ file. When exporting the .obj file from Blender tick 'Triangulate faces'. UV mapping and normals are ignored.">
                  <div class="input-group-prepend">
                    <span class="input-group-text" id="upload_addon">Upload OBJ</span>
                  </div>
                  <div class="custom-file">
                    <input type="file" class="custom-file-input" id="upload" aria-describedby="upload_addon" accept=".obj">
                    <label class="custom-file-label" for="upload">Choose file</label>
                  </div>
                    <div class="input-group-append">
                    <button type="button" class="btn btn-info" id="demo_mod_btn" data-toggle="modal" data-target="#demo_modal">Demo</button>
                    </div>
                </div>
                <div class="invalid-feedback" id="error_upload">Please upload a valid obj file.</div>
            </div>
            ## center
            <div class="col-lg-6 mb-3">
                        <div class="input-group" data-toggle="tooltip" title="Set vertex centroid to zero. If unsure leave ticked.">
                          <div class="input-group-prepend">
                            <span class="input-group-text" id="centroid-addon">Centroid </span>
                          </div>
                          <div class="btn-group btn-group-toggle" data-toggle="buttons">
                          <label class="btn btn-secondary active">
                            <input type="radio" name="centroid" id="centroid_out" autocomplete="off" value="origin" checked> Origin
                          </label>
                          <label class="btn btn-secondary">
                            <input type="radio" name="centroid" id="centroid_unaltered" value="unaltered" autocomplete="off"> Unaltered
                          </label>
                          <label class="btn btn-secondary">
                            <input type="radio" name="centroid" id="centroid_custom" value="custom" autocomplete="off">
                              Custom
                          </label>
                        </div>
                        </div>
                    </div>
            ##scale
            <div class="col-lg-6 mb-3">
            <div class="input-group mb-3">
              <div class="input-group-prepend" title="Maximum size out of width, length and height">
                <span class="input-group-text" id="scale-addon1">Max size</span>
              </div>
              <input type="number" class="form-control" value=5 aria-label="scale" aria-describedby="scale-addon1" id="scale">
                <div class="input-group-append">
                <span class="input-group-text" id="scale-addon1">&Aring;</span>
              </div>
            </div>
            </div>
            <div class="col-lg-6 mb-3 border rounded collapse" id="centroid_custom_xyz">
                <div class="row">
                % for axis in ('x','y','z'):
                   <div class="col-12 col-xl-4">
                        <div class="input-group m-1">
                          <div class="input-group-prepend">
                            <span class="input-group-text" id="${axis}-addon">${axis}</span>
                          </div>
                          <input type="number" class="form-control" value=0 aria-label="${axis}" aria-describedby="${axis}-addon" id="${axis}">
                        </div>
                    </div>
                % endfor
                </div>
            </div>

        </div>
        <div class="row align-center">
                    <div class="col-md-4 offset-md-4">
                        <div class="btn-group d-flex" role="group" aria-label="Submit">
                            <button type="button" class="btn btn-warning flex-fill" id="clear">Clear</button>
                            <button type="button" class="btn btn-success flex-fill" id="submit">Submit</button>
                        </div>
                    </div>
                </div>
            </li>
        </ul>

<%block name="modals">
<div class="modal fade" tabindex="-1" role="dialog" id="demo_modal">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Demo OBJ</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        <p>Demo OBJs.</p>
          <div class="row">
              <div class="col-6 pr-0">
                  <div class="list-group">
              <button type="button" class="list-group-item list-group-item-action demo-obj" data-value="small_spiky.obj"> spiky icosohedron </button>
              <button type="button" class="list-group-item list-group-item-action demo-obj" data-value="large_spiky.obj"> spiky 2-icosphere </button>

            </div>
              </div>
              <div class="col-6 pl-0"><div class="list-group">
                <button type="button" class="list-group-item list-group-item-action demo-obj" data-value="teapot.obj"> teapot </button>
              </div></div>
          </div>

      </div>
    </div>
  </div>
</div>

</%block>

<%block name="script">
    <script type="text/javascript">
        $(document).ready(function () {

//////////////////////////////////////////////////////////////////////////
// upload button for OBJ
$('#upload').change(function () {
    var id=$(this).attr('id');
    var extension = '.obj';
    var file=$(this).val().split('\\').slice(-1)[0];
    if (!! $(this).val()) { //valid upload
        if ($(this).val().toLowerCase().search(extension) != -1) {
            $(this).addClass('is-valid');
            $(this).removeClass('is-invalid');
            $('#error_'+id).hide();
        }
        else { //invalid upload
            $(id).removeClass('is-valid');
            $(id).addClass('is-invalid');
            $('#error_'+id).show();
        }
    $('#'+id+'+.custom-file-label').html(file);
    } // else? nothing added. user chickened out.
});

//control modal demo buttons for pse model
var demo_obj='';
$('.demo-obj').click(function () {
    demo_obj=$(this).data('value');
    $('#upload+.custom-file-label').html('DEMO: '+demo_obj);
    $('#demo_modal').modal('hide');
    $('#obj_string').prop('checked',true);
    $('#obj_string').trigger('change');
});

$('[name="centroid"]').change(function () {
    console.log($(this).val());
    if ($(this).val() === 'custom') {
        $('#centroid_custom_xyz').collapse('show');
    } else {
        $('#centroid_custom_xyz').collapse('hide');
    }
});

//////////////////////////////////////////////////////////////////////////

// validation.
function valid_value(id){
    if (! $(id).val()) {
        window.setTimeout(function () {
            $(id).addClass('is-invalid');
            $(id)[0].scrollIntoView();
            $('#error_' + id.replace('#','')).show();
            $('#throbber').modal('hide');
            ops.addToast('errorate','Invalid',id+' is invalid','bg-warning');
            },0);
        throw 'Incomplete '+id;
    }
    else if (!! $(id)[0].files) {return $(id)[0].files[0]}
    else {return $(id).val();}
}

// submit for calculation
$('#submit').click(function () {
    //get ready by cleaning up
    ops.addToast('gogo','<i class="far fa-cog fa-spin"></i> Calculations in progress','Results shown shortly');
    $('#results').remove();
    stage=false;
    $('.is-invalid').removeClass('is-invalid');
    $('.is-valid').removeClass('is-valid');
    $('.invalid-feedback').hide();

    data = new FormData();
    if (demo_obj) {data.append('demo_filename',demo_obj);}
    else { data.append( 'file', valid_value('#upload'));}
    var centroid = $("input[name='centroid']:checked").val();
    data.append('centroid',centroid);
    if (centroid == 'custom') {
        data.append('origin',[$('#x').val(), $('#y').val(), $('#z').val()])
    }
    data.append('scale',$('#scale').val());
    $.ajax({
        type: "POST",
        url: "convert_mesh",
        processData: false,
        enctype: "multipart/form-data",
        cache: false,
        contentType: false,
        data:  data
    })
            .done(function (msg) {
                ops.addToast('complete','Complete','Job compled successfully','bg-info');
                $('.card-body > ul').append(msg);
            })
            .fail(function (xhr) {
                ops.addToast('error','Error','Serverside error','bg-danger');
            })
});

        }); //ready
    </script>
</%block>
