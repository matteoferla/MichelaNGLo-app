$('#species').on('keyup', event => {
            let species = $('#species');
            window.taxidValue ='ERROR';
            $('#error_species,#taxid,#uniprot').hide();
            species.removeClass('is-valid').removeClass('is-invalid').popover('dispose');
            if (window.species_xhr !== undefined) {
                window.species_xhr.abort();}
            window.reset_gene();
            if (species.val() === '') return 0;
            window.species_xhr = $.ajax({url: "/choose_pdb",
                    data: {'item': 'match species',
                           'name': species.val()
                          },
                     method: 'POST',
                     success: msg => { if (msg.taxid !== undefined) {$('#taxid').show().text('Taxid: '+msg.taxid);
                                                                        window.taxidValue = msg.taxid;
                                                                        species.addClass('is-valid');}
                                       else if (msg.options === 'many') {$('#error_species').show().text('Type more')}
                                       else {
                                           const buttonise = el => `<a href='#' class="list-group-item list-group-item-action" name="species">${'${el}'}</a>`;
                                           let content;
                                           if (msg.options.length > 10) {content = '<div class="list-group">' + msg.options.splice(0,10).map(buttonise).join('')+'</div>'.replace(/\s+/mg,' ');}
                                           else {content = '<div class="list-group">' + msg.options.map(buttonise).join('')+'</div>'.replace(/\s+/mg,' ');}

                                           species.popover({content: content,
                                                            placement: 'bottom',
                                                            html: true})
                                                   .popover('show');
                                            $('.popover .list-group-item').click(event => {species.val($(event.target).text()); species.popover('dispose'); species.trigger('keyup');})
                                       }
                                     },
                     error: (xhr) => {if (xhr.statusText =='abort' || xhr.status === 0 || xhr.readyState === 0) {return;} else {ops.addErrorToast(xhr)}}
            });
    });
// starting value. Cannot guarantee the default/stored value is correct.
let species = $('#species');
if (species.val().toLowerCase() === 'human') {species.val('Human'); window.taxidValue=9606; species.addClass('is-valid'); $('#taxid').show().text('Taxid: 9606');}
else { species.trigger('input');}

// gene.
window.uniprotValue = 'ERROR';
$('#gene').on('keyup', event => {
    if (window.gene_xhr !== undefined) {
        window.gene_xhr.abort();}
    if ((window.taxidValue === 'ERROR') || (window.taxidValue === undefined)) {
        //ops.addToast('taxid','Issue','Please check species is correct.','bg-info');
        $('#species').trigger('keyup');
        return 0;
    }
    let gene = $('#gene');

    if (gene.val() === '') return 0;
    gene.popover('dispose');
    let error_gene = $('#error_gene');
    window.reset_gene();
    window.gene_xhr = $.ajax({url: "/choose_pdb",
            data: {'item': 'match gene',
                   'gene': gene.val(),
                   'species': window.taxidValue
                  },
             method: 'POST',
             success: msg => {
                              if (msg.invalid) {error_gene.show(); gene.addClass('is-invalid')}
                              else if (msg.options) {
                                   const buttonise = el => `<a href='#' class="list-group-item list-group-item-action" name="genes">${'${el}'}</a>`;
                                   let content;
                                   if (msg.options.length > 10) {content = '<div class="list-group">' + msg.options.splice(0,10).map(buttonise).join('')+'</div>'.replace(/\s+/mg,' ');}
                                   else {content = '<div class="list-group">' + msg.options.map(buttonise).join('')+'</div>'.replace(/\s+/mg,' ');}

                                   gene.popover({content: content,
                                                    placement: 'bottom',
                                                    html: true})
                                           .popover('show');
                                    $('.popover .list-group-item').click(event => {gene.val($(event.target).text()); gene.popover('dispose'); gene.trigger('keyup');})
                               }
                              else {
                                  if (msg.corrected_gene) {gene.val(msg.corrected_gene)}
                                  gene.addClass('is-valid');
                                  window.uniprotValue = msg.uniprot;
                                  window.pdbs = msg.pdbs;
                                  $('#uniprot').show().html('Uniprot: <a href="https://www.uniprot.org/uniprot/'+msg.uniprot+'" target="_blank">'+msg.uniprot+' <i class="far fa-external-link-alt"></i></a>');
                                  $('#pdb_fetch').show();
                                  if (event.keyCode === 13) {$('#pdb_fetch').click()}
                              }
                            },
             error: ops.addErrorToast
            });

});

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

if ($('#gene').val()) $('#gene').trigger('keyup');

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
        window.pdbs_xhr.abort();}
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
                $('[name="pdb"]').click(event => load_pdb( $( event.target).data('code') ) );
            }
            else {ops.addToast('issue', 'Issue', JSON.stringify(msg),'bg-danger');}
        },
        error: (xhr) => {if (xhr.statusText =='abort' || xhr.status === 0 || xhr.readyState === 0) {return;} else {ops.addErrorToast(xhr)}}
    });
};

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

window.load_pdb = pdb => {
    $('#staging').show();
    window.pdb = pdb;
    window.myData = undefined;
    NGL.stageIds = {};
    $('#viewport').html('');
    $('#viewcode').text('<div role="NGL" data-load="'+pdb+'" ></div>');
    let x = (pdb.length === 4) ? NGL.specialOps.multiLoader('viewport',[{'type': 'rcsb','value': pdb}]) : NGL.specialOps.multiLoader('viewport',[{'type': 'file','value': pdb}]);
    NGL.specialOps.showTitle('viewport', 'Loaded: '+ pdb);
    ///////////////////////////////////////////
    /*
    $.ajax({
        url: "/choose_pdb",
        data: {
            'item': 'get_pdb',
            'entry': pdb
        },
        method: 'POST',
        success: msg => {
            console.log(msg);
            console.log(myData);
            console.log(x);
        }
    }); */
    //////////////////////////////////
    interactive_builder();
    if ($('#staging').length) $('html, body').animate({scrollTop: $('#staging').offset().top
                                                }, 2000);
};

$('#pdb_fetch').click(event => {
    $(event.target).hide();
    $('#ext_links').html('<p>For more information see the <a href="https://www.rcsb.org/pdb/protein/'+window.uniprotValue+'" target="_blank">PDB entry <i class="far fa-external-link-alt"></i></a>. If no structures are available see <a href="https://swissmodel.expasy.org/repository/uniprot/'+window.uniprotValue+'" target="_blank">Swiss-Model entry <i class="far fa-external-link-alt"></i></a>.</p>');

    $('#fv_label').show();
    $('#matches_label').show();
    get_uniprot();
    let matches = $('#matches');
      if (window.pdbs.length > 0) {
          matches.html(window.pdbs.map(v => v+' <i class="far fa-spinner fa-spin"></i>').join(' <br/> '));
          //get_pdbs(window.pdbs);
      } else {
          matches.html('No crystal structures to show.');
      }
});