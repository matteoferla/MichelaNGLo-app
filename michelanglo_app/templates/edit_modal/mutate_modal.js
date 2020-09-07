// Mako templating is present

$('#mutate_create').click((event) => {

    let name = $('#mutate_name').val() || 'mutant_${len(structure_info)}'; // this $ { is a mako one!!
    let chain = $('#mutate_chain').val() || 'A';
    let mutations = $('#mutate_mutations').val().replace(/p\./gm,'').split(/[\W,]+/);
    console.log(mutations);
    $('#mutate_create').attr('disabled','disabled').children('.far').removeClass('fa-wrench').addClass('fa-circle-notch').addClass('fa-spin');
    ops.addToast('informare','Data submission','Your request is being processed','bg-info');
    let data = {
                'name': name,
                'page': window.page,
                'model': 0,
                'chain': chain,
                'mutations': mutations.join(' ')
            };
    if (window.encryption_key !== undefined) {data.target_encryption_key = window.encryption_key}
    $.ajax({
            url: "/mutate",
            type: 'POST',
            dataType: 'json',
            data: data
        }   )
        .done((msg) => location.reload())
        .fail((xhr) => ops.addToast('userpageerror','Error '+xhr.status,'An error occured. '+(!! xhr.responseJSON ? xhr.responseJSON.status : '(server side)'),'bg-danger'));
});


$('#mutate_modal,#combine_modal').on('show.bs.modal',(event) => ops.addToast('savefirst','Unsaved changes?','Any unsaved changes to the previous modal (description and settings) will be discarded.','bg-info'));


