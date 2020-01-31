//<%text>
//venus main.mako imports uniprot_modal.js 's UniprotFV.

class MutantLocation {
  /*
  This is not perfect.
  There is an inexplicable initial offset.
  When zoomed in and the first block is lost, the line is lost too even when it is inplace.
   */
  constructor(x) {
    this.x = x;
    this.class = 'myVar';
    this.addLine();
    const s = $('#fv svg');
    s.mouseup(event => setTimeout(() => this.addLine.call(this), 1000));
    //s.mousedown(this.make);
  }

  addLine() {
    d3.select('.'+this.class).remove();
    const svgContainer = d3.select("#fv svg g");
    let dOri = d3.select('.domainGroup').data()[0].y - d3.select('.domainGroup').data()[0].x;
    let prime = parseFloat(d3.select('.domainGroup').attr("transform").match(/[-\d.]+/)[0]);
    let dPrime = parseFloat(d3.select('.domainGroup rect').attr("width"));
    this.scaleFactor = dPrime/dOri;
    this.offset = prime - this.scaleFactor * d3.select('.domainGroup').data()[0].x;
    this.h = d3.select(".background").attr("height");
    this.w = this.scaleFactor + 2;
    this.xPrime = this.scaleFactor * this.x - 1;

    svgContainer.append("rect")
            .attr("width", this.w)
            .attr("height", this.h)
            .attr("transform", `translate(${this.xPrime},0)`)
            .attr("class",this.class)
            .style("fill","rgba(200, 0, 0, 0.2)")
            .style("z-index", -1)
            .style("cursor","pointer");
    $('.'+this.class).click(event => this.onClick.call(this));
    return this;
  }

