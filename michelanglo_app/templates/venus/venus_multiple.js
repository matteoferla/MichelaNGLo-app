//<%text>
// same as venus route!

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

// different
// not... class MultiVenus extends Venus {....

class MultiVenus {
    // a new mv instance is made each time analyse is clicked.
    constructor() {
        this.protein = null; // to be filled with obj from ajax
        this.last_clicked_prolink = null; //to be filled by clicking.
        this.uniprot = window.uniprotValue;
        this.taxid = window.taxidValue;
        // assess variants.
        const mv = this.getMutationsValidity();
        if (Object.values(mv).every(v => v)) {
            // all valid mutations.
            this.mutations = Object.keys(mv);
        } else { //invalid mutation
            Object.keys(mv).filter(k => ! mv[k]).map(k => {
            ops.addToast('dodgymutant'+k, '<i class="far fa-alien-monster"></i> Invalid mutation format for '+k,
                'VENUS analyses protein mutations only. The mutation needs to be in the format A123E or Ala123Glu, with or without "p." prefix. Case insensitive.', 'bg-warning');
            $('#venus_calc').removeAttr('disabled');
        });
            throw('invalid mutation');
        }

    }

    analyse() {
        return $.post({
            url: "venus_multianalyse", data: {
                uniprot: this.uniprot,
                species: this.taxid,
                mutations: this.mutations.join(' ')
            }
        }).fail(ops.addErrorToast)
            .done(msg => {
                $('#venus_calc').removeAttr('disabled');
                if (msg.error) {
                    $('#error_' + msg.error).show();
                    $('#' + msg.error).addClass('is-invalid');
                    ops.addToast('error', 'Error - ' + msg.error, '<i class="far fa-bug"></i> An issue arose analysing the results.<br/>' + msg.msg, 'bg-warning');
                } else { //status success!
                    $('html, body').animate({scrollTop: $('#results').offset().top}, 2000);
                    $('#results').show(500);
                    this.protein = msg.protein;
                    this.choices = msg.choices;
                    this.addMutationsList();
                    this.addModelList();


                    // //venus analyse is
                    // $.post({
                    //             url: "venus_analyse", data: {
                    //                 uniprot: uniprotValue,
                    //                 species: taxidValue,
                    //                 step: step,
                    //                 mutation: this.mutation
                    //             }
                    //         }).fail(ops.addErrorToast)
                    //
                    // venus.analyse('fv') is the same as get_uniprot but utilising the protein data.
                    // $('#results').show(500, () => this.analyse('fv').done(msg => {
                    //     eval(msg);
                    //     d3.selectAll('.axis text').style("font-size", "0.6em");
                    //     //new MutantLocation(this.position);
                    //     this.mutations.map(m => parseInt(m.slice(1, -1))).forEach(m => ft.addMutation(m));
                    //
                    // }));














                    // let linktext = `<i>this search (browser)</i>: <code>https://venus.sgc.ox.ac.uk/?uniprot=${uniprotValue}&species=${taxidValue}&mutation=${this.mutation}</code><br/>`;
                    // linktext += `<i>this search (API)</i>: <code>https://venus.sgc.ox.ac.uk/venus_analyse?uniprot=${uniprotValue}&species=${taxidValue}&mutation=${this.mutation}</code>`;
                    // this.createEntry('link', 'Links', linktext);
                    //
                    //
                    // $('html, body').animate({scrollTop: $('#results').offset().top}, 2000);
                    // $('#result_title').html(`${this.protein.gene_name} ${this.protein._mutation} <small>(${this.protein.recommended_name})</small>`);
                    // let exttext = this.makeExt('https://www.uniprot.org/uniprot/' + uniprotValue, 'Uniprot:' + uniprotValue) + ' &mdash; ' +
                    //     this.makeExt('https://www.rcsb.org/pdb/protein/' + this.protein.uniprot, 'PDB:' + uniprotValue) + ' &mdash; ' +
                    //     this.makeExt('https://gnomAD.broadinstitute.org/gene/' + this.protein.gene_name, 'gnomAD:' + this.protein.gene_name);
                    // this.createEntry('extlink', 'External links', exttext);
                }
            });
    }

