//keep track of prolinks
document.execCommand('insertBrOnReturn', false, true);

window.prolinks = {
    elements: [],
    _expandProlink: (description, code, number) => {
        //case 1 the span clicky thing is still there
        description = description.replace(
            new RegExp('<span class=\\W+prolink\\W+ onclick=\\W+prolinks\\.expandProlinkOnClick\\('+number+'\\)\\W+>'+
                '@[Pp]rolink[#_]?'+number+'<\\/span>\\[(.*?)\]','m'),
            code.fore+'$1'+code.aft);
        //case 2 the span thing is not there.
        description = description.replace(new RegExp('@[Pp]rolink[#_]?'+number+'\\[(.*?)\\]','m'), code.fore+'$1'+code.aft);
        return description;
    }
    ,
    expandProlinkOnClickOLD: (number) => {
        let description = $('#edit_description').html();
        let i = parseFloat(number)-1;
        let code = prolinks.elements[i];
        description = prolinks._expandProlink(description, code, number);
        prolinks.elements[i] = null;
        $('#edit_description').html(description);
    },
    expandProlinkOnClick: (number) => {
        let value = prompt("Edit the string if desired", prolinks.elements[number-1].fore);
        if (value !== null) {prolinks.elements[number-1].fore = value;}
    },
    expandProlinks: () => {
        //on save
        let description = $('#edit_description').html();
        if (prolinks.elements !== null) {
                prolinks.elements.forEach(function (code, i) {
                    if (code !== null) {
                        description = prolinks._expandProlink(description, code, i+1);
                    }

                });
            } else {prolinks.elements = [];}
        $('#edit_description').html(description);
    },
    minimiseProlinks: () => {
        // on load
        let description = $('#edit_description').html();
        /*
        "Editable text. press pen to edit. &lt;span class=\"prolink\" data-target=\"#viewport\" data-toggle=\"protein\" data-focus=\"undefined\"&gt;Try me as a span-element&lt;/span&gt;"
        */
        let promatch = description.match(/&lt;[^&]*?data-toggle=\\?\"protein\"\\? .*?&gt;[\s\S]*?&lt;\/.*?&gt;/gm);
        if (promatch !== null) {
            promatch.forEach(function (elem, i) {
                let elemAsHtml = $('<p>'+elem+'</p>').text();
                let n = prolinks.addProlink(elemAsHtml); // n = i+1
                description = description.replace(elem, prolinks.prolink2md(elemAsHtml,n));
            });
        } else {prolinks.elements = [];}
        $('#edit_description').html(description);
    },
    addProlink: (prolink) => prolinks.elements.push({
                    fore: prolink.replace(/(<.*?>).*?<\/.*?>/,'$1').replace(/</mgi,'&lt;').replace(/>/mgi,'&gt;'),
                    aft: prolink.replace(/<.*?>.*?(<\/.*?>)/,'$1').replace(/</mgi,'&lt;').replace(/>/mgi,'&gt;'),
                    original: prolink
                }),
    prolink2md: (prolink, number) => prolink.replace(
                /<.*?>(.*?)<\/.*?>/,
                '<span class="prolink" onclick="prolinks.expandProlinkOnClick('+number+')">@Prolink#'+number+'</span>[$1]'
            )
};

// buttons
$('#edit_submit').click(function () {
    try {
    ops.addToast('informare','Data submission','Your request is being processed','bg-info');
    if ($('#encryption').prop('checked')) {
        if (! $('#encryption_key').val) {return 0}
    }
    if ($('#collapse_prolinks').prop('checked')) {prolinks.expandProlinks()}
    // convert description to markdown.
    var description = $($('#edit_description')[0].outerHTML.replace(/<br.*?>/g,'\n')).text(); //changed from html
    //description = description.replace(/<br.*?>/g,'\n\n').replace(/\n+/gm,'\n\n').replace('&gt;','>').replace('&lt;','<').replace('&amp;','&'); //unescape.
    description = description.replace(/<div>([\s\S]*?)<\/div>/gm, '$1'); //firefox bug.
    description = description.replace(/<br.*?>/g,'\n\n').replace(/\n\n+/gm,'\n\n'); //runaway newline bug.
    // @fa[icon-name]
    description = description.replace(/@fa\[(.*?)\]/gi,'<i class="far fa-$1"></i>');

    //console.log('new');
    $('#edit_submit').attr('disabled','disabled').children('.far').removeClass('fa-save').addClass('fa-circle-notch').addClass('fa-spin');
    $.ajax({
        url: "/edit_user-page",
        type: 'POST',
        dataType: 'json',
        data: {
            'type': 'edit',
            'title': $('#edit_title').val(),
            'description': description,
            'columns_viewport': $('#columns_viewport').val(),
            'columns_text': 12 - parseInt($('#columns_viewport').val()),
            'location_viewport': $('[name="location_viewport"]:checked').val(),
            'image': $('#image').val(),
            'page': '${page}',
            'residues': $('#edit_residues').val(), //no longer valid.
            'freelyeditable': $('#freelyeditable').prop('checked'),
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
        .fail((xhr) => ops.addToast('userpageerror','Error '+xhr.status,'An error occured. '+xhr.responseJSON));

    }
    catch (e) {
        ops.addToast('errare','Clientside error',e.message,'bg-danger');
    }
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
            }

        }).done(() => window.location.href = '/')
          .fail(function (msg) {
            console.log('Fail!');
            if (msg.responseJSON) {
                ops.addToast('failure','Error '+msg.status,msg.responseJSON.status,'bg-warning')
            } else {ops.addToast('failure','Error '+msg.status,'Server side error','bg-warning')}
          });
    }
});


