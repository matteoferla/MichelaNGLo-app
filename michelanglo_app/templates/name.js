// Feature viewer is in features.js
// del waters etc. is the pdb_staging_insert.js
//<%text>


let species = $('#species'); //es6 is node, not jquery element.
let gene = $('#gene');
let mutation = $('#mutation'); // applies only to VENUS, not PDB route.
window.uniprotValue = 9606;
window.taxidValue = undefined;

//species
species.on('keyup', event => {
    let species = $('#species');
    window.taxidValue = 'pending';
    $('#error_species,#taxid,#uniprot').hide();
    species.removeClass('is-valid').removeClass('is-invalid').popover('dispose');
    if (window.species_xhr !== undefined) {
        window.species_xhr.abort();
    }
    window.reset_gene();
    if (species.val() === '') return 0;
    window.species_xhr = $.ajax({
        url: "/choose_pdb",
        data: {
            'item': 'match species',
            'name': species.val()
        },
        method: 'POST',
        success: msg => {
            if (msg.taxid !== undefined) {
                $('#taxid').show().text('Taxid: ' + msg.taxid);
                window.taxidValue = msg.taxid;
                species.addClass('is-valid');
            } else if (msg.options === 'many') {
                $('#error_species').show().text('Type more')
            } else {
                const buttonise = el => `<a href='#' class="list-group-item list-group-item-action" name="species">${el}</a>`;
                let content;
                if (msg.options.length > 10) {
                    content = '<div class="list-group">' + msg.options.splice(0, 10).map(buttonise).join('') + '</div>'.replace(/\s+/mg, ' ');
                } else {
                    content = '<div class="list-group">' + msg.options.map(buttonise).join('') + '</div>'.replace(/\s+/mg, ' ');
                }

                species.popover({
                    content: content,
                    placement: 'bottom',
                    html: true
                })
                    .popover('show');
                $('.popover .list-group-item').click(event => {
                    species.val($(event.target).text());
                    species.popover('dispose');
                    species.trigger('keyup');
                })
            }
        },
        error: (xhr) => {
            if (xhr.statusText === 'abort' || xhr.status === 0 || xhr.readyState === 0) {
                // user cancelled or clicked something before it finished.
                return;
            } else {
                //bona fide error.
                window.taxidValue = 'error';
                ops.addErrorToast(xhr);
            }
        }
    });
});

// gene.
gene.on('keyup', event => {
    if (window.gene_xhr !== undefined) {
        window.gene_xhr.abort();
    }
    if ((window.taxidValue === 'ERROR') || (window.taxidValue === undefined)) {
        //ops.addToast('taxid','Issue','Please check species is correct.','bg-info');
        species.trigger('keyup');
        return 0;
    } else if (window.taxidValue === 'pending') {
        setTimeout(() => gene.trigger('keyup'), 500);
    }
    else if (gene.val() === '') {return 0}
    gene.popover('dispose');
    let error_gene = $('#error_gene');
    window.reset_gene();
    window.gene_xhr = $.ajax({
        url: "/choose_pdb",
        data: {
            'item': 'match gene',
            'gene': gene.val(),
            'species': window.taxidValue
        },
        method: 'POST',
        success: msg => {
            if (msg.invalid) {
                error_gene.show();
                gene.addClass('is-invalid')
            } else if (msg.species_correction) {
                ops.addToast('wrongSpecies', 'Species mismatch', 'The Uniprot ID you entered belongs to a  ' + msg.species_correction[0] + ' (' + msg.species_correction[1] + '; taxid' + msg.species_correction[2] + '). It has been changed accordingly', 'bg-info');
                species.val(msg.species_correction[0]);
                window.taxidValue = msg.species_correction.pop();
                species.trigger('keyup');
                setTimeout(() => gene.trigger('keyup'), 500);
            } else if (msg.options) {
                const buttonise = el => `<a href='#' class="list-group-item list-group-item-action" name="genes">${el}</a>`;
                let content;
                if (msg.options.length > 10) {
                    content = '<div class="list-group">' + msg.options.splice(0, 10).map(buttonise).join('') + '</div>'.replace(/\s+/mg, ' ');
                } else {
                    content = '<div class="list-group">' + msg.options.map(buttonise).join('') + '</div>'.replace(/\s+/mg, ' ');
                }

                gene.popover({
                    content: content,
                    placement: 'bottom',
                    html: true
                })
                    .popover('show');
                $('.popover .list-group-item').click(event => {
                    gene.val($(event.target).text());
                    gene.popover('dispose');
                    gene.trigger('keyup');
                })
            } else {
                if (msg.corrected_gene) {
                    gene.val(msg.corrected_gene)
                }
                gene.addClass('is-valid');
                window.uniprotValue = msg.uniprot;
                window.pdbs = msg.pdbs;
                $('#uniprot').show().html('Uniprot: <a href="https://www.uniprot.org/uniprot/' + msg.uniprot + '" target="_blank">' + msg.uniprot + ' <i class="far fa-external-link-alt"></i></a>');
                $('#pdb_fetch').show();
                if (event.keyCode === 13) {
                    $('#pdb_fetch').click()
                }
            }
        },
        error: (xhr) => {
            if (xhr.statusText === 'abort' || xhr.status === 0 || xhr.readyState === 0) {
                return;
            } else {
                ops.addErrorToast(xhr)
            }
        }
    });
});

