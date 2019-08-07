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
    if (window.mode === undefined) {
        // we are in name.mako
        window.mode = 'code';
        data.append('pdb',window.pdb);
    } else if (window.mode === 'code') {data.append('pdb',$('#pdb').val());}
    else {data.append('pdb',$('#upload_pdb')[0].files[0]);}
    data.append('viewcode',$('#viewcode').text()); //needs two to make it list.
    data.append('mode',window.mode); //file | code
    //ajax it.
    ops.addToast('submitting','Submission','Submission in progress.','bg-info');
    $.ajax({
        type: "POST",
        url: "convert_pdb",
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