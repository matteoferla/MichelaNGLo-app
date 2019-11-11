//<%text>


class Venus {
    constructor() {
        this.prolink = ' class="prolink" data-target="#viewport" data-toggle="protein" ';
        this.names = {   'A': 'Alanine (A/Ala)',
                         'B': 'Aspartate/asparagine (B/Asx)',
                         'C': 'Cysteine (C/Cys)',
                         'D': 'Aspartate (D/Asp)',
                         'E': 'Glutamate (E/Glu)',
                         'F': 'Phenylanine (F/Phe)',
                         'G': 'Glycine (G/Gly)',
                         'H': 'Histidine (H/His)',
                         'I': 'Isoleucine (I/Ile)',
                         'K': 'Lysine (K/Lys)',
                         'L': 'Leucine (L/Leu)',
                         'M': 'Methionine (M/Met)',
                         'N': 'Asparagine (N/Asn)',
                         'P': 'Proline (P/Pro)',
                         'Q': 'Glutamine (Q/Gln)',
                         'R': 'Arginine (R/Arg)',
                         'S': 'Serine (S/Ser)',
                         'T': 'Threonine (T/Thr)',
                         'U': 'Selenocysteine (U/Sel)',
                         'V': 'Valine (V/Val)',
                         'W': 'Tryptophan (W/Trp)',
                         'X': 'Any (X/Xaa)',
                         'Y': 'Tyrosine (Y/Tyr)',
                         'Z': 'Glutamate/glutamine (Z/Glx)',
                         '*': 'Stop (*/Stop)'}
    }
    reset() {   $('#results').hide();
                $('#venus_calc').removeAttr('disabled');
                $('result_title').html('<i class="far fa-dna fa-spin"></i> Loading');
                $('#fv').html();
                $('#results_mutalist').html('');
             }
    analysis (step) {return $.post({url: "venus_analyse", data:  {uniprot: uniprotValue,
                                                                          species: taxidValue,
                                                                          step: step,
                                                                          mutation: $('#mutation').val()}
                                    }).fail(ops.addErrorToast)
                    }
    card (title, text) {return `<li class="list-group-item">
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
                                </li>`}
    protein() {  return venus.analysis('protein')
                            .fail(xhr => {$('#venus_calc').removeAttr('disabled'); ops.addErrorToast(xhr)})
                            .done(msg => {$('#venus_calc').removeAttr('disabled');
                                    if (msg.error) {
                                        $('#error_'+msg.error).show();
                                        $('#'+msg.error).addClass('is-invalid');
                                        ops.addToast('error','Error - '+msg.error,'<i class="far fa-bug"></i> An issue arose analysing the results.<br/>'+msg.msg,'bg-warning');}
                                    else {
                                        const protein = msg.protein;

                                        //this.analysis('fv') is the same as get_uniprot but utilising the protein data.
                                        $('#results').show(500, () => this.analysis('fv').done(msg => eval(msg)));
                                        $('html, body').animate({scrollTop: $('#results').offset().top}, 2000);
                                        $('#result_title').html(`${protein.gene_name} ${protein._mutation} <small>(${protein.recommended_name})</small>`);
                                        this.mutation();
                                        }
                                  })
                }
    mutation() { return this.analysis('mutation').done(msg => {
                                                    const mutalist = $('#results_mutalist');
                                                    if (msg.error) {ops.addToast('error','Error - '+msg.error,'<i class="far fa-bug"></i> An issue arose analysing the results.<br/>'+msg.msg,'bg-warning');}
                                                    else {
                                                        const mutation = msg.mutation;
                                                        // rdkit images
                                                        mutalist.append(this.card('Mutation',
                                                                                                `<span ${this.prolink} data-focus="residue" data-load="wt" data-selection="${mutation.residue_index}:A">
                                                                                                            ${this.names[mutation.from_residue]} at position ${mutation.residue_index}</span> is mutated to
                                                                                                      <span ${this.prolink} data-focus="residue" data-load="mut" data-selection="${mutation.residue_index}:A">${this.names[mutation.to_residue]}</span>
                                                                                                      <div class="row">
                                                                                                            <div class="col-6"><img src="/static/aa/${mutation.from_residue}${mutation.to_residue}.svg" width="100%">
                                                                                                            <p>Differing atoms in  ${this.names[mutation.from_residue]} highlighted in red</p></div>
                                                                                                            <div class="col-6"><img src="/static/aa/${mutation.to_residue}${mutation.from_residue}.svg" width="100%">
                                                                                                            <p>Differing atoms in  ${this.names[mutation.to_residue]} highlighted in red</p></div>
                                                                                                        </div>`));
                                                        // apriori
                                                        if (mutation.to_residue !== '*') {mutalist.append(this.card('Effect independent of structure', mutation.apriori_effect))}
                                                        else {mutalist.append(this.card('Effect independent of structure', `${mutation.apriori_effect}
                                                                                                            <span ${this.prolink} data-focus="domain" data-selection="1-${mutation.residue_index}:A">remnant</span>
                                                                                                              and <span ${this.prolink} data-focus="domain" data-selection="${mutation.residue_index}-99999:A">lost</span>`));}

                                                        //structural card
                                                        // TO COPYPASTE

                                                        //
                                                        mutalist.append('Location',
                                                                        `<p>The mutation is ${Math.floor(mutation.residue_index/len(protein)*100)}% along the protein.`+
                                                                        '<ul>' +
                                                                        mutation.features_near_residue_index.map(v => `<li>${v}</li>`).join()



                                                                            YOU WERE CONVERTING THE FOLLOWING INTO JS¬!!!!!


                                                            `
                            <% feats=  %>
                                %if feats:
                                    Namely, within domain:</p>
                                        <ul>
                                    %for f in feats:
                                        <li><span ${prolink|n}
                                                  %if f['type'] in ('domain','propeptide','splice variant','signal peptide','repeat','coiled-coil region','compositionally biased region','short sequence motif','topological domain','transit peptide', 'transmembrane region','intramembrane region','region of interest','peptide'):
                                                  data-focus="domain"
                                                  %else:
                                                  data-focus="residue"
                                                  %endif
                                                  data-selection="${f['x']}-${f['y']}:CURRENTCHAIN">
                                            ${f['type']} &mdash; (${f['x']}&ndash;${f['y']})</span> ${f['description']}</li>
                                    %endfor
                                        </ul>
                                %else:
                                    </p>
                                %endif`);






                                                    }
                                                })
    }
}

window.venus = new Venus();

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
        venus.protein();
});

$('#new_analysis').click(venus.reset);

//</%text>