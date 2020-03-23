//<%text>
// venus main.mako imports uniprot_modal.js 's UniprotFV.
// .venus-no-mike css classes do not get ported to Michelanglo
// .venus-plain-mike css classes is ported as text to Michelanglo

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
        this.mutation = null;
        this.position = null;
        this.protein = null;
        this.mutational = null;
        this.structural = null;
        this.energetical = null;
        this.energetical_gnomAD = null;
        this.alwaysShowMutant = $('#showMutant').prop('checked'); //remembered from browser weird habit.
        this.mutaColor = NGL.ColormakerRegistry.addSelectionScheme([['hotpink','_C'],["blue",'_N'],["red",'_O'],["white",'_H'],["yellow",'_S'],["orange","*"]]);
        this.documentation = {  'mut': 'Residue identity, note that because a difference in shape is present it does not mean that the structure cannot accommodate the change',
                                'indestr': 'This is a purely based on the nature of the amino acids without taking into account the position. Despite this, it is a strong predictor.',
                                'strcha': 'Model based residue details',
                                'ddg': 'Forcefield calculations. A negative value is stabilising, and a value of 1-2 kcal/mol is neutral. A hydrogen bond has about 1-2 kcal/mol. For more see documentation.',
                                'location': 'What domains are nearby linearly &mdash;but not necessarily containing the residue',
                                'domdet': 'what is this?',
                                'neigh': 'Model based, what residues are within 4 &aring;ngstr&ouml;m?',
                                'motif': 'Motifs predicted using the linear motif patterns from the ELM database. The presence of a linear motif does not mean it is valid, in fact the secondary structure is important: in a helix residues 3 along are facing the same direction, in a sheet alternating residues and in a loop it varies. If a motif is a phosphosite and the residue is not phosphorylated it is likely not legitimate.',
                                'link': 'Link to this search (will be redone) for browser or programmatic access',
                                'extlink': 'Links to external resources related to this gene'
                    }
        this.entry_order = Object.keys(this.documentation); //order is changed dynamically.
        this.animation_speed = 1000;

    }

    reset() {
        this.protein = null;
        this.mutation = null;
        this.structural = null;
        this.position = null;
        this.energetical = null;
        this.energetical_gnomAD = null;
        delete window.myData;
        if (window.myData !== undefined) {
            delete window.myData;
            NGL.getStage().removeAllComponents();
        }
        this.updateStructureOption();
        this.mutalist.html('');
        $('#results').hide();
        $('#venus_calc').removeAttr('disabled');
        $('result_title').html('<i class="far fa-dna fa-spin"></i> Loading');
        $('results_status').html('ERROR');
        $('#fv').html('');
    }

    //###################  Steps
    //Ajax
    analyse(step) {
        return $.post({
            url: "venus_analyse", data: {
                uniprot: uniprotValue,
                species: taxidValue,
                step: step,
                mutation: this.mutation
            }
        }).fail(ops.addErrorToast)
    }

    //step 0
    isValidMutation() {
        //check the mutation is valid
        //this is a copy paste of the fun from pdb_staging_insert.js
        const aa = {'CYS': 'C', 'ASP': 'D', 'SER': 'S', 'GLN': 'Q', 'LYS': 'K',
              'ILE': 'I', 'PRO': 'P', 'THR': 'T', 'PHE': 'F', 'ASN': 'N',
              'GLY': 'G', 'HIS': 'H', 'LEU': 'L', 'ARG': 'R', 'TRP': 'W',
              'ALA': 'A', 'VAL': 'V', 'GLU': 'E', 'TYR': 'Y', 'MET': 'M'};
        let parts = this.mutation.match(/^(\D{1,3})(\d+)(\D{1,3})$/);
        if (parts === null) return false;
        // deal with three letter code.
        if (aa[parts[1]] !== undefined) {parts[1] = aa[parts[1]]}
        if (! 'ACDEFGHIKLMNPQRSTVWYX'.includes(parts[1])) return false;
        if (aa[parts[3]] !== undefined) {parts[3] = aa[parts[3]]}
        if (! 'ACDEFGHIKLMNPQRSTVWYX'.includes(parts[1])) return false;
        // it's good
        this.mutation = parts.splice(1,3).join('');
        return true;
    }

    //step 1
    analyseProtein() {
        //step one
        this.mutation = $('#mutation').val().replace('p.','').toUpperCase();
        this.position = parseInt(this.mutation.match(/\d+/)[0]);
        if (this.isValidMutation() === false) {
            ops.addToast('dodgymutant','<i class="far fa-alien-monster"></i> Invalid mutation format',
                'VENUS analyses missense mutations only. One mutation at the time. The mutation needs to be in the format A123E or Ala123Glu, with or without "p." prefix. Case insensitive.', 'bg-warning');
            $('#venus_calc').removeAttr('disabled');
            return 0;}
        this.setStatus('Running step 1/4', 'working');
        return venus.analyse('protein')
            .fail(xhr => {
                this.setStatus('Failure at step 1/4', 'crash');
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
                    let linktext = `<i>this search (browser)</i>: <code>https://venus.sgc.ox.ac.uk/?uniprot=${uniprotValue}&species=${taxidValue}&mutation=${this.mutation}</code><br/>`;
                    linktext += `<i>this search (API)</i>: <code>https://venus.sgc.ox.ac.uk/venus_analyse?uniprot=${uniprotValue}&species=${taxidValue}&mutation=${this.mutation}</code>`;
                    this.createEntry('link', 'Links', linktext);

                    //this.analyse('fv') is the same as get_uniprot but utilising the protein data.
                    $('#results').show(500, () => this.analyse('fv').done(msg => {eval(msg);
                                                                d3.selectAll('.axis text').style("font-size", "0.6em");
                                                                //new MutantLocation(this.position);
                                                                ft.addMutation(this.position);
                    }));
                    $('html, body').animate({scrollTop: $('#results').offset().top}, 2000);
                    $('#result_title').html(`${this.protein.gene_name} ${this.protein._mutation} <small>(${this.protein.recommended_name})</small>`);
                    let exttext = this.makeExt('https://www.uniprot.org/uniprot/'+uniprotValue, 'Uniprot:'+uniprotValue) + ' &mdash; '+
                            this.makeExt('https://www.rcsb.org/pdb/protein/'+this.protein.uniprot, 'PDB:'+uniprotValue) + ' &mdash; '+
                            this.makeExt('https://gnomAD.broadinstitute.org/gene/'+this.protein.gene_name, 'gnomAD:'+this.protein.gene_name);
                    this.createEntry('extlink','External links', exttext);
                }
            });

    }

    //step 2
    analyseMutation() {
        //step 2
        this.setStatus('Running step 2/4', 'working');
        return this.analyse('mutation').done(msg => {
            if (msg.error) {
                this.setStatus('Failure at step 2/4', 'crash');
                ops.addToast('error', 'Error - ' + msg.error, '<i class="far fa-bug"></i> An issue arose analysing the results.<br/>' + msg.msg, 'bg-warning');
            } else {
                $('#results').show();
                this.analyseStructural();
                this.mutational = msg.mutation;
                // rdkit images
                let mutationtext = `<span ${this.prolink} data-focus="residue" data-load="wt" data-selection="${this.mutational.residue_index}:A">
                                            ${this.names[this.mutational.from_residue]} at position ${this.mutational.residue_index}</span> is mutated to
                                      <span ${this.prolink} data-focus="clash" data-load="mutant" data-selection="${this.mutational.residue_index}:A">${this.names[this.mutational.to_residue]}</span>
                                      <div class="row">
                                            <div class="col-6"><img src="/static/aa/${this.mutational.from_residue}${this.mutational.to_residue}.svg" width="100%">
                                            <p>Differing atoms in  ${this.names[this.mutational.from_residue]} highlighted in red</p></div>
                                            <div class="col-6"><img src="/static/aa/${this.mutational.to_residue}${this.mutational.from_residue}.svg" width="100%">
                                            <p>Differing atoms in  ${this.names[this.mutational.to_residue]} highlighted in red</p></div>
                                        </div>`;
                this.createEntry('mut', 'Mutation', mutationtext);
                // apriori
                let aprioritext = this.mutational.apriori_effect;
                if (this.mutational.to_residue === '*') {
                    aprioritext += `<span ${this.prolink} data-focus="domain" data-selection="1-${this.mutational.residue_index}:A">remnant</span>
                                    and <span ${this.prolink} data-focus="domain" data-selection="${this.mutational.residue_index}-99999:A">lost</span>`
                }
                this.createEntry('indestr', 'Effect independent of structure', aprioritext);
                //structural card
                // TO COPYPASTE

                this.createLocation();

                this.createEntry('domdet','Domain detail', 'To Do figure out how to mine what the domain does. See notes "domain_function".');

                //gnomAD
                if (this.mutational.gnomAD_near_mutation.length) {
                    let omni = this.makeProlink(this.mutational.gnomAD_near_mutation.map(v => v[1]+':A').join(' or '), '(all)');
                    let gnomADtext = `<p>Structure independent, sequence proximity (see structural neighbour for 3D) ${omni}.</p>`;
                    gnomADtext += '<ul>';
                    gnomADtext += this.mutational.gnomAD_near_mutation.map(v => `<li>${this.makeProlink(v)}: (${v[3].toLowerCase()})</li>`).join('');
                    gnomADtext += '</ul>';
                    this.createEntry('gnomad', 'gnomAD', gnomADtext);
                }

                if (this.mutational.elm.length) {
                    let elmtext = '<p>Some of the following predicted motifs might be valid:</p>';
                    elmtext += '<ul>';
                    // converts a regex str to a sele str.
                    const reg2sele = (regex,offset) => regex.replace('$','')
                                                            .replace(')','')
                                                            .replace('(','')
                                                            .replace('^','')
                                                            .replace(/\[.*?\]/g, 'X')
                                                            .replace(/\{(\d?)\,(\d?)}/,(match, p1, p2, offset, string) => 'X'.repeat(parseInt(p1))) //will need fixing...
                                                            .split('')
                                                            .map((v,i)=> (v !== '.') ? i + offset : null)
                                                            .filter(v => v !== null).map(v => v+':A')
                                                            .join(' or ');
                    elmtext += this.mutational.elm.map(v => `<li>${this.makeProlink(reg2sele(v.regex, v.x), `Residues ${v.x}&ndash;${v.y}`)}: <span data-target="tooltip" title="${v.description}">${v.name} ${v.status} (${v.regex})</li>`).join('');
                    elmtext += '</ul>';
                    this.createEntry('motif','Motif', elmtext);
                }
            }
        })
    }

    //step 3
    analyseStructural() {
        //step 3
        this.setStatus('Running step 3/4', 'working');
        return this.analyse('structural').done(msg => {
            if (msg.error) {
                this.setStatus('Failure at step 3/4', 'crash');
                ops.addToast('error', 'Error - ' + msg.error, '<i class="far fa-bug"></i> An issue arose analysing the results.<br/>' + msg.msg, 'bg-warning');
                this.fallbackAnalyse();
            } else {
                this.structural = msg.structural;
                this.analyseddG();
                if (!!this.structural.coordinates.length) this.loadStructure();
            }
            // activate all prolinks
            // const pros = $('#results_mutalist .prolink');
            // pros.protein();
            // pros.click(event => this.showMutant.call(this) );
            // hack them to always show the mutants.
        })
    }

    //step 4
    analyseddG() {
        //step 4
        this.setStatus('Running step 4/5', 'working');
        return this.analyse('ddG').done(msg => {
            if (msg.error) {
                this.setStatus('Failure at step 4/5', 'crash');
                ops.addToast('error', 'Error - ' + msg.error, '<i class="far fa-bug"></i> An issue arose analysing the results.<br/>' + msg.msg, 'bg-warning');
            } else {
                this.analyseddG_gnomad();
                this.energetical = msg.ddG;
                //this.loadStructure();
                const units = '<span title="Technically REU, Rosetta Energy Units, which are approximately the same as kcal/mol when using the ref2015 force-field score function">kcal/mol</span> ';
                let ddgtext = `<i>ddG (with backbone movement allowed):</i> ${Math.round(this.energetical.ddG)} ${units} `;
                if (this.energetical.ddG < -5) {ddgtext += '(stabilising)'}
                else if (this.energetical.ddG > +5) {ddgtext += '(destabilising)'}
                else {ddgtext += '(neutral)'}
                ddgtext += '<br/>';
                let bb = this.energetical.scores.mutate - this.energetical.scores.relaxed;
                ddgtext += `<i>ddG (with backbone movement forbidden):</i> ${Math.round(bb)}  ${units} `;
                if (bb < -5) {ddgtext += '(stabilising)'}
                else if (bb > +5) {ddgtext += '(destabilising)'}
                else {ddgtext += '(neutral)'}
                ddgtext += '<br/>';
                if (this.energetical.scores.mutate + 3 > this.energetical.scores.mutarelax) {
                    ddgtext += `Results in backbone change (RMSD<sub>CA</sub>: ${Math.round(this.energetical.rmsd*100)/100})<br/>`;
                }
                ddgtext += '<button class="btn btn-outline-info venus-no-mike" data-toggle="modal" data-target="#ddG_extra">More</button>';
                this.createEntry('ddg','Free energy calculation', ddgtext);
                const liEl = (l, v) => `<li><b>${l}:</b> ${v}</li>`;
                const innerList = d => '<ul>'+Object.entries(d).map(([k, v]) => liEl(k,v)).join('')+'</ul>';
                let extraParts = liEl('Scorefunction', this.energetical.score_fxn) +
                                 liEl('ddG', this.energetical.ddG +' kcal/mol') +
                                 liEl('solvatation term in ddG', this.energetical.dsol +' kcal/mol') +
                                 liEl('Scores (meaningless due to only partial energy minimisation)', innerList(this.energetical.scores)) +
                                 liEl('ddG contributed by residue', this.energetical.ddG_residue +' kcal/mol') +
                                 liEl('Native residue terms', innerList(this.energetical.native_residue_terms))+
                                 liEl('Mutant residue terms', innerList(this.energetical.mutant_residue_terms));
                $('#ddG_extra .modal-body').html('<p>Detail for ddG score. For meaning, see <a href="/docs/venus" target="_blank">documentation</a>.</p><ul>'+extraParts+'</ul>');
                myData.proteins[0].name = 'model'; //need the name.
                myData.proteins.push({ name: "wt",
                                      type: "data",
                                      value: this.energetical.native,
                                      ext: 'pdb',
                                      chain: 'A',
                                      chain_definitions:this.structural.chain_definitions,
                                      history: {code: this.structural.history.code,
                                                changes: this.structural.history.changes + 'Rosetta locally relaxed'
                                                }
                                    });
                myData.proteins.push({ name: "mutant",
                                      type: "data",
                                      value: this.energetical.mutant,
                                      ext: 'pdb',
                                      chain: 'A',
                                      chain_definitions:this.structural.chain_definitions,
                                      history: {code: this.structural.history.code,
                                                changes: this.structural.history.changes + 'Rosetta locally relaxed, mutated and relaxed'
                                                }
                                    });
                if (this.energetical.phospho) {
                    myData.proteins.push({ name: "phosphorylated",
                                      type: "data",
                                      value: this.energetical.phospho,
                                      ext: 'pdb',
                                      chain: 'A',
                                      chain_definitions:this.structural.chain_definitions,
                                      history: {code: this.structural.history.code,
                                                changes: this.structural.history.changes + 'Rosetta locally relaxed, phosphorylated (no repacking)'
                                                }
                                    });
                }
                this.updateStructureOption();
            }
        //{ddG: float, scores: Dict[str, float], native:str, mutant:str, rmsd:int}
        });
    }

    //step 5
    analyseddG_gnomad() {
        //step 5
        this.setStatus('Running step 5/5', 'working');
        return this.analyse('ddG_gnomad').done(msg => {
            if (msg.error) {
                this.setStatus('Failure at step 5/5', 'crash');
                ops.addToast('error', 'Error - ' + msg.error, '<i class="far fa-bug"></i> An issue arose analysing the results.<br/>' + msg.msg, 'bg-warning');
            } else {
                this.setStatus('All tasks complete', 'done');
                this.energetical_gnomAD = msg.gnomAD_ddG;
                //refill
                this.createLocation();
                this.activate_data_gnomad();
            }
        });
    }

    //step x
    analyse_target(mutation, algorithm) {
        // if (this.busy === true) {
        //     window.ops.addToast('busy', 'Please be patient', 'To prevent overuse, only one at the time', 'bg-warning');
        //     return null;
        // }
        this.setStatus(`Running extra job ${mutation}`, 'working');
        return $.post({
            url: "venus_analyse", data: {
                uniprot: uniprotValue,
                species: taxidValue,
                step: 'extra',
                mutation: this.mutation, //the data is stored serverside for an hour. and this is one part of the hash.
                extra: mutation,
                algorithm: algorithm
            }
        }).fail(ops.addErrorToast).done(msg => {
            if (msg.error) {
                this.setStatus('Failure at extra job', 'crash');
                ops.addToast('error', 'Error - ' + msg.error, '<i class="far fa-bug"></i> An issue arose analysing the results.<br/>' + msg.msg, 'bg-warning');
            } else {
                this.setStatus('All tasks complete', 'done');
                myData.proteins.push({ name: mutation,
                                      type: "data",
                                      value: msg.coordinates,
                                      ext: 'pdb',
                                      chain: 'A',
                                      chain_definitions:this.structural.chain_definitions,
                                      history: {code: this.structural.history.code,
                                                changes: algorithm+' '+msg.ddg
                                                }
                                    });
                ops.addToast(mutation, 'Extra analysis complete', `${mutation} has a ddG of ${parseInt(msg.ddg)} kcal/mol (calculated via local ${algorithm})`, 'bg-success');
                this.updateStructureOption();
            }
        });
    }

    //step phospho
    phosphorylate() {
        $('#phosphorylate-btn').attr('disabled','disabled');
        this.setStatus(`Running extra job post-translation modifications`, 'working');
        return this.analyse('phosphorylate').done(msg => {
            if (msg.error) {
                this.setStatus('Failure at step PTMs', 'crash');
                ops.addToast('error', 'Error - ' + msg.error, '<i class="far fa-bug"></i> An issue arose analysing the results.<br/>' + msg.msg, 'bg-warning');
            } else {
                this.setStatus('All tasks complete', 'done');
                this.energetical.phospho = msg.coordinates;
                myData.proteins.push({ name: "phosphorylated",
                                      type: "data",
                                      value: msg.coordinates,
                                      ext: 'pdb',
                                      chain: 'A',
                                      chain_definitions:this.structural.chain_definitions,
                                      history: {code: this.structural.history.code,
                                                changes: 'phosphorylated'
                                                }
                                    });
                //refill
                this.updateStructureOption();
            }
        });
    }

    //step fallback
    fallbackAnalyse() {
        //viewport
        let strloctext = '<p>No structure available: you may want to create your own protein model (see <a href="/docs/gene#modelling" target="_blank">documentation</a>)</p>';
        this.createEntry('strcha', 'Structural character', strloctext);
        $('#structureOption').append('<li>No structures available</li>');


    }

    //progress bar.
    setStatus(label, mode) { //working, crash, done
        const s = $('#results_status');
        switch(mode) {
          case 'working':
            s.html(`<div class="alert alert-warning w-100"><i class="far fa-dna fa-spin"></i> ${label}</div>`);
            break;
          case 'crash':
            s.html(`<div class="alert alert-danger w-100"><i class="far fa-skull-crossbones"></i> ${label}</div>`);
            break;
        case 'done':
            s.html(`<div class="alert alert-success w-100"><i class="fas fa-check"></i> ${label}</div>`);
            setTimeout(() => s.hide(), this.animation_speed);
            break;
          default:
            s.html(label);
        }
    }

    //###################  Entry
    //an 'entry' is a flush li within the card (within these there may be li).
    createEntry(id, title, text) { //adds or creates the entry.
        const el = $('#'+id);
        const n = this.entry_order.indexOf(id);
        // add entry appropriately
        const entry = $(this.makeEntry(id, title, text));
        entry.hide(0);
        if (el.length === 1) {
            //refresh case.
            el.parents('li').addClass('text-muted').addClass('bg-light');
            el.html(text); //title will be ignored.
            setTimeout(() => el.parents('li').removeClass('text-muted').removeClass('bg-light'), this.animation_speed);
        } else if (this.documentation[id] === undefined) {
            this.mutalist.append(entry);
            entry.show(this.animation_speed);
        } else if (n === -1) {
            this.mutalist.append(entry) //non standard entry
            entry.show(this.animation_speed);
        } else if (n === 0) {
            this.mutalist.prepend(entry) //first entry
            entry.show(this.animation_speed);
        } else {
                const prev = this.entry_order.map((k,i) => [k,i])
                                 .filter(([k,i]) => ($('#'+k).length === 1) && (i < n));
                if (prev.length === 0) {this.mutalist.append(entry); entry.show(this.animation_speed);}
                else {$("#"+prev.reverse()[0][0]).parents('li').after(entry); entry.show(this.animation_speed);}

        }

        //activate parts.
        //the DOM changes need to take effect.
        setTimeout(([venus, id]) => { //venus = this of this class
            const parent = $('#'+id).parents('li');
            const pros = parent.find('.prolink');
            pros.protein();
            pros.click(event => venus.showMutant.call(venus) );
            parent.find('.venus-entry-up').click(event => venus.moveEntry.call(venus, id, 'up'));
            parent.find('.venus-entry-down').click(event => venus.moveEntry.call(venus, id, 'down'));
            parent.find('.venus-entry-kill').click(event => venus.killEntry.call(venus, id));
            parent.find('[data-toggle="tooltip"]').tooltip();
        }, 100, [this, id]);

    }

    moveEntry(id, direction) {
        console.log('move!!');
        // documentation also determines the order.
        const n = this.entry_order.indexOf(id);
        if (n === -1) return null; //silent error.
        let offset = direction === 'up' ? -1 : 1;
        console.log(offset);
        let d = this.entry_order.splice(n, 1)[0];
        console.log(id);
        console.log(d);
        console.log(n);
        this.entry_order.splice(n + offset, 0, d);
        // get the existing element, break it up, destroy it and remake it.
        const el = $('#'+id);
        const text = el.html();
        const title = el.parent().find('span').eq(0).html();
        const li = el.parents('li');
        li.hide(this.animation_speed);
        setTimeout(() => {li.detach();
                                 this.createEntry(id, title, text);}, this.animation_speed);
        if (id === 'location') this.activate_data_gnomad();
        }

    killEntry(id) {
        console.log('die!!');
        const el = $('#'+id).parents('li').hide(this.animation_speed);
        setTimeout(()=> el.detach(), this.animation_speed);
    }

    //###################  sprintf
    //make methods output text
    makeEntry(id, title, text) {
        if (this.documentation[id] !== undefined) {
            //pass
        }
        else if (title.includes('<i class="far fa-question-circle"></i></span>')) {
            //pass
        }
        else {
            title +=' <i class="far fa-question-circle"></i></span>';
        }
        const tt = (this.documentation[id] !== undefined) ? `data-toggle="tooltip" title="${this.documentation[id]}"` : '';
        return `<li class="list-group-item">
                    <div class="row">
                        <div class="col-12 col-md-3">
                        <div class="btn-group mb-3 d-flex justify-content-center venus-no-mike" role="group" aria-label="Basic example">
                          <button type="button" class="btn btn-sm btn-outline-secondary venus-entry-up"><i class="far fa-caret-up"></i></button>
                          <button type="button" class="btn btn-sm btn-outline-secondary venus-entry-down"><i class="far fa-caret-down"></i></button>
                          <button type="button" class="btn btn-sm btn-outline-secondary venus-entry-kill"><i class="far fa-times"></i></button>
                        </div>
                            <span class="font-weight-bold text-right align-middle" ${tt}>
                            ${title}
                             </span>
                        </div>
                        <div class="col-12 col-md-9 text-left border-left" id="${id}">
                            ${text}
                        </div>
                    </div>
                </li>`
    }

    makeProlink(v, label) {
        // near static method. this.prolink
        // v string and label exists.
        // v is array of gnomad
        // v is dictionary
        if (typeof v === "string") {
            return `<span ${this.prolink} data-color="cyan" data-focus="residue" data-selection="${v}">${label}</span>`;
        }
        else if (Array.isArray(v)) {
            //gnomad
            //["gnomAD_101_101_rs1131691997",101,101,"MODERATE","K101R (rs1131691997)",0]
            let p = v[4];
            if (parseInt(v[1]) === this.position) p = '<b>'+p+'</b>';
            return `<span  ${this.prolink} data-focus="residue" data-color="cyan" data-selection="${v[1]}:A">${p}</span>`;
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
            return `<span  ${this.prolink} data-color="${dc}"  data-focus="${df}" data-selection="${ds}">${p}</span>`;
            }
        else {
            console.log('ERRRROR'+JSON.stringify(v));
        }
        }

    makeExt(url, txt) {
        //sprintf an external link
        return `<a href="${url}" target="_blank">${txt} <i class="far fa-external-link-square"></i></a>`}

    //###################  other
    createLocation() {
        //Features
        let locationtext = `<p>The mutation is ${this.mutational.position_as_protein_percent}% along the protein.</p>`;
        const effectSplit = v => {
            if (! this.energetical_gnomAD) {return ''}
            else {
                let gnomads = Object.keys(this.energetical_gnomAD)
                                      .filter(g => { //which are within?
                                                    let i = parseInt(g.match(/\d+/)[0]);
                                                    return v.x <= i && v.y >= i;
                                                    });
                let effect = gnomads.map(g => this.energetical_gnomAD[g])
                                    .reduce((acc,gs,i) => {
                                          if (gs > 2) {acc.destabilising++}
                                          else if (gs < -2) {acc.stabilising++}
                                          else {acc.neutral++}
                                          return acc;
                                      }, {destabilising: 0, neutral: 0, stabilising: 0});
                if (Object.values(effect).reduce((a,v) => a+v, 0) === 0) return '';
                let variants = gnomads.map(g => `${g} (≈${parseInt(this.energetical_gnomAD[g])} kcal/mol)`).join(', ');
                return ` <span class="underlined venus-plain-mike" style="cursor: pointer;"
                                data-toggle="tooltip" title="${variants}"
                                data-gnomad='${JSON.stringify(gnomads)}'
                                >(`+Object.entries(effect)
                                  .filter(([k,v]) => v !== 0)
                                  .map(([k,v]) => `${k}: ${v}`).join(', ')
                           +')</span>';
            }};

        const locTxter = v => `<li>${this.makeProlink(v)}:
                                ${v.type} (${v.description}),
                                <br/>
                                <i>gnomAD missenses</i>: ${v.gnomad.missense || 0}${effectSplit(v)},<br/>
                                <i>gnomAD nonsenses</i>: ${v.gnomad.nonsenses || 0}.</li>`;
        if (this.mutational.features_at_mutation.length) {
            locationtext += '<span>Encompassing features:</span>';
            locationtext += '<ul>';
            locationtext += this.mutational.features_at_mutation.map(locTxter).join('');
            locationtext += '</ul>';
        }
        const atIdx = this.mutational.features_at_mutation.map(({id}) => id);
        const otherFeats = this.mutational.features_near_mutation.filter(v => atIdx.indexOf(v.id) === -1);
        if (otherFeats.length) {
            locationtext += '<br/><span>Nearby features:</span>';
            locationtext += '<ul>';
            locationtext += otherFeats.map(locTxter).join('');
            locationtext += '</ul>';
        }
        this.createEntry('location', 'Location', locationtext);
    }

    activate_data_gnomad() { //called by step 5.
                const dg = $('[data-gnomad]');
                dg.off('click'); //Unsure when this would occur.
                dg.click(event => {
                    $('#gnomad_extra').modal('show');
                    const el = $(event.target);
                    let content = '<p>Mutations within feature present in the healthy population (gnomAD). Note that the free energy calculations are very crude for expediency (local repacking only).</p>';
                    content += '<ul class="fa-ul">';
                    const addLi = mutation => {
                        let detail = this.get_gnomAD_details(mutation);
                        //deal with homozygous icon.
                        let icon = detail.homozygous === 0 ? 'far fa-adjust' : 'fas fa-circle';
                        let hom = `${detail.homozygous} homozygous cases`;
                        return `<li><span class="fa-li" data-toggle="tooltip" title="${hom}">
                                    <i class="far ${icon}"></i></span>
                                    ${detail.description} (≈${parseInt(this.energetical_gnomAD[mutation])} kcal/mol)
                                    <br/>
                                    <div class="btn-group small" role="group" aria-label="Basic example">
                                      <button type="button" class="btn btn-outline-info"
                                                data-toggle="protein" data-selection="${detail.x}:A" data-focus="residue" data-title="${detail.description} (wild type shown)"
                                                >
                                      show wild type (${this.names[mutation[0]]})</button>
                                      <button type="button" class="btn btn-outline-info modal-hider"
                                      data-mutation="${mutation}" data-algorithm="repack">
                                      show variant (${this.names[mutation.slice(-1)]}) (fast prediction)
                                      </button>
                                      <button type="button" class="btn btn-outline-info modal-hider"
                                      data-mutation="${mutation}" data-algorithm="relax">show variant (${this.names[mutation.slice(-1)]}) (accurate prediction)</button>
                                    </div>
                                </li>`;
                    };
                    content += el.data('gnomad').map(v => addLi(v)).join('');
                    content +='</ul>';
                    $('#gnomad_extra .modal-body').html(content);
                    const pros =$('#gnomad_extra [data-toggle="protein"]');
                    pros.each((i,e) => $(e).protein());
                    pros.click(event => $('#gnomad_extra').modal('hide'));
                    $('#gnomad_extra .modal-hider').click(event => {
                                $('#gnomad_extra').modal('hide');
                                const mutation = $(event.target).data('mutation');
                                const algorithm =  $(event.target).data('algorithm');
                                window.ops.addToast('calculatin'+mutation, 'Prediction in progress', 'The model requested will appear below the structural viewport when available', 'bg-info');
                                this.analyse_target(mutation, algorithm);
                    });

                });
    }

    showMutant() {
        if (this.alwaysShowMutant) {
            console.log(venus.alwaysShowMutant, this.alwaysShowMutant);
            const showMut = (sele) => {
                const prot = NGL.getStage().getComponentByType('structure');
                if (prot !== undefined) prot.addRepresentation("hyperball", sele);
            };
            setTimeout((sele) => showMut(sele), 100, {sele: this.position + ':A', color: this.mutaColor});
        }
    }

    get_gnomAD_details (mutation) {
        // mutation is str "A23Q" returns { id: "gnomAD_114_114_rs1163968308", x: 114, y: 114, impact: "MODERATE", description: "V114L (rs1163968308)", homozygous: 0 }
        //Oh dear. Python Variant object (gnomad) is saved as string.
        return Object.fromEntries(this.protein.gnomAD.filter(v => v.includes(mutation))[0]
                                                    .replace(/Variant\((.*)\)/,'$1')
                                                    .replace(/\'/g,'')
                                                    .split(',')
                                                    .map(v => v.split('='))
                                                    .map(([k,v]) => [k.trim(), isNaN(parseInt(v)) ? v : parseInt(v)])
                                        );
    }

    loadStructure () {
        NGL.specialOps.multiLoader('viewport', [{ name: "wt",
                                                              type: "data",
                                                              value: this.structural.coordinates,
                                                              ext: 'pdb',
                                                              chain: 'A',
                                                              chain_definitions:this.structural.chain_definitions,
                                                              history: this.structural.history}])
                        .then(protein => NGL.specialOps.showResidue('viewport', this.position+':A'));
        UniprotFV.enpower();
        this.updateStructureOption();
        let strloctext = '<p><i>Chosen model:</i> ';
        if (this.structural.code.length === 4) {
            strloctext += this.makeExt("https://www.rcsb.org/structure/"+this.structural.code, 'PDB:'+this.structural.code)+'</p>';
        } else {
            strloctext += this.makeExt("https://swissmodel.expasy.org/repository/uniprot/"+window.uniprotValue, 'SWISSMODEL:'+this.structural.code)+'</p>';
        }
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
        // structural character
        this.createEntry('strcha', 'Structural character', strloctext);
        let omni = this.makeProlink(this.structural.neighbours.map(v => v.resi+':A').join(' or '), '(all)');
        let strtext = `<p>Structural neighbourhood ${omni}.</p>`;
        strtext += '<ul>'+this.structural.neighbours.map(v => `<li>${this.makeProlink(v.resi+":"+v.chain, v.resn+v.resi)} ${v.detail}</li>`).join('')+'</ul>';
        this.createEntry('neigh','Structural neighbourhood', strtext);
    }

    updateStructureOption() {
        if (window.myData === undefined) return 0;
        const so = $('#structureOption');
        so.html('');
        myData.proteins.map(({name}) => so.append(`<li><span ${this.prolink} data-load="${name}">${name}</span></li>`));
        // special case: mutant structure
        $('#structureOption [data-load="mutant"]').attr('data-focus','clash')
                                                  .attr('data-selection', this.position);
        // special case: PTMs
        $('#structureOption [data-load="phosphorylated"]').attr('data-focus','residue')
                                                          .attr('data-selection','SEP or TPO or PTR or ALY or NMM or DA2 or MLZ')
                                                          .attr('data-radius', 1.5);
        // special cases: custom mutations.
        window.myData.proteins.map(({name}) => name)
                              .filter(name => name.match(/\w\d+\w/))
                              .forEach(name => $(`#structureOption [data-load="${name}"]`)
                                                                .attr('data-focus', 'clash')
                                                                .attr('data-selection', name.slice(1,-1)+':A')
                                );
        if (window.myData.proteins.filter(({name}) => name === 'mutant').length === 1) {
            so.append(`<li><span ${this.prolink} data-load="wt" data-focus="overlay mutant" data-selection="${this.position}:A">Overlay of wild-type and mutant</span></li>`);
        }
        so.find('.prolink').each((i,e) => $(e).protein());
        if (this.energetical && window.myData.proteins.filter(({name}) => name === 'phosphorylated').length === 0) {
            so.append('<li><button id="phosphorylate-btn" type="button" class="btn btn-outline-secondary btn-sm" onclick="venus.phosphorylate.call(venus)">Make phosphorylated model</button></li>');
        }
    }

    createPage () {
        //Make a Michelanglo page
        let results = $('#results_mutalist').clone();
        results.find('.venus-no-mike').detach();
        results.find('.venus-plain-mike').each((i, el) => $(el).html(`<span>${$(el).text()}</span>`));
        results.find('#results_mutalist').append(`<li class="list-group-item">${$('#structureOption').html()}</li>`);

        let text = results.html();
        let data = {uniprot: window.uniprotValue, //same as this.protein.uniprot,
                    species: window.taxidValue,
                    mutation: this.mutation,
                    text: text,
                    code: this.structural.code,
                    definitions: JSON.stringify(this.structural.chain_definitions),
                    history: JSON.stringify(this.structural.history)};
        if (this.energetical === undefined) {
            data.block = this.structural.coordinates;
        } else {
            data.wt_block = this.energetical.native;
            data.mut_block = this.energetical.mutant;
        }
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


/////////////////// DOM elements ////////////////////////////////////////////////////

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
vbtn.click(e => {
    venus.reset.call(venus);
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
    venus.analyseProtein();
});

$('#new_analysis').click(e => venus.reset.call(venus));

// const alert = text => `<div class="alert alert-danger"><b>To do</b> ${text}</div>`;
//
// $('#results_mutalist').parent().append([//alert('rewire NGL viewport following screen'),
//                               //alert('pipe structure to PDB offset fix.'),
//                               //alert('structural route.'),
//                               //alert('autoload the sequence chosen by Analyser.get_best_model'),
//                               alert('URGENT!!! write documentation you idiot!'),
//                               alert('add collapsed sequence viewer'),
//                               alert('add rudimentary scoring metric to bump up entries'),
//                               alert('deal with truncations'),
//                               alert('b factor and disorder'),
//                               alert('improve useless structurally class'),
//                               alert('Mike exporter --make selective'),
//                               alert('Fix load of swissmodel. ?! Why did this fix itself??'),
//                               alert('cp the code for the domains from table ---what does this mean?'),
//                              ]);

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

$('#showMutant').click(event => {
    venus.alwaysShowMutant = $(event.target).prop('checked');
    }
);

//</%text>