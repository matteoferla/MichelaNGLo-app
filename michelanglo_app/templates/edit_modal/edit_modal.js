//keep track of prolinks

window.prolinks = {
    elements: [],
    expandProlinkOnClick: function (number) { //click on one
        var description = $('#edit_description').html();
        var i = parseFloat(number)-1;
        var code = prolinks.elements[i];
        description = description.replace(new RegExp('[^\\"]\\[([^\\]]*?)\\]\\(.*?(\\w+)\\:prolink_'+number+'.*?\\)','m'), '&lt;$2 '+code+'&gt;$1 &lt;/$2&gt;');
        prolinks.elements[i] = null;
        $('#edit_description').html(description);
    },
    minimiseProlinks: function () {
        var description = $('#edit_description').html();
        promatch = description.match(/&lt;.*?data-toggle=\W+protein\W+ .*?&gt;[\s\S]*?&lt;\/.*?&gt;/gm); //data-toggle=\"protein\"
        console.log(promatch);
        if (promatch !== null) {
            promatch.forEach(function (elem, i) {
                var elemAsHtml = $('<p>'+elem+'</p>').text();
                var n = prolinks.addProlink(elemAsHtml); // n = i+1
                description = description.replace(elem, prolinks.prolink2md(elemAsHtml,n));
            });
        } else {prolinks.elements = [];}
        $('#edit_description').html(description);
    },
    expandProlinks: function(description) { //expand for submission.
        if (prolinks.elements !== null) {
                prolinks.elements.forEach(function (code, i) {
                    if (code !== null) {
                        description = description.replace(new RegExp('[^\\"]\\[([^\\]]*?)\\]\\(.*?(\\w+)\\:prolink_'+(i+1)+'.*?\\)','m'), '<$2 '+code+'>$1</$2>');
                    }

                });
            } else {prolinks.elements = [];}
        return description;
    },
    addProlink: function(prolink) {
        var code  = prolink.replace(/<.*? (.*?)>.*?<\/.*?>/,'$1');
        return prolinks.elements.push(code); //the index +1
    },
    prolink2md: function(prolink, number) {
        return prolink.replace(/<(.*?)>(.*?)<\/(.*?)>/,'[$2](<span class="prolink" onclick="prolinks.expandProlinkOnClick('+number+')">$3:prolink_'+number+'</span>)');
    }
};

// buttons
$('#edit_submit').click(function () {
    if ($('#encryption').prop('checked')) {
        if (! $('#encryption_key').val) {return 0}
    }
    var description = $('#edit_description').text(); //changed from html
    //description = description.replace(/<br.*?>/g,'\n\n').replace(/\n+/gm,'\n\n').replace('&gt;','>').replace('&lt;','<').replace('&amp;','&'); //unescape.
    description = description.replace(/<div>([\s\S]*?)<\/div>/gm, '$1'); //firefox bug.
    description = description.replace(/<br.*?>/g,'\n\n').replace(/\n+/gm,'\n\n'); //runaway newline bug.
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

//collapse prolinks.
//setTimeout(() => prolinks.minimiseProlinks, 500);

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