//collapse prolinks.
$('#collapse_prolinks').prop('checked', true);
prolinks.minimiseProlinks();

// allow uncollapsing
$('#collapse_prolinks').change((event) => {
    let state = $('#collapse_prolinks').prop('checked');
    if (state === true) {prolinks.minimiseProlinks();}
    else {prolinks.expandProlinks();}
    });


//reset values the stupid way
$('#edit_modal').on('hide.bs.modal', ()=> {window.location.reload();
                                           ops.addToast('resetting',
                                                        'Relaoding page',
                                                        'To ensure that the state of the edit menu is correctly reset, the page will reload.',
                                                        'bg-warning');});


///////////////////////////MODAL/////////////////////////////////////////////////////////////////////
//the prolink making modal is shared elsewhere. Here it gets customised.
$('#results').append('<div class="btn-group mb-3" role="group" aria-label="Use">\n' +
                    '  <button type="button" class="btn btn-success" id="usespan"><i class="far fa-paint-roller"></i> Use element in text</button>\n' +
                    '  <button type="button" class="btn btn-secondary" data-dismiss="modal" aria-label="Close" data-target="#markup_modal"><i class="far fa-sign-out"></i> Cancel</button>\n' +
                    '</div>');

$('#markup_modal_btn').on('click', e => {
    window.currentRange = document.getSelection().getRangeAt(0);
});

$('#usespan').click(function () {
    $('#markup_calculate').trigger('click');
    let elems=$($('#results').text());
    // select the appropriate one.
    let wanted = elems[0].outerHTML;
    let n = prolinks.addProlink(wanted);
    let addenda;
    if ($('#collapse_prolinks').prop('checked')) {addenda = prolinks.prolink2md(wanted, n);}
    else {addenda = wanted.replace(/</mgi,'&lt;').replace(/>/mgi,'&gt;');}
    if (window.currentRange.toString().length > 0) {
        addenda = addenda.replace(/Try me as .*?element/,window.currentRange.toString());
    } else {
        addenda = addenda.replace(/Try me as .*?element/,'a custom message');
    }

    window.currentRange.deleteContents();
    let span = '<span>'+addenda+'</span>';
    $('#edit_description')[0].contains(document.getSelection().getRangeAt(0).commonAncestorContainer) ? window.currentRange.insertNode( $(span)[0] ) : $('#edit_description').prepend(span);
    //let d = $('#edit_description');
    //d.html(d.html()+'\n'+addenda);
    //$('[data-toggle="tooltip"]').tooltip();
    $('#markup_modal').modal('hide');
});

$('#formatting button').click(e => {
    let id = e.target.id || e.target.parentElement.id; //scope madness
    if (id === 'formatting_help') {$('#formatting_help_modal').modal('show'); return 0;}
    let current = document.getSelection().getRangeAt(0);
    let content = current.toString();
    current.deleteContents();
    switch(id) {
      case 'formatting_bold':
        current.insertNode( $('<b>**'+content+'**</b>')[0] );
        break;
      case 'formatting_italic':
        current.insertNode( $('<i>_'+content+'_</i>')[0] );
        break;
      case 'formatting_link':
        current.insertNode( $('<span style="text-decoration: underline; color: blue;">['+content+'](https://URL)</span>')[0] );
        break;
      case 'formatting_h3':
        current.insertNode( $('<h3>### '+content+'    </h3>')[0] );
        break;
      case 'formatting_h4':
        current.insertNode( $('<h4>#### '+content+'      </h4>')[0] );
        break;
      case 'formatting_sub':
        current.insertNode( $('<sub>_{'+content+'}</sub>')[0] );
        break;
      case 'formatting_super':
        current.insertNode( $('<super>^{'+content+'}</super>')[0] );
        break;
      case 'formatting_list':
        current.insertNode( $('<p>* '+content+'</p>')[0]);
        break;
      case 'formatting_list-ol':
        current.insertNode( $('<p>1. '+content+'</p>')[0]);
        break;
       case 'formatting_code':
        current.insertNode( $('<code>`'+content+'`</code>')[0]);
        break;
      case 'formatting_quote':
        current.insertNode( $('<blockquote> > '+content+'</blockquote>')[0]);
        break;
      default:
        current.insertNode( $('<span>&'+id .replace('formatting_','')+';</span>')[0] );
    }
});

//////////////////////////SECURITY///////////////////////////////////////////////////
//deal with odd mutual exclusivity.
$('#public').change(function () {
    if ($(this).prop('checked')) {
        $('#encryption').prop('checked', false);
        $('#confidential').prop('checked', false);
        $('#freelyeditable').prop('checked', false);
    }
});

$('#encryption').change(function () {
    if ($(this).prop('checked')) {
        $('#public').prop('checked', false);
    }
});

$('#freelyeditable').change(function() {
    if ($(this).prop('checked')) {
        if ($('#public').prop('checked')) {
            $('#freelyeditable_error').show();
            setTimeout(()=> $('#freelyeditable_error').hide(1000), 3000);
            $('#freelyeditable').prop('checked',false);
        } else {
            $('#authorlist').hide(1000);
        }
    } else {
        $('#authorlist').show(1000);
    }
});
