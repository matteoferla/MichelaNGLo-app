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
        this.mutaColor = NGL.ColormakerRegistry.addSelectionScheme([['hotpink','_C'],["blue",'_N'],["red",'_O'],["white",'_H'],["yellow",'_S'],["orange","*"]]);
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

    makeProlink(v, label) {
        // v string and label exists.
        // v is array of gnomad
        // v is dictionary
        if (typeof v === "string") {
            return `<span class="prolink" data-target="viewport" data-toggle="protein" data-color="cyan" data-focus="residue" data-selection="${v}">${label}</span>`;
        }
        else if (Array.isArray(v)) {
            //gnomad
            //["gnomAD_101_101_rs1131691997",101,101,"MODERATE","K101R (rs1131691997)",0]
            let p = v[4];
            if (parseInt(v[1]) === this.position) p = '<b>'+p+'</b>';
            return `<span class="prolink" data-target="viewport" data-toggle="protein" data-focus="residue" data-color="cyan" data-selection="${v[1]}:A">${p}</span>`;
        }
        else if (v.x !== undefined) {
            //feature!
            //{"x":105,"y":107,"description":"strand","id":"strand_105_107","type":"strand"}
            let df = 'residue';
            let ds = v.x+':A';
            let p = 'Residue '+v.x;
            if (parseInt(v.x)=== this.position) p = '<b>Residue '+v.x+'</b>';
            let dc='cyan';
            if (v.x !== v.y) { df = 'domain'; ds = `${v.x}-${v.y}:A`; p = `Residues ${v.x}&ndash;${v.y}`; dc='darkgreen';}
            return `<span class="prolink" data-target="viewport" data-toggle="protein" data-color="${dc}"  data-focus="${df}" data-selection="${ds}">${p}</span>`;
            }
        else {
            console.log('ERRRROR'+JSON.stringify(v));
        }
        }

    makeExt(url, txt) {return `<a href="${url}" target="_blank">${txt} <i class="far fa-external-link-square"></i></a>`}

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
                let locationtext = `<p>The mutation is ${this.mutation.position_as_protein_percent}% along the protein.</p>`;
                if (this.mutation.features_near_mutation.length) {
                    locationtext += '<span>Nearby features:</span>';
                    locationtext += '<ul>';
                    locationtext += this.mutation.features_near_mutation.map(v => `<li>${this.makeProlink(v)}: ${v.type} (${v.description})</li>`).join('');
                    locationtext += '</ul>';
                }
                this.mutalist.append(this.makeCard('Location', locationtext));

                this.mutalist.append(this.makeCard('Domain detail', 'To Do figure out how to mine what the domain does. See notes "domain_function".'));

                //gnomAD
                if (this.mutation.gnomAD_near_mutation.length) {
                    let omni = this.makeProlink(this.mutation.gnomAD_near_mutation.map(v => v[1]+':A').join(' or '), '(all)');
                    let gnomADtext = `<p>Structure independent, sequence proximity (see structural neighbour for 3D) ${omni}.</p>`;
                    gnomADtext += '<ul>';
                    gnomADtext += this.mutation.gnomAD_near_mutation.map(v => `<li>${this.makeProlink(v)}: (${v[3].toLowerCase()})</li>`).join('');
                    gnomADtext += '</ul>';
                    this.mutalist.append(this.makeCard('gnomAD', gnomADtext));
                }

                if (this.mutation.elm.length) {
                    let elmtext = '<p>Some of the following predicted motifs might be valid:</p>';
                    elmtext += '<ul>';
                    elmtext += this.mutation.elm.map(v => `<li>${this.makeProlink(v)}: <span data-target="tooltip" title="${v.description}">${v.name} ${v.status} (${v.regex})</li>`).join('');
                    elmtext += '</ul>';
                    this.mutalist.append(this.makeCard('Motif', elmtext));
                }
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
            // activate all prolinks
            $('#results_mutalist .prolink').protein();
            // hack them to always show the mutatns.
            const showMut = (sele) => {
                const prot = NGL.getStage().getComponentByType('structure');
                if (prot !== undefined) prot.addRepresentation( "hyperball", sele);
            };
            $('#results_mutalist .prolink').click(event => setTimeout((sele) => showMut(sele),100, { sele: this.position+':A', color: this.mutaColor}));

            let exttext = this.makeExt('https://www.uniprot.org/uniprot/'+uniprotValue, 'Uniprot:'+uniprotValue) + ' &mdash; '+
                          this.makeExt('https://www.rcsb.org/pdb/protein/'+this.protein.uniprot, 'PDB:'+uniprotValue) + ' &mdash; '+
                          this.makeExt('https://gnomAD.broadinstitute.org/gene/'+this.protein.gene_name, 'gnomAD:'+this.protein.gene_name);
            this.mutalist.append(this.makeCard('External links', exttext));
            $('[data-target="tooltip"]').tooltip();
        })
    }

    loadStructure () {
        NGL.specialOps.multiLoader('viewport', [{ type: "data", value: this.structural.coordinates, ext: 'pdb', chain: 'A'}])
                        .then(protein => NGL.specialOps.showResidue('viewport', this.position+':A'))
        UniprotFV.enpower();
        let strloctext = '<p><i>Chosen model:</i> '+this.makeExt("https://www.rcsb.org/structure/"+this.structural.code, this.structural.code)+'</p>';
        strloctext += `<p><i>Solvent exposure:</i> ${(this.structural.buried) ? 'buried' : 'surface'} (RSA: ${Math.round(this.structural.RSA*100)/100})</p>`;
        strloctext += `<p><i>Secondary structure type:</i> ${this.structural.SS}</p>`;
        strloctext += `<p><i>Residue resolution:</i> ${(this.structural.has_all_heavy_atoms) ? 'Resolved in crystal' : 'Some heavy atoms unresolved (too dynamic)'}</p>`;
        if (!! this.structural.ligand_list.length) {
            //this.structural.closest_ligand = [GDP]180.O3B:A
            let lig = this.structural.closest_ligand.match(/\[.*\]/)[0].slice(1,-1);
            let ds = lig+' and '+this.structural.closest_ligand.match(/\:\w/)[0];
            let d = Math.round(this.structural.distance_to_closest_ligand)+' &Aring;'
            strloctext += `<p><i>Closest ligand:</i> <span class="prolink" data-target="viewport" data-color="teal" data-focus="residue" data-selection="${ds}">${lig}</span> (${d})</p>`;
        }
        this.mutalist.append(this.makeCard('Structural character', strloctext));

        let omni = this.makeProlink(this.structural.neighbours.map(v => v.resi+':A').join(' or '), '(all)');
        let strtext = `<p>Structural neighbourhood ${omni}.</p>`;
        strtext += '<ul>'+this.structural.neighbours.map(v => `<li>${this.makeProlink(v.resi+":"+v.chain, v.resn+v.resi)} ${v.detail}</li>`).join('')+'</ul>';
        this.mutalist.append(this.makeCard('Structural neighbourhood', strtext));
    }

    createPage () {
        let data = {uniprot: window.uniprotValue, //same as this.protein.uniprot,
                    species: window.taxidValue,
                    mutation: this.mutation,
                    text: $('#results_mutalist').html(),
                    code: this.structural.code,
                    block: this.structural.coordinates,
                    definitions: JSON.stringify(this.structural.chain_definitions),
                    history: JSON.stringify(this.structural.history)};
        // other end at page_creation.py
        return $.post({url: "venus_create", data: data, dataType: 'json'})
        .done(function (msg) {
                ops.addToast('jobcompletion','Conversion complete','The data has been converted successfully.','bg-success');
                ops.addToast('redirect','Conversion complete','Redirecting you to page '+msg.page,'bg-info');
                console.log(msg);
                window.location.href = "/data/"+msg.page;
        })
        .fail(ops.addErrorToast);
    }
}

