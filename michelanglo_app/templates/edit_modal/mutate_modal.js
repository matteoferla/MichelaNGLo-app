$('#mutate_create').click((event) => {
    let chain = $('#mutate_chain').val() || 'A';
    let mutations = $('#mutate_mutations').val().replace(/p\./gm,'').split(/[\W,]+/);
    console.log(mutations);
    $.ajax({
            url: "/mutate",
            type: 'POST',
            dataType: 'json',
            data: {
                'page': "${page}",
                %if key:
                'key': "${key}",
                %endif
                'model': 0,
                'chain': chain,
                'mutations': mutations.join(' ')
            }
        }   )
        .done((msg) => location.reload())
        .fail((xhr) => ops.addToast('userpageerror','Error '+xhr.status,'An error occured. '+(!! xhr.responseJSON ? xhr.responseJSON.status : '(server side)'),'bg-danger'));
});