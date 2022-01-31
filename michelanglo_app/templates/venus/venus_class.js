//<%text>
// venus main.mako imports uniprot_modal.js 's UniprotFV.
// .venus-no-mike css classes do not get ported to Michelanglo
// .venus-plain-mike css classes is ported as text to Michelanglo

class Venus {
    constructor() {
        this.prepareDOM();
        this.timeout = 60 * 5 * 1000 - 100; // Apache is also set to 5 minutes.
        this.uniprot = window.uniprotValue; // name.js code.
        this.taxid = window.taxidValue;
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
        this.subpopulations = {
            "afr": "African/African American",
            "ami": "Amish", "amr": "Latino/Admixed American",
            "asj": "Ashkenazi Jewish",
            "eas": "East Asian",
            "fin": "European (Finnish)",
            "mid": "Middle Eastern",
            "nfe": "European (non-Finnish)",
            "sas": "South Asian",
            "oth": "Other"
        };
        this.mutalist = $('#results_mutalist');
        // these will be declared later. these here are for self clarity
        this.job_id = undefined;
        this.mutation = undefined;
        this.position = undefined;
        this.protein = undefined;
        this.mutational = undefined;
        this.structural = undefined;
        this.energetical = undefined;
        this.energetical_gnomAD = undefined;
        this.alwaysShowLigands = false;
        this.alwaysShowMutant = $('#showMutant').prop('checked'); //remembered from browser weird habit.
        this.mutaColor = NGL.ColormakerRegistry.addSelectionScheme([['hotpink', '_C'], ["blue", '_N'], ["red", '_O'], ["white", '_H'], ["yellow", '_S'], ["orange", "*"]]);
        this.documentation = {
            //'conclusion': 'Key features that may be of interest', merged into 'indestr'
            'mut': 'Residue identity, note that because a difference in shape is present it does not mean that the structure cannot accommodate the change',
            //'indestr': 'This is a purely based on the nature of the amino acids without taking into account the position. Despite this, it is a strong predictor.',
            'effect': 'Summary of effect',
            'strcha': 'Model based residue details',
            'ddg': 'Forcefield calculations. A negative value is stabilising, and a value >2 kcal/mol is destabilising. A hydrogen bond has about 1-2 kcal/mol. See documentation for details.',
            'neigh': 'Displays residues within 10 &aring;ngstr&ouml; of the mutation, as determined from the model',
            'location': 'What domains are nearby linearly &mdash;but not necessarily containing the residue',
            'domdet': 'what is this?',
            'gnomad': 'gnomAD mutations with 5 residues distance (structure independent)',
            'motif': 'Motifs predicted using the linear motif patterns from the ELM database. The presence of a linear motif does not mean it is valid, in fact the secondary structure is important: in a helix residues 3 along are facing the same direction, in a sheet alternating residues and in a loop it varies. If a motif is a phosphosite and the residue is not phosphorylated it is likely not legitimate.',
            'link': 'Link to this search (will be redone) for browser or programmatic access',
            'extlink': 'Links to external resources related to this gene',
            'references': 'VENUS relies a several sources of external data, so be sure to cite them!'
        };
        this.StatusModeIcons = {
            'working': "far fa-dna fa-spin",
            'crash': "far fa-skull-crossbones",
            'halt': "far fa-skull-crossbones",
            'done': "fas fa-check"
        };

        this.StatusModeColors = {
            'working': "bg-warning",
            'crash': "bg-danger",
            'halt': "bg-info",
            'done': "bg-success"
        };
        this.stepNames = ['Retrieval of protein info',
            'Assessment of mutation without structure',
            'Picking and tweaking best model',
            '&Delta;&Delta;G calculation',
            'Quick gnomAD scoring'];
        this.entry_order = Object.keys(this.documentation); //order is changed dynamically.
        this.animation_speed = 1000;
        this.seq = undefined;
        this.last_clicked_prolink = '';
        this.shown_warnings = [];
        this.timeTaken = null;
        this.debug = window.venusDebug;
        if (this.debug) {
            NGL.setDebug(true);
        }
    }

    reset() {
        this.protein = undefined;
        this.mutation = undefined;
        this.structural = undefined;
        this.position = undefined;
        this.energetical = undefined;
        this.energetical_gnomAD = undefined;
        this.seq = undefined;
        this.prepareDOM();
        this.shown_warnings = [];
        this.timeTaken = null;
        this.job_id = undefined;
    }

    prepareDOM() {
        delete window.myData;
        $('#model_id').innerHTML = 'N/A';
        if (window.myData !== undefined) {
            delete window.myData;
            NGL.getStage().removeAllComponents();
        }
        $('#viewport').children().filter((i, elem) => elem.nodeName !== 'BUTTON').detach();
        NGL.stageIds.viewport = undefined;
        this.updateStructureOption();
        if (this.mutalist !== undefined) this.mutalist.html('');
        $('#results_mutalist').children().detach();
        $('#results').hide();
        $('#venus_calc').removeAttr('disabled');
        $('#toaster').prepend(`
                                <div class="toast ml-auto w-100 bg-warning show" 
                                   role="alert" aria-live="assertive" aria-atomic="true"  id="results_status">
                                  <div class="toast-header">
                                    <strong class="mr-auto">Progress</strong>
                                    <button type="button" class="ml-2 mb-1 close" data-dismiss="toast" aria-label="Close">
                                      <span aria-hidden="true">&times;</span>
                                    </button>
                                  </div>
                                  <div class="toast-body">
                                    Error.
                                  </div>
                                </div>`);
        $('#results_status').show();
        $('#result_title').html('<i class="far fa-dna fa-spin"></i> Loading');
        $('toast-body').html('ERROR');
        $('#fv').html('');
        $('#changeByPage_selector').html('<option name="changeByPage" value="0" selected>Select page first</option>');
        $('#changeByPage_selector').attr('disabled', 'disabled');
        $('#alignment_extra .modal-body').children().detach();
    }

    //###################  Steps
    //sends ajax request. Some do not use this. analyse_target for example.
    // job_id === undefined means that job_id is not sent, so all good.
    analyse(step, extras) {
        let data = {
            uniprot: this.uniprot,
            species: this.taxid,
            step: step,
            mutation: this.mutation,
            debug: this.debug,
            job_id: this.job_id,
        };
        extras = extras || this.get_user_settings();
        // chrome autofills usernames and passwords or 9606
        if ((this.uniprot + '' === '9606') ||
            (this.mutation + '' === '9606') ||
            (this.uniprot.search(/\d/) === -1) ||
            (this.mutation.search(/\d/) === -1)
        ) {
            throw 'chrome autofill prevented.'
        }
        for (const [key, value] of Object.entries(extras)) {
            // no sanitisation ATM
            data[key] = value;
        }
        return $.post({
            url: "venus_analyse",
            data: data,
            timeout: this.timeout
        }).fail((error, text) => {
            if (text !== 'timeout') {
                ops.addErrorToast(error);
                this.setStatus(`Error: ${error.message}`, 'crash');
            } else {
                // polling
                ops.addToast('polling',
                    'Slow task',
                    'The task is taking longer than expected (possibly large protein?)',
                    'bg-warning');
                return this.analyse(step, extras);
            }

        }).then(reply => {
            this.timeTaken = reply.time_taken;
            return reply
        });
    }

    //step 0
    isValidMutation() {
        //check the mutation is valid client side
        //this is a copy paste of the fun from pdb_staging_insert.js
        const aa = {
            'CYS': 'C', 'ASP': 'D', 'SER': 'S', 'GLN': 'Q', 'LYS': 'K',
            'ILE': 'I', 'PRO': 'P', 'THR': 'T', 'PHE': 'F', 'ASN': 'N',
            'GLY': 'G', 'HIS': 'H', 'LEU': 'L', 'ARG': 'R', 'TRP': 'W',
            'ALA': 'A', 'VAL': 'V', 'GLU': 'E', 'TYR': 'Y', 'MET': 'M'
        };
        let parts = this.mutation.trim().match(/^(\D{1,3})(\d+)(\D{1,3})$/);
        if (parts === null) return false; //Not a typo: a failed match returns null not undefined.
        // parts 0: full match, 1:from 2:index 3:to
        if (parts[3] === '=') {
            parts[3] = parts[1];
        }
        // deal with identity
        // deal with three letter code.
        if (aa[parts[1]] !== undefined) {
            parts[1] = aa[parts[1]]
        }
        if (!'ACDEFGHIKLMNPQRSTVWYX'.includes(parts[1])) return false;
        if (aa[parts[3]] !== undefined) {
            parts[3] = aa[parts[3]]
        }
        if (!'ACDEFGHIKLMNPQRSTVWYX'.includes(parts[1])) return false;
        // it's good
        this.mutation = parts.splice(1, 3).join('');
        return true;
    }

