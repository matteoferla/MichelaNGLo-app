//keep track of prolinks

window.prolinks = {
    elements: [],
    expandProlinkOnClick: function (number) { //click on one
    },
    makeProlinkDummy: function (index, element) {
        return '';
    },
    minimiseProlinks: function (description) {
        return description;
    },
    expandProlinks: function(description) { //expand for submission.
        if (prolinks.elements !== null) {
                prolinks.elements.forEach(function (code, i) {
                    description = description.replace(new RegExp('\\[([\\s\\S]*?)\\]\\((\\w+)\\:prolink_'+(i+1)+'\\)','m'), '<$2 '+code+'>$1</$2>')
                });
            } else {prolinks.elements = [];}
        return description;
    },
    addProlink: function(prolink) {
        var code  = prolink.replace(/<.*? (.*?)>.*?<\/.*?>/,'$1');
        return prolinks.elements.push(code); //the index +1
    },
    prolink2md: function(prolink, number) {
        return prolink.replace(/<(.*?)>(.*?)<\/(.*?)>/,'[$2]($3:prolink_'+number+')');
    }
};

// buttons
$('#edit_submit').click(function () {
    if ($('#encryption').prop('checked')) {
        if (! $('#encryption_key').val) {return 0}
    }
    var description = $('#edit_description').html();
    description = description.replace(/<br.*?>/g,'\n\n').replace('&gt;','<').replace('&lt;','>').replace('&amp;','&'); //unescape.
    description = description.replace(/<div>([\s\S]*?)<\/div>/gm, '$1'); //firefox bug.
    description = prolinks.expandProlinks(description);
    console.log('new');
    $.ajax({
        url: "/edit_user-page",
        type: 'POST',
        dataType: 'json',
        data: {
            'type': 'edit',
            'title': $('#edit_title').val(),
            'description': description,
            'page': '${page}',
            'residues': $('#edit_residues').val(), //no longer valid.
            'proteinJSON': JSON.stringify($('[role="NGL"]').data('proteins')),
            'backgroundcolor': $('[role="NGL"]').data('backgroundcolor'),
            'new_editors': JSON.stringify($('.user-editable-state:checked').map((idx, item) => $(item).data('user')).toArray()),
            'encryption': $('#encryption').prop('checked'),
            'encryption_key': $('#encryption_key').val(),
            'public': $('#public').prop('checked'),
            'confidential': $('#confidential').prop('checked')
        }
        })
        .done((msg) => location.reload())
        .fail((xhr) => ops.addToast('userpageerror','Error '+xhr.statusCode,'An error occured.'));
});

$('#edit_delete').click(function () {
    if (confirm('Are you sure you want to remove this page?')) {
        $.ajax({
            url: "/delete_user-page",
            type: 'POST',
            dataType: 'json',
            data: {
                'type': 'delete',
                'page': $(location).attr("href").split('/').pop().split('.')[0]
            },
            success: function (result) {
                window.location.href = '/';
            }
        });
    }
});


///////////////////////////MODAL/////////////////////////////////////////////////////////////////////
//the prolink making modal is shared elsewhere. Here it gets customised.
$('#results').append('<div class="btn-group mb-3" role="group" aria-label="Use">\n' +
                    '  <button type="button" class="btn btn-primary"  id="useanchor">Use anchor element</button>\n' +
                    '  <button type="button" class="btn btn-success" id="usespan">Use span element</button>\n' +
                    '  <button type="button" class="btn btn-secondary" data-dismiss="modal" aria-label="Close" data-target="#markup_modal">Cancel</button>\n' +
                    '</div>');

$('#useanchor,#usespan').click(function () {
    var elems=$($('#results').text());
    var wanted = ($(this).attr('id') === 'useanchor') ? elems[0].outerHTML : elems[2].outerHTML;
    var i = prolinks.addProlink(wanted);
    addenda = prolinks.prolink2md(wanted, i);
    var d = $('#edit_description');
    d.html(d.html()+'\n'+addenda);
    $('#markup_modal').modal('hide');
    $('[data-toggle="tooltip"]').tooltip();
});

//////////////////////////SECURITY///////////////////////////////////////////////////
//deal with odd mutual exclusivity.
$('#public').change(function () {
    if ($(this).prop('checked')) {
        $('#encryption').prop('checked', false);
        $('#confidential').prop('checked', false);
    }
});

$('#encryption').change(function () {
    if ($(this).prop('checked')) {
        $('#public').prop('checked', false);
    }
});
