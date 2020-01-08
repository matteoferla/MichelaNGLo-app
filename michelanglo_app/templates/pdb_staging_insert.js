//<%text>
$('#create').click(function (event) {
    $(event.target).attr('disabled', "disabled");
    //hard reset to prove all runs fine
    $('#viewport').detach();
    window.myData = undefined;
    NGL.stageIds = {};
    // get data.
    var data = new FormData();
    if (window.mode === undefined) {
        // we are in name.mako
        window.mode = 'code';
        data.append('pdb',window.pdbCode);
    } else if (window.mode === 'code') {data.append('pdb',$('#pdb').val());}
    else if (window.mode === 'renumbered') {data.append('pdb', window.pdbString);}
    else {data.append('pdb',$('#upload_pdb')[0].files[0]);}
    data.append('viewcode',$('#results code').text()); //needs two to make it list.
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
                ops.addToast('redirect','Conversion complete','Redirecting you to page '+msg.page,'bg-info');
                console.log(msg);
                window.location.href = "/data/"+msg.page;
        })
        .fail(ops.addErrorToast);
});

window.getCoordinates = async () => {
    let pdb = '';
    let extension = 'pdb';
    if ((window.mode === undefined) || (window.mode === 'code')) { pdb = window.pdbCode}
    else if (window.mode === 'renumbered') { pdb = window.pdbString}
    else if (window.mode === 'file') {
        let f = $('#upload_pdb')[0].files[0];
        pdb = await f.text();
        extension = f.name.split('\.').pop().toLowerCase()
    }
    else {
        console.log('What?! '+window.mode);
        return [null, null];} //impossible anyway.
    return [pdb, extension];
};

$('#mutate').click(async (event)  => {
    $(event.target).attr('disabled','disabled');
    let mutate_chain = $('#mutate_chain').val() || 'A';
    let mutations = $('#mutate_mutations').val().replace(/p\./gm, '').trim().split(/[\W,]+/);
    let [pdb, extension] = await getCoordinates();
    if (pdb === null) return 0;
    $.ajax({
        url: "/premutate",
        type: 'POST',
        dataType: 'json',
        data: {
            'pdb': pdb,
            'chain': mutate_chain,
            'mutations': mutations.join(' '),
            'format': extension
        },
        success: msg => {
            window.loadMyMsg(msg);
            mutations.forEach(v => $('#mutate_collapse').append(`<a href="#viewport"
                                                                    onclick="$('#markup_selection').val('${parseInt(v.replace(/\D/g,''))}:${mutate_chain}'); $('#markup_view').val(''); $('#clash').click();">
                                                                    Set view builder to show clashes at ${v}?</a>`));
                        },
        error: ops.addErrorToast
    });
});


$('#delete').click(async (event)  => {
    $(event.target).attr('disabled','disabled');
    let chains = $('#delete_chains').val().replace(/p\./gm, '').trim().split(/[\W,]+/);
    let [pdb, extension] = await getCoordinates();
    if (pdb === null) return 0;
    $.ajax({
        url: "/remove_chains",
        type: 'POST',
        dataType: 'json',
        data: {
            pdb: pdb,
            chains: chains.join(' '),
            format: extension
        },
        success: window.loadMyMsg,
        error: ops.addErrorToast
    });

});

$('#dehydrate').click(async (event)  => {
    $(event.target).attr('disabled','disabled');
    let chains = $('#delete_chains').val().replace(/p\./gm, '').trim().split(/[\W,]+/);
    let [pdb, extension] = await getCoordinates();
    if (pdb === null) return 0;
    $.ajax({
        url: "/dehydrate",
        type: 'POST',
        dataType: 'json',
        data: {
            pdb: pdb,
            format: extension,
            water: $('#water_toggle').prop('checked'),
            ligand: $('#artefact_toggle').prop('checked')
        },
        success: window.loadMyMsg,
        error: ops.addErrorToast
    });

});

$('#markup_model').detach();

// fix location.
$('#selection_modal .modal-dialog').removeClass('float-left').addClass('float-right').css('padding-right', '32px !important;');
$('#selection_modal .fa-arrow-right').removeClass('fa-arrow-right').addClass('fa-check');

$('#dehydrate_collapse').on('shown.bs.collapse',event => {
    const protein = NGL.getStage().compList[0];
    const water = $('#water_toggle').closest('.col-12');
    const artefact = $('#artefact_toggle').closest('.col-12');
    const hider = el => {el.hide(); el.find('.custom-control-input').prop('checked',false);};
    const shower = el => {el.show(); el.find('.custom-control-input').prop('checked',true);};
    (protein.structure.getView(new NGL.Selection('water')).atomCount !== 0) ? shower(water) : hider(water);
    (protein.structure.getView(new NGL.Selection('ligand')).atomCount !== 0) ? shower(artefact) : hider(artefact);
    if (protein.structure.getView(new NGL.Selection('ligand or water')).atomCount === 0) {
        $('#ligandlist').append('<b>No waters or ligands present</b>');
    } else {
        $('#ligandlist p').detach();
    }
});

// fun for the loading of a pdb.
window.renumber_alerter = (pdb) => {
    if (pdb.length === 4) $.ajax({
                                url: "/choose_pdb",
                                data: {
                                    'item': 'get_pdb',
                                    'pdb': pdb
                                },
                                method: 'POST',
                                success: msg => {
                                    if (msg.chains.length === 0) return 1;
                                    let chains = msg.chains;
                                    if (chains.map(v => v.offset).some(v => v !== 0)) {
                                        $('#renumber_alert').addClass('show').show();
                                        $('#renumber_details').html('chains '+chains.map(v => v.offset ? `${v.chain} (<a href="https://www.uniprot.org/uniprot/${v.uniprot}">Uniprot:${v.uniprot} <i class="far fa-external-link"></i></a>; offset of ${v.offset})` : `${v.chain} (${v.uniprot}; aligned)`).join('; '));
                                    }
                                    else {$('#renumber_alert').removeClass('show').hide();}
                                }
                            })
    else $('#renumber_alert').removeClass('show').hide();
};

// deal with click of alert.
$('#renumber').click(async event => {
    $(event.target).attr('disabled','disabled');
    let [pdb, extension] = await getCoordinates();
    if (pdb === null) return 0;
    $.post({
                url: "/renumber",
                data: {
                    pdb: pdb,
                    format: extension
                },
                success: window.loadMyMsg,
                error: ops.addErrorToast
            })

});

window.loadMyMsg = (msg) => {
    $('#renumber_alert').removeClass('show');
    $('#renumber').removeAttr('disabled');
    window.pdbString = msg.pdb;
    $('#staging').show();
    window.myData = undefined;
    NGL.stageIds = {};
    $('#viewport').html('');
    $('#viewcode').text('<div role="NGL" data-proteins=\'[{"type": "data", "value": "pdbString", "isVariable": true}]\'></div>');
    NGL.specialOps.multiLoader('viewport',[{type: 'data', value: "pdbString", isVariable: true}]);
    window.mode = 'renumbered';
    interactive_builder();
    $('[disabled="disabled"]').removeAttr('disabled');

};
//</%text>