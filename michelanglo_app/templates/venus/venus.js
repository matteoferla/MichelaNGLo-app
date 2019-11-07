//<%text>
/////////////////// CALCULATE
const vbtn = $('#venus_calc');
$('#mutation').keyup(e => {if ($(e.target).val().search(/\d+/) !== -1 && uniprotValue !== 'ERROR') {
                                        vbtn.show();
                                        $('#error_mutation').hide();
                                        $(e.target).removeClass('is-invalid');
                                        if (event.keyCode === 13) vbtn.click();
                                } else {vbtn.hide();}
                            });
vbtn.click(e => {
    venus.reset();
    if (taxidValue === 'ERROR') {$('#error_species').show(); return 0;}
    if (uniprotValue === 'ERROR') {$('#error_gene').show(); return 0;}
    if ($('#mutation').val().search(/\d+/) === -1) {$('#error_mutation').show(); return 0;}
        $(e.target).attr('disabled','disabled');
        $.post({url: "venus_analyse", data:  venus.getData('protein')})
                .done(msg => {$('#venus_calc').removeAttr('disabled'); window.venus.protein(msg)})
                .fail(xhr => {$('#venus_calc').removeAttr('disabled'); ops.addErrorToast(xhr)});
});

$('#new_analysis').click(venus.reset);

window.venus = {reset: () => {$('#results').hide();
                                $('#venus_calc').removeAttr('disabled');
                                $('result_title').html('<i class="far fa-dna fa-spin"></i> Loading');
                                $('#fv').detach();
                             },
                protein: msg => {
                                if (msg.error) {
                                    $('#error_'+msg.error).show();
                                    $('#'+msg.error).addClass('is-invalid');
                                    ops.addToast('error','Error - '+msg.error,'<i class="far fa-bug"></i> An issue arose analysing the results.<br/>'+msg.msg,'bg-warning');}
                                else {
                                    const protein = msg.protein;
                                    $('#results').show(500);
                                    $('html, body').animate({scrollTop: $('#results').offset().top}, 2000);
                                    $('#result_title').html(`${protein.gene_name} ${protein._mutation} <small>(${protein.recommended_name})</small>`);
                                    //this is the same as get_uniprot but utilising the protein data.
                                    setTimeout(() => $.post({url: "venus_analyse", data:  venus.getData('fv')})
                                                                    .done(msg => eval(msg))
                                                                    .fail(ops.addErrorToast), 500);
                                    }
                            },
                getData: step => ({uniprot: uniprotValue,
                          species: taxidValue,
                          step: step,
                          mutation: $('#mutation').val()}),
                card: (title, text) => `<li class="list-group-item">
                                            <div class="row">
                                                <div class="col-12 col-md-3">
                                                    <span class="font-weight-bold text-right align-middle">
                                                    ${title}
                                                     </span>
                                                </div>
                                                <div class="col-12 col-md-9 text-left border-left">
                                                    ${text}
                                                </div>
                                            </div>
                                        </li>`
};

//</%text>