    //step 0 copied from venus class then modded.
    getMutationsValidity() { // get a obj of key=mut & value=bool
        let mutations = window.mutation.value.replace('p.','').split(/[^\w*]/).filter(m => m.length !== 0);
        //check the mutation is valid
        //this is a copy paste of the fun from pdb_staging_insert.js
        const aa = {
            'CYS': 'C', 'ASP': 'D', 'SER': 'S', 'GLN': 'Q', 'LYS': 'K',
            'ILE': 'I', 'PRO': 'P', 'THR': 'T', 'PHE': 'F', 'ASN': 'N',
            'GLY': 'G', 'HIS': 'H', 'LEU': 'L', 'ARG': 'R', 'TRP': 'W',
            'ALA': 'A', 'VAL': 'V', 'GLU': 'E', 'TYR': 'Y', 'MET': 'M'
        };
        return Object.fromEntries(mutations.map(
                                                mutation => {
                                                    let parts = mutation.match(/^(\D{1,3})(\d+)(\D{1,3})$/);
                                                    // ["G10W", "G", "10", "W", index: 0, input: "G10W", groups: undefined]
                                                    const getMutation = (p) => p.splice(1, 3).join('');
                                                    if (parts === null) return [mutation, false];
                                                    // deal with three letter code.
                                                    if (aa[parts[1]] !== undefined) {
                                                        parts[1] = aa[parts[1]];
                                                    }
                                                    if (!'ACDEFGHIKLMNPQRSTVWYX'.includes(parts[1])) return [getMutation(parts), false];
                                                    if (aa[parts[3]] !== undefined) {
                                                        parts[3] = aa[parts[3]]
                                                    }
                                                    if (!'ACDEFGHIKLMNPQRSTVWYX'.includes(parts[1])) return [getMutation(parts), false];
                                                    // it's good
                                                    return [getMutation(parts), true];
                                                })
                );

    }

    addMutationsList () {
        const inners = this.mutations.map(mutation => `<li class="list-group-item">
                                                            <div class="row">
                                                                <div class="col-md-4">
                                                                    <b>${mutation}</b>
                                                                </div>
                                                                <div class="col-md-4">
                                                                    <span class="prolink" data-target="viewport"
                                                                        data-focus="residue" data-selection="${mutation.slice(1,-1)}">show wt</span>
                                                                </div>
                                                                <div class="col-md-4">
                                                                    <a href="/venus?uniprot=${this.uniprot}&species=${this.taxid}&mutation=${mutation}" target="_blank">analyse in VENUS</a>
                                                                </div>
                                                            </div>
                                                        </li>`);
        $('#result_mutation_list').html(inners.join('\n'));
        $('#result_mutation_list .prolink').protein();
}

    addModelList () {
        const inners = Object.keys(this.choices).map(k => {
                        const valids = this.choices[k].join(', ');
                        let selections = this.mutations.map(mutation => mutation.slice(1,-1)).join(' or ');
                        let model, name;
                        if (k.length === 6) {
                            name = `PDB:${k}`;
                            const chain = k.slice(-1,);
                            model = k.slice(0,-2);
                            selections = `(${selections}) and :${chain}`;
                        } else {
                            name = `SWISSMODEL:${k}`;
                            model = k;

                        }
                        return `<button type="button" class="list-group-item list-group-item-action"
                                    data-target="viewport"
                                    data-focus="residue" data-selection="${selections}"
                                    data-load="${model}"
                                >
                                    ${name}: ${valids}
                                </button>`;
                    });
        $('#results_mutalist').html(inners.join('\n'));
        $('#results_mutalist button').click(event => {
            $('#results_mutalist .active').removeClass('active');
            $(event.target).addClass('active');
            NGL.specialOps.prolink(event.target);
            window.multivenus.last_clicked_prolink = event.target;
        }).first().click();
        setTimeout(() => {
            NGL.specialOps._preventScroll('viewport');
            NGL.specialOps.enableClickToShow('viewport');
        }, 1000);

    }
}


vbtn.click(e => {
    if (taxidValue === 'ERROR') {
        $('#error_species').show();
        return 0;
    }
    if (uniprotValue === 'ERROR') {
        $('#error_gene').show();
        return 0;
    }
    if (mutation.val().search(/\d+/) === -1) {
        $('#error_mutation').show();
        return 0;
    }
    $(e.target).attr('disabled', 'disabled');
    try {
        window.multivenus = new MultiVenus();
        window.multivenus.analyse();
    } catch (e) {
        // already dealt with.
        if (e !== 'invalid mutation') throw e;
    }

});

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
//</%text>