// Common
window.reset_gene = () => {
    $('#gene').removeClass('is-valid').removeClass('is-invalid');
    $('#error_gene').hide();
    $('#matches').html(' ');
    $('#fv').html(' ');
    $('#fv_label').hide();
    $('#matches_label').hide();
    $('#ext_links').html(' ');
    $('#pdb_fetch').hide();
};

// PDB route only.
window.get_pdbs = pdbs => {
    //this gets the PBDe data.
    // it is getting removed.
    if (window.taxidValue === 'ERROR') {
        //ops.addToast('taxid','Issue','Please check species is correct.','bg-info');
        $('#species').addClass('is-invalid');
        $('#error_species').show().text('Unknown species');
        return 0;
    }
    if (window.pdbs_xhr !== undefined) {
        window.pdbs_xhr.abort();
    }
    window.pdbs_xhr = $.ajax({
        url: "/choose_pdb",
        data: {
            'item': 'get_pdbs',
            'entries': pdbs,
            'uniprot': window.uniprotValue,
            'species': window.taxidValue
        },
        method: 'POST',
        success: msg => {
            if (msg.descriptions !== undefined) {
                $('#matches').html(msg.descriptions);
                $('[name="pdb"]').click(event => load_pdb($(event.target).data('code')));
            } else {
                ops.addToast('issue', 'Issue', JSON.stringify(msg), 'bg-danger');
            }
        },
        error: (xhr) => {
            if (xhr.statusText === 'abort' || xhr.status === 0 || xhr.readyState === 0) {
                return;
            } else {
                ops.addErrorToast(xhr)
            }
        }
    });
};

// Common
window.get_uniprot = () => $.ajax({
    url: "/choose_pdb",
    data: {
        'item': 'get_uniprot',
        'uniprot': window.uniprotValue,
        'species': window.taxidValue
    },
    method: 'POST',
    success: msg => eval(msg),
    error: ops.addErrorToast
});

// PDB route only.
window.load_pdb = pdb => {
    $('#staging').show();
    window.pdbCode = pdb;
    window.myData = undefined;
    window.engineered = undefined;
    window.mode = 'code';
    NGL.stageIds = {};
    $('#viewport').html('');
    $('#viewcode').text('<div role="NGL" data-load="' + pdb + '" ></div>');
    if (pdb.length === 4) {
        NGL.specialOps.multiLoader('viewport', [{'type': 'rcsb', 'value': pdb}]);
        $('#model_alert').removeClass('show').hide();
    } else if (pdb.match('https://swissmodel.expasy.org/repository/') !== null) {
        $('#model_alert').addClass('show').show();
        NGL.specialOps.multiLoader('viewport', [{
            type: 'url',
            'value': pdb,
            chain_definitions: [{
                chain: 'A',
                uniprot: pdb.match(/uniprot\/(.*?)\.pdb/)[1],
                x: pdb.match(/range\=/) ? pdb.match(/range\=(\d+)/)[1] : pdb.match(/from\=(\d+)/)[1],
                y: pdb.match(/range\=/) ? pdb.match(/range\=\d+\-(\d+)/)[1] : pdb.match(/to\=(\d+)/)[1],
                name: $('#gene').val(),
                offset: 0
            }
            ]
        }]);
    } else {
        NGL.specialOps.multiLoader('viewport', [{type: 'url', 'value': pdb}]);
    }
    NGL.specialOps.showTitle('viewport', 'Loaded: ' + pdb);
    renumber_alerter(pdb);
    naturalise_alerter(pdb);
    interactive_builder();
    if ($('#staging').length) $('html, body').animate({scrollTop: $('#staging').offset().top}, 2000);
};