    //step 1
    analyseProtein() {
        //step one
        // Check mutations are valid for the protein. In Python ``protein.check_mutation()``
        this.mutation = $('#mutation').val().replace('p.', '').toUpperCase();
        this.position = parseInt(this.mutation.match(/\d+/)[0]);
        if (this.isValidMutation() === false) {
            ops.addToast('dodgymutant', '<i class="far fa-alien-monster"></i> Invalid mutation format',
                'VENUS analyses missense mutations only. One mutation at the time. The mutation needs to be in the format A123E or Ala123Glu, with or without "p." prefix. Case insensitive.', 'bg-warning');
            $('#venus_calc').removeAttr('disabled');
            return 0;
        }
        this.setStepStatus(1);
        return this.analyse('protein')
            .fail(xhr => {
                this.setStepStatus(1, 'crash');
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
                    this.createLinks();
                    this.job_id = msg.job_id;

                    //this.analyse('fv') is the same as get_uniprot but utilising the protein data.
                    $('#results').show(500, () => this.analyse('fv').done(msg => {
                        eval(msg);
                        d3.selectAll('.axis text').style("font-size", "0.6em");
                        //new MutantLocation(this.position);
                        ft.addMutation(this.position);
                    }));
                    $('html, body').animate({scrollTop: $('#results').offset().top}, 2000);
                    $('#result_title').html(`${this.protein.gene_name} ${this.protein._mutation} <small>(${this.protein.recommended_name})</small>`);
                    let extElements = [this.makeBSListExt('https://www.uniprot.org/uniprot/' + this.uniprot, 'Uniprot:' + this.uniprot),
                        this.makeBSListExt('https://www.rcsb.org/uniprot/' + this.uniprot, 'PDB:' + this.uniprot),
                        this.makeBSListExt('https://alphafold.ebi.ac.uk/entry/' + this.uniprot, 'EBI-AlphaFold2:' + this.uniprot),
                        this.makeBSListExt('https://gnomAD.broadinstitute.org/gene/' + this.protein.gene_name, 'gnomAD:' + this.protein.gene_name),
                        this.makeBSListExt('https://www.phosphosite.org/homeAction.action', 'PhosphositePlus'),
                        this.makeBSListExt('http://elm.eu.org/index.html', 'ELM'),
                        this.makeBSListExt('https://consurfdb.tau.ac.il/', 'ConsurfDB')];
                    const exttext = '<div class="list-group list-group-flush">' + extElements.join('') + '</div>';
                    this.createEntry('extlink', 'External links', exttext);
                    let reftext = '<a href="#referenceModal" class="text-info" data-toggle="modal" data-target="#referenceModal">See suggested papers</a>';
                    this.createEntry('references', 'References', reftext);
                    // alter uniprot links in page (e.g. modals)
                    $('.uniprotLink').attr('href', 'https://www.uniprot.org/uniprot/' + this.uniprot);
                }
            });

    }

    //step 2
    analyseMutation() {
        //step 2
        // what is the structure independent effect?
        // Runs ``protein.predict_effect()`` in Python.
        this.setStepStatus(1);
        return this.analyse('mutation').done(msg => {
            if (msg.error) {
                this.setStepStatus(2, 'crash');
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
                                            <div class="col-6"><img src="/static/aa/${this.mutational.from_residue}${this.mutational.to_residue}.svg" width="100%" alt="change">
                                            <p>Differing atoms in  ${this.names[this.mutational.from_residue]} highlighted in red</p></div>
                                            <div class="col-6"><img src="/static/aa/${this.mutational.to_residue}${this.mutational.from_residue}.svg" width="100%" alt="change">
                                            <p>Differing atoms in  ${this.names[this.mutational.to_residue]} highlighted in red</p></div>
                                        </div>`;
                this.createEntry('mut', 'Mutation', mutationtext);

                //structural card
                this.createLocation();
                //this.createEntry('domdet', 'Domain detail', 'To Do figure out how to mine what the domain does. See notes "domain_function".');

                //gnomAD... This is redudant and less good than the structural one...
                if (this.mutational.gnomAD_near_mutation.length) {
                    let omni = this.makeProlink(this.mutational.gnomAD_near_mutation.map(v => v[1] + ':A').join(' or '), '(all)');
                    let gnomADtext = `<p>Structure independent, sequence proximity (see structural neighbour for 3D, when it completes) ${omni}.</p>`;
                    gnomADtext += '<ul>';
                    const gMut = (v) => v[3].toUpperCase().split(' ')[0];
                    gnomADtext += this.mutational.gnomAD_near_mutation
                        .map(v => {
                            let element = '<li>';
                            element += `${this.makeProlink(v, gMut(v))}: `;
                            element += `${v[3]}`;
                            if (v[11] === 'missense_variant') {
                                element += `<i class="far fa-calculator venus-no-mike" data-variant='${JSON.stringify([gMut(v)])}' style="cursor: pointer;"></i>`;
                            }
                            element += '</li>'
                            return element
                        }).join('');
                    gnomADtext += '</ul>';
                    this.createEntry('gnomad', 'gnomAD', gnomADtext);
                }

                if (this.mutational.elm.length) {
                    let elmtext = `<p>Some of the following predicted motifs might be valid (see ${this.makeExt('http://elm.eu.org/', 'ELM for more')}):</p>`;
                    elmtext += '<ul>';
                    // converts a regex str to a sele str.
                    const reg2sele = (regex, offset) => regex.replace('$', '')
                        .replace(')', '')
                        .replace('(', '')
                        .replace('^', '')
                        .replace(/\[.*?\]/g, 'X')
                        .replace(/\{(\d?)\,(\d?)}/, (match, p1, p2, offset, string) => 'X'.repeat(parseInt(p1))) //will need fixing...
                        .split('')
                        .map((v, i) => (v !== '.') ? i + offset : null)
                        .filter(v => v !== null).map(v => v + ':A')
                        .join(' or ');
                    elmtext += this.mutational.elm.map(v => `<li>${this.makeProlink(reg2sele(v.regex, v.x), `Residues ${v.x}&ndash;${v.y}`)}: <span data-target="tooltip" title="${v.description}">${v.name} ${v.status} (${v.regex})</li>`).join('');
                    elmtext += '</ul>';
                    this.createEntry('motif', 'Motif', elmtext);
                }
                // Sequence
                this.addSequence();
                // apriori for now.
                this.concludeMutational();
            }
        })
    }

    get_user_settings() {
        let extras = {
            'scorefxn_name': $('#scorefxn_name').val(),
            'custom_filename': upload_pdb.files.length > 0 ? upload_pdb.files[0].name : undefined
        };
        ['allow_pdb', 'allow_swiss', 'allow_alphafold', 'outer_constrained', 'remove_ligands', 'single_chain'].forEach(name => {
            extras[name] = $('#' + name).prop('checked');
        });
        ['swiss_oligomer_identity_cutoff',
            'swiss_monomer_identity_cutoff',
            'swiss_oligomer_qmean_cutoff',
            'swiss_monomer_qmean_cutoff',
            'radius',
            'cycles'].forEach(name => {
            extras[name] = parseFloat($('#' + name).val())
        });
        return extras;
    }

    //step 3
    analyseStructural() {
        //step 3
        // see parseStructuralResponse for main.
        this.setStepStatus(3);
        if (window.user_uploaded_data === undefined) {
            // normal. File not provided.
            return this.analyse('structural').done(msg => this.parseStructuralResponse.call(this, msg));
        } else {
            return this.analyseCustomFile().done(msg => this.parseStructuralResponse.call(this, msg));
        }
    }

    parseStructuralResponse(msg) {
        if (msg.has_structure === false) {
            $('#modalStructureless').modal('show');
            this.setStatus('No structure.', 'halt');
            this.fallbackAnalyse();
            this.concludeMutational();
        } else if (msg.error) {
            this.setStepStatus(3, 'crash');
            ops.addToast('error', 'Error - ' + msg.error, '<i class="far fa-bug"></i> An issue arose analysing the results.<br/>' + msg.msg, 'bg-warning');
            this.fallbackAnalyse();
            this.concludeMutational();
        } else {
            this.structural = msg.structural;
            this.structural.custom_ddG = {};
            this.showWarnings(msg.warnings);
            this.analyseddG();
            if (!!this.structural.coordinates.length) this.loadStructure();
            this.concludeMutational();
        }
        // activate all prolinks
        // const pros = $('#results_mutalist .prolink');
        // pros.protein();
        // pros.click(event => this.showMutant.call(this) );
        // hack them to always show the mutants.
    }

    showWarnings(warnings) {
        warnings.forEach(msg => {
            if (!this.shown_warnings.includes(msg)) {
                ops.addToast('Warning', 'Unable to use structure', msg, 'bg-warning');
                this.shown_warnings.push(msg);
            }
        });
    }

    //step 4
    analyseddG() {
        //step 4
        this.setStepStatus(4);
        return this.analyse('ddG').done(msg => {
            if (msg.error) {
                this.setStepStatus(4, 'crash');
                ops.addToast('error', 'Error - ' + msg.error, '<i class="far fa-bug"></i> An issue arose analysing the results.<br/>' + msg.msg, 'bg-warning');
            } else {
                this.analyseddG_gnomad();
                this.energetical = msg.ddG;
                //this.loadStructure();
                const units = '<span title="Technically REU, Rosetta Energy Units, which are approximately the same as kcal/mol when using the ref2015 force-field score function">kcal/mol</span> ';
                let ddgnote = 'impossible';
                let ddgverdict = 'impossible';
                let ddgtext = '<i>Predicted effect: </i>';
                const cutoff = 2;
                if (this.energetical.ddG < -cutoff) {
                    ddgnote = 'A variant may be structurally stabilising, but phenotypically deleterious.';
                    ddgverdict = 'stabilising';
                } else if (this.energetical.ddG > +cutoff) {
                    ddgnote = 'A variant may be structurally destabilising, but phenotypically neutral.';
                    ddgverdict = 'destabilising';
                } else {
                    ddgnote = 'A variant may be structurally neutral, but phenotypically deleterious.';
                    ddgverdict = 'structurally neutral';
                }
                ddgtext += `<b>${ddgverdict}</b>`; // no more data-toggle="tooltip" title="${ddgnote}"
                ddgtext += `<div class="alert alert-warning alert-dismissible fade show" role="alert">
                              <strong>NB</strong> ${ddgnote}
                              <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                              </button>
                            </div>`
                const ddGLine = this.energetical.ddG < 10 ? Math.round(this.energetical.ddG) : '>10';
                ddgtext += `<i>Estimated &Delta;&Delta;G (with backbone movement allowed):</i> ${ddGLine} ${units} `;

                let shape = ['silent',
                    ...['smaller', 'bigger', 'differently shaped', 'equally sized']
                        .filter(v => venus.mutational.apriori_effect.includes(v))
                ].pop();
                // MAE from O2567
                const data = {
                    "buried": {
                        "bigger": {"MAE": 1.27, "MSE": -0.75, "SE": 0.12, "allocation": 0.69},
                        "differently shaped": {"MAE": 2.23, "MSE": -1.96, "SE": 0.36, "allocation": 0.53},
                        "equally sized": {"MAE": 1.27, "MSE": -1.27, "SE": 0.29, "allocation": 0.5},
                        "proline involved": {"MAE": 2.32, "MSE": 1.49, "SE": 0.48, "allocation": 0.67},
                        "smaller": {"MAE": 2.01, "MSE": -1.69, "SE": 0.09, "allocation": 0.48}
                    },
                    "surface": {
                        "bigger": {"MAE": 0.81, "MSE": 0.37, "SE": 0.02, "allocation": 0.84},
                        "differently shaped": {"MAE": 0.58, "MSE": 0.07, "SE": 0.02, "allocation": 0.86},
                        "equally sized": {"MAE": 0.71, "MSE": -0.14, "SE": 0.06, "allocation": 0.79},
                        "proline involved": {"MAE": 1.06, "MSE": 0.07, "SE": 0.08, "allocation": 0.79},
                        "smaller": {"MAE": 0.93, "MSE": -0.6, "SE": 0.02, "allocation": 0.7}
                    }
                };
                let cat_mae = 'N/A';
                let cat_mad = 'N/A';
                let cat_allocation = 'N/A';
                let buriedStr = ['surface', 'buried'][this.structural.buried + 0]; // coerce this.structural.buried to int
                if (shape !== 'silent') {
                    const subdata = data[buriedStr][shape];
                    cat_mae = subdata["MAE"];
                    cat_mad = subdata["SE"];
                    cat_allocation = subdata["allocation"];
                }
                ddgtext += '<br/>';
                ddgtext += `<i>Category of mutation:</i> ${shape}, ${this.structural.buried ? 'buried' : 'surface'}<br/>`;
                ddgtext += `<i><span title="Median Absolute Error calculated with the O2567 dataset, single chain, no ligand and radius = 12 Å, 2 cycle and ref2015 scorefunction. Median: 50% of cases will be off by more than this." data-toggle="tooltip">
                            median error for category:
                            </span></i> ${cat_mae} kcal/mol<br/>`;
                ddgtext += `<i><span title="concordant >2 kcal/mol in O2567 dataset" data-toggle="tooltip">Correct assignment for category</span></i>: ${cat_allocation * 100}%<br/>`;
                let bb = this.energetical.scores.mutate - this.energetical.scores.relaxed;
                const ddGline2 = bb < 10 ? Math.round(bb) : '>10 ';
                ddgtext += `<i>&Delta;&Delta;G (with backbone movement forbidden):</i> ${ddGline2}  ${units} `;
                ddgtext += '<br/>';
                if (this.energetical.scores.mutate + 3 > this.energetical.scores.mutarelax) {
                    ddgtext += `Results in backbone change (RMSD<sub>CA</sub>: ${Math.round(this.energetical.rmsd * 100) / 100})<br/>`;
                }
                ddgtext += '<button class="btn btn-outline-info venus-no-mike" data-toggle="modal" data-target="#ddG_extra"><i class="fas fa-search"></i> More details</button>';
                ddgtext += '<p>Additionally requested calculations:</p><ul id="extraDDGResults">';
                Object.entries(this.structural.custom_ddG)
                    .forEach(({mutation, data}) => {
                        const color = data > this.energetical.ddG ? 'text-warning' : 'text-secondary';
                        const ddGLine = data < 10 ? data.toFixed(1) : '>10';
                        ddgtext += `<li><b>${this.makeProlink(mutation.slice(1, -1), mutation)}</b>
                                        <span class="${color}">
                                        ${ddGLine} kcal/mol
                                        </span>
                                        </li>`
                    });
                ddgtext += `</ul>
                <div class="input-group mb-3">
                  <div class="input-group-prepend">
                    <span class="input-group-text">Calculate a custom mutation</span>
                  </div>
                  <input type="text" class="form-control" placeholder="extra mutation" aria-label="extra mutation" aria-describedby="#extraCalculate"  id="extraWanted">
                  <div class="input-group-append">
                    <button class="btn btn-outline-secondary" type="button" id="extraCalculate"><i class="far fa-calculator venus-no-mike"></i></button>
                  </div>
                </div>
                `;
                this.createEntry('ddg', 'Free energy calculation', ddgtext);

                // modal
                // const liEl = (l, v) => `<li><b>${l}:</b> ${v}</li>`;
                // const innerList = d => '<ul>' + Object.entries(d).map(([k, v]) => liEl(k, v.toFixed(1))).join('') + '</ul>';
                // let extraParts = liEl('Scorefunction', ) +
                //     liEl('ddG', this.energetical.ddG.toFixed(1) + ' kcal/mol') +
                //     liEl('solvatation term in ddG',  + ' kcal/mol') +
                //     liEl('Scores (meaningless due to only partial energy minimisation)', innerList(this.energetical.scores)) +
                //     liEl('ddG contributed by residue', this.energetical.ddG_residue.toFixed(1) + ' kcal/mol') +
                //     liEl('Native residue terms', innerList(this.energetical.native_residue_terms)) +
                //     liEl('Mutant residue terms', innerList(this.energetical.mutant_residue_terms));
                let modalText = `<p>Individual values for components of ΔΔG score, intended for advanced use.
                                    See documentation for discussion of &Delta;&Delta;G.
                                    For meaning, see <a href="/docs/venus" target="_blank">documentation</a>.</p>
                                    <p><b>Total &Delta;&Delta;G</b>: ${this.energetical.ddG.toFixed(1)} kcal/mol<br/>
                                    <b>Residue contribution to &Delta;&Delta;G</b>: ${this.energetical.ddG_residue.toFixed(1)} kcal/mol<br/>
                                    <b>Scorefunction</b>: ${this.energetical.score_fxn}<br/>
                                    <b>FastRelax cycles</b>: ${this.energetical.cycles}</p>
                                    <b>Movemap radius</b>: ${this.energetical.radius}</p>`;
                modalText += `<table class="table" style="hyphens: auto; word-break: break-all;">
                              <thead>
                                <tr>
                                  <th scope="col">Term</th>
                                  <th scope="col">Definition</th>
                                  <th scope="col">Weight factor</th>
                                  <th scope="col">Difference</th>
                                  <th scope="col">Weighted difference</th>
                                  <th scope="col">Score Native</th>
                                  <th scope="col">Score Mutant</th>
                                </tr>
                              </thead>
                              <tbody>`;
                const rowHeaderMaker = term => `<th scope="row">${term}</th>`;
                const TdMaker = term => `<td>${term}</td>`;
                const decimalTdMaker = term => `<td>${term.toFixed(1)}</td>`;
                const rowMaker = term => `<tr>${rowHeaderMaker(term)}
                                              ${TdMaker(this.energetical.terms[term]['meaning'])}
                                              ${TdMaker(this.energetical.terms[term]['weight'])}
                                              ${decimalTdMaker(this.energetical.terms[term]['difference'])}
                                              ${decimalTdMaker(this.energetical.terms[term]['difference'] * this.energetical.terms[term]['weight'])}
                                              ${decimalTdMaker(this.energetical.terms[term]['native'])}
                                              ${decimalTdMaker(this.energetical.terms[term]['mutant'])}
                                          </tr>`;
                modalText += Object.keys(this.energetical.terms).map(rowMaker).join('');
                modalText += `</tbody></table>`;
                $('#ddG_extra .modal-body').html(modalText);
                // add structures
                myData.proteins[0].name = 'model'; //need the name.
                myData.proteins.push({
                    name: "wt",
                    type: "data",
                    value: this.energetical.native,
                    ext: 'pdb',
                    chain: 'A',
                    chain_definitions: this.structural.chain_definitions,
                    history: {
                        code: this.structural.history.code,
                        changes: this.structural.history.changes + 'Rosetta locally relaxed'
                    }
                });
                myData.proteins.push({
                    name: "mutant",
                    type: "data",
                    value: this.energetical.mutant,
                    ext: 'pdb',
                    chain: 'A',
                    chain_definitions: this.structural.chain_definitions,
                    history: {
                        code: this.structural.history.code,
                        changes: this.structural.history.changes + 'Rosetta locally relaxed, mutated and relaxed'
                    }
                });
                if (this.energetical.phospho) {
                    myData.proteins.push({
                        name: "phosphorylated",
                        type: "data",
                        value: this.energetical.phospho,
                        ext: 'pdb',
                        chain: 'A',
                        chain_definitions: this.structural.chain_definitions,
                        history: {
                            code: this.structural.history.code,
                            changes: this.structural.history.changes + 'Rosetta locally relaxed, phosphorylated (no repacking)'
                        }
                    });
                }
                // extra
                $('#extraCalculate').click(event => {
                    const mutation = $('#extraWanted').val();
                    window.ops.addToast('calculatin' + mutation, 'Prediction in progress', 'The model requested will appear below the structural viewport when available', 'bg-info');
                    this.analyse_target(mutation, 'relax');
                });
                this.updateStructureOption();
                this.updateNeighbourhood();
                this.concludeMutational();
            }
            //{ddG: float, scores: Dict[str, float], native:str, mutant:str, rmsd:int}
        });
    }

    //step 5
    analyseddG_gnomad() {
        //step 5
        this.setStepStatus(5);
        return this.analyse('ddG_gnomad').done(msg => {
            if (msg.error) {
                this.setStepStatus(5, 'crash');
                ops.addToast('error', 'Error - ' + msg.error, '<i class="far fa-bug"></i> An issue arose analysing the results.<br/>' + msg.msg, 'bg-warning');
            } else {
                this.setStatus('All tasks complete', 'done');
                this.energetical_gnomAD = msg.gnomAD_ddG;
                //refill
                this.updateNeighbourhood();
                this.createLocation();
                this.activate_data_gnomad();
                this.concludeMutational();
            }
        });
    }

    //step x
    analyse_target(mutation, algorithm) {
        // if (this.busy === true) {
        //     window.ops.addToast('busy', 'Please be patient', 'To prevent overuse, only one at the time', 'bg-warning');
        //     return null;
        // }
        let submissionData = {
            uniprot: this.uniprot,
            species: this.taxid,
            step: 'extra',
            mutation: this.mutation, //the data is stored serverside for an hour. and this is one part of the hash.
            extra: mutation,
            algorithm: algorithm,
            allow_pdb: $('#allow_pdb').prop('checked'),
            allow_swiss: $('#allow_swiss').prop('checked'),
            allow_alphafold: $('#allow_alphafold').prop('checked'),
            debug: this.debug,
            job_id: this.job_id
        };
        this.setStatus(`Running extra job ${mutation}`, 'working');
        return $.post({
            url: "venus_analyse",
            data: submissionData,
            timeout: this.timeout,
        }).fail((error, text) => {
            if (text !== 'timeout') {
                ops.addErrorToast(error);
                this.setStatus(`Error: ${error.message}`, 'crash');
            } else {
                // polling
                setTimeout(() => this.analyse_target(mutation, algorithm), 30000);
                ops.addToast('polling',
                    'Slow task',
                    'The task is taking longer than expected (possibly large protein?)',
                    'bg-warning');
            }

        })
            .done(msg => {
                if (msg.error) {
                    this.setStatus('Failure at extra job', 'crash');
                    ops.addToast('error', 'Error - ' + msg.error, '<i class="far fa-bug"></i> An issue arose analysing the results.<br/>' + msg.msg, 'bg-warning');
                } else {
                    this.setStatus('All tasks complete', 'done');
                    myData.proteins.push({
                        name: mutation,
                        type: "data",
                        value: msg.coordinates,
                        ext: 'pdb',
                        chain: 'A',
                        chain_definitions: this.structural.chain_definitions,
                        history: {
                            code: this.structural.history.code,
                            changes: algorithm + ' ' + msg.ddg
                        }
                    });
                    ops.addToast(mutation, 'Extra analysis complete', `${mutation} has a ddG of ${parseInt(msg.ddg)} kcal/mol (calculated via local ${algorithm})`, 'bg-success');
                    this.updateStructureOption();
                    const ddg = msg.ddg;
                    this.structural.custom_ddG[mutation] = ddg;
                    const color = ddg > this.energetical.ddG ? 'text-warning' : 'text-secondary';
                    $('#extraDDGResults').append(`<li><b>${this.makeProlink(mutation.slice(1, -1), mutation)}</b>
                                        <span class="${color}">
                                        ${ddg.toFixed(1)} kcal/mol
                                        </span>
                                        </li>`);
                }
            });
    }

    //step phospho
    phosphorylate() {
        $('#phosphorylate-btn').attr('disabled', 'disabled');
        this.setStatus(`Running extra job post-translation modifications`, 'working');
        return this.analyse('phosphorylate').done(msg => {
            if (msg.error) {
                this.setStatus('Failure at step PTMs', 'crash');
                ops.addToast('error', 'Error - ' + msg.error, '<i class="far fa-bug"></i> An issue arose analysing the results.<br/>' + msg.msg, 'bg-warning');
            } else {
                this.setStatus('All tasks complete', 'done');
                this.energetical.phospho = msg.coordinates;
                myData.proteins.push({
                    name: "phosphorylated",
                    type: "data",
                    value: msg.coordinates,
                    ext: 'pdb',
                    chain: 'A',
                    chain_definitions: this.structural.chain_definitions,
                    history: {
                        code: this.structural.history.code,
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
        strloctext += `<button type="button" class="btn btn-outline-primary"
                                data-toggle="modal" data-target="#change_modal"
                        ><i class="far fa-upload"></i> Change
                        </button>`;
        this.createEntry('strcha', 'Structural character', strloctext);
        $('#structureOption').append('<li>No structures available</li>');


    }

    //custom pdb
    analyseCustomFile() {
        const extras = this.get_user_settings();
        extras.pdb = window.user_uploaded_data.pdb;
        extras.filename = window.user_uploaded_data.name;
        extras.params = window.user_uploaded_data.params;
        extras.format = window.user_uploaded_data.name;
        return this.analyse('customfile', extras);
    }

    //progress bar.
    setStatus(label, mode) { //working, crash, done
        mode = mode || 'working';
        $('#results_status').detach();
        const color = this.StatusModeColors[mode] || '';
        $('#toaster').prepend(`
                                <div class="toast ml-auto w-100 ${color} show" 
                                      style="z-index:9000; pointer-events: auto"
                                     role="alert" aria-live="assertive" aria-atomic="true" 
                                     data-autohide="false" 
                                     id="results_status">
                                  <div class="toast-header">
                                    <strong class="mr-auto">Progress</strong>
                                    <button type="button" class="ml-2 mb-1 close" data-dismiss="toast" aria-label="Close">
                                      <span aria-hidden="true">&times;</span>
                                    </button>
                                  </div>
                                  <div class="toast-body">
                                    ${label}
                                    <small id="results_status_caption"></small>
                                  </div>
                                </div>`);
        $('#results_status').mouseover(event => {
            if ($(event.target).data('toggle')) {
                $('#results_status_caption').html(`<br/>(${event.target.title})`);
            }
        })
            .toast('show');
        if (mode === 'done') setTimeout(() => $('#results_status').hide(), this.animation_speed * 2);
    }


    setStepStatus(step, mode, custom) {
        mode = mode || 'working';
        custom = custom || false;
        let forelabels = {'working': 'Running step', 'crash': 'Failure at step'};
        let label = `${forelabels[mode]} ${step}/5 (${this.stepNames[step - 1]})`;
        if (custom) {
            label += ' (rerunning with custom file) '
        }
        let boxes = ' &nbsp; ';
        boxes += this.stepNames.map((val, i) => {
            if (i < step - 1) {
                return `<i class="far fa-check-square" data-toggle="tooltip" title="${val}"></i>`;
            } else if (mode === 'crash') {
                return `<i class="far fa-times-square" data-toggle="tooltip" title="${val}"></i>`;
            } else if (i === step - 1) {
                return `<i class="far fa-plus-square" data-toggle="tooltip" title="${val}"></i>`;
            } else {
                return `<i class="far fa-square" data-toggle="tooltip" title="${val}"></i>`;
            }
        }).join('');

        this.setStatus(label + boxes, mode);
        if (mode === 'working') {
            window.ops.addToast('step' + step, 'Starting step', label, 'bg-primary');
        }

    }

    addSequence() {
        const card = $('#seqCard');
        // --- Load -----
        this.seq = new Sequence(this.protein.sequence);
        const legend = [];
        const coverage = new Array(this.protein.sequence.length)
            .fill(null)
            .map((v, i) => ({
                    start: i,
                    end: i + 1,
                    color: 'black',
                    tooltip: `${this.protein.sequence[i]}${i + 1}`,
                    underscore: false,
                    onclick: () => NGL.specialOps.showClickedResidue(
                        'viewport',
                        `${i}:A`,
                        undefined,
                        'turquoise'
                    )
                })
            );
        // the width of the sequence is a bit more than 1 em because of the space
        // so technically * 1.1 hence the 5.5
        // #seqCard has a padding of 2 px.
        // .charNumbers is about 2 em.
        const availSpace = (card.width() - 2) / parseFloat($("body").css("font-size")) - 2;
        const charsPerLine = Math.floor(availSpace / 5.5) * 10; // em
        if (charsPerLine <= 0 || card.is(':animated')) {
            // locally this gets triggered before the DOM finishes the .show of results
            // impossible in production
            setTimeout(() => this.addSequence(), 1000);
            return;
        }
        this.seq.render('#seqDiv', {charsPerLine: charsPerLine});
        $('.sequenceHeader').detach(); //title off.
        // --- Add no-go ---
        // this would need to be added after structural data.
        // if (this.structural !== undefined && this.structural.structure !== undefined) {
        //     const s_min = this.structural.structure.x;
        //     const s_max = this.structural.structure.y;
        //     coverage.forEach((v, i) => {
        //         if (v.start < s_min) {coverage[i].bgcolor = 'grey'}
        //         else if (v.start > s_max) {coverage[i].bgcolor = 'grey'}
        //         // else pass
        //     })
        // }
        // --- Add Mut -----
        coverage[this.mutational.residue_index - 1].bgcolor = 'salmon';
        coverage[this.mutational.residue_index - 1].tooltip += ' Mutated residue';
        // --- feats -----
        // PTMs
        if (this.protein.features['PSP_modified_residues'] !== undefined) {
            this.protein.features['PSP_modified_residues'].forEach(v => {
                //{symbol: "RBMX2", residue_index: 8, from_residue: "K", ptm: "ub", count: 1}
                if (coverage[v.residue_index - 1] === undefined) return null;
                coverage[v.residue_index - 1].underscore = true;
                coverage[v.residue_index - 1].tooltip += ' ' + v.ptm;
            });
            // legend later.
        }
        if (this.protein.features['modified residue'] !== undefined) {
            this.protein.features['modified residue'].forEach(v => {
                //{x: 149, y: 149, description: "Phosphoserine", id: "modifiedresidue_149", type: "modified residue"}
                coverage[v.x - 1].underscore = true;
                coverage[v.x - 1].tooltip += ' ' + v.description;
            });
            // legend later.
        }
        // xlink
        if (this.protein.features['cross-link'] !== undefined) {
            this.protein.features['cross-link'].forEach(v => {
                //{symbol: "RBMX2", residue_index: 8, from_residue: "K", ptm: "ub", count: 1}
                coverage[v.x - 1].underscore = true;
                coverage[v.x - 1].tooltip += ' ' + v.description;
            });
        }
        // --- Add gnomad ---
        // "Variant(id='gnomAD_17_17_rs994011128', x=17, y=17,…, description='Q17H (rs994011128)', homozygous=0)"
        // gnomAD off for now: too much!
        // get_gnomAD_details(mutation) gets only one...
        this.protein.gnomAD.forEach(v => {
            let m = v.description.match(/\w(\d+)\w /);
            if (m === null) return;
            let [description, x] = m.slice(0, 2);
            x = parseInt(x);
            if (x > this.protein.sequence.length) return; // wrong isoform!
            if (x <= 1) return;
            coverage[x - 1].color = 'gray';
            coverage[x - 1].tooltip += ' ' + description.replace('description=', '');
        });
        //legend.push({name: "gnomAD", color: "purple", underscore: false});
        // --- Add Legend & spans -----
        // double coverage caused issues.
        // const dejavu = [];
        // const coverage2 = coverage.reduce((a, v)=>{
        //                         if (! dejavu.includes(v.start)) {a.push(v);
        //                                                      dejavu.push(v.start);
        //                                                      }
        //                         return a;},
        //                 []);
        this.seq.coverage(coverage);
        legend.push({name: "Mutated residue", color: "salmon"});
        legend.push({name: "Post-translationally modified residue", color: 'black', underscore: true});
        legend.push({name: "gnomAD missense", color: 'gray', underscore: false});
        this.seq.addLegend(legend);
        this.hideCard('seqCard');
    }

    hideCard(id) {
        const card = $(`#${id}`);
        card.find('.card-body').hide(500);
        card.find('.collapse-icon').children().detach();
        card.find('.collapse-icon').append('<i class="far fa-expand-arrows-alt"></i>');
        const sub = card.find('.text-muted');
        sub.text('(Click to expand)');
        card.find('.card-header')
            .unbind('click')
            .click(event => this.showCard(id));
    }

    showCard(id) {
        const card = $(`#${id}`);
        card.find('.card-body').show(500);
        card.find('.collapse-icon').children().detach();
        card.find('.collapse-icon').append('<i class="far fa-compress-arrows-alt"></i>');
        const sub = card.find('.text-muted');
        sub.text(sub.data('show-text'));
        card.find('.card-header')
            .unbind('click')
            .click(event => this.hideCard(id));
    }

//###################  Entry
//an 'entry' is a flush li within the card (within these there may be li).
    createEntry(id, title, text) {
        //adds or creates the entry.
        // namely, the row in Mutation with the line between it.
        // the location is dictated by `entry_order`, which is generated by `documentation`.
        const el = $('#' + id);
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
            const prev = this.entry_order.map((k, i) => [k, i])
                .filter(([k, i]) => ($('#' + k).length === 1) && (i < n));
            if (prev.length === 0) {
                this.mutalist.append(entry);
                entry.show(this.animation_speed);
            } else {
                $("#" + prev.reverse()[0][0]).parents('li').after(entry);
                entry.show(this.animation_speed);
            }

        }

        //activate parts.
        //the DOM changes need to take effect.
        setTimeout(([venus, id]) => { //venus = this of this class
            const parent = $('#' + id).parents('li');
            const pros = parent.find('.prolink');
            pros.protein();
            // theres a listener/signal that I do not remember its name
            pros.click(event => {
                venus.showMutant.call(venus);
                venus.showLigands.call(venus);
                venus.last_clicked_prolink = event.target;
            });
            parent.find('.venus-entry-up').click(event => venus.moveEntry.call(venus, id, 'up'));
            parent.find('.venus-entry-down').click(event => venus.moveEntry.call(venus, id, 'down'));
            parent.find('.venus-entry-kill').click(event => venus.killEntry.call(venus, id));
            parent.find('[data-toggle="tooltip"]').tooltip();
        }, 100, [this, id]);

    }

    moveEntry(id, direction) {
        // documentation also determines the order.
        const n = this.entry_order.indexOf(id);
        if (n === -1) return null; //silent error.
        let offset = direction === 'up' ? -1 : 1;
        let d = this.entry_order.splice(n, 1)[0];
        this.entry_order.splice(n + offset, 0, d);
        // get the existing element, break it up, destroy it and remake it.
        const el = $('#' + id);
        const text = el.html();
        const title = el.parent().find('span').eq(0).html();
        const li = el.parents('li');
        li.hide(this.animation_speed);
        setTimeout(() => {
            li.detach();
            this.createEntry(id, title, text);
        }, this.animation_speed);
        if (id === 'location') this.activate_data_gnomad();
    }

    killEntry(id) {
        const el = $('#' + id).parents('li').hide(this.animation_speed);
        setTimeout(() => el.detach(), this.animation_speed);
    }

//###################  sprintf
//make methods output text
    makeEntry(id, title, text) {
        if (this.documentation[id] !== undefined) {
            //pass
        } else if (title.includes('<i class="far fa-question-circle"></i></span>')) {
            //pass
        } else {
            title += ' <i class="far fa-question-circle"></i></span>';
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
        } else if (Array.isArray(v)) {
            //old gnomad
            //["gnomAD_101_101_rs1131691997",101,101,"MODERATE","K101R (rs1131691997)",0]
            let p = v[1];
            if (parseInt(v[1]) === this.position) p = '<b>' + p + '</b>';
            return `<span  ${this.prolink} data-focus="residue" data-color="cyan" data-selection="${v[1]}:A">${p}</span>`;
        } else if (v.x !== undefined) {
            //feature!
            //{"x":105,"y":107,"description":"strand","id":"strand_105_107","type":"strand"}
            let df = 'residue';
            let ds = v.x + ':A';
            let p = 'Residue ' + v.x;
            if (parseInt(v.x) === this.position) p = '<b>Residue ' + v.x + '</b>';
            let dc = 'cyan';
            if (v.x !== v.y) {
                df = 'domain';
                ds = `${v.x}-${v.y}:A`;
                p = `Residues ${v.x}&ndash;${v.y}`;
                dc = 'darkgreen';
            }
            return `<span  ${this.prolink} data-color="${dc}"  data-focus="${df}" data-selection="${ds}">${p}</span>`;
        } else {
            console.log('ERROR' + JSON.stringify(v));
        }
    }

    makeExt(url, text) {
        //sprintf an external link
        return `<a href="${url}" target="_blank">${text} <i class="far fa-external-link-square"></i></a>`
    }

    makeBSListExt(url, text) {
        return `<a href="${url}" target="_blank" class="list-group-item list-group-item-action">
                ${text} <i class="far fa-external-link-square"></i></a>`

    }

//###################  other
    createLocation() {
        //Features
        let locationtext = `<p>The mutation is ${this.mutational.position_as_protein_percent}% along the protein.</p>`;
        const effectSplit = v => {
            if (!this.energetical_gnomAD) {
                return ''
            } else {
                let gnomads = Object.keys(this.energetical_gnomAD)
                    .filter(g => { //which are within?
                        let i = parseInt(g.match(/\d+/)[0]);
                        return v.x <= i && v.y >= i;
                    });
                let effect = gnomads.map(g => this.energetical_gnomAD[g])
                    .reduce((acc, gs, i) => {
                        if (gs > 2) {
                            acc.destabilising++
                        } else if (gs < -2) {
                            acc.stabilising++
                        } else {
                            acc.neutral++
                        }
                        return acc;
                    }, {destabilising: 0, neutral: 0, stabilising: 0});
                if (Object.values(effect).reduce((a, v) => a + v, 0) === 0) return '';
                let variants = gnomads.map(g => `${g} (≈${parseInt(this.energetical_gnomAD[g])} kcal/mol)`).join(', ');
                const modalAttr = `data-toggle="tooltip" title="${variants}" data-variant='${JSON.stringify(gnomads)}'`;
                return ` <span class="underlined venus-plain-mike" style="cursor: pointer;"
                                ${modalAttr}
                                >(` + Object.entries(effect)
                        .filter(([k, v]) => v !== 0)
                        .map(([k, v]) => `N<sub>${k}</sub>: ${v}`).join(', ')
                    + ` <i class="far fa-calculator" ${modalAttr}></i></span>)`;
            }
        };

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

    createLinks() {
        let linktext = `<i>this search (browser)</i>: <code>${window.location.protocol}//${window.location.host}${window.location.pathname}?uniprot=${this.uniprot}&species=${this.taxid}&mutation=${this.mutation}</code><br/>`;
        linktext += `<i>this search (API)</i>: <code>${window.location.protocol}//${window.location.host}/venus_analyse?uniprot=${this.uniprot}&species=${this.taxid}&mutation=${this.mutation}</code>`;
        this.createEntry('link', 'Links', linktext);
    }

    activate_data_gnomad() { //called by step 5.
        const dg = $('[data-variant]');
        dg.off('click'); //Unsure when this would occur.
        dg.click(event => {
            const el = $(event.target);
            const variants = el.data('variant').filter(variant => {
                    const deets = this.get_gnomAD_details(variant);
                    if (deets === undefined) {
                        return false
                    } else if (deets.consequence !== 'missense_variant') {
                        return false
                    } else {
                        return true
                    }
                }
            );
            if (variants.length === 0) {
                window.ops.addToast('nonsense', '∆∆G calculations for missense', 'It is not possible to calculate the ∆∆G for a nonsense mutation', 'bg-info');
                return
            }
            $('#gnomad_extra').modal('show');
            let btn = '';
            let homoTargets;
            let heteroTargets;
            if (this.energetical_gnomAD !== undefined) {
                const allTargets = el.data('variant')
                    .filter(mutation => {
                        if (this.energetical_gnomAD[mutation] === undefined) return false;
                        else return this.energetical_gnomAD[mutation] >= this.energetical.ddG;
                    });
                homoTargets = allTargets.filter(mutation => this.get_gnomAD_details(mutation).homozygous > 0);
                heteroTargets = allTargets.filter(mutation => this.get_gnomAD_details(mutation).homozygous === 0);
                if (allTargets.length > 0) {
                    btn = `
<div class="input-group mb-3">
  <div class="input-group-prepend">
    <span class="input-group-text">Bulk accurate<br/> calculations: </span>
  </div>
  <button class="btn btn-outline-info border-right-0 border-left-0 rounded-0" type="button" id="ddGHeteroGnomADs"
    ${heteroTargets.length ? '' : 'disabled'}
    ><i class="far fa-calculatorvenus-no-mike"></i> All het<br/> (<i class="far fa-adjust"></i>)</button>
  <div class="input-group-append">
    <button class="btn btn-outline-info" type="button"  id="ddGHomoGnomADs"
    ${homoTargets.length ? '' : 'disabled'}
    ><i class="far fa-calculator venus-no-mike"></i> All hom<br/> (<i class="fas fa-circle"></i>)</button>
  </div>
</div>`;
                }
            }
            let content = `<p>Mutations within feature present in the population (gnomAD).<br/>
NB. that the free energy calculations are very crude for expediency (target repacking only) and 
the gnomAD variants may include pathogenic variants (hence the suggestion to check gnomAD for a particular mutation)<br/>
</p>${btn}
`;
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
            content += el.data('variant').map(v => addLi(v)).join('');
            content += '</ul>';
            $('#gnomad_extra .modal-body').html(content);
            const pros = $('#gnomad_extra [data-toggle="protein"]');
            const bulker = (targets) => {
                if (targets.length < 10) {
                    window.ops.addToast('patient', 'Please be patient', 'Results will be shown in Free energy calculation section.', 'bg-info');
                    targets.forEach(mutation => this.analyse_target(mutation, 'relax'));
                } else {
                    window.ops.addToast('patient', 'Too many variants', 'Unfortunately, there are too many variants. Please select a smaller feature', 'bg-info');
                }
            };
            $('#ddGHomoGnomADs').click(event => {
                $('#ddGHomoGnomADs').prop('disabled', true);
                $('#ddGHomoGnomADs').off('click'); // prop disabled true isn't working
                bulker(homoTargets);
            });
            $('#ddGHeteroGnomADs').click(event => {
                $('#ddGHeteroGnomADs').prop('disabled', true);
                $('#ddGHeteroGnomADs').off('click');
                bulker(heteroTargets);
            });
            pros.each((i, e) => $(e).protein());
            pros.click(event => $('#gnomad_extra').modal('hide'));
            $('#gnomad_extra .modal-hider').click(event => {
                $('#gnomad_extra').modal('hide');
                const mutation = $(event.target).data('mutation');
                const algorithm = $(event.target).data('algorithm');
                window.ops.addToast('calculating ' + mutation, 'Prediction in progress', 'The model requested will appear below the structural viewport when available', 'bg-info');
                this.analyse_target(mutation, algorithm);
            });

        });
    }

    showMutant() {
        if (this.alwaysShowMutant) {
            const showMut = (sele) => {
                const prot = NGL.getStage().getComponentByType('structure');
                if (prot !== undefined) prot.addRepresentation("hyperball", sele);
            };
            setTimeout((sele) => showMut(sele), 100, {sele: this.position + ':A', color: this.mutaColor});
        }
    }

    showLigands() {
        if (this.alwaysShowLigands) {
            const showLig = (sele) => {
                const prot = NGL.getStage().getComponentByType('structure');
                if (prot !== undefined) prot.addRepresentation("licorice", {
                    multipleBond: "symmetric",
                    sele: 'not (polymer or water)'
                });
            };
            setTimeout(() => showLig(), 100);
        }
    }

    get_gnomAD_details(mutation) {
        //Python Variant object (gnomad) wass saved as string --> corrected.
        /* mutation is str "A23Q" returns
            {'id': 'gnomAD_8_8_rs1323613865', 'x': 8, 'y': 8, 'description': 'V8A (rs1323613865)',
            'from_residue': 'V', 'residue_index': 8, 'to_residue': 'A',
            'impact': 'MODERATE', 'homozygous': 0, 'frequency': 0, 'N': 1, 'consequence':
            'missense_variant', 'frequencies': {'afr': 0.0, 'amr': 0.0, 'asj': 0.0,
            'eas': 0.000411862, 'fin': 0.0, 'mid': 0.0, 'nfe': 0.0, 'sas': 0.0, 'oth': 0.0},
            'type': 'missense'}
         */
        const detail = this.protein.gnomAD.filter(v => v.description.includes(mutation))[0];
        return this.add_ddG_details(mutation, detail);
    }

    add_ddG_details(mutation, detail) {
        if (detail === undefined) {
            return undefined
        } else if (this.custom_ddG !== undefined && this.custom_ddG[mutation] !== undefined) {
            detail.ddG = this.custom_ddG[mutation];
        } else if (this.energetical_gnomAD !== undefined && this.energetical_gnomAD[mutation] !== undefined) {
            detail.ddG = this.energetical_gnomAD[mutation];
        }
        return detail;
    }

    get_clinvar_details(mutation) {
        /*
        {"id":"clinvar_12_12_rs104894229","x":12,"y":12,
        "description":"Neoplasm of the thyroid gland; Neoplasm of the large intestine",
        "from_residue":"G","residue_index":12,"to_residue":"R","impact":"Pathogenic/Likely pathogenic",
        "homozygous":null,"frequency":0,"N":1,"consequence":"single nucleotide variant",
        "frequencies":null,"type":"missense"}
         */
        const detail = this.protein.clinvar.filter(v => `${v.from_residue}${v.residue_index}${v.to_residue}`
            .includes(mutation))[0];
        return this.add_ddG_details(mutation, detail);
    }

    loadStructure() {
        if (NGL.getStage('viewport') !== undefined) { //this is a rerun... resetting
            window.myData = undefined;
            NGL.specialOps.postInitialise('viewport');
        }
        NGL.specialOps.multiLoader('viewport', [{
            name: "wt",
            type: "data",
            value: this.structural.coordinates,
            ext: 'pdb',
            chain: 'A',
            chain_definitions: this.structural.chain_definitions,
            history: this.structural.history
        }])
            .then(protein => {
                NGL.specialOps.showResidue('viewport', this.position + ':A');
                NGL.specialOps.enableClickToShow('viewport');
            });
        // When run locally and with an already analysed case, D3 is outrun...
        const empower = () => {
            if (window.ft === undefined) {
                setTimeout(empower, 500)
            } else {
                UniprotFV.empower(); // set the click events
                $("#model_id").html(this.structural.code);
                if (this.structural.chain_definitions !== undefined) {
                    const chainAs = this.structural.chain_definitions.filter(c => c.chain === 'A');
                    const chainA = (chainAs.length > 0) ? chainAs[0] : this.structural.chain_definitions[0];
                    // D3 is a bit slow at loading.
                    setTimeout(() => ft.addModel(chainA.x, chainA.y, venus.protein.sequence.length), 500);
                }
            }
        };
        empower()
        this.updateStructureOption();
        const align = $('#alignment_extra');
        align.unbind('shown.bs.modal');
        align.modal('hide');
        if (this.structural.has_conservation) {
            $('#conservationBtn').show();
        } else {
            $('#conservationBtn').hide();
        }
        // links
        let strloctext = '';
        if (this.structural.structure.type === 'rcsb') {
            strloctext += '<p><i>Chosen model:</i> ';
            strloctext += this.makeExt("https://www.rcsb.org/structure/" + this.structural.code, 'PDB:' + this.structural.code);
            strloctext += ` ${this.structural.structure.resolution} &Aring;`;
            strloctext += '</p>';
            // conservation overrides this
            // if (!! this.structural.bfactor) {
            //     strloctext += `<p data-toggle="tooltip" title="In a crystal structure, high b-factor is bad, but is a relative value dependant on the resolution etc.">
            //                     <i>b-factor</i>: ${this.structural.bfactor.toFixed(2)}</p>`;
            // }
        } else if (this.structural.structure.type === 'swissmodel') {
            // warnings
            const qmean = this.structural.structure.extra.qmean.qmean4_z_score;
            const identity = this.structural.structure.extra.identity;
            if ((identity < 20) && (qmean < -2.)) {
                strloctext += `<div class="alert alert-danger" role="alert"><i class="far fa-exclamation-triangle"></i> Warning:
                                    The identity to the template is low, ${identity}%,
                                    and the ${this.makeExt("https://swissmodel.expasy.org/docs/help#qmean", "Z-scored Qmean")}
                                     is more than two sigma worse than the average native protein ${qmean}
                                    </div>`;
            } else if (identity < 20) {
                strloctext += `<div class="alert alert-warning" role="alert"><i class="far fa-exclamation-triangle"></i> Warning:
                                    The identity to the template is low, ${identity}%,
                                    but the ${this.makeExt("https://swissmodel.expasy.org/docs/help#qmean", "Z-scored Qmean")}, ${qmean}, is reasonable.
                                    </div>`;
            } else if (qmean < -2.) {
                strloctext += `<div class="alert alert-warning" role="alert"><i class="far fa-exclamation-triangle"></i> Warning:
                                    The ${this.makeExt("https://swissmodel.expasy.org/docs/help#qmean", "Z-scored Qmean")}
                                     is more than two sigma worse than the average native protein ${qmean}.
                                    </div>`;
            } else if (this.structural.structure.extra.identity <= 50) {
                strloctext += `<div class="alert alert-secondary" role="alert"><i class="far fa-exclamation-triangle"></i> Caution: The identity to the template is moderately low.</div>`;
            }

            //

            strloctext += '<p><i>Chosen model:</i> ';
            strloctext += this.makeExt("https://swissmodel.expasy.org/repository/uniprot/" + this.uniprot, 'SWISSMODEL:' + this.structural.code);
            strloctext += ` ${(this.structural.structure.extra.identity).toFixed(0)}% identity `;
            strloctext += `<button type="button" class="btn btn-outline-info venus-no-mike m-2" data-toggle="modal" data-target="#alignment_extra">see alignment</button>`;
            strloctext += '</p>';
            align.find('.modal-body').append(`<p>Template: the sequence of the protein structure used for threading by Swissmodel,
                            in this case template(${venus.structural.code.split(' ')[2]})<br/>
                            Uniprot: the sequence of this protein under investigation 
                            (${this.protein.gene_name}).</p><div id="msa_viewer" class="p-2"></div>`);
            const seqs = msa.io.fasta.parse(`>template\n${this.structural.structure.alignment.template}\n` +
                `>uniprot\n${this.structural.structure.alignment.uniprot}\n`);
            align.on('shown.bs.modal', event => msa({el: align.find('#msa_viewer'), seqs: seqs}).render());
        } else if (this.structural.structure.type === 'alphafold2') {
            strloctext += '<p><i>Chosen model:</i> ';
            strloctext += this.makeExt("https://alphafold.ebi.ac.uk/entry/" + this.uniprot, 'AlphaFold2:' + this.uniprot);
            strloctext += ` (<span class='prolink' data-target="#viewport" data-toggle="protein" data-selection="*"
                                data-focus="domain" data-color="bfactor">show confidence in  pLDDT</span>)`;
            strloctext += '</p>';
            let plddt_color = 'bg-danger';
            let plddt_word = 'error';
            if (this.structural.bfactor > 90) {
                plddt_color = 'bg-success';
                plddt_word = 'very highly confident';
            } else if (this.structural.bfactor > 70) {
                plddt_color = 'bg-info';
                plddt_word = 'confident';
            } else if (this.structural.bfactor > 50) {
                plddt_color = 'bg-warning'; //text-white and bg-warning looks fine.
                plddt_word = 'low';
            } else {
                plddt_color = 'bg-danger';
                plddt_word = 'very low';
            }

            strloctext += `<p class="${plddt_color} text-white p-1" data-toggle="tooltip" 
                            title="A pLDDT over 70% is confident. Below 50% is poor.">
                                <i>pLDDT</i>: ${this.structural.bfactor.toFixed(1)}% (${plddt_word})</p>`;
        } else {
            strloctext += '<p><i>Chosen model:</i> ';
            strloctext += `User submitted file (orginal filename: ${this.structural.structure.id})`;
            strloctext += '</p>';
        }
        strloctext += `<p><i>Solvent exposure:</i> ${(this.structural.buried) ? 'buried' : 'surface'} (RSA: ${Math.round(this.structural.RSA * 100) / 100})</p>`;
        let simbaVerdict;
        if (this.structural.simbai_ddG > +2) {
            simbaVerdict = 'destabilising';
        } else if (this.structural.simbai_ddG < -2) {
            simbaVerdict = 'stabilising';
        } else {
            simbaVerdict = 'neutral';
        }
        strloctext += `<p><i>Quick ∆∆G (SIMBA-I)</i> ${Math.round(this.structural.simbai_ddG * 10) / 10} kcal/mol (${simbaVerdict})</p>`;
        strloctext += `<p><i>Secondary structure type:</i> ${this.structural.SS}</p>`;
        strloctext += `<p><i>Residue resolution:</i> ${(this.structural.has_all_heavy_atoms) ? 'Resolved in crystal/model' : 'Some heavy atoms unresolved (too dynamic)'}</p>`;
        if (this.structural.closest_ligand !== undefined && this.structural.closest_ligand.match(/\[.*\]/) !== null) {
            //this.structural.closest_ligand = [GDP]180.O3B:A
            let lig = this.structural.closest_ligand.match(/\[.*\]/)[0].slice(1, -1);
            let ds = lig + ' and ' + this.structural.closest_ligand.match(/\:\w/)[0];
            let d = Math.round(this.structural.distance_to_closest_ligand) + ' &Aring;'
            strloctext += `<p><i>Closest ligand:</i> <span class="prolink" data-target="viewport" data-color="teal" data-focus="residue" data-selection="${ds}">${lig}</span> (${d})</p>`;
        }
        // ---anything transplanted?
        const ulInner = this.structural
            .chain_definitions
            .map(definition => {
                // this.prolink has class. Not wanted.
                const prolink = `data-target="#viewport" data-toggle="protein" data-focus="domain" data-selection=":${definition.chain}"`;
                let chain = `<b>Chain ${definition.chain}</b> `;
                if (definition.uniprot === this.protein.uniprot) {
                    return `<a href="#viewport"  class="list-group-item list-group-item-action" ${prolink}>${chain}
                                                Protein of interest 
                                                (${this.protein.gene_name},
                                                ${definition.x}&ndash;${definition.y})</a>`;
                }
                let text = chain;
                if (definition.name) {
                    text += definition.name + ' ';
                } else if (definition.description) {  // name is the official name, description is crap from submitter
                    text += definition.description + ' ';
                }
                if (definition.uniprot && definition.uniprot !== 'P00404') {
                    // 404 = dumb decision for unknown uniprot...
                    text += definition.uniprot + ' ';
                }
                if (!definition.transplanted) {
                    return `<a href="#viewport" class="list-group-item list-group-item-action" ${prolink}>${text}</a>`;
                } else {
                    return `<a href="#viewport"  class="list-group-item list-group-item-action list-group-item-warning" ${prolink}><i class="far fa-exclamation-triangle" data-toggle="tooltip" title="Chain taken from template (not threaded)"></i> ${text}</a>`;
                }
            });
        strloctext += `<p>Chains:</p><div class="list-group" id="chainDescr">${ulInner.join('')}</div>`;
        // structural character
        this.createEntry('strcha', 'Structural character', strloctext);
        // unsure why these do not get picked up.
        $('#chainDescr [href="#viewport"]').protein();
        this.updateNeighbourhood();
    }

    updateNeighbourhood() {
        // # =========== Neighbours ===========
        // ## The all selector
        const allSele = this.structural.neighbours.map(v => v.resi + ':A').join(' or ');
        let omni;
        if (this.structural.has_conservation) {
            omni = `<span ${this.prolink} data-color="bfactor" data-focus="residue" data-selection="${allSele}">
                    all, coloured by conservation</span>`;
        } else {
            omni = `<span ${this.prolink} data-color="turquoise" data-focus="residue" data-selection="${allSele}">
                    all</span>`;
        }

        // ## the ptm selector
        const ptmSele = this.structural.neighbours
            .filter(v => v.ptms.length)
            .map(v => v.resi + ':A').join(' or ');
        const ptms = `<span ${this.prolink} data-color="turquoise"  data-focus="residue" data-selection="${ptmSele}">
                    PTM sites</span>`;

        // ## the gnomad selector
        const gnomadSele = this.structural.neighbours
            .filter(v => Object.keys(v.gnomads).length)
            .map(v => v.resi + ':A').join(' or ');
        const gnomads = `<span ${this.prolink} data-color="turquoise"  data-focus="residue" data-selection="${gnomadSele}">
                    gnomAD</span>`;
        let badGnomads = '';
        if (this.energetical_gnomAD !== undefined) {
            // there should always be an object gnomads, so the ternary is overkill
            const cacognomadSele = this.structural.neighbours
                .filter(v => Object.keys(v.gnomads)
                    .map(mutation => this.get_gnomAD_details(mutation).ddG >= 2)
                    .some(v => v)
                )
                .map(v => v.resi + ':A').join(' or ');
            badGnomads = `<span ${this.prolink} data-color="salmon"  data-focus="residue" data-selection="${cacognomadSele}">
                    destabilising gnomAD</span>`;
        }
        let ddGNeighs = '';
        if (this.energetical !== undefined) {
            const energySele = this.energetical.neighbours.map(v => v.trim().replace(' ', ':')).join(' or ');
            ddGNeighs = `<span ${this.prolink} data-color="teal"  data-focus="residue" data-selection="${energySele}">
                    minimisation</span>`;
        }

        let strtext = `<p>Structural neighbourhood (${omni}; ${ptms}; ${gnomads}; ${badGnomads}; ${ddGNeighs}).
                        (see ${this.makeExt('https://gnomad.broadinstitute.org/', 'gnomAD')} and
                        ${this.makeExt('https://www.phosphosite.org', 'PhosphoSitePlus')} 
                        for extra information)</p>`;
        strtext += '<table class="table">';
        let con_th = '';
        // See venus_text.py for modal descriptions which get added by extra_info.mako
        const infoMaker = (id) => `<span data-toggle="modal" data-target="#${id}"><i class="fas fa-question-circle"></i>`;
        const subcaptionClass = 'class="text-muted font-weight-normal"';
        const infoClick = ' Click on info icon for more info.';
        if (this.structural && this.structural.has_conservation) {
            con_th = `<th scope="col" class="align-top"
                          title="Consurf normalised homology score: positive = less conserved. negative = conserved. ${infoClick}"
                          data-toggle="tooltip"> 
                      Conservation<br/>
                      <span ${subcaptionClass}>
                      (ConsurfDB grades 
                      ${infoMaker('consurfModal')}
                      </span>
                      )</span>
                      </th>`;
        }
        strtext += `<thead><tr>

                    <th scope="col" class="align-top">Residue</th>
                    <th scope="col" class="align-top"
                        title="Neighbouring residues sorted by distance to the target residue. ${infoClick}"
                        data-toggle="tooltip"
                    >Distance <span ${subcaptionClass}>(sorted by distance ${infoMaker('distanceModal')})</span></th>
                    ${con_th}
                    <th scope="col" class="align-top"
                        title="Secondary and tertiary structure"
                        data-toggle="tooltip"
                    >Structural detail</th>
                    <th scope="col" class="align-top"
                        title="Noteworthy features involving the residue from a variety of sources. ${infoClick}"
                        data-toggle="tooltip"
                    >Features <span ${subcaptionClass}>${infoMaker('featureModal')}</span></th>
                    </tr></thead>`;
        strtext += '<tbody>'
        strtext += this.structural.neighbours.sort((a, b) => a.distance - b.distance)
            .map(v => this.makeNeighbourRow(v)).join('');
        strtext += '</tbody>'
        strtext += '</table>'
        this.createEntry('neigh', 'Structural neighbourhood', strtext);
        // this.activate_data_gnomad(); // currently run in step 5 only due to ${detail.description} (≈${parseInt(this.energetical_gnomAD[mutation])} kcal/mol)
    }

    makeNeighbourRow(data) {
        /* data is an element of this.structural.neighbours
        This attribute is first filled with the return of `StructureAnalyser().get_neighbours()`,
        but it is actually expanded by `ProteinAnalyser().annotate_neighbours()`.
        Data is a dictionary with keys `neigh`: `resi` (changed to int), `resn` (changed to 1 letter),
        `chain`, `distance`,  `detail` (str), `ptms` (list), `gnomads`  (list), `clinvar`  (list)
        and `other_chain` (bool).
        */
        const label = data.resn + data.resi; //NB. resi is a string because PyMOL and it may be an insertion code (!?)
        const selector = data.resi + ":" + data.chain;
        const prolink = this.makeProlink(selector, label);
        const distance = `${data.distance.toFixed(1)} &Aring;`;
        let structural_descriptions = [];
        if (this.energetical) { // hydrogen bonding etc. is via PyRosetta
            // {"pose_idx":336,"pdb_idx":336,"pdb_chain":"A","resn":"SER","is_protein":true,"omega":"trans","ss":"L",
            // "betaturn":"TurnAA_I",
            // "hbonds":[{"distance":1.9845822998206568,"energy":-1.5254094966466458,"acc_resi":339,"acc_resn":"GLN","acc_atm_name":"OE1","don_resi":336,"don_resn":"SER","don_atm_name":"H","direction":"donor","other_pdb_idx":339,"other_pdb_chain":"A","other_atm_name":"OE1","own_atm_name":"H"},
            // {"distance":1.9551069428506849,"energy":-1.2034188581245286,"acc_resi":336,"acc_resn":"SER","acc_atm_name":"O","don_resi":340,"don_resn":"LYS","don_atm_name":"H","direction":"acceptor","other_pdb_idx":340,"other_pdb_chain":"A","other_atm_name":"H","own_atm_name":"O"}]}
            const raw_structural_descriptions = this.energetical.neighbor_description
                                               .filter(o => (o.pdb_idx === data.resi) && (o.pdb_chain === data.chain) )
                                               .shift();
            if (raw_structural_descriptions !== undefined) {
                const ss_type = {L: 'Loop', E: 'Sheet', H: 'Helix'};
                structural_descriptions.push( ss_type[raw_structural_descriptions.ss] );
                structural_descriptions.push( raw_structural_descriptions.omega );
                if (raw_structural_descriptions.betaturn) {
                    structural_descriptions.push(`likely &beta;-turn: ${raw_structural_descriptions.betaturn}`)
                }
                const bond2text = bond => `${bond.direction} H-bond `+
                                            '<small class="text-muted font-weight-normal">('+
                                           `by ${bond.own_atm_name} with ${bond.other_atm_name}`+
                                           ` of ${bond.other_pdb_idx}:${bond.other_pdb_chain}, `+
                                           `${bond.distance.toFixed(1)} Å, ${bond.energy.toFixed(1)} kcal/mol`+
                                            ')</small>';
                structural_descriptions.push(...raw_structural_descriptions.hbonds.map(bond2text));

            }
        }

        let details = []; // formerly mdash sepearated. Mostly. Now joined by br
        // ----------------------------- Interface
        if (data.other_chain) {
            details.push(`from interacting protein (chain ${data.chain})`);
            // Todo fix the following.
            // const chainDeets = this.structural.chain_definitions.filter(v => v.chain = 'A');
            // if (chainDeets) {
            //     // chainDeets[0].name is undefined?
            //     detail = ` from interacting protein (${data.chain}${chainDeets[0].name ? ': '+chainDeets[0].name : ''})`;
            // } else {
            //      console.log('Warning: no name in chain definitions??');
            // }
        }
        // ----------------------------- Fill PTMs stuff.
        details.push(...data.ptms);
        // ----------------------------- Fill gnomAD stuff.
        details.push(...data.gnomads.map(this.gnomad2cell.bind(this)));
        // ---------------------------- Fill clivar stuff
        details.push(...data.clinvars.map(this.clinvar2cell.bind(this)));
        // ----------------------------- conservation
        let conservation = '';
        if (!!this.structural.has_conservation) {
            conservation = 'no conservation data';
            if (data.conscore !== undefined) {
                let con_color = data.conscore < 0 ? 'bg-primary text-white' : 'bg-secondary text-white';
                conservation = `<span  title='ConsurfDB normalised homology score: positive = less conserved. negative = conserved' 
                                       data-toggle='tooltip'
                                       class="${con_color}"
                                       >
                                ${data.conscore.toFixed(1)}</span>
                                
                                <span title='alterative residues in homologous protein: ${data.variety.join('/')}' data-toggle='tooltip'>
                                    alts: ${data.variety.length}
                                </span>
                                `;
            }
        }
        // ----------------------------- Output
        let headerCell = `<th scope="row">${prolink}</th>`;
        if (this.mutational.residue_index.toString() === data.resi.toString()) {
            // This neighbour is the mutated residue itself.
            headerCell = `<th scope="row">${prolink} (target)</th>`;
        }
        const distanceCell = `<td>${distance}</td>`;
        const detailCell = `<td>${details.join('<br/>')}</td>`;
        let conservationCell = '';
        if (this.structural && this.structural.has_conservation) {
            conservationCell = `<td>${conservation}</td>`;
        }
        const structural_lis = structural_descriptions.map(s => `<li class="list-group-item p-0">${s}</li>`);
        const structCell = `<td><ul class="list-group list-group-flush">${structural_lis.join('')}</ul></td>`;
        return `<tr>${headerCell}${distanceCell}${conservationCell}${structCell}${detailCell}</tr>`;

    }

    gnomad2cell(mutation) {
        const datagnomad = `data-variant='${JSON.stringify([mutation])}'`;
        // `deets` is this.protein.gnomAD + this.energetical_gnomAD + this.custom_ddG :
        const deets = this.get_gnomAD_details(mutation);
        /*
        deets is somethings like:

           {"id":"gnomAD_79_79_rs193163027",
           "x":79,"y":79,
           "description":"L79V (rs193163027)",
           "from_residue":"L",
           "residue_index":79,
           "to_residue":"V",
           "impact":"MODERATE",
           "homozygous":0,
           "frequency":0.000145943,
           "N":1,
           "consequence":"missense_variant",
           "frequencies":{"afr":0,"amr":0,"asj":0,"eas":0,"fin":0,"mid":0,"nfe":0.000145943,"sas":0,"oth":0},
           "type":"missense"}
        */
        let freqicon;
        const catfreq = Object.entries(deets.frequencies)
            .map(([k, v]) => `${this.subpopulations[k]}: ${v.toPrecision(2)}`)
            .join(';<br>');
        const freqInner = `data-toggle="tooltip"
                           data-html="true" 
                           title="Frequency in gnomAD controls dataset:
                            ${deets.frequency.toPrecision(2)}.<br>
                            <b>Allele count: ${deets.N}.</b><br>
                            ${catfreq}.
                            "
                           `;
        if (deets.N > 1000) {
            freqicon = 'fa-signal';
        } else if (deets.N > 100) {
            freqicon = 'fa-signal-4';
        } else if (deets.N > 10) {
            freqicon = 'fa-signal-3';
        } else if (deets.N > 5) {
            freqicon = 'fa-signal-2';
        } else if (deets.N > 1) {
            freqicon = 'fa-signal-1';
        } else { // impossible.
            freqicon = 'fa-signal-slash';
        }
        const zygoicon = deets.homozygous === 0 ? 'far fa-adjust' : 'fas fa-circle';
        const underline = this.energetical_gnomAD !== undefined ? 'underlined' : '';
        const iconed = `<i class="fad ${freqicon}" ${freqInner} style="cursor:help"></i>
                        <i class="far ${zygoicon}" ${datagnomad} style="cursor:help" data-toggle="tooltip"
                        title="${deets.homozygous} homozygous cases in gnomAD control dataset"></i>`
            .replaceAll(/[\s\n]+/g, ' ');
        // ^^^^^ just because the spaces look rubbish in the HTML.

        if (!deets) {
            //glitched? Generally nonsense mutations?
            return mutation;
        } else if (deets.type !== 'missense') {
            // Not a missense. (nonsense).
            return `${mutation} ${iconed}`;
        } else if (deets.ddG === undefined) {
            // Missense w/o ddG
            return `<span style='cursor: pointer;'
                                    class='${underline} venus-plain-mike'
                                    ${datagnomad}>
                              ${deets.description}
                              </span>
                              ${iconed}`;
        } else {
            // Missense w/ ddG
            let kcalColor;
            if (deets.ddG >= 2) {
                kcalColor = 'text-danger'
            } else if (deets.ddG >= 1.2) {
                kcalColor = 'text-warning'
            } else if (deets.ddG < -2) {
                kcalColor = 'text-muted'
            } else {
                kcalColor = 'text-info'
            }
            const kcal = `<span class='${kcalColor}' ${datagnomad}>${deets.ddG.toPrecision(2)} kcal/mol</span>`;
            return `<span style='cursor: pointer;'
                                    class='${underline} venus-plain-mike'
                                    ${datagnomad}>
                              ${deets.description} ${kcal}
                              </span>
                              ${iconed}`;
        }
    }

    clinvar2cell(mutation) {
        const dataclinvar = `data-variant='${JSON.stringify([mutation])}'`;
        // `deets` is this.protein.gnomAD + this.energetical_gnomAD + this.custom_ddG :
        const deets = this.get_clinvar_details(mutation);
        let clinColor;
        if (deets.impact.toLowerCase().includes('pathogenic')) {
            clinColor = 'text-danger';
        } else if (deets.impact.toLowerCase().includes('benign')) {
            clinColor = 'text-muted';
        } else {
            clinColor = 'text-muted';
        }

        let kcal = '';
        if (deets.ddG) {
            const kcalColor = deets.ddG < 2 ? 'text-muted' : 'text-danger';
            kcal = `<span class='${kcalColor}' ${dataclinvar}>${deets.ddG.toPrecision(2)} kcal/mol</span>`;
        }
        const underline = this.energetical_gnomAD !== undefined ? 'underlined' : '';
        return `<span class="${clinColor}">ClinVar ${deets.impact}</span>
                        <span style='cursor: pointer;'
                                            class='${underline} venus-plain-mike'
                                            ${dataclinvar}>
                                      ${mutation} ${kcal}
                                      </span>
                        
                       <i class="far fa-stethoscope"
                            data-toggle="tooltip" title="${deets.description}. Number of submissions: ${deets.N}"
                            style="cursor: help;">
                       </i>
                     `;
    }

    updateStructureOption() {
        const so = $('#structureOption');
        so.html('');
        if (window.myData === undefined) return 0;
        NGL.getStage('viewport').handleResize(); // asynchronous changes...
        const nicer = {
            'model': 'original structure',
            'wt': 'wild type (energy minimised)',
            'mutant': `${venus.mutation} (energy minimised)`
        };
        const longnamer = (name) => (nicer[name] !== undefined) ? nicer[name] : name;
        myData.proteins.map(({name}) => so.append(`<li>
                                                        <span ${this.prolink} data-load="${name}">
                                                            ${longnamer(name)}
                                                        </span>
                                                        <a href="#structureOption" onclick="venus.download('${name}')" ><i class="far fa-download"></i></a>
                                                    </li>`));
        // special case: mutant structure
        $('#structureOption [data-load="mutant"]').attr('data-focus', 'clash')
            .attr('data-selection', this.position);
        // special case: PTMs
        $('#structureOption [data-load="phosphorylated"]').attr('data-focus', 'residue')
            .attr('data-selection', 'SEP or TPO or PTR or ALY or NMM or DA2 or MLZ')
            .attr('data-radius', 1.5);
        // special cases: custom mutations.
        window.myData.proteins.map(({name}) => name)
            .filter(name => name.match(/\w\d+\w/))
            .forEach(name => $(`#structureOption [data-load="${name}"]`)
                .attr('data-focus', 'clash')
                .attr('data-selection', name.slice(1, -1) + ':A')
            );
        if (window.myData.proteins.filter(({name}) => name === 'mutant').length === 1) {
            so.append(`<li><span ${this.prolink} data-load="wt" data-focus="overlay mutant" data-selection="${this.position}:A">Overlay of wild-type and mutant</span></li>`);
        }
        so.find('.prolink').each((i, e) => {
            $(e).protein();
            $(e).click(event => {
                // is this unbound?
                venus.showMutant.call(venus);
                venus.showLigands.call(venus);
                venus.last_clicked_prolink = event.target;
            });
        });

        if (this.energetical && window.myData.proteins.filter(({name}) => name === 'phosphorylated').length === 0) {
            so.append('<li><button id="phosphorylate-btn" type="button" class="btn btn-outline-secondary btn-sm" onclick="venus.phosphorylate.call(venus)">Make phosphorylated model</button></li>');
        }
    }

    download(name) {
        const element = document.createElement('a');
        const extension = 'pdb';
        const entry = myData.proteins.filter(({name: n}) => n === name)[0];
        if (entry.type === 'url') {
            element.setAttribute('href', entry.value);
        } else if (entry.type === 'rcsb') {
            element.setAttribute('href', `https://files.rcsb.org/download/${entry.value}.pdb`);
        } else if (entry.type === 'data' && !entry.isVariable) {
            const text = entry.value;
            element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(text));
        } else if (entry.type === 'data' && !!entry.isVariable) {
            const text = window[entry.value];
            element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(text));
        } else {
            throw 'impossible.'
        }
        element.setAttribute('download', `${name}.${extension}`);
        element.style.display = 'none';
        document.body.appendChild(element);
        element.click();
        document.body.removeChild(element);
    }

    createPage(wantedIndices) {
        // Make a Michelanglo page
        // gets called by the click listener of #createMike
        // Get the text block
        let results = $('#results_mutalist').clone();
        results.find('.venus-no-mike').detach();
        results.find('.venus-plain-mike').each((i, el) => $(el).html(`<span>${$(el).text()}</span>`));
        results.find('#results_mutalist').append(`<li class="list-group-item">${$('#structureOption').html()}</li>`);
        let text = results.html().replaceAll(/\n\s+/g, '\n');
        // get the view data
        let prolink = $(this.last_clicked_prolink).data() || {};
        if (this.alwaysShowMutant) {
            prolink['selection-alt1'] = this.position + ':A';
            prolink['focus-alt1'] = 'residue'
        }
        prolink['hetero'] = this.alwaysShowLigands;
        prolink['view'] = NGL.getStage().viewerControls.getOrientation().elements;
        let data = {
            uniprot: this.uniprot, // same as this.protein.uniprot or window.UniprotValue
            species: this.taxid,
            mutation: this.mutation,
            text: text,
            code: this.structural.code, //pdb code. No JS is accepted from user.
            definitions: this.structural.chain_definitions,
            history: this.structural.history,
            prolink: prolink,
            protein: myData.proteins.filter((v, i) => wantedIndices.includes(i)),
            job_id: this.job_id,
        };
        // other end at page_creation.py
        return $.post({
            url: "venus_create", data: {'proteindata': JSON.stringify(data)},
            dataType: 'json',
            timeout: this.timeout
        })
            .done(function (msg) {
                ops.addToast('jobcompletion', 'Conversion complete', 'The data has been converted successfully.', 'bg-success');
                ops.addToast('redirect', 'Conversion complete', 'Redirecting you to page ' + msg.page, 'bg-info');
                window.location.href = "/data/" + msg.page;
            })
            .fail(ops.addErrorToast);
    }

// ------------ Summary conclusions ----------------------------------------
// From mutational
    concludeMutational() {
        // is it a PTM?
        const details = {
            buried: this.structural !== undefined && this.structural.buried,
            distorted: this.energetical !== undefined && this.energetical.rmsd > 0.2,
            toNegCharged: this.mutational.to_residue === 'E' || this.mutational.to_residue === 'D',
        };
        // assess any salient features
        let effects = [this.mutational.apriori_effect,
            this.concludeMutational_nonsense(details),
            this.concludeMutational_destabilising(details),
            this.concludeMutational_phospho(details),
            this.concludeMutational_disulfo(details),
            this.concludeMutational_ubi(details),
            this.concludeDistance(details),]
            .filter(v => v !== null);

        // ubiquitin
        // other PTM
        // disulfide
        //       'buried_pro',
        //       'helix_pro',
        //       'buried_charge',
        //       'buried_hydrophilic',
        //       'disallowed_phi',
        //       'buried_gly',
        //       'buried_salt
        //        'alter',
        const icon = '<span class="fa-li"><i class="far fa-lightbulb-on"></i></span>';
        const effect = ('<ul  class="fa-ul">' +
            (effects.map(v => `<li>${icon}${v}</li>`)).join('\n') +
            '<li><span class="fa-li"><i class="far fa-clipboard-list-check"></i></span> For a discussion of possible hypotheses to draw see <a href="/docs/venus_hypothesis" target="_blank">hypothesis generation notes</a></li>' +
            '</ul>'
        );
        this.createEntry('effect', 'Effect', effect);
    }

    concludeMutational_nonsense({}) {
        if (this.mutational.to_residue === '*') {
            return `<span ${this.prolink}
                        data-focus="domain" 
                        data-selection="1-${this.mutational.residue_index}:A">
                        remnant</span>
                        and <span ${this.prolink} data-focus="domain" 
                        data-selection="${this.mutational.residue_index}-99999:A">lost</span>`;
        } else {
            return null;
        }
    }
    ;

    concludeMutational_buttonMaker(id, msg) {
        return `<a href="#${id}" class="text-info venus-plain-mike" data-toggle="modal" data-target="#${id}">${msg}</a>`;
    }

    concludeMutational_filter(filterFx) {
        const isAt = this.mutational
            .features_at_mutation
            .filter(filterFx)
            .length > 0;
        const isNear = this.mutational
            .features_near_mutation
            .filter(filterFx)
            .length > 0;
        const opening = isAt ? 'The mutated residue disrupts ' : 'The mutated residue may disrupt a nearby ';
        return [isAt, isNear, opening];
    }

    concludeMutational_phospho({buried, distorted, toNegCharged}) {
        const phosphoFilter = entry => entry.description === 'phosphorylated' || entry.ptm === 'p';
        const [isAt, isNear, opening] = this.concludeMutational_filter(phosphoFilter);
        let phosphoeffects = [];
        if (isAt || isNear) {
            // buried
            if (buried) {
                // cryptic phospho site.
                phosphoeffects.push(
                    this.concludeMutational_buttonMaker('modalBuriedPhosphorylation',
                        'a buried phophosphorylation site'));
            }
            if (distorted) {
                // distorted phospho site.
                phosphoeffects.push('that is ' +
                    this.concludeMutational_buttonMaker('modalDistortedPhosphorylation',
                        'altering the protein'));
            }
            //charged
            if (toNegCharged) {
                // charged
                phosphoeffects.push('changing the charge' +
                    this.concludeMutational_buttonMaker('modalChargedPhosphorylation',
                        'negatively charged residue'));
            }
            // combine phospho

            let phosphoeffect = opening +
                this.concludeMutational_buttonMaker('modalPhosphorylation',
                    'a phophosphorylation site');
            if (phosphoeffects.length > 0) {
                phosphoeffect += ' — ';
                phosphoeffect += phosphoeffects.join(', ');
            }
            phosphoeffect += '.';
            return phosphoeffect;
        } else {
            return null;
        }
    }

    concludeMutational_disulfo({}) {
        const filter = entry => entry.description === 'disulfide';
        const [isAt, isNear, opening] = this.concludeMutational_filter(filter);
        if (isAt || isNear) {
            return opening +
                this.concludeMutational_buttonMaker('modalDisulfide',
                    'a disulfide bond') +
                '.';
        } else {
            return null;
        }
    }

    concludeMutational_ubi({}) {
        const filter = entry => entry.ptm === 'ub' || entry.ptm === 'sm';
        const [isAt, isNear, opening] = this.concludeMutational_filter(filter);
        if (isAt || isNear) {
            return opening +
                this.concludeMutational_buttonMaker('modalUbiquitination',
                    'a ubiquitination site') +
                '.';
        } else {
            return null;
        }
    }

    concludeMutational_destabilising({}) {
        const destabilising = this.concludeMutational_buttonMaker('modalDestabilisation',
            'destabilising');
        if (this.energetical === undefined) {
            return null;
        } else if (this.energetical.ddG > 10) {
            return `the mutation is extremely ${destabilising} and the calculations are likely to be inaccurate
            (∆∆G: <span class="text-decoration-underline" data-toggle="tooltip" data-title="~${venus.energetical.ddG.toFixed(0)} kcal/mol">&gt; 10</span>
             kcal/mol)`
        } else if (this.energetical.ddG > 5) {
            return `the mutation is strongly ${destabilising} (∆∆G: ${venus.energetical.ddG.toFixed(1)} kcal/mol)`
        } else if (this.energetical.ddG > 2) {
            return `the mutation is mildly ${destabilising} (∆∆G: ${venus.energetical.ddG.toFixed(1)} kcal/mol)`
        } else {
            return null;
        }
    }

    concludeDistance({}) {
        if (this.structural === undefined) {
            return null;
        } else if (this.structural.distance_to_closest_ligand < 12) {
            const name = this.structural.closest_ligand.match(/\[.*\]/) !== null ?
                this.structural.closest_ligand.match(/\[(.*)\]/)[1] :
                'unknown';
            return `the mutation is ${this.structural.distance_to_closest_ligand.toPrecision(2)} 
            &Aring; away from the ligand labelled ${name}`;
        } else {
            return null;
        }
    }
}

//</%text>