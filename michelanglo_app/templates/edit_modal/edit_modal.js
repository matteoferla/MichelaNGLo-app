//keep track of prolinks
window.prolinks = {
    elements: [],
    expandProlinkOnClick: function(number) { //click on one
            var description = $('#edit_description').html();
            var escaped = $('<div/>').text(prolinks.elements[number]).html();
            description = description.replace(new RegExp('<prolink#'+number+'\.*?>'), prolinks[number]).replace(new RegExp('&lt;.*?prolink#'+number+'\.*?&gt;'), escaped);
            $('#edit_description').html(description);
        },
    makeProlinkDummy: function (index, element) {
            return '&lt;<span class="bg-light" data-toggle="tooltip" title="'+
                encodeURI(element.replace('"','&quot;'))+
                '" onclick="prolinks.expandProlinkOnClick('+index+')">prolink#'+index+
                ' &hellip; </span>&gt;';
        },
    minimiseProlinks: function (description) {
            promatch = description.match(/&lt;.*?data-toggle=[\'\"']protein[\'\"'] .*?&gt;/g);
            if (promatch !== null) {
                promatch.forEach(function (e, i) {
                    description = description.replace(e, prolinks.makeProlinkDummy(i, e));
                });
                prolinks.elements = promatch.map(e => $('<p>'+e+'</p>').text());
            } else {prolinks.elements = [];}
            return description;
        },
    expandProlinks: function(description) { //expand for submission.
            if (prolinks.elements !== null) {
                prolinks.elements.forEach(function (e, i) {
                    description = description.replace(new RegExp('<prolink#'+i+'\.*?>'), e).replace(new RegExp('&lt;prolink#'+i+'\.*?&gt;'), e);
                });
            } else {prolinks.elements = [];}
            return description;
        }
};
// update the dom... it will load a fraction of a section after this.
setTimeout(() => $('#edit_description').html(prolinks.minimiseProlinks($('#edit_description').html())), 500);

// buttons
$('#edit_submit').click(function () {
    if ($('#encryption').prop('checked')) {
        if (! $('#encryption_key').val) {return 0}
    }
    $.ajax({
        url: "/edit_user-page",
        type: 'POST',
        dataType: 'json',
        data: {
            'type': 'edit',
            'title': $('#edit_title').val(),
            'description': prolinks.expandProlinks($('#edit_description').text()),
            'page': '${page}',
            'residues': $('#edit_residues').val(), //no longer valid.
            'proteinJSON': JSON.stringify($('[role="NGL"]').data('proteins')),
            'backgroundcolor': $('[role="NGL"]').data('backgroundcolor'),
            'new_editors': JSON.stringify($('.user-editable-state:checked').map((idx, item) => $(item).data('user')).toArray()),
            'encryption': $('#encryption').prop('checked'),
            'encryption_key': $('#encryption_key').val(),
            'public': $('#public').prop('checked'),
            'confidential': $('#confidential').prop('checked')
        },
        success: function (result) {
            location.reload();
        }

    });
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



$('#results').append('<div class="btn-group mb-3" role="group" aria-label="Use">\n' +
                    '  <button type="button" class="btn btn-primary"  id="useanchor">Use anchor element</button>\n' +
                    '  <button type="button" class="btn btn-success" id="usespan">Use span element</button>\n' +
                    '  <button type="button" class="btn btn-secondary" data-dismiss="modal" aria-label="Close" data-target="#markup_modal">Cancel</button>\n' +
                    '</div>');

$('#useanchor,#usespan').click(function () {
    var elems=$($('#results').text());
    var wanted = ($(this).attr('id') === 'useanchor') ? elems[0] : elems[2];
    var i = prolinks.elements.push(wanted.outerHTML.replace(/Try me.*?>/,'')) -1; //length is +1...
    var added = prolinks.makeProlinkDummy(i, wanted.outerHTML)+'TEXT TO SHOW &lt;/'+wanted.nodeName.toLowerCase()+'&gt;';
    console.log(added);
    $('#edit_description').html($('#edit_description').html()+'\n'+added);
    $('#markup_modal').modal('hide');
    $('[data-toggle="tooltip"]').tooltip();
});

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