  onClick() {
      if (window.myData !== undefined) NGL.specialOps.showResidue('viewport', this.x+':A');
  }
}

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
        };
        this.mutalist = $('#results_mutalist');
        // these will be declared later. these here are for documentation.
        this.protein = null;
        this.position = null;
        this.mutation = null;
        this.structural = null;
    }

    reset() {
        $('#results').hide();
        $('#venus_calc').removeAttr('disabled');
        $('result_title').html('<i class="far fa-dna fa-spin"></i> Loading');
        $('#fv').html('');
        this.mutalist .html('');
        this.protein = null;
        this.mutation = null;
        this.structural = null;
        this.position = null;
    }

    analyse(step) {
        this.mutation = $('#mutation').val();
        this.position = parseInt(this.mutation.match(/\d+/)[0]);
        return $.post({
            url: "venus_analyse", data: {
                uniprot: uniprotValue,
                species: taxidValue,
                step: step,
                mutation: this.mutation
            }
        }).fail(ops.addErrorToast)
    }

    makeCard(title, text) {
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

    analyseProtein() {
        return venus.analyse('protein')
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
                    this.analyseMutation();
                    this.protein = msg.protein;

                    //this.analyse('fv') is the same as get_uniprot but utilising the protein data.
                    $('#results').show(500, () => this.analyse('fv').done(msg => {eval(msg);
                                                                d3.selectAll('.axis text').style("font-size", "0.6em");
                                                                new MutantLocation(this.position);}));
                    $('html, body').animate({scrollTop: $('#results').offset().top}, 2000);
                    $('#result_title').html(`${this.protein.gene_name} ${this.protein._mutation} <small>(${this.protein.recommended_name})</small>`);
                }
            })
    }

    analyseMutation() {
        return this.analyse('mutation').done(msg => {
            if (msg.error) {
                ops.addToast('error', 'Error - ' + msg.error, '<i class="far fa-bug"></i> An issue arose analysing the results.<br/>' + msg.msg, 'bg-warning');
            } else {
                this.analyseStructural();
                this.mutation = msg.mutation;
                // rdkit images
                let mutationtext = `<span ${this.prolink} data-focus="residue" data-load="wt" data-selection="${this.mutation.residue_index}:A">
                                            ${this.names[this.mutation.from_residue]} at position ${this.mutation.residue_index}</span> is mutated to
                                      <span ${this.prolink} data-focus="residue" data-load="mut" data-selection="${this.mutation.residue_index}:A">${this.names[this.mutation.to_residue]}</span>
                                      <div class="row">
                                            <div class="col-6"><img src="/static/aa/${this.mutation.from_residue}${this.mutation.to_residue}.svg" width="100%">
                                            <p>Differing atoms in  ${this.names[this.mutation.from_residue]} highlighted in red</p></div>
                                            <div class="col-6"><img src="/static/aa/${this.mutation.to_residue}${this.mutation.from_residue}.svg" width="100%">
                                            <p>Differing atoms in  ${this.names[this.mutation.to_residue]} highlighted in red</p></div>
                                        </div>`;
                this.mutalist.append(this.makeCard('Mutation', mutationtext));
                // apriori
                let aprioritext = this.mutation.apriori_effect;
                if (this.mutation.to_residue === '*') {
                    aprioritext += `
                                                                            <span ${this.prolink} data-focus="domain" data-selection="1-${this.mutation.residue_index}:A">remnant</span>
                                                                            and <span ${this.prolink} data-focus="domain" data-selection="${this.mutation.residue_index}-99999:A">lost</span>`
                }
                this.mutalist.append(this.makeCard('Effect independent of structure', aprioritext));
                //structural card
                // TO COPYPASTE

                //Features
                let locationtext = `<p>The mutation is ${this.mutation.position_as_protein_percent}% along the protein.</p>`
                if (this.mutation.features_near_mutation.length) {
                    locationtext += '<ul>';
                    locationtext += this.mutation.features_near_mutation.map(v => `<li>(${JSON.stringify(v)}</li>`).join('');
                    locationtext += '</ul>';
                }
                this.mutalist.append(this.makeCard('Location', locationtext));

                this.mutalist.append(this.makeCard('Domain detail', 'To Do figure out how to mine what the domain does. See notes "domain_function".'));

                //gnomAD
                if (this.mutation.gnomAD_near_mutation.length) {
                    let gnomADtext = '<p>Structure independent, sequence proximity.</p>';
                    gnomADtext += '<ul>';
                    gnomADtext += this.mutation.gnomAD_near_mutation.map(v => `<li>(${JSON.stringify(v)}</li>`).join('');
                    gnomADtext += '</ul>';
                    this.mutalist.append(this.makeCard('gnomAD', gnomADtext));
                }

                let exttext = `<a href="https://www.uniprot.org/uniprot/${uniprotValue}" target="_blank">Uniprot:${uniprotValue} <i class="far fa-external-link-square"></i></a> &mdash;
                                                                        <a href="https://www.rcsb.org/pdb/protein/${this.protein.uniprot}" target="_blank">PDB:${uniprotValue} <i class="far fa-external-link-square"></i></a> &mdash;
                                                                        <a href="https://gnomAD.broadinstitute.org/gene/${this.protein.gene_name}" target="_blank">gnomAD:${this.protein.gene_name} <i class="far fa-external-link-square"></i></a>`;
                this.mutalist.append(this.makeCard('External links', exttext));
            }
        })
    }

    analyseStructural() {
        return this.analyse('structural').done(msg => {
            if (msg.error) {
                ops.addToast('error', 'Error - ' + msg.error, '<i class="far fa-bug"></i> An issue arose analysing the results.<br/>' + msg.msg, 'bg-warning');
            } else {
                this.structural = msg.structural;
                if (!!this.structural.coordinates.length) this.loadStructure();
            }
        })
    }

    loadStructure () {
        NGL.specialOps.multiLoader('viewport', [{ type: "data", value: this.structural.coordinates, ext: 'pdb', chain: 'A'}])
                        .then(protein => NGL.specialOps.showResidue('viewport', this.position+':A'))
        UniprotFV.enpower();
        let strloctext = `<p>Chosen model: ${this.structural.code}</p>`;
        strloctext += `<p>${(this.structural.buried) ? 'buried' : 'surface'} ${this.structural.SS} (RSA: ${this.structural.RSA})</p>`;
        strloctext += `<p>${(this.structural.has_all_heavy_atoms) ? 'Resolved in crystal' : 'Some heavy atoms unresolved (too dynamic)'}</p>`;
        if (!! this.structural.ligand_list.length) {
            strloctext += `<p>Closest ligand atom: ${this.structural.closest_ligand.match(/\[.*\]/)[0].slice(1,-1)} ${this.structural.distance_to_closest_ligand}</p>`;
        }
        this.mutalist.append(this.makeCard('Structural character', strloctext));


        let strtext = '<p>Structural neighbourhood.</p>';
        strtext += '<ul>'+this.structural.neighbours.map(v => `<li>${v}</li>`).join()+'</ul>';
        this.mutalist.append(this.makeCard('Structural neighbourhood', strtext));
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
    venus.analyseProtein();
});

$('#new_analysis').click(venus.reset);

const alert = text => `<div class="alert alert-danger"><b>To do</b> ${text}</div>`;

$('#viewport').parent().parent().parent().append([alert('rewire NGL viewport following screen'),
                                                  //alert('pipe structure to PDB offset fix.'),
                                                  //alert('structural route.'),
                                                  //alert('autoload the sequence chosen by Analyser.get_best_model'),
                                                  alert('write documentation md!'),
                                                  alert('Fix load of swissmodel.'),
                                                  alert('cp the code for the domains from table ---what does this mean?'),
                                                  alert('add collapsed sequence viewer'),
                                                  alert('Fix RDKit matched structures to not claim that a sp2 Carbon os the same as sp3!'),
                                                  alert('Mike exporter')

                                                 ]);

//</%text>