// PDB route only.
$('#pdb_fetch').click(event => {
    $(event.target).hide();
    $('#ext_links').html('<p>For more information see the <a href="https://www.rcsb.org/uniprot/' + window.uniprotValue + '" target="_blank">PDB entry <i class="far fa-external-link-alt"></i></a>. If no structures are available see <a href="https://swissmodel.expasy.org/repository/uniprot/' + window.uniprotValue + '" target="_blank">Swiss-Model entry <i class="far fa-external-link-alt"></i></a>.</p>');

    $('#fv_label').show();
    $('#matches_label').show();
    get_uniprot();
    let matches = $('#matches');
    if (window.pdbs.length > 0) {
        matches.html(window.pdbs.map(v => v + ' <i class="far fa-spinner fa-spin"></i>').join(' <br/> '));
        //get_pdbs(window.pdbs);
    } else {
        matches.html('No crystal structures to show.');
    }
});


// renumber button moved to pdb staging insert as it's shared.

// START UP TRIGGER

//URL QUERY
//uniprot=Q14185&species=9606&step=protein&mutation=A100E
const urlQueriest = () => {
    const query = new URLSearchParams(window.location.search);
    let querySpecies = query.get('species');
    let queryGene = query.get('uniprot') || query.get('gene');
    let queryMutation = query.get('mutation');
    let venusDebug = query.get('debug');
    if (!!venusDebug) {
        window.venusDebug = true;
    }
    if (!!querySpecies) {
        $('#species').val(querySpecies);
    }
    if (!!queryGene) {
        $('#gene').val(queryGene);
    }
    if (!!queryMutation) {
        $('#mutation').val(queryMutation);
    }
    ['allow_pdb','allow_swiss','allow_alphafold'].forEach(v => {
        let status = query.get(v);
        if (['off', 'false', '0', false, 0].includes(status)) {
            $('#'+v).prop('checked', false);
        }
    });
};

urlQueriest();

// starting value for species. Cannot guarantee the default/stored value is correct.
if (species.val().toLowerCase() === 'human') {
    species.val('Human');
    window.taxidValue = 9606;
    species.addClass('is-valid');
    $('#taxid').show().text('Taxid: 9606');
} else {
    species.keyup();
}

// startup trigger for gene.
if (gene.val()) {
    //if (window.gene_xhr !== undefined) {
    //    window.gene_xhr = {abort: ()=> null}; //mocked abort
    //}
    if (window.species_xhr === undefined || species_xhr.status === 200) {
        gene.keyup();
    } else {
        window.species_xhr.then(msg => gene.keyup());
    }
}
// startup trigger for mutation
if (mutation.val()) {
    if (window.gene_xhr === undefined) {
        setTimeout(() => $('#venus_calc').click(), 500);
    } else if (gene_xhr.status === 200) {
        $('#venus_calc').click();
    } else {
        window.gene_xhr.then(msg => $('#venus_calc').click());
    }
}

// random needs not to check taxid and uniprot as they are already provided
const randomURLQuery = () => {
    const query = new URLSearchParams(window.location.search);
    if (query.get('random') !== null) {
        $.getJSON('/venus_random').then(suggested =>
            { $('#species').val(suggested.species);
              window.taxidValue = parseInt(suggested.taxid);
              $('#gene').val(suggested.name);
              window.uniprotValue = suggested.uniprot;
              $('#mutation').val(suggested.mutation);
              $('#venus_calc').click();
            }
        );
    }
};
randomURLQuery();


//</%text>