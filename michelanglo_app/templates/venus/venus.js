//<%text>


class Venus {
    constructor() {
        this.prolink = ' class="prolink" data-target="#viewport" data-toggle="protein" ';
        this.names = {
            'A': 'Alanine (A/Ala)',
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
            '*': 'Stop (*/Stop)'
        }
    }

    reset() {
        $('#results').hide();
        $('#venus_calc').removeAttr('disabled');
        $('result_title').html('<i class="far fa-dna fa-spin"></i> Loading');
        $('#fv').html();
        $('#results_mutalist').html('');
    }

    analysis(step) {
        return $.post({
            url: "venus_analyse", data: {
                uniprot: uniprotValue,
                species: taxidValue,
                step: step,
                mutation: $('#mutation').val()
            }
        }).fail(ops.addErrorToast)
    }

    card(title, text) {
        return `<li class="list-group-item">
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
    }

    protein() {
        return venus.analysis('protein')
            .fail(xhr => {
                $('#venus_calc').removeAttr('disabled');
                ops.addErrorToast(xhr)
            })
            .done(msg => {
                $('#venus_calc').removeAttr('disabled');
                if (msg.error) {
                    $('#error_' + msg.error).show();
                    $('#' + msg.error).addClass('is-invalid');
                    ops.addToast('error', 'Error - ' + msg.error, '<i class="far fa-bug"></i> An issue arose analysing the results.<br/>' + msg.msg, 'bg-warning');
                } else {
                    this.mutation();
                    window.protein = msg.protein;

                    //this.analysis('fv') is the same as get_uniprot but utilising the protein data.
                    $('#results').show(500, () => this.analysis('fv').done(msg => eval(msg)));
                    $('html, body').animate({scrollTop: $('#results').offset().top}, 2000);
                    $('#result_title').html(`${protein.gene_name} ${protein._mutation} <small>(${protein.recommended_name})</small>`);
                }
            })
    }

    mutation() {
        return this.analysis('mutation').done(msg => {
            const mutalist = $('#results_mutalist');
            if (msg.error) {
                ops.addToast('error', 'Error - ' + msg.error, '<i class="far fa-bug"></i> An issue arose analysing the results.<br/>' + msg.msg, 'bg-warning');
            } else {
                this.structural();
                window.mutation = msg.mutation;
                // rdkit images
                let mutationtext = `<span ${this.prolink} data-focus="residue" data-load="wt" data-selection="${mutation.residue_index}:A">
                                            ${this.names[mutation.from_residue]} at position ${mutation.residue_index}</span> is mutated to
                                      <span ${this.prolink} data-focus="residue" data-load="mut" data-selection="${mutation.residue_index}:A">${this.names[mutation.to_residue]}</span>
                                      <div class="row">
                                            <div class="col-6"><img src="/static/aa/${mutation.from_residue}${mutation.to_residue}.svg" width="100%">
                                            <p>Differing atoms in  ${this.names[mutation.from_residue]} highlighted in red</p></div>
                                            <div class="col-6"><img src="/static/aa/${mutation.to_residue}${mutation.from_residue}.svg" width="100%">
                                            <p>Differing atoms in  ${this.names[mutation.to_residue]} highlighted in red</p></div>
                                        </div>`;
                mutalist.append(this.card('Mutation', mutationtext));
                // apriori
                let aprioritext = mutation.apriori_effect;
                if (mutation.to_residue === '*') {
                    aprioritext += `
                                                                            <span ${this.prolink} data-focus="domain" data-selection="1-${mutation.residue_index}:A">remnant</span>
                                                                            and <span ${this.prolink} data-focus="domain" data-selection="${mutation.residue_index}-99999:A">lost</span>`
                }
                mutalist.append(this.card('Effect independent of structure', aprioritext));
                //structural card
                // TO COPYPASTE

                //Features
                let locationtext = `<p>The mutation is ${mutation.position_as_protein_percent}% along the protein.</p>`
                if (mutation.features_near_mutation.length) {
                    locationtext += '<ul>';
                    locationtext += mutation.features_near_mutation.map(v => `<li>(${JSON.stringify(v)}</li>`).join('');
                    locationtext += '</ul>';
                }
                mutalist.append(this.card('Location', locationtext));

                mutalist.append(this.card('Domain detail', 'To Do figure out how to mine what the domain does. See notes "domain_function".'));

                //gnomAD
                if (mutation.gnomAD_near_mutation.length) {
                    let gnomADtext = '<p>Structure independent, sequence proximity.</p>';
                    gnomADtext += '<ul>';
                    gnomADtext += mutation.gnomAD_near_mutation.map(v => `<li>(${JSON.stringify(v)}</li>`).join('');
                    gnomADtext += '</ul>';
                    mutalist.append(this.card('gnomAD', gnomADtext));
                }

                let exttext = `<a href="https://www.uniprot.org/uniprot/${uniprotValue}" target="_blank">Uniprot:${uniprotValue} <i class="far fa-external-link-square"></i></a> &mdash;
                                                                        <a href="https://www.rcsb.org/pdb/protein/${protein.uniprot}" target="_blank">PDB:${uniprotValue} <i class="far fa-external-link-square"></i></a> &mdash;
                                                                        <a href="https://gnomAD.broadinstitute.org/gene/${protein.gene_name}" target="_blank">gnomAD:${protein.gene_name} <i class="far fa-external-link-square"></i></a>`;
                mutalist.append(this.card('External links', exttext));
            }
        })
    }

    structural() {
        return this.analysis('structural').done(msg => {
            const mutalist = $('#results_mutalist');
            if (msg.error) {
                ops.addToast('error', 'Error - ' + msg.error, '<i class="far fa-bug"></i> An issue arose analysing the results.<br/>' + msg.msg, 'bg-warning');
            } else {
                window.structural = msg.structural;
                if (!!structural.coordinates.length) {
                    NGL.specialOps.multiLoader('viewport', [{ type: "data", value: structural.coordinates, ext: 'pdb', chain: 'A'}]);
                    //NGL.getStage().loadFile(new Blob([structural.coordinates, {type: 'text/plain'}]), {, firstModelOnly: true})
                }
                let strloctext = `<p>Chosen model: ${structural.code}</p>`;
                strloctext += `<p>${(structural.buried) ? 'buried' : 'surface'} ${structural.SS} (RSA: ${structural.RSA})</p>`;
                strloctext += `<p>${(structural.has_all_heavy_atoms) ? 'Resolved in crystal' : 'Some heavy atoms unresolved (too dynamic)'}</p>`;
                if (!! structural.ligand_list.length) {
                    strloctext += `<p>Closest ligand atom: ${structural.closest_ligand.match(/\[.*\]/)[0].slice(1,-1)} ${structural.distance_to_closest_ligand}</p>`;
                }
                mutalist.append(this.card('Structural character', strloctext));


                let strtext = '<p>Structural neighbourhood.</p>';
                strtext += '<ul>'+structural.neighbours.map(v => `<li>${v}</li>`).join()+'</ul>';
                mutalist.append(this.card('Structural neighbourhood', strtext));
            }
        })
    }
}

window.venus = new Venus();

/////////////////// CALCULATE
const vbtn = $('#venus_calc');
$('#mutation').keyup(e => {
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
    venus.reset();
    if (taxidValue === 'ERROR') {
        $('#error_species').show();
        return 0;
    }
    if (uniprotValue === 'ERROR') {
        $('#error_gene').show();
        return 0;
    }
    if ($('#mutation').val().search(/\d+/) === -1) {
        $('#error_mutation').show();
        return 0;
    }
    $(e.target).attr('disabled', 'disabled');
    venus.protein();
});

$('#new_analysis').click(venus.reset);

const alert = text => `<div class="alert alert-danger"><b>To do</b> ${text}</div>`;

$('#viewport').parent().parent().parent().append([alert('rewire NGL viewport following screen'),
                                                  alert('pipe structure to PDB offset fix.'),
                                                  alert('structural route.'),
                                                  alert('autoload the sequence chosen by Analyser.get_best_model'),
                                                  alert('write documentation md!'),
                                                  alert('cp the code for the domains from table'),
                                                  alert('collapsed sequence viewer'),
                                                  alert('Fix RDKit matched structures to not claim that a sp2 Carbon os the same as sp3!'),
                                                  alert('Mike exporter')

                                                 ]);

//</%text>