window.venus = new Venus();


/////////////////// CALCULATE

$(window).scroll(function() {
	    var card = $('#vieport_side');
        var currentY = $(window).scrollTop();
	    var windowY = $(window).innerHeight();
	    var offsetY = card.offset().top - parseInt(card.css('top')) - 4;
        if ((currentY > offsetY) && (currentY + windowY > offsetY + card.height())) {
    	$('#viewport').parent().parent().css('top', currentY - offsetY);
    }
    else {$('#viewport').parent().parent().css('top', 0);}
        //console.log(`scrolltop: ${currentY} win height ${windowY} off: ${offsetY} card top: ${card.offset().top}`);
	});



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

$('#results_mutalist').parent().append([//alert('rewire NGL viewport following screen'),
                              //alert('pipe structure to PDB offset fix.'),
                              //alert('structural route.'),
                              //alert('autoload the sequence chosen by Analyser.get_best_model'),
                              alert('write documentation md!'),
                              alert('Fix load of swissmodel.'),
                              alert('cp the code for the domains from table ---what does this mean?'),
                              alert('add collapsed sequence viewer'),
                              alert('Fix RDKit matched structures to not claim that a sp2 Carbon os the same as sp3!'),
                              alert('Mike exporter'),
                              alert('Fix links in Mutation li')
                             ]);

// for now....
$('#report-btn').click(event => {
    if (venus.structural === undefined) {
        ops.addToast('patience','Please be patient','The analysis is not complete.','bg-warning');
        return 0;
    }
    $(event.target).attr('disabled','disabled');
    const text = $(event.target).html();
    $(event.target).html('<i class="far fa-spinner fa-spin"></i> '+text);
    venus.createPage().then(() => {
        $(event.target).attr('disabled','disabled');
        $(event.target).html(text);
    });
});

//</%text>