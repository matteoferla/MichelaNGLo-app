//<%text>
// venus main.mako imports uniprot_modal.js 's UniprotFV.
// venus_class.js adds Venus class.
// .venus-no-mike css classes do not get ported to Michelanglo
// .venus-plain-mike css classes is ported as text to Michelanglo

//window.venus = new Venus();


/////////////////// DOM elements ////////////////////////////////////////////////////

// species and uniprot searches are done by name.js
// Also URL query is resolved by urlQueriest in name.js

$(window).scroll(() => {
    const card = $('#vieport_side');
    let currentY = $(window).scrollTop();
    let windowH = $(window).innerHeight();
    let cardH = card.height();
    let offsetY = card.offset().top - parseInt(card.css('top')) - 4;
    const rcard = $('#results_card');
    let maxY = rcard.offset().top + rcard.height();
    //console.log(`currentY ${currentY}, windowH ${windowH}, cardH ${cardH}, offsetY ${offsetY}, maxY ${maxY}`)
    let position = 0;
    // the top is getting cut off:
    if ((currentY > offsetY) && (currentY + windowH > offsetY + cardH)) {
        // new position, without cutting off the bottom.
        position = cardH > windowH ? currentY - offsetY - (cardH - windowH) : currentY - offsetY;
        if (cardH + currentY > maxY) {
            return 0; //no change. i.e. position = card.css('top')
        }
    }
    card.css('top', position);
    //console.log(`scrolltop: ${currentY} win height ${windowY} off: ${offsetY} card top: ${card.offset().top}`);
});


const vbtn = $('#venus_calc');
mutation.keyup(e => {
    if ($(e.target).val().search(/\d+/) !== -1 && uniprotValue !== 'ERROR') {
        vbtn.show();
        $('#error_mutation').hide();
        $(e.target).removeClass('is-invalid');
        if (event.keyCode === 13) vbtn.click();
    } else {
        vbtn.hide();
    }
});

vbtn.click(e => {
    if (taxidValue === 'ERROR') {
        $('#error_species').show();
        return 0;
    }
    else if (taxidValue === 'pending') {
        setTimeout(() => vbtn.click(), 500);
        return 0;
    }
    else if (uniprotValue === 'ERROR') {
        $('#error_gene').show();
        return 0;
    }
    else if (uniprotValue === 'pending') {
        setTimeout(() => vbtn.click(), 500);
        return 0;
    }
    else if (mutation.val().search(/\d+/) === -1) {
        $('#error_mutation').show();
        return 0;
    }
    else {
        window.venus = new Venus();
        //venus.reset.call(venus);
        $(e.target).attr('disabled', 'disabled');
        venus.analyseProtein();
    }
});

$('#new_analysis').click(e => venus.reset.call(venus));

// const alert = text => `<div class="alert alert-danger"><b>To do</b> ${text}</div>`;
//
// $('#results_mutalist').parent().append([//alert('rewire NGL viewport following screen'),
//                               //alert('pipe structure to PDB offset fix.'),
//                               //alert('structural route.'),
//                               //alert('autoload the sequence chosen by Analyser.get_best_model'),
//                               alert('URGENT!!! write documentation you idiot!'),
//                               alert('add collapsed sequence viewer'),
//                               alert('add rudimentary scoring metric to bump up entries'),
//                               alert('deal with truncations'),
//                               alert('b factor and disorder'),
//                               alert('improve useless structurally class'),
//                               alert('Mike exporter --make selective'),
//                               alert('Fix load of swissmodel. ?! Why did this fix itself??'),
//                               alert('cp the code for the domains from table ---what does this mean?'),
//                              ]);

// for now....
$('#report-btn').click(event => {
    if (venus.structural === undefined) {
        ops.addToast('patience', 'Please be patient', 'The analysis is not complete.', 'bg-warning');
        return 0;
    }
    $('#createMikeModal').modal('show');
    const mo = $('#modelOptions');
    mo.html('');
    myData.proteins.forEach((p, i) => mo.append(`
        <div class="form-group form-check mb-0 ml-3">
            <input type="checkbox" class="mikeProtChoice form-check-input" data-index="${i}" id="mikeProtChoice${i}">
            <label class="form-check-label" for="mikeProtChoice${i}">${p.name}</label>
        </div>
        `));
    // mark the currently selected one.
    const current = $(`#modelOptions [data-index="${myData.currentIndices['viewport']}"]`)
    current.addClass('is-valid');
    current.prop( "checked", true );
    current.prop( "disabled", true );
    current.attr('title', 'Currently loaded');
});

$('#createMike').click(event => {
    $(event.target).attr('disabled', 'disabled');
    const text = $(event.target).html();
    $(event.target).html('<i class="far fa-spinner fa-spin"></i> ' + text);
    venus.createPage().then(() => {
        $(event.target).attr('disabled', 'disabled');
        $(event.target).html(text);
    });
});

$('#showMutant').click(event => {
        venus.alwaysShowMutant = $(event.target).prop('checked');
        venus.showMutant();
    }
);

$('#showLigands').click(event => {
        venus.alwaysShowLigands = $(event.target).prop('checked');
        venus.showLigands();
    }
);

$('#changeByPage_fetch').click(event => {
    const uuid = changeByPage.value.trim().split('/').pop();
    if (uuid === '') {
        $('#changeByPage').addClass('is-invalid');
        return null
    } else {
        $('#changeByPage').removeClass('is-invalid');
    }
    window.venus.fetchMike(uuid);
});

/// this is very confusing. change_model is the button in change_modal
$('#change_model').click(async event => {
    // get params
    const params = await Promise.all(Array.from(upload_params.files).map(f => f.text()));
    //
    if (upload_pdb.files.length !== 0) {
        // file route
        const f = upload_pdb.files[0];
        const pdb = await f.text();
        const name = f.name;
        window.user_uploaded_data = {'pdb': pdb, 'name': name, 'params': params};
        $('#change_model_btn').removeClass('btn-info');
        $('#change_model_btn').addClass('btn-success');
        // used by step 3.
        // window.venus.analyseCustomFile(pdb, name, params);
    } else if (!changeByPage_selector.hasAttribute('disabled')) {
        const index = changeByPage_selector.selectedIndex;
        const name = changeByPage_selector.options[index].value;
        $.post({
            url: "save_pdb", data: {
                uuid: changeByPage.value,
                index: index
            }
        }).fail(ops.addErrorToast)
            .done(pdb => {
                    const format = pdb.includes('_atom_site.Cartn_x') ? 'cif' : 'pdb';
                    window.user_uploaded_data = {'pdb': pdb, 'name': name + '.' + format, 'params': params};
                    $('#change_model_btn').removeClass('btn-info');
                    $('#change_model_btn').addClass('btn-success');
                }
            );
    } else {
        ops.addToast('errorate', 'Invalid', 'Nothing provided.', 'bg-warning');
        $('#change_model_btn').removeClass('btn-info');
        $('#change_model_btn').removeClass('btn-success');
        $('#change_model_btn').addClass('btn-warning');
        throw 'Nothing given!';
    }
    $('#change_modal').modal('hide');
});


//</%text>