//<%text>
$('#create').click(function (event) {
    $(event.target).attr('disabled', "disabled");
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
    if (myData.proteins[0].history !== undefined) data.append('history', JSON.stringify(myData.proteins[0].history));
    if (myData.proteins[0].chain_definitions !== undefined) data.append('definitions', JSON.stringify(myData.proteins[0].chain_definitions));
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

    //hard reset to prove all runs fine
    $('#viewport').detach();
    window.myData = undefined;
    NGL.stageIds = {};
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


///
window.engineered = [];
window.naturalise_alerter = (pdb) => {
    $('#naturalise_alert').removeClass('show').hide();
    $('#naturalise_details').html('');
    if (pdb.length === 4) $.getJSON({url: 'https://www.ebi.ac.uk/pdbe/api/pdb/entry/molecules/'+pdb, dataType: 'json', crossOrigin: true})
                            .then(response => { const components = response[pdb.toLowerCase()];
                                               window.engineered = [];
                                               for (let chain of components.filter(e=>e.molecule_type === 'polypeptide(L)')) {
                                                   console.log(chain);
                                                   let chEng = [];
                                                   //mse
                                                   let m = Object.entries(chain.pdb_sequence_indices_with_multiple_residues).filter(([r, v]) => v.three_letter_code === "MSE").map(([r, v]) => r);

                                                   if (m.length > 0) chEng = chEng.concat(m.map(v => 'X'+v+'M'));
                                                   console.log(chEng);
                                                   //engineered
                                                   if (chain.mutation_flag !== null) chEng = chEng.concat(chain.mutation_flag.split('/'));
                                                   if (chEng.length > 0) {
                                                       console.log(chEng);
                                                       engineered.push({chains: chain.in_chains, resi: chEng});
                                                       $('#naturalise_alert').addClass('show').show();
                                                       $('#naturalise_details').text($('#naturalise_details').text()+chEng.join(' ')+' in chain '+chain.in_chains.join('+'));
                                                   }
                                               }
                                           }
                                    )
};


window.get_data = async event => {
    $(event.target).attr('disabled','disabled');
    let [pdb, extension] = await getCoordinates();
    if (pdb === null) return 0;
    let data = {pdb: pdb, format: extension};
    if (myData.proteins[0].chain_definitions && myData.proteins[0].chain_definitions[0].uniprot) data['definitions'] = JSON.stringify(myData.proteins[0].chain_definitions);
    if (myData.proteins[0].history !== undefined) data['history'] = JSON.stringify(myData.proteins[0].history);
    return data;
};

window.loadMyMsg = (msg) => {
    window.pdbString = msg.pdb;
    $('#staging').show();
    window.myData = undefined;
    NGL.stageIds = {};
    $('#viewport').html('');
    $('#viewcode').text('<div role="NGL" data-proteins=\'[{"type": "data", "value": "pdbString", "isVariable": true}]\'></div>');
    NGL.specialOps.multiLoader('viewport',[{type: 'data',
                                                        value: "pdbString",
                                                        isVariable: true,
                                                        history: msg.history,
                                                        chain_definitions: msg.definitions}]);
    window.mode = 'renumbered';
    interactive_builder();
    $('[disabled="disabled"]').removeAttr('disabled');
};

////////////////////////// SPECIAL OPERATION WITH COORDINATES ////////////////////////////////////////////////
// deal with click of alert.
$('#renumber').click(async event => {
    let data = await get_data(event);
    $.post({
                url: "/renumber",
                data: data,
                dataType: 'json',
                success: msg => {window.loadMyMsg(msg);
                                $('#renumber_alert').removeClass('show');
                                $('#renumber').removeAttr('disabled');
                                if (msg.definitions !== undefined) {
                                    if (window.engineered.length > 0) {
                                        // convert [{chain: X1, offset: n1},{chain: X2, offset: n2}] to {X1: n1, X2: n2}
                                        let o = msg.definitions.reduce((o, d) => ({ ...o, [d.chain]: d.applied_offset}), {});
                                        window.engineered = window.engineered.map(c => ({chains: c.chains,
                                                                                         resi: c.resi.map(m => m[0]+
                                                                                                             (parseInt(m.slice(1,-1))+ o[c.chains[0]])+
                                                                                                             m.charAt(m.length-1))}));
                                        $('#naturalise_details').text(window.engineered.map(c => c.resi.join(' ')+' in chain '+c.chains.join('+')).join(', and '));
                                    }
                                }
                                },
                error: ops.addErrorToast
            });
});

$('#mutate').click(async (event)  => {
    let mutate_chain = $('#mutate_chain').val() || 'A';
    let mutations = $('#mutate_mutations').val().replace(/p\./gm, '').trim().split(/[\W,]+/);
    let data = await get_data(event);
    data.chain = mutate_chain;
    data.mutations = mutations.join(' ');
    $.post({
        url: "/premutate",
        dataType: 'json',
        data: data,
        success: msg => {
            window.loadMyMsg(msg);
            mutations.forEach(v => $('#mutate_collapse').append(`<a href="#viewport"
                                                                    onclick="$('#markup_selection').val('${parseInt(v.replace(/\D/g,''))}:${mutate_chain}'); $('#markup_view').val(''); $('#clash').click();">
                                                                    Set view builder to show clashes at ${v}?</a>`));
                        },
        error: ops.addErrorToast
    });
});


$('#naturalise').click(async event => {
    let data = await get_data(event);
    const reverseMutation = m => m.charAt(-1)+m.slice(1,-1)+m[0];
    data.chain = window.engineered.reduce((acc, {chains, resi}) => acc.concat(chains.reduce((a2, c) => a2.concat(resi.map(x => c)), [])), []);
    data.mutations = window.engineered.reduce((acc, {chains, resi}) => acc.concat(chains.reduce((a2, c) => a2.concat(resi.map(reverseMutation)), [])), []);
    $.post({
        url: "/premutate",
        dataType: 'json',
        data: data,
        success: msg => {window.loadMyMsg(msg);
                        $('#naturalise_alert').removeClass('show');
                        $('#naturalise').removeAttr('disabled');
                        },
        error: ops.addErrorToast
    });
});


$('#delete').click(async (event)  => {
    let data = await get_data(event);
    data.chains =  $('#delete_chains').val().replace(/p\./gm, '').trim().split(/[\W,]+/).join(' ');
    $.post({
        url: "/remove_chains",
        type: 'POST',
        dataType: 'json',
        data: data,
        success: window.loadMyMsg,
        error: ops.addErrorToast
    });

});

$('#dehydrate').click(async (event)  => {
    let data = await get_data(event);
    data.water = $('#water_toggle').prop('checked');
    data.ligand = $('#artefact_toggle').prop('checked');
    let [pdb, extension] = await getCoordinates();
    if (pdb === null) return 0;
    $.post({
        url: "/dehydrate",
        dataType: 'json',
        data: data,
        success: window.loadMyMsg,
        error: ops.addErrorToast
    });

});
//</%text>