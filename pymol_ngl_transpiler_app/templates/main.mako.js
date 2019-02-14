/*
<%namespace file="labels.mako" name="info"/>
<%doc>
 This file is a mako template to make JS. The extension is backwards to avoid tinkering with the default PyCharm editor.
 This file contains the main page's script.
</%doc>
*/

//housekeeping
$('[data-toggle="tooltip"]').tooltip();

//toggle swtich to control teh mode.
$('[name="input_mode"]').on('change', function() {
  if($(this).val() === "file") {
    $('#in_via_file').collapse('show');
    $('#in_via_out,#in_via_pdb').collapse('hide');
  } else if($(this).val() === "out") {
    $('#in_via_out').collapse('show');
    $('#in_via_file,#in_via_pdb').collapse('hide');
  } else if($(this).val() === "pdb") {
      $('#in_via_pdb').collapse('show');
      $('#in_via_out,#in_via_file').collapse('hide');
  } else {
      alert('No idea why I thought I needed a third.')
  }
});
//////////////////////////////////////////////////////////////////////////
//control the resolt of ticking the pdb data in the code checkbutton
$('#pdb_string').change(function () {
    if ($('#pdb_string').is(':checked')) {
        $('#pdb').attr('disabled',true);
        $('#pdb').val('N/A');
        $('#pdb').removeClass('is-invalid');
        $('#error_pdb').hide();
    } else {
        $('#pdb').removeAttr('disabled');
        $('#pdb').val('');
        $('#pdb').addClass('is-invalid');
        $('#error_pdb').show();
    }
});

//////////////////////////////////////////////////////////////////////////
// upload button for PSE and PDB
$('#upload,#upload_id').change(function () {
    var id=$(this).attr('id');
    var extension = id == 'upload' ? '.pse' : '.pdb';
    var file=$(this).val().split('\\').slice(-1)[0];
    if (!! $(this).val()) { //valid upload
        if ($(this).val().toLowerCase().search(extension) != -1) {
        $(this).addClass('is-valid');
        $(this).removeClass('is-invalid');
        $('#error_'+id).hide();
        if (extension == '.pse') {
            if (! $('#pdb').val()) {$('#pdb').val(file).replace('.pse','.pdb')}
        }
        else {
            //unique actions for pdb
        }
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
var demo_pse='';
$('.demo-pse').click(function () {
    demo_pse=$(this).data('value');
    $('#upload+.custom-file-label').html('DEMO: '+demo_pse);
    $('#demo_modal').modal('hide');
    $('#pdb_string').prop('checked',true);
    $('#pdb_string').trigger('change');
});
//////////////////////////////////////////////////////////////////////////
// demo button for output mode
$('#demo').click(function () {
    $("#input_mode_out").prop("checked", false);
    $.get("static/pymol_demo.txt", function (text) {
        $('#pymol_output').val(text);
    });
});


//////////////////////////////////////////////////////////////////////////
// reset
$('#clear').click(function () {
    $('#results').remove();
    $('#pymol_output').val('');
    $('#pdb').val('');
    $('.is-invalid').removeClass('is-invalid');
    $('.is-valid').removeClass('is-valid');
    $('.invalid-feedback').hide();
});

// validation.
function valid_value(id){
    if (! $(id).val()) {
        window.setTimeout(function () {
            $(id).addClass('is-invalid');
            $(id)[0].scrollIntoView();
            $('#error_' + id.replace('#','')).show();
            $('#throbber').modal('hide');
            },0);
        throw 'Incomplete '+id;
    }
    else if (!! $(id)[0].files) {return $(id)[0].files[0]}
    else {return $(id).val();}
}

// submit for calculation
$('#submit').click(function () {
    //get ready by cleaning up
    $('#throbber').modal('show');
    $('#results').remove();
    stage=false;
    $('.is-invalid').removeClass('is-invalid');
    $('.is-valid').removeClass('is-valid');
    $('.invalid-feedback').hide();

    data = new FormData();
    // determine mode
    var mode=$("input[name='input_mode']:checked").val();
    // deal with the include PDB data which means that the it is not a publically available PDB.
    if ($('#pdb_string').is(':checked')) {data.append( 'pdb', ''); data.append('pdb_string',1)} else {data.append( 'pdb', valid_value('#pdb'));}
    data.append( 'mode', mode );
    if        (mode == 'out') {
        data.append('pymol_output', valid_value('#pymol_output'));
    } else if (mode == 'file' && !! demo_pse) {data.append('demo_file',demo_pse);
    } else if (mode == 'file') {    data.append( 'file', valid_value('#upload'));
    } else if (mode == 'pdb') {
        if (!! $('#upload_pdb')[0].files) {data.append( 'pdb_file', valid_value('#upload_pdb'));}
        else {data.append( 'pdb', valid_value('#pdb'));}
    } else {throw 'Impossible mode';}
    data.append( 'uniform_non_carbon',$('#uniform_non_carbon').is(':checked'));
    data.append('viewport_id',valid_value('#viewport_id'));
    data.append( 'image',$('#image').is(':checked'));
    data.append('stick',$("input[name='sticks']:checked").val());
    var snapshot = '';
    if ($('#snapshot').is(':checked')) {
        snapshot = $('#snapshot_id').val();
    }
    data.append('save',snapshot);
    var cdn = '';
    if ($('#cdn_bool').is(':checked')) {
        cdn = $('#cdn').val();
    }
    data.append( 'cdn',cdn);
    data.append( 'indent',$('#indent').val());
    //{pdb: pdb, uniform_non_carbon: uniform_non_carbon, pymol_output: pymol_output, indent: indent, cdn: cdn}
    $.ajax({
        type: "POST",
        url: "ajax_convert",
        processData: false,
        enctype: "multipart/form-data",
        cache: false,
        contentType: false,
        data:  data
    })
            .done(function (msg) {
                $('#throbber').modal('hide');
                $('.card-body > ul').append(msg);
            })
            .fail(function () {
                $('#throbber').modal('hide');
                alert('ERROR');
            })
});
