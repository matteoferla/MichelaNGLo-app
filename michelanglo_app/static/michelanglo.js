NGL.specialOps = {
    'note': `This is a monkeypatch to allow HTML control of the structure using the markup defined in https://michelanglo.sgc.ox.ac.uk/docs/markup
/* This script adds to NGL the following...

* NGL.stageIds an object taht stores id: stages
* NGL.getStage(id) is a getter for this.
* NGL.specialOps
** NGL.specialOps.showDomain(id, selection, color, view), which focuses stage to show the given selection with the given color
** NGL.specialOps.showResidue(id, selection, color, radius, view), which focuses on the selection and their neighbourhood by n radius
** NGL.specialOps.showClash(id, selection, color, radius, tolerance, view) which shows the clashes that selection may have
** NGL.specialOps.slowOrient deals with the view if provided for these previous three.
** NGL.specialOps.showTitle(id,text) shows the title.
** NGL.specialOps.multiLoader(id, proteins, backgroundColor, startIndex), see below about proteins object
** NGL.specialOps.postInitialise() gets called by load if the stage was not set via multiLoader
** NGL.specialOps.load(option)
** NGL.specialOps.removeImg() switches the image off
** NGL.specialOps._run_loadFx() and a few others.
* NGL.Stage extra prototypes
** NGL.Stage.prototype.getComponentByType allowing stage objects to return a list of components. e.g. .getComponentsByType('structure') to select the protein.
** NGL.Stage.prototype.getComponentByType allowing stage objects to return the first component. e.g. .getComponentByType('structure') to select the protein. If there is none, it raises an error.
** NGL.Stage.prototype.removeComponentsbyName array version.
** NGL.Stage.prototype.removeClashes removes clashes and the rotation.
* $.prototype.protein to enable a link --will run on click.
NB. this file ends with $('[data-toggle="protein"]').protein(); to activate all links.

proteins is an array of {name: 'unique_name', type: 'rcsb' (default) | 'url' | 'data', value: xxx, 'ext': 'pdb' (default), loadFx: xxx}
where the optional loadFx is a function that is run on loading.
`, version: '1.1'
};

NGL.specialOps.version = '0.3.0';

NGL.stageIds = {};

NGL.getStage = function (id) {
    // returns a stage stored in stageIds ...
    // unless somehow a stage was given.
    if (id === undefined) {
        if (myData) {
            id = myData.id
        } else {
            id = 'viewport'
        }
    }
    if (typeof id === 'string') {
        id = id.replace('#', '');
        if (id in NGL.stageIds) {
            return NGL.stageIds[id];
        } else if ($('#' + id + ' img').length !== 0) {
            if (NGL.Debug) {
                console.log('You have not activated the stage yet!');
            }
            NGL.specialOps.load(0);
        } else if (window.stage !== undefined) {
            if (NGL.Debug) {
                console.log('No stored stage in .stageIds, but there is a window.stage...');
            }
            return window.stage;
        } else {
            if (NGL.Debug) {
                console.log('No stored stage in .stageIds nor is a window.stage...');
            }
            return undefined;
        }
    } else if (id.compList !== undefined) { //it's an Stage
        return id;

    } else if (id.stage !== undefined) { //it's an Component
        return id.stage;
    } else {
        if (NGL.Debug) {
            console.log('No idea what this is.');
        }
    }
};

///////////////////////////// NGL.SpecialOps ///////////////


/// show series.

NGL.specialOps.slowOrient = function (id, view) {
    //wrapper for a string view.
    NGL.getStage(id).getComponentByType('structure').autoView(2000); //zoom out.
    if (typeof view !== 'string') {
        NGL.getStage(id).animationControls.orient(view, 2000);
    } else {
        NGL.getStage(id).animationControls.orient(JSON.parse(view), 2000);
    }
};

NGL.specialOps.showDomain = function (id, selection, color, view) {
    if (NGL.debug) {
        console.log('Show domain ' + selection)
    }
    // Prepare
    NGL.specialOps.postInitialise(); //worst case schenario prevention.
    color = color || "green";
    //selection = typeof selection === "string" ? new NGL.Selection(selection) : selection;
    let proteins = NGL.getStage(id).getComponentsByType('structure');
    NGL.getStage(id).removeClashes();
    proteins.map(protein => protein.removeAllRepresentations());
    // Color in!
    let schemeId = NGL.ColormakerRegistry.addSelectionScheme([[color, selection], ["white", "*"]]);
    myData.current_cartoonScheme = schemeId;
    proteins.map(protein => protein.addRepresentation("cartoon", {color: schemeId, smoothSheet: true}));
    NGL.specialOps._orientAfterShow(id, view, selection);
};

NGL.specialOps._orientAfterShow = function (id, view, selection) {
        if (!!view) {
        NGL.specialOps.slowOrient(id, view);
    } else {
        let protein = NGL.getStage(id).getComponentByType('structure');
        //protein.autoView(2000);
        protein.autoView(selection, 2000);
    }

};

NGL.specialOps.showResidue = function (id, selection, color, radius, view, label, cartoonScheme) { //'chainid'
    if (NGL.debug) {
        console.log('Show residues ' + selection)
    }
    //try the selection (its better to crash now than after clearing the scene...)
    // Prepare
    NGL.specialOps.postInitialise(); //worst case schenario prevention.
    // defaults
    color = color || "hotpink";
    radius = radius || 4;
    //selection = typeof selection === "string" ? new NGL.Selection(selection) : selection;
    //get protein
    let proteins = NGL.getStage(id).getComponentsByType('structure');
    let firstExpandedSelection = proteins.map(protein => {
        // corner case that there is no cartoon.
        if (protein.reprList.length === 0) {
            /* so if it is undefined (default) and there is a current Scheme it is set to that but if for some reason there is
            no current scheme and or cartoonScheme is none or false it goes white (as before).
            else the user has specified something like chainid.
            */
            if (((cartoonScheme === 'previous') || (cartoonScheme === undefined)) && (myData.current_cartoonScheme)) {
                protein.addRepresentation("cartoon", {color: myData.current_cartoonScheme, smoothSheet: true})
            } else if ((cartoonScheme === undefined) || (cartoonScheme === false) || (cartoonScheme === 'false') || (cartoonScheme === 'none')) {
                protein.addRepresentation("cartoon", {
                    color: NGL.ColormakerRegistry.addSelectionScheme([["white", "*"]]),
                    smoothSheet: true
                })
            } else {
                protein.addRepresentation("cartoon", {color: cartoonScheme, smoothSheet: true})
            }
        }
        // Remove all bar cartoon-like representation
        ['ball+stick', 'contact', 'label', 'hyperball', 'licorice', 'line', 'point', 'spacefill', 'surface', 'tube'].map(function (value) {
            protein.stage.getRepresentationsByName(value).forEach(function (o) {
                protein.removeRepresentation(o);
            }); //.forEach representation
        }); //.map representation name
        //remove clashes
        NGL.getStage(id).removeClashes();
        var schemeId = NGL.ColormakerRegistry.addSelectionScheme([
            [color, '_C'], ["blue", '_N'], ["red", '_O'], ["white", '_H'], ["yellow", '_S'], ["orange", "*"] //this is such a weird way of doing it.
        ]);
        const expanded = NGL.specialOps.expandSelection(protein, selection, radius);
        protein.addRepresentation("licorice", {sele: expanded});
        protein.addRepresentation("hyperball", {sele: selection.toString(), color: schemeId});
        protein.addRepresentation("contact", {
            masterModelIndex: 0,
            weakHydrogenBond: true,
            maxHbondDonPlaneAngle: 35,
            sele: expanded
        });
        if (!!label) {
            protein.addRepresentation('label', {
                sele: selection.toString(),
                color: color,
                showBackground: true,
                backgroundColor: 'white',
                labelGrouping: 'residue'
            });
        }
        return expanded;
    })[0];
    //reorient.
    NGL.specialOps._orientAfterShow(id, view, firstExpandedSelection);
};

NGL.specialOps.showClash = function (id, selection, color, radius, tolerance, view, label, cartoonScheme) {
    // This find and shows clashes at a given seletion. it calls getClash to find them and then addSpikyball to add them.
    // Prepare
    NGL.specialOps.postInitialise(); //worst case schenario prevention.
    radius = radius || 4;
    NGL.specialOps.showResidue(id, selection, color, radius, view, label, cartoonScheme);
    let proteins = NGL.getStage(id).getComponentsByType('structure');
    proteins.map(protein => NGL.specialOps.getClash(protein, selection)
                                          .map(position => NGL.specialOps.addSpikyball(protein.stage, position)));
};

NGL.specialOps.showSurface = function (id, selection, view) {
    if (NGL.debug) {
        console.log('Show surface ' + selection)
    }
    // Prepare
    NGL.specialOps.postInitialise(); //worst case schenario prevention.
    selection = selection || "polymer";
    var color = 'electrostatic'; //not changeable for now.
    var proteins = NGL.getStage(id).getComponentsByType('structure');
    proteins.map(protein => {
        protein.addRepresentation("surface", {
                                                            sele: selection,
                                                            colorScheme: color,
                                                            colorDomain: [-0.3, 0.3],
                                                            surfaceType: "av"
                                                        });
    });

    NGL.specialOps._orientAfterShow(id, view, selection);
};

NGL.specialOps.showBlur = function (id, selection, color, radius, view, scale, label) {
    if (NGL.debug) {
        console.log('Show surface ' + selection)
    }
    // Prepare
    NGL.specialOps.postInitialise(); //worst case schenario prevention.
    let proteins = NGL.getStage(id).getComponentsByType('structure');
    NGL.getStage(id).removeClashes();
    proteins.map(protein => {
        protein.removeAllRepresentations();
        let bfactors = protein.structure.atomStore.bfactor;
        //console.log(scale);
        //console.log(bfactors.length / bfactors.reduce((a,b)=> a+b, 0));
        scale = scale || bfactors.length / bfactors.reduce((a, b) => a + b, 0);
        protein.addRepresentation("tube", {
            sele: "polymer",
            radiusType: "bfactor",
            radiusScale: scale,
            color: "bfactor",
            colorScale: "RdYlBu"
        });
    });

    if (selection) {
        NGL.specialOps.showResidue(id, selection, color, radius, view, label); //cartoonScheme must/cannot not be implemented!
    } else if (!!view) {
        NGL.specialOps.slowOrient(id, view);
    } else {
        // no selection. NGL.specialOps._orientAfterShow(id, view, selection) needs selection.
        proteins[0].autoView(2000);
    }
};

NGL.specialOps.doubleLoader = function (stage, partner, resolve) {
    let N_proteins = stage.getComponentsByType('structure').length;
    if (N_proteins === 0) {throw 'no protein.'}
    else if (N_proteins === 1) {
        //load the partner
        if (NGL.debug) {
            console.log(partner);
            console.log(window[partner]);
        }
        let m = myData.proteins.filter((prot) => prot.name === partner || prot.value === partner)[0];
        let p;
        window.myData.partner = partner;
        if (m.type === 'data') {
            let pdbblock = m.isVariable === undefined ? m.value : window[partner];
            p = stage.loadFile(new Blob([pdbblock, {type: 'text/plain'}]), {ext: 'pdb', firstModelOnly: true});
        } else if (m.type === 'rcsb') {
            p = stage.loadFile('rcsb://' + m.value);
        } else if (m.type === 'url') {
            p = stage.loadFile(m.value, {ext: 'pdb', firstModelOnly: true});
        } else {
            throw 'Unknown type ' + m.type
        }
        p.then(mutProtein => {
            let proteins = stage.getComponentsByType('structure');
            return resolve(proteins[0], mutProtein);
        });
    } else if (window.myData.partner !== partner) {
        stage.removeComponent(stage.compList[1]);
        return NGL.specialOps.doubleLoader(stage, partner, resolve);
    } else {
        let proteins = stage.getComponentsByType('structure');
        return resolve(proteins[0], proteins[1]);
    }
};

NGL.specialOps.splitColor = function (color) {
    let wtColor = 0x00c78e;
    let mutColor = 0xff5733;
    if (color !== undefined) {
        if (typeof(color) === 'string' && color.includes(' ')) {
            wtColor = color.split(/\W/)[0];
            mutColor = color.split(/\W/)[1];}
        else {
             wtColor = color;
             mutColor = color;
        }
    }
    return [wtColor, mutColor];
};

NGL.specialOps.showOverlay = function (id, partner, selection, color, radius, view, label) {
    // to do. deal with color.
    // Prepare
    let [wtColor, mutColor] = NGL.specialOps.splitColor(color);
    radius = radius || 4;
    NGL.specialOps.postInitialise(); //worst case schenario prevention.
    const stage = NGL.getStage(id);
    stage.removeClashes();

    const commonChange = (protein, scheme) => {
        protein.removeAllRepresentations();
        protein.addRepresentation("cartoon", {color: scheme, sele: '*'});
        protein.addRepresentation("hyperball", {color: scheme, sele: selection});
        const expanded = NGL.specialOps.expandSelection(protein, selection, radius);
        protein.addRepresentation("licorice", {sele: expanded});
        protein.addRepresentation("contact", {
            masterModelIndex: 0,
            weakHydrogenBond: true,
            maxHbondDonPlaneAngle: 35,
            sele: expanded
        });
    };

    const wildtypeChange = (wtProtein) => {
        let wtScheme = NGL.specialOps.schemeMaker(wtColor);
        commonChange(wtProtein, wtScheme);
    };
    const mutChange = (mutProtein) => {
        let mutScheme = NGL.specialOps.schemeMaker(mutColor);
        commonChange(mutProtein, mutScheme);
        NGL.specialOps.getClash(mutProtein, selection)
           .map(position => NGL.specialOps.addSpikyball(mutProtein.stage, position));
    };
    NGL.specialOps.doubleLoader(stage, partner, (wt, mt) => { mutChange(mt);
                                                                    wildtypeChange(wt);
                                                                    if (!!view) {
                                                                        NGL.specialOps.slowOrient(id, view);
                                                                    } else {wt.autoView(selection, 2000);}
                                                                    if (!!label) {
                                                                        NGL.specialOps.showTitle(id, label);
                                                                    }
                                                                    });

};


NGL.specialOps.showDomainOverlay = function (id, partner, selection, color, view, label) {
    // to do. deal with color.
    // Prepare
    let [wtColor, mutColor] = NGL.specialOps.splitColor(color);
    const change = (protein, color, selection) => {
        protein.removeAllRepresentations();
        protein.addRepresentation("cartoon", {color: 'white', sele: `not (${selection})`, smoothSheet: true});
        protein.addRepresentation("cartoon", {color: color, sele: selection, smoothSheet: true});
    };

    NGL.specialOps.postInitialise(); //worst case schenario prevention.
    const stage = NGL.getStage(id);
    stage.removeClashes();
    NGL.specialOps.doubleLoader(stage, partner, (wt, mt) => { change(mt, mutColor, selection);
                                                                      change(wt, wtColor, selection);
                                                                    if (!!view) {
                                                                        NGL.specialOps.slowOrient(id, view);
                                                                    } else {wt.autoView(selection, 2000);}
                                                                    if (!!label) {
                                                                        NGL.specialOps.showTitle(id, label);
                                                                    }
                                                                    });
};

///  other.

NGL.specialOps.isValid = (id, sele) => NGL.getStage(id).getComponentByType('structure').structure.getView(new NGL.Selection(sele)).atomCount > 0;

NGL.specialOps.expandSelection = (protein, selection, radius) => {

            let selector = new NGL.Selection(selection.toString());
            const atomSet = protein.structure.getAtomSetWithinSelection(selector, parseFloat(radius));
            // expand selection to complete groups
            const atomSet2 = protein.structure.getAtomSetWithinGroup(atomSet);
            return atomSet2.toSeleString() + ' and not (' + selection.toString() + ' and not (.C or .N)';
};

NGL.specialOps.getClash = function (protein, selection, tolerance) {
    tolerance = tolerance || 1; //how much is the wiggle room. 0.2 &Aring; is probs good.
        // Find what clashes in the conponent protein.
    let clashPositions = [];
        protein.structure.getView(new NGL.Selection(selection.toString()))
                         .eachAtom(function (atom) {
                protein.structure.eachAtom(function (neighbour) {
                if ([atom.distanceTo(neighbour) < atom.vdw + neighbour.vdw - tolerance, //distance is too close
                    !atom.hasBondTo(neighbour),  //they are not bonded.
                    atom.residueIndex !== neighbour.residueIndex, //they are not intra-residue
                    !(atom.atomname === 'C' && neighbour.atomname === 'N' && parseInt(atom.residueIndex) === parseInt(neighbour.residueIndex) - 1), // not a C-N bond at C-term
                    !(atom.atomname === 'N' && neighbour.atomname === 'C' && parseInt(atom.residueIndex) - 1 === parseInt(neighbour.residueIndex)), // not a C-N bond at N-term
                ].every((s) => !!s)) {
                    //take note to create the ball
                    clashPositions.push([atom.x / 2 + neighbour.x / 2, atom.y / 2 + neighbour.y / 2, atom.z / 2 + neighbour.z / 2]);
                    if (NGL.Debug) {
                        console.log('Clash between ' + atom.atomname + ' of residue (' + atom.vdw.toString() + ' &Aring;) ' + atom.residueIndex + ' and ' +
                            neighbour.atomname + ' of residue ' + neighbour.residueIndex + ' (' + atom.vdw.toString() + ' &Aring;). Distance: ' + atom.distanceTo(neighbour).toString() + ' cutoff: ' + (atom.vdw + neighbour.vdw - tolerance).toString());
                    }
                } //end if
            }); //end neigh atom
        }); //end this atom
    return clashPositions;
    };

NGL.specialOps.addSpikyball = function (stage, position) {
    //position is x, y, z
    const refmesh = [ -0.01,  0.17,  0.34, -0.08,  0.08,  0.11, -0.06,  0.04,  0.13,  0.19,
                     0.15, -0.29,  0.05,   0.0, -0.16,  0.02,  0.04, -0.15,  0.01, -0.15,
                    -0.35,   0.0, -0.15, -0.35,   0.0,   0.0, -0.16,  0.33,  0.17,  0.08,
                     0.33,  0.16,  0.09,  0.15,  0.04, -0.02,  0.19, -0.18,  0.27,  0.05,
                    -0.14,  0.07,  0.09, -0.11,  0.05, -0.01,  0.15,  0.35, -0.01,  0.16,
                     0.34, -0.06,  0.04,  0.13,  0.01, -0.15, -0.35,  0.05,   0.0, -0.16,
                     0.06, -0.04, -0.13,  0.33,  0.17,  0.08,  0.13,  0.08, -0.04,  0.11,
                     0.11,   0.0,  0.19, -0.18,  0.27,  0.19, -0.18,  0.28,  0.02, -0.11,
                      0.1, -0.01,  0.15,  0.35, -0.05,   0.0,  0.16,   0.0,   0.0,  0.16,
                     0.01, -0.17, -0.34,  0.01, -0.16, -0.34,  0.06, -0.04, -0.13,  0.32,
                     0.18,   0.1,  0.32,  0.18,  0.09,  0.11,  0.11,   0.0,  0.01, -0.17,
                    -0.34,  0.08, -0.08, -0.11,  0.04, -0.11,  -0.1,  0.32,  0.18,   0.1,
                     0.08,  0.14,  0.02,  0.08,  0.11,  0.07,  0.01,  0.15,  0.35,   0.0,
                     0.15,  0.35,   0.0,   0.0,  0.16,  0.01,  0.15,  0.35,  0.05,   0.0,
                     0.16,  0.06,  0.04,  0.13,  0.32,  0.17,  0.12,  0.32,  0.18,  0.11,
                     0.08,  0.11,  0.07, -0.32,  0.17,  0.12, -0.32,  0.16,  0.12, -0.11,
                     0.04,   0.1,   0.0, -0.18, -0.33,   0.0, -0.18, -0.34,  0.04, -0.11,
                     -0.1,  0.32,  0.17,  0.12,  0.08,  0.08,  0.11,  0.11,  0.04,   0.1,
                    -0.32,  0.17,  0.12, -0.08,  0.08,  0.11, -0.08,  0.11,  0.07,   0.0,
                    -0.18, -0.33,   0.0, -0.14, -0.09, -0.04, -0.11,  -0.1,  0.32, -0.17,
                    -0.12,  0.32, -0.18, -0.11,  0.08, -0.11, -0.07,  0.33,  0.15,  0.11,
                     0.32,  0.16,  0.12,  0.11,  0.04,   0.1, -0.32,  0.18,   0.1, -0.32,
                     0.18,  0.11, -0.08,  0.11,  0.07,  0.32, -0.17, -0.12,  0.08, -0.08,
                    -0.11,  0.11, -0.04,  -0.1,  0.33,  0.15,  0.11,  0.13,   0.0,  0.09,
                     0.15,   0.0,  0.05, -0.32,  0.18,   0.1, -0.08,  0.14,  0.02, -0.11,
                     0.11,   0.0,  0.33, -0.15, -0.11,  0.32, -0.16, -0.12,  0.11, -0.04,
                     -0.1, -0.33,  0.17,  0.08, -0.32,  0.18,  0.09, -0.11,  0.11,   0.0,
                     0.33, -0.15, -0.11,  0.13,   0.0, -0.09,  0.15,   0.0, -0.05,  0.33,
                     0.15,  0.09,  0.33,  0.15,   0.1,  0.15,   0.0,  0.05, -0.33,  0.17,
                     0.08, -0.13,  0.08, -0.04, -0.15,  0.04, -0.02,  0.33,  0.15,  0.09,
                     0.17,   0.0,   0.0,  0.15,  0.04, -0.02,  0.33, -0.15, -0.09,  0.33,
                    -0.15,  -0.1,  0.15,   0.0, -0.05, -0.19, -0.15,  0.29, -0.19, -0.16,
                     0.29, -0.02, -0.04,  0.15, -0.33,  0.15,  0.09, -0.33,  0.16,  0.09,
                    -0.15,  0.04, -0.02,  0.33, -0.15, -0.09,  0.17,   0.0,   0.0,  0.15,
                    -0.04,  0.02, -0.19, -0.15,  0.29, -0.05,   0.0,  0.16, -0.09,   0.0,
                     0.13, -0.33,  0.15,  0.09, -0.17,   0.0,   0.0, -0.15,   0.0,  0.05,
                     0.33, -0.17, -0.08,  0.33, -0.16, -0.09,  0.15, -0.04,  0.02, -0.21,
                    -0.15,  0.27,  -0.2, -0.15,  0.28, -0.09,   0.0,  0.13,  0.33, -0.17,
                    -0.08,  0.13, -0.08,  0.04,  0.11, -0.11,   0.0, -0.21, -0.15,  0.27,
                    -0.13,   0.0,   0.1, -0.13, -0.04,  0.07, -0.33,  0.15,  0.11, -0.33,
                     0.15,   0.1, -0.15,   0.0,  0.05, -0.33,  0.15,  0.11, -0.13,   0.0,
                     0.09, -0.11,  0.04,   0.1, -0.21, -0.17,  0.26, -0.21, -0.16,  0.27,
                    -0.13, -0.04,  0.07, -0.21,  0.17, -0.26, -0.21,  0.16, -0.27, -0.13,
                     0.04, -0.07,  0.32, -0.18,  -0.1,  0.32, -0.18, -0.09,  0.11, -0.11,
                      0.0, -0.21, -0.17,  0.26, -0.13, -0.08,  0.04, -0.09, -0.11,  0.05,
                    -0.21,  0.17, -0.26, -0.13,  0.08, -0.04, -0.09,  0.11, -0.05,  0.32,
                    -0.18,  -0.1,  0.08, -0.14, -0.02,  0.08, -0.11, -0.07,   0.0, -0.38,
                    -0.01,   0.0, -0.38, -0.01, -0.04, -0.14, -0.05, -0.19, -0.18,  0.27,
                     -0.2, -0.18,  0.27, -0.09, -0.11,  0.05, -0.19,  0.18, -0.27,  -0.2,
                     0.18, -0.27, -0.09,  0.11, -0.05, -0.19, -0.18,  0.27, -0.05, -0.14,
                     0.07, -0.02, -0.11,   0.1, -0.19,  0.18, -0.27, -0.05,  0.14, -0.07,
                    -0.02,  0.11,  -0.1, -0.01, -0.38,   0.0, -0.01, -0.38,   0.0, -0.06,
                    -0.14,  0.02,   0.0, -0.38, -0.01,   0.0, -0.14, -0.08,  0.04, -0.14,
                    -0.05, -0.18,  0.17, -0.28, -0.19,  0.18, -0.28, -0.02,  0.11,  -0.1,
                      0.0,  0.38, -0.01,   0.0,  0.39,   0.0,  0.01,  0.38,   0.0, -0.01,
                     0.38,   0.0,   0.0,  0.39,   0.0,   0.0,  0.38, -0.01,   0.0,  0.38,
                     0.01,   0.0,  0.39,   0.0, -0.01,  0.38,   0.0,   0.0,  0.38,  0.01,
                      0.0,  0.39,   0.0,   0.0,  0.38,  0.01,  0.01,  0.38,   0.0,   0.0,
                     0.39,   0.0,   0.0,  0.38,  0.01,   0.0,  0.18,  0.34,   0.0,  0.17,
                     0.35,  0.01,  0.16,  0.34,   0.0,  0.18,  0.34,   0.0,  0.17,  0.35,
                      0.0,  0.18,  0.34, -0.01,  0.16,  0.34,   0.0,  0.17,  0.35,   0.0,
                     0.18,  0.34,   0.0,  0.15,  0.35,   0.0,  0.17,  0.35, -0.01,  0.16,
                     0.34,  0.01,  0.16,  0.34,   0.0,  0.17,  0.35,   0.0,  0.15,  0.35,
                    -0.32,  0.18,  0.11, -0.33,  0.17,   0.1, -0.32,  0.16,  0.12, -0.32,
                     0.18,  0.09, -0.33,  0.17,   0.1, -0.32,  0.18,  0.11, -0.33,  0.16,
                     0.09, -0.33,  0.17,   0.1, -0.32,  0.18,  0.09, -0.33,  0.15,   0.1,
                    -0.33,  0.17,   0.1, -0.33,  0.16,  0.09, -0.32,  0.16,  0.12, -0.33,
                     0.17,   0.1, -0.33,  0.15,   0.1,  -0.2,  0.18, -0.27,  -0.2,  0.17,
                    -0.28, -0.21,  0.16, -0.27, -0.19,  0.18, -0.28,  -0.2,  0.17, -0.28,
                     -0.2,  0.18, -0.27, -0.19,  0.16, -0.29,  -0.2,  0.17, -0.28, -0.19,
                     0.18, -0.28,  -0.2,  0.15, -0.28,  -0.2,  0.17, -0.28, -0.19,  0.16,
                    -0.29, -0.21,  0.16, -0.27,  -0.2,  0.17, -0.28,  -0.2,  0.15, -0.28,
                     0.19,  0.18, -0.28,   0.2,  0.17, -0.28,  0.19,  0.16, -0.29,   0.2,
                     0.18, -0.27,   0.2,  0.17, -0.28,  0.19,  0.18, -0.28,  0.21,  0.16,
                    -0.27,   0.2,  0.17, -0.28,   0.2,  0.18, -0.27,   0.2,  0.15, -0.28,
                      0.2,  0.17, -0.28,  0.21,  0.16, -0.27,  0.19,  0.16, -0.29,   0.2,
                     0.17, -0.28,   0.2,  0.15, -0.28,  0.32,  0.18,  0.09,  0.33,  0.17,
                      0.1,  0.33,  0.16,  0.09,  0.32,  0.18,  0.11,  0.33,  0.17,   0.1,
                     0.32,  0.18,  0.09,  0.32,  0.16,  0.12,  0.33,  0.17,   0.1,  0.32,
                     0.18,  0.11,  0.33,  0.15,   0.1,  0.33,  0.17,   0.1,  0.32,  0.16,
                     0.12,  0.33,  0.16,  0.09,  0.33,  0.17,   0.1,  0.33,  0.15,   0.1,
                     -0.2, -0.15,  0.28,  -0.2, -0.17,  0.28, -0.19, -0.16,  0.29, -0.21,
                    -0.16,  0.27,  -0.2, -0.17,  0.28,  -0.2, -0.15,  0.28,  -0.2, -0.18,
                     0.27,  -0.2, -0.17,  0.28, -0.21, -0.16,  0.27, -0.19, -0.18,  0.28,
                     -0.2, -0.17,  0.28,  -0.2, -0.18,  0.27, -0.19, -0.16,  0.29,  -0.2,
                    -0.17,  0.28, -0.19, -0.18,  0.28, -0.33, -0.16, -0.09, -0.33, -0.17,
                     -0.1, -0.32, -0.18, -0.09, -0.33, -0.15,  -0.1, -0.33, -0.17,  -0.1,
                    -0.33, -0.16, -0.09, -0.32, -0.16, -0.12, -0.33, -0.17,  -0.1, -0.33,
                    -0.15,  -0.1, -0.32, -0.18, -0.11, -0.33, -0.17,  -0.1, -0.32, -0.16,
                    -0.12, -0.32, -0.18, -0.09, -0.33, -0.17,  -0.1, -0.32, -0.18, -0.11,
                    -0.01, -0.16, -0.34,   0.0, -0.17, -0.35,   0.0, -0.18, -0.34,   0.0,
                    -0.15, -0.35,   0.0, -0.17, -0.35, -0.01, -0.16, -0.34,  0.01, -0.16,
                    -0.34,   0.0, -0.17, -0.35,   0.0, -0.15, -0.35,   0.0, -0.18, -0.34,
                      0.0, -0.17, -0.35,  0.01, -0.16, -0.34,   0.0, -0.18, -0.34,   0.0,
                    -0.17, -0.35,   0.0, -0.18, -0.34,  0.32, -0.16, -0.12,  0.33, -0.17,
                     -0.1,  0.32, -0.18, -0.11,  0.33, -0.15,  -0.1,  0.33, -0.17,  -0.1,
                     0.32, -0.16, -0.12,  0.33, -0.16, -0.09,  0.33, -0.17,  -0.1,  0.33,
                    -0.15,  -0.1,  0.32, -0.18, -0.09,  0.33, -0.17,  -0.1,  0.33, -0.16,
                    -0.09,  0.32, -0.18, -0.11,  0.33, -0.17,  -0.1,  0.32, -0.18, -0.09,
                      0.2, -0.18,  0.27,   0.2, -0.17,  0.28,  0.19, -0.18,  0.28,  0.21,
                    -0.16,  0.27,   0.2, -0.17,  0.28,   0.2, -0.18,  0.27,   0.2, -0.15,
                     0.28,   0.2, -0.17,  0.28,  0.21, -0.16,  0.27,  0.19, -0.16,  0.29,
                      0.2, -0.17,  0.28,   0.2, -0.15,  0.28,  0.19, -0.18,  0.28,   0.2,
                    -0.17,  0.28,  0.19, -0.16,  0.29,  0.01, -0.38,   0.0,   0.0, -0.39,
                      0.0,   0.0, -0.38, -0.01,   0.0, -0.38,  0.01,   0.0, -0.39,   0.0,
                     0.01, -0.38,   0.0, -0.01, -0.38,   0.0,   0.0, -0.39,   0.0,   0.0,
                    -0.38,  0.01,   0.0, -0.38, -0.01,   0.0, -0.39,   0.0, -0.01, -0.38,
                      0.0,   0.0, -0.38, -0.01,   0.0, -0.39,   0.0,   0.0, -0.38, -0.01,
                    -0.15,  0.04, -0.02, -0.15,  0.04, -0.02, -0.17,   0.0,   0.0,  0.17,
                      0.0,   0.0,  0.17,   0.0,   0.0,  0.15, -0.04,  0.02, -0.05,   0.0,
                     0.16, -0.05,   0.0,  0.16, -0.09,   0.0,  0.13, -0.17,   0.0,   0.0,
                    -0.17,   0.0,   0.0, -0.15,   0.0,  0.05,  0.15, -0.04,  0.02,  0.15,
                    -0.04,  0.02,  0.13, -0.08,  0.04, -0.09,   0.0,  0.13, -0.09,   0.0,
                     0.13, -0.13,   0.0,   0.1,  0.13, -0.08,  0.04,  0.13, -0.08,  0.04,
                     0.11, -0.11,   0.0, -0.13,   0.0,   0.1, -0.13,   0.0,   0.1, -0.13,
                    -0.04,  0.07, -0.15,   0.0,  0.05, -0.15,   0.0,  0.05, -0.13,   0.0,
                     0.09, -0.13,   0.0,  0.09, -0.13,   0.0,  0.09, -0.11,  0.04,   0.1,
                    -0.13, -0.04,  0.07, -0.13, -0.04,  0.07, -0.13, -0.08,  0.04, -0.13,
                     0.04, -0.07, -0.13,  0.04, -0.07, -0.13,  0.08, -0.04,  0.11, -0.11,
                      0.0,  0.11, -0.11,   0.0,  0.08, -0.14, -0.02, -0.13, -0.08,  0.04,
                    -0.13, -0.08,  0.04, -0.09, -0.11,  0.05, -0.13,  0.08, -0.04, -0.13,
                     0.08, -0.04, -0.09,  0.11, -0.05,  0.08, -0.14, -0.02,  0.08, -0.14,
                    -0.02,  0.08, -0.11, -0.07, -0.09, -0.11,  0.05, -0.09, -0.11,  0.05,
                    -0.05, -0.14,  0.07, -0.09,  0.11, -0.05, -0.09,  0.11, -0.05, -0.05,
                     0.14, -0.07, -0.05, -0.14,  0.07, -0.05, -0.14,  0.07, -0.02, -0.11,
                      0.1, -0.05,  0.14, -0.07, -0.05,  0.14, -0.07, -0.02,  0.11,  -0.1,
                    -0.02,  0.11,  -0.1, -0.02,  0.11,  -0.1,   0.0,  0.08, -0.14,  0.06,
                     0.14, -0.02,  0.06,  0.14, -0.02,  0.05,  0.14, -0.07, -0.02, -0.11,
                      0.1, -0.02, -0.11,   0.1,   0.0, -0.08,  0.14, -0.04, -0.14, -0.05,
                    -0.04, -0.14, -0.05,   0.0, -0.14, -0.08,   0.0,  0.08, -0.14,   0.0,
                     0.08, -0.14, -0.02,  0.04, -0.15,  0.05,  0.14, -0.07,  0.05,  0.14,
                    -0.07,   0.0,  0.14, -0.07,   0.0, -0.08,  0.14,   0.0, -0.08,  0.14,
                    -0.02, -0.04,  0.15, -0.06, -0.14,  0.02, -0.06, -0.14,  0.02, -0.08,
                    -0.14, -0.02, -0.11, -0.11,   0.0, -0.11, -0.11,   0.0, -0.13, -0.08,
                     0.04, -0.02,  0.04, -0.15, -0.02,  0.04, -0.15, -0.05,   0.0, -0.16,
                      0.0,  0.14, -0.07,   0.0,  0.14, -0.07, -0.05,  0.14, -0.07,   0.0,
                    -0.14, -0.08,   0.0, -0.14, -0.08,  0.04, -0.14, -0.05, -0.13, -0.08,
                     0.04, -0.13, -0.08,  0.04, -0.15, -0.04,  0.02, -0.05,   0.0, -0.16,
                    -0.05,   0.0, -0.16, -0.09,   0.0, -0.13, -0.05,  0.14, -0.07, -0.05,
                     0.14, -0.07, -0.06,  0.14, -0.02, -0.05, -0.14,  0.07, -0.05, -0.14,
                     0.07, -0.06, -0.14,  0.02, -0.15, -0.04,  0.02, -0.15, -0.04,  0.02,
                    -0.17,   0.0,   0.0, -0.06,  0.14, -0.02, -0.06,  0.14, -0.02, -0.08,
                     0.14,  0.02, -0.08, -0.14, -0.02, -0.08, -0.14, -0.02, -0.04, -0.14,
                    -0.05, -0.17,   0.0,   0.0, -0.17,   0.0,   0.0, -0.15,   0.0, -0.05,
                    -0.09,   0.0, -0.13, -0.09,   0.0, -0.13, -0.13,   0.0,  -0.1, -0.08,
                     0.14,  0.02, -0.08,  0.14,  0.02, -0.04,  0.14,  0.05, -0.13,   0.0,
                     -0.1, -0.13,   0.0,  -0.1, -0.13,  0.04, -0.07, -0.15,   0.0, -0.05,
                    -0.15,   0.0, -0.05, -0.13,   0.0, -0.09,   0.0, -0.14,  0.07,   0.0,
                    -0.14,  0.07, -0.05, -0.14,  0.07,  0.02,  0.04, -0.15,  0.02,  0.04,
                    -0.15,   0.0,  0.08, -0.14, -0.04,  0.14,  0.05, -0.04,  0.14,  0.05,
                      0.0,  0.14,  0.08, -0.13,   0.0, -0.09, -0.13,   0.0, -0.09, -0.11,
                    -0.04,  -0.1,   0.0,  0.08, -0.14,   0.0,  0.08, -0.14,  0.02,  0.11,
                     -0.1,   0.0,  0.14,  0.08,   0.0,  0.14,  0.08,  0.04,  0.14,  0.05,
                    -0.11, -0.04,  -0.1, -0.11, -0.04,  -0.1, -0.08, -0.08, -0.11,  0.05,
                    -0.14,  0.07,  0.05, -0.14,  0.07,   0.0, -0.14,  0.07,  0.02,  0.11,
                     -0.1,  0.02,  0.11,  -0.1,  0.05,  0.14, -0.07, -0.08, -0.08, -0.11,
                    -0.08, -0.08, -0.11, -0.08, -0.11, -0.07,   0.0, -0.08,  0.14,   0.0,
                    -0.08,  0.14,  0.02, -0.11,   0.1,  0.05,  0.14, -0.07,  0.05,  0.14,
                    -0.07,  0.09,  0.11, -0.05,  0.04,  0.14,  0.05,  0.04,  0.14,  0.05,
                     0.08,  0.14,  0.02,  0.08, -0.14, -0.02,  0.08, -0.14, -0.02,  0.06,
                    -0.14,  0.02,  0.08,  0.14,  0.02,  0.08,  0.14,  0.02,  0.06,  0.14,
                    -0.02,  0.09,  0.11, -0.05,  0.09,  0.11, -0.05,  0.13,  0.08, -0.04,
                     0.21, -0.15,  0.27,  0.21, -0.16,  0.27,  0.13, -0.04,  0.07,  0.19,
                     0.15, -0.29,   0.2,  0.15, -0.28,  0.09,   0.0, -0.13, -0.01, -0.15,
                    -0.35, -0.05,   0.0, -0.16,   0.0,   0.0, -0.16, -0.01,  0.17,  0.34,
                      0.0,  0.18,  0.34, -0.04,  0.11,   0.1, -0.01, -0.15, -0.35, -0.01,
                    -0.16, -0.34, -0.06, -0.04, -0.13,  0.21, -0.17,  0.26,   0.2, -0.18,
                     0.27,  0.09, -0.11,  0.05,   0.0,  0.18,  0.33,   0.0,  0.14,  0.09,
                    -0.04,  0.11,   0.1,  0.19, -0.15,  0.29,   0.2, -0.15,  0.28,  0.09,
                      0.0,  0.13,  0.21,  0.15, -0.27,  0.13,   0.0,  -0.1,  0.09,   0.0,
                    -0.13, -0.01, -0.17, -0.34, -0.08, -0.08, -0.11, -0.06, -0.04, -0.13,
                      0.0,  0.18,  0.33,   0.0,  0.18,  0.34,  0.04,  0.11,   0.1,  0.21,
                    -0.17,  0.26,  0.13, -0.08,  0.04,  0.13, -0.04,  0.07,  0.21,  0.15,
                    -0.27,  0.21,  0.16, -0.27,  0.13,  0.04, -0.07, -0.01, -0.17, -0.34,
                      0.0, -0.18, -0.34, -0.04, -0.11,  -0.1, -0.32, -0.18,  -0.1, -0.08,
                    -0.14, -0.02, -0.11, -0.11,   0.0,  0.01,  0.17,  0.34,  0.08,  0.08,
                     0.11,  0.04,  0.11,   0.1,  0.01, -0.38,   0.0,   0.0, -0.38, -0.01,
                     0.04, -0.14, -0.05,  0.21,  0.17, -0.26,  0.13,  0.08, -0.04,  0.13,
                     0.04, -0.07, -0.32, -0.18,  -0.1, -0.32, -0.18, -0.11, -0.08, -0.11,
                    -0.07,  0.01,  0.17,  0.34,  0.01,  0.16,  0.34,  0.06,  0.04,  0.13,
                     0.21, -0.15,  0.27,  0.13,   0.0,   0.1,  0.09,   0.0,  0.13,  0.21,
                     0.17, -0.26,   0.2,  0.18, -0.27,  0.09,  0.11, -0.05,  0.01,  0.38,
                      0.0,  0.08,  0.14,  0.02,  0.06,  0.14, -0.02,  0.01, -0.38,  0.01,
                     0.01, -0.38,   0.0,  0.06, -0.14,  0.02,  0.01,  0.38,   0.0,   0.0,
                     0.38,  0.01,  0.04,  0.14,  0.05,  0.19, -0.15,  0.29,  0.05,   0.0,
                     0.16,  0.02, -0.04,  0.15,  0.19,  0.18, -0.27,  0.05,  0.14, -0.07,
                     0.09,  0.11, -0.05, -0.32, -0.17, -0.12, -0.08, -0.08, -0.11, -0.08,
                    -0.11, -0.07,  0.19,  0.18, -0.27,  0.19,  0.18, -0.28,  0.02,  0.11,
                     -0.1, -0.32, -0.17, -0.12, -0.32, -0.16, -0.12, -0.11, -0.04,  -0.1,
                     0.18, -0.17,  0.28,  0.19, -0.16,  0.29,  0.02, -0.04,  0.15,   0.0,
                     0.38,  0.01,   0.0,  0.14,  0.08,  0.04,  0.14,  0.05,  0.18,  0.17,
                    -0.28,   0.0,  0.08, -0.14,  0.02,  0.11,  -0.1, -0.33, -0.15, -0.11,
                    -0.13,   0.0, -0.09, -0.11, -0.04,  -0.1,   0.0,  0.38,  0.01,   0.0,
                     0.38,  0.01, -0.04,  0.14,  0.05,  0.01, -0.38,   0.0,  0.08, -0.14,
                    -0.02,  0.06, -0.14,  0.02,  0.18,  0.17, -0.28,  0.19,  0.16, -0.29,
                     0.02,  0.04, -0.15, -0.33, -0.15, -0.11, -0.33, -0.15,  -0.1, -0.15,
                      0.0, -0.05,  0.18, -0.17,  0.28,   0.0, -0.08,  0.14,  0.02, -0.11,
                      0.1, -0.21,  0.15, -0.27, -0.13,   0.0,  -0.1, -0.13,  0.04, -0.07,
                    -0.01,  0.38,   0.0, -0.08,  0.14,  0.02, -0.04,  0.14,  0.05,  0.01,
                    -0.38,  0.01,  0.05, -0.14,  0.07,   0.0, -0.14,  0.07, -0.21,  0.15,
                    -0.27,  -0.2,  0.15, -0.28, -0.09,   0.0, -0.13, -0.33, -0.15, -0.09,
                    -0.17,   0.0,   0.0, -0.15,   0.0, -0.05, -0.01,  0.38,   0.0, -0.01,
                     0.38,   0.0, -0.06,  0.14, -0.02, -0.33, -0.15, -0.09, -0.33, -0.16,
                    -0.09, -0.15, -0.04,  0.02, -0.01,  0.38, -0.01, -0.05,  0.14, -0.07,
                    -0.06,  0.14, -0.02, -0.01, -0.38,  0.01,   0.0, -0.38,  0.01,   0.0,
                    -0.14,  0.07, -0.19,  0.15, -0.29, -0.05,   0.0, -0.16, -0.09,   0.0,
                    -0.13, -0.33, -0.17, -0.08, -0.13, -0.08,  0.04, -0.15, -0.04,  0.02,
                    -0.01,  0.38, -0.01,   0.0,  0.38, -0.01,   0.0,  0.14, -0.07, -0.19,
                     0.15, -0.29, -0.19,  0.16, -0.29, -0.02,  0.04, -0.15, -0.33, -0.17,
                    -0.08, -0.32, -0.18, -0.09, -0.11, -0.11,   0.0, -0.01, -0.38,   0.0,
                    -0.08, -0.14, -0.02, -0.04, -0.14, -0.05, -0.18, -0.17,  0.28,   0.0,
                    -0.08,  0.14, -0.02, -0.04,  0.15,  0.01,  0.38, -0.01,  0.05,  0.14,
                    -0.07,   0.0,  0.14, -0.07, -0.18,  0.17, -0.28,   0.0,  0.08, -0.14,
                    -0.02,  0.04, -0.15, -0.18, -0.17,  0.28, -0.19, -0.18,  0.28, -0.02,
                    -0.11,   0.1,  0.01,  0.38, -0.01,  0.01,  0.38,   0.0,  0.06,  0.14,
                    -0.02, -0.01, -0.38,  0.01, -0.05, -0.14,  0.07, -0.06, -0.14,  0.02,
                     0.06, -0.14,  0.02,  0.06, -0.14,  0.02,  0.05, -0.14,  0.07,  0.08,
                     0.14,  0.02,  0.08,  0.14,  0.02,  0.06,  0.14, -0.02,  0.09,  0.11,
                    -0.05,  0.09,  0.11, -0.05,  0.13,  0.08, -0.04,  0.05, -0.14,  0.07,
                     0.05, -0.14,  0.07,   0.0, -0.14,  0.07,  0.06,  0.04,  0.13,  0.06,
                     0.04,  0.13,  0.08,  0.08,  0.11, -0.08, -0.11, -0.07, -0.08, -0.11,
                    -0.07, -0.08, -0.14, -0.02,  0.13,  0.08, -0.04,  0.13,  0.08, -0.04,
                     0.13,  0.04, -0.07,  0.08,  0.08,  0.11,  0.08,  0.08,  0.11,  0.04,
                     0.11,   0.1, -0.08, -0.14, -0.02, -0.08, -0.14, -0.02, -0.11, -0.11,
                      0.0,   0.0, -0.14,  0.07,   0.0, -0.14,  0.07, -0.05, -0.14,  0.07,
                    -0.04, -0.11,  -0.1, -0.04, -0.11,  -0.1, -0.08, -0.08, -0.11,  0.13,
                     0.04, -0.07,  0.13,  0.04, -0.07,  0.13,   0.0,  -0.1, -0.05, -0.14,
                     0.07, -0.05, -0.14,  0.07, -0.06, -0.14,  0.02,  0.04,  0.11,   0.1,
                     0.04,  0.11,   0.1,   0.0,  0.14,  0.09, -0.08, -0.08, -0.11, -0.08,
                    -0.08, -0.11, -0.06, -0.04, -0.13,  0.13,   0.0,  -0.1,  0.13,   0.0,
                     -0.1,  0.09,   0.0, -0.13,   0.0,  0.14,  0.09,   0.0,  0.14,  0.09,
                    -0.04,  0.11,   0.1, -0.06, -0.14,  0.02, -0.06, -0.14,  0.02, -0.08,
                    -0.14, -0.02, -0.06, -0.04, -0.13, -0.06, -0.04, -0.13, -0.05,   0.0,
                    -0.16, -0.08, -0.14, -0.02, -0.08, -0.14, -0.02, -0.04, -0.14, -0.05,
                    -0.04,  0.11,   0.1, -0.04,  0.11,   0.1, -0.08,  0.08,  0.11, -0.05,
                      0.0, -0.16, -0.05,   0.0, -0.16,   0.0,   0.0, -0.16,  0.09,   0.0,
                    -0.13,  0.09,   0.0, -0.13,  0.05,   0.0, -0.16, -0.08,  0.08,  0.11,
                    -0.08,  0.08,  0.11, -0.06,  0.04,  0.13,  0.05,   0.0, -0.16,  0.05,
                      0.0, -0.16,  0.02,  0.04, -0.15,   0.0,   0.0, -0.16,   0.0,   0.0,
                    -0.16,  0.05,   0.0, -0.16,  0.15,  0.04, -0.02,  0.15,  0.04, -0.02,
                     0.13,  0.08, -0.04, -0.04, -0.14, -0.05, -0.04, -0.14, -0.05,   0.0,
                    -0.14, -0.08, -0.06,  0.04,  0.13, -0.06,  0.04,  0.13, -0.05,   0.0,
                     0.16,  0.05,   0.0, -0.16,  0.05,   0.0, -0.16,  0.06, -0.04, -0.13,
                     0.13,  0.08, -0.04,  0.13,  0.08, -0.04,  0.11,  0.11,   0.0,   0.0,
                    -0.14, -0.08,   0.0, -0.14, -0.08,  0.04, -0.14, -0.05, -0.05,   0.0,
                     0.16, -0.05,   0.0,  0.16,   0.0,   0.0,  0.16,  0.06, -0.04, -0.13,
                     0.06, -0.04, -0.13,  0.08, -0.08, -0.11,  0.11,  0.11,   0.0,  0.11,
                     0.11,   0.0,  0.08,  0.14,  0.02,  0.08, -0.08, -0.11,  0.08, -0.08,
                    -0.11,  0.04, -0.11,  -0.1,  0.08,  0.14,  0.02,  0.08,  0.14,  0.02,
                     0.08,  0.11,  0.07,   0.0,   0.0,  0.16,   0.0,   0.0,  0.16,  0.05,
                      0.0,  0.16,  0.05,   0.0,  0.16,  0.05,   0.0,  0.16,  0.06,  0.04,
                     0.13,  0.08,  0.11,  0.07,  0.08,  0.11,  0.07,  0.08,  0.08,  0.11,
                    -0.11,  0.04,   0.1, -0.11,  0.04,   0.1, -0.08,  0.08,  0.11,  0.04,
                    -0.11,  -0.1,  0.04, -0.11,  -0.1,   0.0, -0.14, -0.09,  0.08,  0.08,
                     0.11,  0.08,  0.08,  0.11,  0.11,  0.04,   0.1, -0.08,  0.08,  0.11,
                    -0.08,  0.08,  0.11, -0.08,  0.11,  0.07,   0.0, -0.14, -0.09,   0.0,
                    -0.14, -0.09, -0.04, -0.11,  -0.1,  0.08, -0.11, -0.07,  0.08, -0.11,
                    -0.07,  0.08, -0.08, -0.11,  0.11,  0.04,   0.1,  0.11,  0.04,   0.1,
                     0.13,   0.0,  0.09, -0.08,  0.11,  0.07, -0.08,  0.11,  0.07, -0.08,
                     0.14,  0.02,  0.08, -0.08, -0.11,  0.08, -0.08, -0.11,  0.11, -0.04,
                     -0.1,  0.13,   0.0,  0.09,  0.13,   0.0,  0.09,  0.15,   0.0,  0.05,
                    -0.08,  0.14,  0.02, -0.08,  0.14,  0.02, -0.11,  0.11,   0.0,  0.11,
                    -0.04,  -0.1,  0.11, -0.04,  -0.1,  0.13,   0.0, -0.09, -0.11,  0.11,
                      0.0, -0.11,  0.11,   0.0, -0.13,  0.08, -0.04,  0.13,   0.0, -0.09,
                     0.13,   0.0, -0.09,  0.15,   0.0, -0.05,  0.15,   0.0,  0.05,  0.15,
                      0.0,  0.05,  0.17,   0.0,   0.0, -0.13,  0.08, -0.04, -0.13,  0.08,
                    -0.04, -0.15,  0.04, -0.02,  0.17,   0.0,   0.0,  0.17,   0.0,   0.0,
                     0.15,  0.04, -0.02,  0.15,   0.0, -0.05,  0.15,   0.0, -0.05,  0.17,
                      0.0,   0.0, -0.02, -0.04,  0.15, -0.02, -0.04,  0.15, -0.05,   0.0,
                     0.16, -0.15,  0.04, -0.02, -0.15,  0.04, -0.02, -0.17,   0.0,   0.0,
                    -0.02, -0.04,  0.15, -0.02, -0.04,  0.15, -0.05,   0.0,  0.16,  0.15,
                      0.0, -0.05,  0.15,   0.0, -0.05,  0.17,   0.0,   0.0,  0.17,   0.0,
                      0.0,  0.17,   0.0,   0.0,  0.15,  0.04, -0.02, -0.13,  0.08, -0.04,
                    -0.13,  0.08, -0.04, -0.15,  0.04, -0.02,  0.15,   0.0,  0.05,  0.15,
                      0.0,  0.05,  0.17,   0.0,   0.0,  0.13,   0.0, -0.09,  0.13,   0.0,
                    -0.09,  0.15,   0.0, -0.05, -0.11,  0.11,   0.0, -0.11,  0.11,   0.0,
                    -0.13,  0.08, -0.04,  0.11, -0.04,  -0.1,  0.11, -0.04,  -0.1,  0.13,
                      0.0, -0.09, -0.08,  0.14,  0.02, -0.08,  0.14,  0.02, -0.11,  0.11,
                      0.0,  0.13,   0.0,  0.09,  0.13,   0.0,  0.09,  0.15,   0.0,  0.05,
                     0.08, -0.08, -0.11,  0.08, -0.08, -0.11,  0.11, -0.04,  -0.1, -0.08,
                     0.11,  0.07, -0.08,  0.11,  0.07, -0.08,  0.14,  0.02,  0.11,  0.04,
                      0.1,  0.11,  0.04,   0.1,  0.13,   0.0,  0.09,  0.08, -0.11, -0.07,
                     0.08, -0.11, -0.07,  0.08, -0.08, -0.11,   0.0, -0.14, -0.09,   0.0,
                    -0.14, -0.09, -0.04, -0.11,  -0.1, -0.08,  0.08,  0.11, -0.08,  0.08,
                     0.11, -0.08,  0.11,  0.07,  0.08,  0.08,  0.11,  0.08,  0.08,  0.11,
                     0.11,  0.04,   0.1,  0.04, -0.11,  -0.1,  0.04, -0.11,  -0.1,   0.0,
                    -0.14, -0.09, -0.11,  0.04,   0.1, -0.11,  0.04,   0.1, -0.08,  0.08,
                     0.11,  0.08,  0.11,  0.07,  0.08,  0.11,  0.07,  0.08,  0.08,  0.11,
                     0.02, -0.11,   0.1,  0.02, -0.11,   0.1,  0.05, -0.14,  0.07,  0.05,
                      0.0,  0.16,  0.05,   0.0,  0.16,  0.06,  0.04,  0.13,  0.05, -0.14,
                     0.07,  0.05, -0.14,  0.07,  0.09, -0.11,  0.05,   0.0,   0.0,  0.16,
                      0.0,   0.0,  0.16,  0.05,   0.0,  0.16,  0.08,  0.14,  0.02,  0.08,
                     0.14,  0.02,  0.08,  0.11,  0.07,  0.08, -0.08, -0.11,  0.08, -0.08,
                    -0.11,  0.04, -0.11,  -0.1,  0.11,  0.11,   0.0,  0.11,  0.11,   0.0,
                     0.08,  0.14,  0.02,  0.13, -0.04,  0.07,  0.13, -0.04,  0.07,  0.13,
                      0.0,   0.1,  0.06, -0.04, -0.13,  0.06, -0.04, -0.13,  0.08, -0.08,
                    -0.11, -0.05,   0.0,  0.16, -0.05,   0.0,  0.16,   0.0,   0.0,  0.16,
                     0.13,  0.08, -0.04,  0.13,  0.08, -0.04,  0.11,  0.11,   0.0,  0.09,
                    -0.11,  0.05,  0.09, -0.11,  0.05,  0.13, -0.08,  0.04,  0.05,   0.0,
                    -0.16,  0.05,   0.0, -0.16,  0.06, -0.04, -0.13, -0.06,  0.04,  0.13,
                    -0.06,  0.04,  0.13, -0.05,   0.0,  0.16,  0.15,  0.04, -0.02,  0.15,
                     0.04, -0.02,  0.13,  0.08, -0.04,  0.09,   0.0,  0.13,  0.09,   0.0,
                     0.13,  0.05,   0.0,  0.16,   0.0,   0.0, -0.16,   0.0,   0.0, -0.16,
                     0.05,   0.0, -0.16,  0.05,   0.0, -0.16,  0.05,   0.0, -0.16,  0.02,
                     0.04, -0.15,  0.13, -0.08,  0.04,  0.13, -0.08,  0.04,  0.13, -0.04,
                     0.07, -0.08,  0.08,  0.11, -0.08,  0.08,  0.11, -0.06,  0.04,  0.13,
                     0.09,   0.0, -0.13,  0.09,   0.0, -0.13,  0.05,   0.0, -0.16, -0.05,
                      0.0, -0.16, -0.05,   0.0, -0.16,   0.0,   0.0, -0.16, -0.04,  0.11,
                      0.1, -0.04,  0.11,   0.1, -0.08,  0.08,  0.11,  0.04, -0.14, -0.05,
                     0.04, -0.14, -0.05,  0.08, -0.14, -0.02, -0.06, -0.04, -0.13, -0.06,
                    -0.04, -0.13, -0.05,   0.0, -0.16,  0.13,   0.0,   0.1,  0.13,   0.0,
                      0.1,  0.09,   0.0,  0.13,   0.0,  0.14,  0.09,   0.0,  0.14,  0.09,
                    -0.04,  0.11,   0.1,  0.13,   0.0,  -0.1,  0.13,   0.0,  -0.1,  0.09,
                      0.0, -0.13,  0.06, -0.14,  0.02,  0.06, -0.14,  0.02,  0.05, -0.14,
                     0.07, -0.08, -0.08, -0.11, -0.08, -0.08, -0.11, -0.06, -0.04, -0.13,
                     0.04,  0.11,   0.1,  0.04,  0.11,   0.1,   0.0,  0.14,  0.09,  0.13,
                     0.04, -0.07,  0.13,  0.04, -0.07,  0.13,   0.0,  -0.1,  0.05,   0.0,
                     0.16,  0.05,   0.0,  0.16,  0.02, -0.04,  0.15, -0.04, -0.11,  -0.1,
                    -0.04, -0.11,  -0.1, -0.08, -0.08, -0.11, -0.08, -0.14, -0.02, -0.08,
                    -0.14, -0.02, -0.11, -0.11,   0.0,  0.08,  0.08,  0.11,  0.08,  0.08,
                     0.11,  0.04,  0.11,   0.1,  0.13,  0.08, -0.04,  0.13,  0.08, -0.04,
                     0.13,  0.04, -0.07,  0.02, -0.04,  0.15,  0.02, -0.04,  0.15,   0.0,
                    -0.08,  0.14, -0.08, -0.11, -0.07, -0.08, -0.11, -0.07, -0.08, -0.14,
                    -0.02,  0.04, -0.11,  -0.1,  0.08, -0.11, -0.07,  0.04, -0.14, -0.05,
                     0.04, -0.11,  -0.1,  0.08, -0.08, -0.11,  0.08, -0.11, -0.07,  0.04,
                    -0.14, -0.05,  0.08, -0.11, -0.07,  0.08, -0.14, -0.02,  0.08, -0.14,
                    -0.02,  0.08, -0.14, -0.02,  0.04, -0.14, -0.05,  0.04, -0.11,  -0.1,
                     0.04, -0.14, -0.05,   0.0, -0.14, -0.08,  0.04, -0.11,  -0.1,   0.0,
                    -0.14, -0.08,   0.0, -0.14, -0.09,  0.04,  0.14,  0.05,  0.04,  0.14,
                     0.05,  0.08,  0.14,  0.02,  0.05,  0.14, -0.07,  0.05,  0.14, -0.07,
                     0.09,  0.11, -0.05, -0.08, -0.08, -0.11, -0.08, -0.08, -0.11, -0.08,
                    -0.11, -0.07,  0.08, -0.14, -0.02,  0.08, -0.14, -0.02,  0.06, -0.14,
                     0.02,  0.02,  0.11,  -0.1,  0.02,  0.11,  -0.1,  0.05,  0.14, -0.07,
                    -0.11, -0.04,  -0.1, -0.11, -0.04,  -0.1, -0.08, -0.08, -0.11,  0.04,
                    -0.14, -0.05,  0.04, -0.14, -0.05,  0.08, -0.14, -0.02,   0.0,  0.14,
                     0.08,   0.0,  0.14,  0.08,  0.04,  0.14,  0.05,   0.0, -0.08,  0.14,
                      0.0, -0.08,  0.14,  0.02, -0.11,   0.1,   0.0,  0.08, -0.14,   0.0,
                     0.08, -0.14,  0.02,  0.11,  -0.1, -0.13,   0.0, -0.09, -0.13,   0.0,
                    -0.09, -0.11, -0.04,  -0.1, -0.04,  0.14,  0.05, -0.04,  0.14,  0.05,
                      0.0,  0.14,  0.08,  0.02, -0.04,  0.15,  0.02, -0.04,  0.15,   0.0,
                    -0.08,  0.14,  0.02,  0.04, -0.15,  0.02,  0.04, -0.15,   0.0,  0.08,
                    -0.14, -0.15,   0.0, -0.05, -0.15,   0.0, -0.05, -0.13,   0.0, -0.09,
                    -0.13,   0.0,  -0.1, -0.13,   0.0,  -0.1, -0.13,  0.04, -0.07, -0.08,
                     0.14,  0.02, -0.08,  0.14,  0.02, -0.04,  0.14,  0.05, -0.09,   0.0,
                    -0.13, -0.09,   0.0, -0.13, -0.13,   0.0,  -0.1, -0.17,   0.0,   0.0,
                    -0.17,   0.0,   0.0, -0.15,   0.0, -0.05, -0.06,  0.14, -0.02, -0.06,
                     0.14, -0.02, -0.08,  0.14,  0.02,  0.05,   0.0,  0.16,  0.05,   0.0,
                     0.16,  0.02, -0.04,  0.15, -0.15, -0.04,  0.02, -0.15, -0.04,  0.02,
                    -0.17,   0.0,   0.0,  0.09,   0.0,  0.13,  0.09,   0.0,  0.13,  0.05,
                      0.0,  0.16, -0.05,  0.14, -0.07, -0.05,  0.14, -0.07, -0.06,  0.14,
                    -0.02, -0.05,   0.0, -0.16, -0.05,   0.0, -0.16, -0.09,   0.0, -0.13,
                    -0.13, -0.08,  0.04, -0.13, -0.08,  0.04, -0.15, -0.04,  0.02,   0.0,
                     0.14, -0.07,   0.0,  0.14, -0.07, -0.05,  0.14, -0.07,  0.13,   0.0,
                      0.1,  0.13,   0.0,   0.1,  0.09,   0.0,  0.13, -0.02,  0.04, -0.15,
                    -0.02,  0.04, -0.15, -0.05,   0.0, -0.16, -0.11, -0.11,   0.0, -0.11,
                    -0.11,   0.0, -0.13, -0.08,  0.04,  0.13, -0.04,  0.07,  0.13, -0.04,
                     0.07,  0.13,   0.0,   0.1,   0.0, -0.08,  0.14,   0.0, -0.08,  0.14,
                    -0.02, -0.04,  0.15,  0.05,  0.14, -0.07,  0.05,  0.14, -0.07,   0.0,
                     0.14, -0.07,   0.0,  0.08, -0.14,   0.0,  0.08, -0.14, -0.02,  0.04,
                    -0.15, -0.02, -0.11,   0.1, -0.02, -0.11,   0.1,   0.0, -0.08,  0.14,
                     0.06,  0.14, -0.02,  0.06,  0.14, -0.02,  0.05,  0.14, -0.07,  0.13,
                    -0.08,  0.04,  0.13, -0.08,  0.04,  0.13, -0.04,  0.07, -0.02,  0.11,
                     -0.1, -0.02,  0.11,  -0.1,   0.0,  0.08, -0.14,  0.09, -0.11,  0.05,
                     0.09, -0.11,  0.05,  0.13, -0.08,  0.04, -0.05,  0.14, -0.07, -0.05,
                     0.14, -0.07, -0.02,  0.11,  -0.1, -0.05, -0.14,  0.07, -0.05, -0.14,
                     0.07, -0.02, -0.11,   0.1,  0.05, -0.14,  0.07,  0.05, -0.14,  0.07,
                     0.09, -0.11,  0.05, -0.09,  0.11, -0.05, -0.09,  0.11, -0.05, -0.05,
                     0.14, -0.07, -0.09, -0.11,  0.05, -0.09, -0.11,  0.05, -0.05, -0.14,
                     0.07,  0.02, -0.11,   0.1,  0.02, -0.11,   0.1,  0.05, -0.14,  0.07,
                     0.08, -0.14, -0.02,  0.08, -0.14, -0.02,  0.08, -0.11, -0.07, -0.13,
                     0.08, -0.04, -0.13,  0.08, -0.04, -0.09,  0.11, -0.05, -0.13, -0.08,
                     0.04, -0.13, -0.08,  0.04, -0.09, -0.11,  0.05,  0.11, -0.11,   0.0,
                     0.11, -0.11,   0.0,  0.08, -0.14, -0.02, -0.13,  0.04, -0.07, -0.13,
                     0.04, -0.07, -0.13,  0.08, -0.04, -0.13, -0.04,  0.07, -0.13, -0.04,
                     0.07, -0.13, -0.08,  0.04, -0.13,   0.0,  0.09, -0.13,   0.0,  0.09,
                    -0.11,  0.04,   0.1, -0.15,   0.0,  0.05, -0.15,   0.0,  0.05, -0.13,
                      0.0,  0.09, -0.13,   0.0,   0.1, -0.13,   0.0,   0.1, -0.13, -0.04,
                     0.07,  0.13, -0.08,  0.04,  0.13, -0.08,  0.04,  0.11, -0.11,   0.0,
                    -0.09,   0.0,  0.13, -0.09,   0.0,  0.13, -0.13,   0.0,   0.1,  0.15,
                    -0.04,  0.02,  0.15, -0.04,  0.02,  0.13, -0.08,  0.04, -0.17,   0.0,
                      0.0, -0.17,   0.0,   0.0, -0.15,   0.0,  0.05, -0.05,   0.0,  0.16,
                    -0.05,   0.0,  0.16, -0.09,   0.0,  0.13,  0.17,   0.0,   0.0,  0.17,
                      0.0,   0.0,  0.15, -0.04,  0.02,  0.06,  0.04,  0.13,  0.06,  0.04,
                     0.13,  0.08,  0.08,  0.11, -0.04,  0.11,   0.1,   0.0,  0.14,  0.08,
                    -0.04,  0.14,  0.05, -0.08,  0.11,  0.07, -0.08,  0.08,  0.11, -0.04,
                     0.11,   0.1, -0.04,  0.14,  0.05, -0.08,  0.14,  0.02, -0.08,  0.14,
                     0.02, -0.04,  0.14,  0.05, -0.08,  0.14,  0.02, -0.08,  0.11,  0.07,
                    -0.08,  0.08,  0.11, -0.08,  0.08,  0.11, -0.04,  0.11,   0.1, -0.04,
                     0.11,   0.1,   0.0,  0.14,  0.09,   0.0,  0.14,  0.08, -0.09,  0.11,
                    -0.05, -0.13,  0.08, -0.04, -0.11,  0.11,   0.0, -0.06,  0.14, -0.02,
                    -0.05,  0.14, -0.07, -0.05,  0.14, -0.07, -0.06,  0.14, -0.02, -0.05,
                     0.14, -0.07, -0.09,  0.11, -0.05, -0.13,  0.08, -0.04, -0.13,  0.08,
                    -0.04, -0.11,  0.11,   0.0, -0.06,  0.14, -0.02, -0.11,  0.11,   0.0,
                    -0.08,  0.14,  0.02, -0.06,  0.14, -0.02, -0.08,  0.14,  0.02, -0.08,
                     0.14,  0.02,  0.02,  0.11,  -0.1,   0.0,  0.08, -0.14, -0.02,  0.11,
                     -0.1,   0.0,  0.14, -0.07,  0.05,  0.14, -0.07,  0.05,  0.14, -0.07,
                      0.0,  0.14, -0.07,  0.05,  0.14, -0.07,  0.02,  0.11,  -0.1,   0.0,
                     0.08, -0.14,   0.0,  0.08, -0.14, -0.02,  0.11,  -0.1,   0.0,  0.14,
                    -0.07, -0.02,  0.11,  -0.1, -0.05,  0.14, -0.07,   0.0,  0.14, -0.07,
                    -0.05,  0.14, -0.07, -0.05,  0.14, -0.07,  0.11,  0.11,   0.0,  0.13,
                     0.08, -0.04,  0.09,  0.11, -0.05,  0.06,  0.14, -0.02,  0.08,  0.14,
                     0.02,  0.08,  0.14,  0.02,  0.06,  0.14, -0.02,  0.08,  0.14,  0.02,
                     0.11,  0.11,   0.0,  0.13,  0.08, -0.04,  0.13,  0.08, -0.04,  0.09,
                     0.11, -0.05,  0.06,  0.14, -0.02,  0.09,  0.11, -0.05,  0.05,  0.14,
                    -0.07,  0.06,  0.14, -0.02,  0.05,  0.14, -0.07,  0.05,  0.14, -0.07,
                     0.04,  0.14,  0.05,   0.0,  0.14,  0.08,  0.04,  0.11,   0.1,   0.0,
                     0.14,  0.08,   0.0,  0.14,  0.09,  0.04,  0.11,   0.1,  0.04,  0.11,
                      0.1,  0.08,  0.08,  0.11,  0.08,  0.08,  0.11,  0.04,  0.11,   0.1,
                     0.08,  0.08,  0.11,  0.08,  0.11,  0.07,  0.04,  0.14,  0.05,  0.08,
                     0.11,  0.07,  0.08,  0.14,  0.02,  0.04,  0.14,  0.05,  0.08,  0.14,
                     0.02,  0.08,  0.14,  0.02, -0.06,  0.04,  0.13, -0.08,  0.08,  0.11,
                    -0.08,  0.08,  0.11, -0.06,  0.04,  0.13, -0.11,  0.04,   0.1, -0.09,
                      0.0,  0.13, -0.06,  0.04,  0.13, -0.08,  0.08,  0.11, -0.11,  0.04,
                      0.1, -0.09,   0.0,  0.13, -0.11,  0.04,   0.1, -0.13,   0.0,  0.09,
                    -0.13,   0.0,  0.09, -0.13,   0.0,   0.1, -0.09,   0.0,  0.13, -0.09,
                      0.0,  0.13, -0.05,   0.0,  0.16, -0.05,   0.0,  0.16, -0.15, -0.04,
                     0.02, -0.13, -0.08,  0.04, -0.13, -0.04,  0.07, -0.15,   0.0,  0.05,
                    -0.17,   0.0,   0.0, -0.17,   0.0,   0.0, -0.15,   0.0,  0.05, -0.17,
                      0.0,   0.0, -0.15, -0.04,  0.02, -0.13, -0.08,  0.04, -0.13, -0.08,
                     0.04, -0.13, -0.04,  0.07, -0.15,   0.0,  0.05, -0.13, -0.04,  0.07,
                    -0.13,   0.0,   0.1, -0.15,   0.0,  0.05, -0.13,   0.0,   0.1, -0.13,
                      0.0,  0.09, -0.06, -0.04, -0.13, -0.08, -0.08, -0.11, -0.11, -0.04,
                     -0.1, -0.09,   0.0, -0.13, -0.05,   0.0, -0.16, -0.05,   0.0, -0.16,
                    -0.09,   0.0, -0.13, -0.05,   0.0, -0.16, -0.06, -0.04, -0.13, -0.08,
                    -0.08, -0.11, -0.08, -0.08, -0.11, -0.11, -0.04,  -0.1, -0.09,   0.0,
                    -0.13, -0.11, -0.04,  -0.1, -0.13,   0.0, -0.09, -0.09,   0.0, -0.13,
                    -0.13,   0.0, -0.09, -0.13,   0.0,  -0.1,  0.09,   0.0, -0.13,  0.11,
                    -0.04,  -0.1,  0.06, -0.04, -0.13,  0.09,   0.0, -0.13,  0.13,   0.0,
                    -0.09,  0.11, -0.04,  -0.1,  0.06, -0.04, -0.13,  0.11, -0.04,  -0.1,
                     0.08, -0.08, -0.11,  0.08, -0.08, -0.11,  0.08, -0.08, -0.11,  0.06,
                    -0.04, -0.13,  0.09,   0.0, -0.13,  0.06, -0.04, -0.13,  0.05,   0.0,
                    -0.16,  0.09,   0.0, -0.13,  0.05,   0.0, -0.16,  0.05,   0.0, -0.16,
                    -0.15,  0.04, -0.02, -0.13,  0.08, -0.04, -0.13,  0.08, -0.04, -0.15,
                     0.04, -0.02, -0.13,  0.04, -0.07, -0.15,   0.0, -0.05, -0.15,  0.04,
                    -0.02, -0.13,  0.08, -0.04, -0.13,  0.04, -0.07, -0.15,   0.0, -0.05,
                    -0.13,  0.04, -0.07, -0.13,   0.0,  -0.1, -0.13,   0.0,  -0.1, -0.13,
                      0.0, -0.09, -0.15,   0.0, -0.05, -0.15,   0.0, -0.05, -0.17,   0.0,
                      0.0, -0.17,   0.0,   0.0, -0.02,  0.04, -0.15,   0.0,  0.08, -0.14,
                     0.02,  0.04, -0.15,   0.0,   0.0, -0.16, -0.05,   0.0, -0.16, -0.02,
                     0.04, -0.15,  0.02,  0.04, -0.15,  0.05,   0.0, -0.16,   0.0,   0.0,
                    -0.16,   0.0,  0.08, -0.14,   0.0,  0.08, -0.14,  0.02,  0.04, -0.15,
                     0.05,   0.0, -0.16,  0.05,   0.0, -0.16,   0.0,   0.0, -0.16,   0.0,
                      0.0, -0.16, -0.05,   0.0, -0.16, -0.05,   0.0, -0.16,  0.15,   0.0,
                    -0.05,  0.13,   0.0,  -0.1,  0.13,  0.04, -0.07,  0.15,  0.04, -0.02,
                     0.17,   0.0,   0.0,  0.15,   0.0, -0.05,  0.13,  0.04, -0.07,  0.13,
                     0.08, -0.04,  0.13,  0.08, -0.04,  0.13,  0.04, -0.07,  0.13,  0.08,
                    -0.04,  0.15,  0.04, -0.02,  0.17,   0.0,   0.0,  0.17,   0.0,   0.0,
                     0.15,   0.0, -0.05,  0.15,   0.0, -0.05,  0.13,   0.0, -0.09,  0.13,
                      0.0,  -0.1,   0.0,   0.0,  0.16, -0.02, -0.04,  0.15,  0.02, -0.04,
                     0.15,   0.0,   0.0,  0.16, -0.05,   0.0,  0.16, -0.02, -0.04,  0.15,
                     0.02, -0.04,  0.15, -0.02, -0.04,  0.15,   0.0, -0.08,  0.14,   0.0,
                    -0.08,  0.14,   0.0, -0.08,  0.14,  0.02, -0.04,  0.15,   0.0,   0.0,
                     0.16,  0.02, -0.04,  0.15,  0.05,   0.0,  0.16,   0.0,   0.0,  0.16,
                     0.05,   0.0,  0.16,  0.05,   0.0,  0.16,  0.09,   0.0,  0.13,  0.13,
                      0.0,  0.09,  0.11,  0.04,   0.1,  0.06,  0.04,  0.13,  0.05,   0.0,
                     0.16,  0.09,   0.0,  0.13,  0.11,  0.04,   0.1,  0.08,  0.08,  0.11,
                     0.08,  0.08,  0.11,  0.11,  0.04,   0.1,  0.08,  0.08,  0.11,  0.06,
                     0.04,  0.13,  0.05,   0.0,  0.16,  0.05,   0.0,  0.16,  0.09,   0.0,
                     0.13,  0.09,   0.0,  0.13,  0.13,   0.0,   0.1,  0.13,   0.0,  0.09,
                     0.15,   0.0,  0.05,  0.13, -0.04,  0.07,  0.15, -0.04,  0.02,  0.15,
                      0.0,  0.05,  0.13,   0.0,   0.1,  0.13, -0.04,  0.07,  0.15, -0.04,
                     0.02,  0.13, -0.04,  0.07,  0.13, -0.08,  0.04,  0.13, -0.08,  0.04,
                     0.13, -0.08,  0.04,  0.15, -0.04,  0.02,  0.15,   0.0,  0.05,  0.15,
                    -0.04,  0.02,  0.17,   0.0,   0.0,  0.15,   0.0,  0.05,  0.17,   0.0,
                      0.0,  0.17,   0.0,   0.0, -0.09, -0.11,  0.05, -0.13, -0.08,  0.04,
                    -0.13, -0.08,  0.04, -0.09, -0.11,  0.05, -0.11, -0.11,   0.0, -0.06,
                    -0.14,  0.02, -0.09, -0.11,  0.05, -0.13, -0.08,  0.04, -0.11, -0.11,
                      0.0, -0.06, -0.14,  0.02, -0.11, -0.11,   0.0, -0.08, -0.14, -0.02,
                    -0.08, -0.14, -0.02, -0.08, -0.14, -0.02, -0.06, -0.14,  0.02, -0.06,
                    -0.14,  0.02, -0.05, -0.14,  0.07, -0.05, -0.14,  0.07,  0.11, -0.11,
                      0.0,  0.13, -0.08,  0.04,  0.13, -0.08,  0.04,  0.11, -0.11,   0.0,
                     0.09, -0.11,  0.05,  0.06, -0.14,  0.02,  0.11, -0.11,   0.0,  0.13,
                    -0.08,  0.04,  0.09, -0.11,  0.05,  0.06, -0.14,  0.02,  0.09, -0.11,
                     0.05,  0.05, -0.14,  0.07,  0.05, -0.14,  0.07,  0.05, -0.14,  0.07,
                     0.06, -0.14,  0.02,  0.06, -0.14,  0.02,  0.08, -0.14, -0.02,  0.08,
                    -0.14, -0.02, -0.08, -0.11, -0.07, -0.08, -0.08, -0.11, -0.04, -0.11,
                     -0.1, -0.04, -0.14, -0.05, -0.08, -0.14, -0.02, -0.08, -0.11, -0.07,
                    -0.08, -0.08, -0.11, -0.08, -0.08, -0.11, -0.04, -0.11,  -0.1, -0.04,
                    -0.11,  -0.1,   0.0, -0.14, -0.09,   0.0, -0.14, -0.08, -0.04, -0.11,
                     -0.1,   0.0, -0.14, -0.08, -0.04, -0.14, -0.05, -0.04, -0.14, -0.05,
                    -0.08, -0.14, -0.02, -0.08, -0.14, -0.02, -0.02, -0.11,   0.1, -0.05,
                    -0.14,  0.07,   0.0, -0.14,  0.07,  0.02, -0.11,   0.1,   0.0, -0.08,
                     0.14, -0.02, -0.11,   0.1, -0.05, -0.14,  0.07, -0.05, -0.14,  0.07,
                      0.0, -0.14,  0.07,   0.0, -0.14,  0.07,  0.05, -0.14,  0.07,  0.05,
                    -0.14,  0.07,   0.0, -0.14,  0.07,  0.05, -0.14,  0.07,  0.02, -0.11,
                      0.1,  0.02, -0.11,   0.1,   0.0, -0.08,  0.14,   0.0, -0.08,  0.14,
                    -0.01,  0.16,  0.34, -0.01,  0.17,  0.34, -0.06,  0.04,  0.13,  0.19,
                     0.16, -0.29,  0.19,  0.15, -0.29,  0.02,  0.04, -0.15,  0.05,   0.0,
                    -0.16,  0.01, -0.15, -0.35,   0.0,   0.0, -0.16,  0.13,  0.08, -0.04,
                     0.33,  0.17,  0.08,  0.15,  0.04, -0.02,   0.2, -0.18,  0.27,  0.19,
                    -0.18,  0.27,  0.09, -0.11,  0.05, -0.05,   0.0,  0.16, -0.01,  0.15,
                     0.35, -0.06,  0.04,  0.13,  0.01, -0.16, -0.34,  0.01, -0.15, -0.35,
                     0.06, -0.04, -0.13,  0.32,  0.18,  0.09,  0.33,  0.17,  0.08,  0.11,
                     0.11,   0.0,  0.05, -0.14,  0.07,  0.19, -0.18,  0.27,  0.02, -0.11,
                      0.1,   0.0,  0.15,  0.35, -0.01,  0.15,  0.35,   0.0,   0.0,  0.16,
                     0.08, -0.08, -0.11,  0.01, -0.17, -0.34,  0.06, -0.04, -0.13,  0.08,
                     0.14,  0.02,  0.32,  0.18,   0.1,  0.11,  0.11,   0.0,   0.0, -0.18,
                    -0.34,  0.01, -0.17, -0.34,  0.04, -0.11,  -0.1,  0.32,  0.18,  0.11,
                     0.32,  0.18,   0.1,  0.08,  0.11,  0.07,  0.05,   0.0,  0.16,  0.01,
                     0.15,  0.35,   0.0,   0.0,  0.16,  0.01,  0.16,  0.34,  0.01,  0.15,
                     0.35,  0.06,  0.04,  0.13,  0.08,  0.08,  0.11,  0.32,  0.17,  0.12,
                     0.08,  0.11,  0.07, -0.08,  0.08,  0.11, -0.32,  0.17,  0.12, -0.11,
                     0.04,   0.1,   0.0, -0.14, -0.09,   0.0, -0.18, -0.33,  0.04, -0.11,
                     -0.1,  0.32,  0.16,  0.12,  0.32,  0.17,  0.12,  0.11,  0.04,   0.1,
                    -0.32,  0.18,  0.11, -0.32,  0.17,  0.12, -0.08,  0.11,  0.07,   0.0,
                    -0.18, -0.34,   0.0, -0.18, -0.33, -0.04, -0.11,  -0.1,  0.08, -0.08,
                    -0.11,  0.32, -0.17, -0.12,  0.08, -0.11, -0.07,  0.13,   0.0,  0.09,
                     0.33,  0.15,  0.11,  0.11,  0.04,   0.1, -0.08,  0.14,  0.02, -0.32,
                     0.18,   0.1, -0.08,  0.11,  0.07,  0.32, -0.16, -0.12,  0.32, -0.17,
                    -0.12,  0.11, -0.04,  -0.1,  0.33,  0.15,   0.1,  0.33,  0.15,  0.11,
                     0.15,   0.0,  0.05, -0.32,  0.18,  0.09, -0.32,  0.18,   0.1, -0.11,
                     0.11,   0.0,  0.13,   0.0, -0.09,  0.33, -0.15, -0.11,  0.11, -0.04,
                     -0.1, -0.13,  0.08, -0.04, -0.33,  0.17,  0.08, -0.11,  0.11,   0.0,
                     0.33, -0.15,  -0.1,  0.33, -0.15, -0.11,  0.15,   0.0, -0.05,  0.17,
                      0.0,   0.0,  0.33,  0.15,  0.09,  0.15,   0.0,  0.05, -0.33,  0.16,
                     0.09, -0.33,  0.17,  0.08, -0.15,  0.04, -0.02,  0.33,  0.16,  0.09,
                     0.33,  0.15,  0.09,  0.15,  0.04, -0.02,  0.17,   0.0,   0.0,  0.33,
                    -0.15, -0.09,  0.15,   0.0, -0.05, -0.05,   0.0,  0.16, -0.19, -0.15,
                     0.29, -0.02, -0.04,  0.15, -0.17,   0.0,   0.0, -0.33,  0.15,  0.09,
                    -0.15,  0.04, -0.02,  0.33, -0.16, -0.09,  0.33, -0.15, -0.09,  0.15,
                    -0.04,  0.02,  -0.2, -0.15,  0.28, -0.19, -0.15,  0.29, -0.09,   0.0,
                     0.13, -0.33,  0.15,   0.1, -0.33,  0.15,  0.09, -0.15,   0.0,  0.05,
                     0.13, -0.08,  0.04,  0.33, -0.17, -0.08,  0.15, -0.04,  0.02, -0.13,
                      0.0,   0.1, -0.21, -0.15,  0.27, -0.09,   0.0,  0.13,  0.32, -0.18,
                    -0.09,  0.33, -0.17, -0.08,  0.11, -0.11,   0.0, -0.21, -0.16,  0.27,
                    -0.21, -0.15,  0.27, -0.13, -0.04,  0.07, -0.13,   0.0,  0.09, -0.33,
                     0.15,  0.11, -0.15,   0.0,  0.05, -0.32,  0.16,  0.12, -0.33,  0.15,
                     0.11, -0.11,  0.04,   0.1, -0.13, -0.08,  0.04, -0.21, -0.17,  0.26,
                    -0.13, -0.04,  0.07, -0.13,  0.08, -0.04, -0.21,  0.17, -0.26, -0.13,
                     0.04, -0.07,  0.08, -0.14, -0.02,  0.32, -0.18,  -0.1,  0.11, -0.11,
                      0.0,  -0.2, -0.18,  0.27, -0.21, -0.17,  0.26, -0.09, -0.11,  0.05,
                     -0.2,  0.18, -0.27, -0.21,  0.17, -0.26, -0.09,  0.11, -0.05,  0.32,
                    -0.18, -0.11,  0.32, -0.18,  -0.1,  0.08, -0.11, -0.07,   0.0, -0.14,
                    -0.08,   0.0, -0.38, -0.01, -0.04, -0.14, -0.05, -0.05, -0.14,  0.07,
                    -0.19, -0.18,  0.27, -0.09, -0.11,  0.05, -0.05,  0.14, -0.07, -0.19,
                     0.18, -0.27, -0.09,  0.11, -0.05, -0.19, -0.18,  0.28, -0.19, -0.18,
                     0.27, -0.02, -0.11,   0.1, -0.19,  0.18, -0.28, -0.19,  0.18, -0.27,
                    -0.02,  0.11,  -0.1, -0.08, -0.14, -0.02, -0.01, -0.38,   0.0, -0.06,
                    -0.14,  0.02,   0.0, -0.38, -0.01,   0.0, -0.38, -0.01,  0.04, -0.14,
                    -0.05,   0.0,  0.08, -0.14, -0.18,  0.17, -0.28, -0.02,  0.11,  -0.1,
                     0.01,  0.38, -0.01,   0.0,  0.38, -0.01,  0.01,  0.38,   0.0, -0.01,
                     0.38, -0.01, -0.01,  0.38,   0.0,   0.0,  0.38, -0.01, -0.01,  0.38,
                      0.0,   0.0,  0.38,  0.01, -0.01,  0.38,   0.0,   0.0,  0.38,  0.01,
                      0.0,  0.38,  0.01,   0.0,  0.38,  0.01,  0.01,  0.38,   0.0,  0.01,
                     0.38,   0.0,   0.0,  0.38,  0.01,  0.01,  0.17,  0.34,   0.0,  0.18,
                     0.34,  0.01,  0.16,  0.34,   0.0,  0.18,  0.33,   0.0,  0.18,  0.34,
                      0.0,  0.18,  0.34, -0.01,  0.17,  0.34, -0.01,  0.16,  0.34,   0.0,
                     0.18,  0.34, -0.01,  0.15,  0.35,   0.0,  0.15,  0.35, -0.01,  0.16,
                     0.34,  0.01,  0.15,  0.35,  0.01,  0.16,  0.34,   0.0,  0.15,  0.35,
                    -0.32,  0.17,  0.12, -0.32,  0.18,  0.11, -0.32,  0.16,  0.12, -0.32,
                     0.18,   0.1, -0.32,  0.18,  0.09, -0.32,  0.18,  0.11, -0.33,  0.17,
                     0.08, -0.33,  0.16,  0.09, -0.32,  0.18,  0.09, -0.33,  0.15,  0.09,
                    -0.33,  0.15,   0.1, -0.33,  0.16,  0.09, -0.33,  0.15,  0.11, -0.32,
                     0.16,  0.12, -0.33,  0.15,   0.1, -0.21,  0.17, -0.26,  -0.2,  0.18,
                    -0.27, -0.21,  0.16, -0.27, -0.19,  0.18, -0.27, -0.19,  0.18, -0.28,
                     -0.2,  0.18, -0.27, -0.18,  0.17, -0.28, -0.19,  0.16, -0.29, -0.19,
                     0.18, -0.28, -0.19,  0.15, -0.29,  -0.2,  0.15, -0.28, -0.19,  0.16,
                    -0.29, -0.21,  0.15, -0.27, -0.21,  0.16, -0.27,  -0.2,  0.15, -0.28,
                     0.18,  0.17, -0.28,  0.19,  0.18, -0.28,  0.19,  0.16, -0.29,  0.19,
                     0.18, -0.27,   0.2,  0.18, -0.27,  0.19,  0.18, -0.28,  0.21,  0.17,
                    -0.26,  0.21,  0.16, -0.27,   0.2,  0.18, -0.27,  0.21,  0.15, -0.27,
                      0.2,  0.15, -0.28,  0.21,  0.16, -0.27,  0.19,  0.15, -0.29,  0.19,
                     0.16, -0.29,   0.2,  0.15, -0.28,  0.33,  0.17,  0.08,  0.32,  0.18,
                     0.09,  0.33,  0.16,  0.09,  0.32,  0.18,   0.1,  0.32,  0.18,  0.11,
                     0.32,  0.18,  0.09,  0.32,  0.17,  0.12,  0.32,  0.16,  0.12,  0.32,
                     0.18,  0.11,  0.33,  0.15,  0.11,  0.33,  0.15,   0.1,  0.32,  0.16,
                     0.12,  0.33,  0.15,  0.09,  0.33,  0.16,  0.09,  0.33,  0.15,   0.1,
                    -0.19, -0.15,  0.29,  -0.2, -0.15,  0.28, -0.19, -0.16,  0.29, -0.21,
                    -0.15,  0.27, -0.21, -0.16,  0.27,  -0.2, -0.15,  0.28, -0.21, -0.17,
                     0.26,  -0.2, -0.18,  0.27, -0.21, -0.16,  0.27, -0.19, -0.18,  0.27,
                    -0.19, -0.18,  0.28,  -0.2, -0.18,  0.27, -0.18, -0.17,  0.28, -0.19,
                    -0.16,  0.29, -0.19, -0.18,  0.28, -0.33, -0.17, -0.08, -0.33, -0.16,
                    -0.09, -0.32, -0.18, -0.09, -0.33, -0.15, -0.09, -0.33, -0.15,  -0.1,
                    -0.33, -0.16, -0.09, -0.33, -0.15, -0.11, -0.32, -0.16, -0.12, -0.33,
                    -0.15,  -0.1, -0.32, -0.17, -0.12, -0.32, -0.18, -0.11, -0.32, -0.16,
                    -0.12, -0.32, -0.18,  -0.1, -0.32, -0.18, -0.09, -0.32, -0.18, -0.11,
                    -0.01, -0.17, -0.34, -0.01, -0.16, -0.34,   0.0, -0.18, -0.34, -0.01,
                    -0.15, -0.35,   0.0, -0.15, -0.35, -0.01, -0.16, -0.34,  0.01, -0.15,
                    -0.35,  0.01, -0.16, -0.34,   0.0, -0.15, -0.35,  0.01, -0.17, -0.34,
                      0.0, -0.18, -0.34,  0.01, -0.16, -0.34,   0.0, -0.18, -0.33,   0.0,
                    -0.18, -0.34,   0.0, -0.18, -0.34,  0.32, -0.17, -0.12,  0.32, -0.16,
                    -0.12,  0.32, -0.18, -0.11,  0.33, -0.15, -0.11,  0.33, -0.15,  -0.1,
                     0.32, -0.16, -0.12,  0.33, -0.15, -0.09,  0.33, -0.16, -0.09,  0.33,
                    -0.15,  -0.1,  0.33, -0.17, -0.08,  0.32, -0.18, -0.09,  0.33, -0.16,
                    -0.09,  0.32, -0.18,  -0.1,  0.32, -0.18, -0.11,  0.32, -0.18, -0.09,
                     0.19, -0.18,  0.27,   0.2, -0.18,  0.27,  0.19, -0.18,  0.28,  0.21,
                    -0.17,  0.26,  0.21, -0.16,  0.27,   0.2, -0.18,  0.27,  0.21, -0.15,
                     0.27,   0.2, -0.15,  0.28,  0.21, -0.16,  0.27,  0.19, -0.15,  0.29,
                     0.19, -0.16,  0.29,   0.2, -0.15,  0.28,  0.18, -0.17,  0.28,  0.19,
                    -0.18,  0.28,  0.19, -0.16,  0.29,  0.01, -0.38,   0.0,  0.01, -0.38,
                      0.0,   0.0, -0.38, -0.01,  0.01, -0.38,  0.01,   0.0, -0.38,  0.01,
                     0.01, -0.38,   0.0, -0.01, -0.38,  0.01, -0.01, -0.38,   0.0,   0.0,
                    -0.38,  0.01, -0.01, -0.38,   0.0,   0.0, -0.38, -0.01, -0.01, -0.38,
                      0.0,   0.0, -0.38, -0.01,   0.0, -0.38, -0.01,   0.0, -0.38, -0.01,
                    -0.17,   0.0,   0.0, -0.15,  0.04, -0.02, -0.17,   0.0,   0.0,  0.15,
                    -0.04,  0.02,  0.17,   0.0,   0.0,  0.15, -0.04,  0.02, -0.09,   0.0,
                     0.13, -0.05,   0.0,  0.16, -0.09,   0.0,  0.13, -0.15,   0.0,  0.05,
                    -0.17,   0.0,   0.0, -0.15,   0.0,  0.05,  0.13, -0.08,  0.04,  0.15,
                    -0.04,  0.02,  0.13, -0.08,  0.04, -0.13,   0.0,   0.1, -0.09,   0.0,
                     0.13, -0.13,   0.0,   0.1,  0.11, -0.11,   0.0,  0.13, -0.08,  0.04,
                     0.11, -0.11,   0.0, -0.13, -0.04,  0.07, -0.13,   0.0,   0.1, -0.13,
                    -0.04,  0.07, -0.13,   0.0,  0.09, -0.15,   0.0,  0.05, -0.13,   0.0,
                     0.09, -0.11,  0.04,   0.1, -0.13,   0.0,  0.09, -0.11,  0.04,   0.1,
                    -0.13, -0.08,  0.04, -0.13, -0.04,  0.07, -0.13, -0.08,  0.04, -0.13,
                     0.08, -0.04, -0.13,  0.04, -0.07, -0.13,  0.08, -0.04,  0.08, -0.14,
                    -0.02,  0.11, -0.11,   0.0,  0.08, -0.14, -0.02, -0.09, -0.11,  0.05,
                    -0.13, -0.08,  0.04, -0.09, -0.11,  0.05, -0.09,  0.11, -0.05, -0.13,
                     0.08, -0.04, -0.09,  0.11, -0.05,  0.08, -0.11, -0.07,  0.08, -0.14,
                    -0.02,  0.08, -0.11, -0.07, -0.05, -0.14,  0.07, -0.09, -0.11,  0.05,
                    -0.05, -0.14,  0.07, -0.05,  0.14, -0.07, -0.09,  0.11, -0.05, -0.05,
                     0.14, -0.07, -0.02, -0.11,   0.1, -0.05, -0.14,  0.07, -0.02, -0.11,
                      0.1, -0.02,  0.11,  -0.1, -0.05,  0.14, -0.07, -0.02,  0.11,  -0.1,
                      0.0,  0.08, -0.14, -0.02,  0.11,  -0.1,   0.0,  0.08, -0.14,  0.05,
                     0.14, -0.07,  0.06,  0.14, -0.02,  0.05,  0.14, -0.07,   0.0, -0.08,
                     0.14, -0.02, -0.11,   0.1,   0.0, -0.08,  0.14,   0.0, -0.14, -0.08,
                    -0.04, -0.14, -0.05,   0.0, -0.14, -0.08, -0.02,  0.04, -0.15,   0.0,
                     0.08, -0.14, -0.02,  0.04, -0.15,   0.0,  0.14, -0.07,  0.05,  0.14,
                    -0.07,   0.0,  0.14, -0.07, -0.02, -0.04,  0.15,   0.0, -0.08,  0.14,
                    -0.02, -0.04,  0.15, -0.08, -0.14, -0.02, -0.06, -0.14,  0.02, -0.08,
                    -0.14, -0.02, -0.13, -0.08,  0.04, -0.11, -0.11,   0.0, -0.13, -0.08,
                     0.04, -0.05,   0.0, -0.16, -0.02,  0.04, -0.15, -0.05,   0.0, -0.16,
                    -0.05,  0.14, -0.07,   0.0,  0.14, -0.07, -0.05,  0.14, -0.07,  0.04,
                    -0.14, -0.05,   0.0, -0.14, -0.08,  0.04, -0.14, -0.05, -0.15, -0.04,
                     0.02, -0.13, -0.08,  0.04, -0.15, -0.04,  0.02, -0.09,   0.0, -0.13,
                    -0.05,   0.0, -0.16, -0.09,   0.0, -0.13, -0.06,  0.14, -0.02, -0.05,
                     0.14, -0.07, -0.06,  0.14, -0.02, -0.06, -0.14,  0.02, -0.05, -0.14,
                     0.07, -0.06, -0.14,  0.02, -0.17,   0.0,   0.0, -0.15, -0.04,  0.02,
                    -0.17,   0.0,   0.0, -0.08,  0.14,  0.02, -0.06,  0.14, -0.02, -0.08,
                     0.14,  0.02, -0.04, -0.14, -0.05, -0.08, -0.14, -0.02, -0.04, -0.14,
                    -0.05, -0.15,   0.0, -0.05, -0.17,   0.0,   0.0, -0.15,   0.0, -0.05,
                    -0.13,   0.0,  -0.1, -0.09,   0.0, -0.13, -0.13,   0.0,  -0.1, -0.04,
                     0.14,  0.05, -0.08,  0.14,  0.02, -0.04,  0.14,  0.05, -0.13,  0.04,
                    -0.07, -0.13,   0.0,  -0.1, -0.13,  0.04, -0.07, -0.13,   0.0, -0.09,
                    -0.15,   0.0, -0.05, -0.13,   0.0, -0.09, -0.05, -0.14,  0.07,   0.0,
                    -0.14,  0.07, -0.05, -0.14,  0.07,   0.0,  0.08, -0.14,  0.02,  0.04,
                    -0.15,   0.0,  0.08, -0.14,   0.0,  0.14,  0.08, -0.04,  0.14,  0.05,
                      0.0,  0.14,  0.08, -0.11, -0.04,  -0.1, -0.13,   0.0, -0.09, -0.11,
                    -0.04,  -0.1,  0.02,  0.11,  -0.1,   0.0,  0.08, -0.14,  0.02,  0.11,
                     -0.1,  0.04,  0.14,  0.05,   0.0,  0.14,  0.08,  0.04,  0.14,  0.05,
                    -0.08, -0.08, -0.11, -0.11, -0.04,  -0.1, -0.08, -0.08, -0.11,   0.0,
                    -0.14,  0.07,  0.05, -0.14,  0.07,   0.0, -0.14,  0.07,  0.05,  0.14,
                    -0.07,  0.02,  0.11,  -0.1,  0.05,  0.14, -0.07, -0.08, -0.11, -0.07,
                    -0.08, -0.08, -0.11, -0.08, -0.11, -0.07,  0.02, -0.11,   0.1,   0.0,
                    -0.08,  0.14,  0.02, -0.11,   0.1,  0.09,  0.11, -0.05,  0.05,  0.14,
                    -0.07,  0.09,  0.11, -0.05,  0.08,  0.14,  0.02,  0.04,  0.14,  0.05,
                     0.08,  0.14,  0.02,  0.06, -0.14,  0.02,  0.08, -0.14, -0.02,  0.06,
                    -0.14,  0.02,  0.06,  0.14, -0.02,  0.08,  0.14,  0.02,  0.06,  0.14,
                    -0.02,  0.13,  0.08, -0.04,  0.09,  0.11, -0.05,  0.13,  0.08, -0.04,
                     0.13,   0.0,   0.1,  0.21, -0.15,  0.27,  0.13, -0.04,  0.07,  0.05,
                      0.0, -0.16,  0.19,  0.15, -0.29,  0.09,   0.0, -0.13,   0.0, -0.15,
                    -0.35, -0.01, -0.15, -0.35,   0.0,   0.0, -0.16, -0.08,  0.08,  0.11,
                    -0.01,  0.17,  0.34, -0.04,  0.11,   0.1, -0.05,   0.0, -0.16, -0.01,
                    -0.15, -0.35, -0.06, -0.04, -0.13,  0.13, -0.08,  0.04,  0.21, -0.17,
                     0.26,  0.09, -0.11,  0.05,   0.0,  0.18,  0.34,   0.0,  0.18,  0.33,
                    -0.04,  0.11,   0.1,  0.05,   0.0,  0.16,  0.19, -0.15,  0.29,  0.09,
                      0.0,  0.13,   0.2,  0.15, -0.28,  0.21,  0.15, -0.27,  0.09,   0.0,
                    -0.13, -0.01, -0.16, -0.34, -0.01, -0.17, -0.34, -0.06, -0.04, -0.13,
                      0.0,  0.14,  0.09,   0.0,  0.18,  0.33,  0.04,  0.11,   0.1,  0.21,
                    -0.16,  0.27,  0.21, -0.17,  0.26,  0.13, -0.04,  0.07,  0.13,   0.0,
                     -0.1,  0.21,  0.15, -0.27,  0.13,  0.04, -0.07, -0.08, -0.08, -0.11,
                    -0.01, -0.17, -0.34, -0.04, -0.11,  -0.1, -0.32, -0.18, -0.09, -0.32,
                    -0.18,  -0.1, -0.11, -0.11,   0.0,   0.0,  0.18,  0.34,  0.01,  0.17,
                     0.34,  0.04,  0.11,   0.1,  0.08, -0.14, -0.02,  0.01, -0.38,   0.0,
                     0.04, -0.14, -0.05,  0.21,  0.16, -0.27,  0.21,  0.17, -0.26,  0.13,
                     0.04, -0.07, -0.08, -0.14, -0.02, -0.32, -0.18,  -0.1, -0.08, -0.11,
                    -0.07,  0.08,  0.08,  0.11,  0.01,  0.17,  0.34,  0.06,  0.04,  0.13,
                      0.2, -0.15,  0.28,  0.21, -0.15,  0.27,  0.09,   0.0,  0.13,  0.13,
                     0.08, -0.04,  0.21,  0.17, -0.26,  0.09,  0.11, -0.05,  0.01,  0.38,
                      0.0,  0.01,  0.38,   0.0,  0.06,  0.14, -0.02,  0.05, -0.14,  0.07,
                     0.01, -0.38,  0.01,  0.06, -0.14,  0.02,  0.08,  0.14,  0.02,  0.01,
                     0.38,   0.0,  0.04,  0.14,  0.05,  0.19, -0.16,  0.29,  0.19, -0.15,
                     0.29,  0.02, -0.04,  0.15,   0.2,  0.18, -0.27,  0.19,  0.18, -0.27,
                     0.09,  0.11, -0.05, -0.32, -0.18, -0.11, -0.32, -0.17, -0.12, -0.08,
                    -0.11, -0.07,  0.05,  0.14, -0.07,  0.19,  0.18, -0.27,  0.02,  0.11,
                     -0.1, -0.08, -0.08, -0.11, -0.32, -0.17, -0.12, -0.11, -0.04,  -0.1,
                      0.0, -0.08,  0.14,  0.18, -0.17,  0.28,  0.02, -0.04,  0.15,   0.0,
                     0.38,  0.01,   0.0,  0.38,  0.01,  0.04,  0.14,  0.05,  0.19,  0.18,
                    -0.28,  0.18,  0.17, -0.28,  0.02,  0.11,  -0.1, -0.32, -0.16, -0.12,
                    -0.33, -0.15, -0.11, -0.11, -0.04,  -0.1,   0.0,  0.14,  0.08,   0.0,
                     0.38,  0.01, -0.04,  0.14,  0.05,  0.01, -0.38,   0.0,  0.01, -0.38,
                      0.0,  0.06, -0.14,  0.02,   0.0,  0.08, -0.14,  0.18,  0.17, -0.28,
                     0.02,  0.04, -0.15, -0.13,   0.0, -0.09, -0.33, -0.15, -0.11, -0.15,
                      0.0, -0.05,  0.19, -0.18,  0.28,  0.18, -0.17,  0.28,  0.02, -0.11,
                      0.1, -0.21,  0.16, -0.27, -0.21,  0.15, -0.27, -0.13,  0.04, -0.07,
                      0.0,  0.38,  0.01, -0.01,  0.38,   0.0, -0.04,  0.14,  0.05,   0.0,
                    -0.38,  0.01,  0.01, -0.38,  0.01,   0.0, -0.14,  0.07, -0.13,   0.0,
                     -0.1, -0.21,  0.15, -0.27, -0.09,   0.0, -0.13, -0.33, -0.15,  -0.1,
                    -0.33, -0.15, -0.09, -0.15,   0.0, -0.05, -0.08,  0.14,  0.02, -0.01,
                     0.38,   0.0, -0.06,  0.14, -0.02, -0.17,   0.0,   0.0, -0.33, -0.15,
                    -0.09, -0.15, -0.04,  0.02, -0.01,  0.38,   0.0, -0.01,  0.38, -0.01,
                    -0.06,  0.14, -0.02, -0.05, -0.14,  0.07, -0.01, -0.38,  0.01,   0.0,
                    -0.14,  0.07,  -0.2,  0.15, -0.28, -0.19,  0.15, -0.29, -0.09,   0.0,
                    -0.13, -0.33, -0.16, -0.09, -0.33, -0.17, -0.08, -0.15, -0.04,  0.02,
                    -0.05,  0.14, -0.07, -0.01,  0.38, -0.01,   0.0,  0.14, -0.07, -0.05,
                      0.0, -0.16, -0.19,  0.15, -0.29, -0.02,  0.04, -0.15, -0.13, -0.08,
                     0.04, -0.33, -0.17, -0.08, -0.11, -0.11,   0.0,   0.0, -0.38, -0.01,
                    -0.01, -0.38,   0.0, -0.04, -0.14, -0.05, -0.19, -0.16,  0.29, -0.18,
                    -0.17,  0.28, -0.02, -0.04,  0.15,   0.0,  0.38, -0.01,  0.01,  0.38,
                    -0.01,   0.0,  0.14, -0.07, -0.19,  0.16, -0.29, -0.18,  0.17, -0.28,
                    -0.02,  0.04, -0.15,   0.0, -0.08,  0.14, -0.18, -0.17,  0.28, -0.02,
                    -0.11,   0.1,  0.05,  0.14, -0.07,  0.01,  0.38, -0.01,  0.06,  0.14,
                    -0.02, -0.01, -0.38,   0.0, -0.01, -0.38,  0.01, -0.06, -0.14,  0.02,
                     0.05, -0.14,  0.07,  0.06, -0.14,  0.02,  0.05, -0.14,  0.07,  0.06,
                     0.14, -0.02,  0.08,  0.14,  0.02,  0.06,  0.14, -0.02,  0.13,  0.08,
                    -0.04,  0.09,  0.11, -0.05,  0.13,  0.08, -0.04,   0.0, -0.14,  0.07,
                     0.05, -0.14,  0.07,   0.0, -0.14,  0.07,  0.08,  0.08,  0.11,  0.06,
                     0.04,  0.13,  0.08,  0.08,  0.11, -0.08, -0.14, -0.02, -0.08, -0.11,
                    -0.07, -0.08, -0.14, -0.02,  0.13,  0.04, -0.07,  0.13,  0.08, -0.04,
                     0.13,  0.04, -0.07,  0.04,  0.11,   0.1,  0.08,  0.08,  0.11,  0.04,
                     0.11,   0.1, -0.11, -0.11,   0.0, -0.08, -0.14, -0.02, -0.11, -0.11,
                      0.0, -0.05, -0.14,  0.07,   0.0, -0.14,  0.07, -0.05, -0.14,  0.07,
                    -0.08, -0.08, -0.11, -0.04, -0.11,  -0.1, -0.08, -0.08, -0.11,  0.13,
                      0.0,  -0.1,  0.13,  0.04, -0.07,  0.13,   0.0,  -0.1, -0.06, -0.14,
                     0.02, -0.05, -0.14,  0.07, -0.06, -0.14,  0.02,   0.0,  0.14,  0.09,
                     0.04,  0.11,   0.1,   0.0,  0.14,  0.09, -0.06, -0.04, -0.13, -0.08,
                    -0.08, -0.11, -0.06, -0.04, -0.13,  0.09,   0.0, -0.13,  0.13,   0.0,
                     -0.1,  0.09,   0.0, -0.13, -0.04,  0.11,   0.1,   0.0,  0.14,  0.09,
                    -0.04,  0.11,   0.1, -0.08, -0.14, -0.02, -0.06, -0.14,  0.02, -0.08,
                    -0.14, -0.02, -0.05,   0.0, -0.16, -0.06, -0.04, -0.13, -0.05,   0.0,
                    -0.16, -0.04, -0.14, -0.05, -0.08, -0.14, -0.02, -0.04, -0.14, -0.05,
                    -0.08,  0.08,  0.11, -0.04,  0.11,   0.1, -0.08,  0.08,  0.11,   0.0,
                      0.0, -0.16, -0.05,   0.0, -0.16,   0.0,   0.0, -0.16,  0.05,   0.0,
                    -0.16,  0.09,   0.0, -0.13,  0.05,   0.0, -0.16, -0.06,  0.04,  0.13,
                    -0.08,  0.08,  0.11, -0.06,  0.04,  0.13,  0.02,  0.04, -0.15,  0.05,
                      0.0, -0.16,  0.02,  0.04, -0.15,  0.05,   0.0, -0.16,   0.0,   0.0,
                    -0.16,  0.05,   0.0, -0.16,  0.13,  0.08, -0.04,  0.15,  0.04, -0.02,
                     0.13,  0.08, -0.04,   0.0, -0.14, -0.08, -0.04, -0.14, -0.05,   0.0,
                    -0.14, -0.08, -0.05,   0.0,  0.16, -0.06,  0.04,  0.13, -0.05,   0.0,
                     0.16,  0.06, -0.04, -0.13,  0.05,   0.0, -0.16,  0.06, -0.04, -0.13,
                     0.11,  0.11,   0.0,  0.13,  0.08, -0.04,  0.11,  0.11,   0.0,  0.04,
                    -0.14, -0.05,   0.0, -0.14, -0.08,  0.04, -0.14, -0.05,   0.0,   0.0,
                     0.16, -0.05,   0.0,  0.16,   0.0,   0.0,  0.16,  0.08, -0.08, -0.11,
                     0.06, -0.04, -0.13,  0.08, -0.08, -0.11,  0.08,  0.14,  0.02,  0.11,
                     0.11,   0.0,  0.08,  0.14,  0.02,  0.04, -0.11,  -0.1,  0.08, -0.08,
                    -0.11,  0.04, -0.11,  -0.1,  0.08,  0.11,  0.07,  0.08,  0.14,  0.02,
                     0.08,  0.11,  0.07,  0.05,   0.0,  0.16,   0.0,   0.0,  0.16,  0.05,
                      0.0,  0.16,  0.06,  0.04,  0.13,  0.05,   0.0,  0.16,  0.06,  0.04,
                     0.13,  0.08,  0.08,  0.11,  0.08,  0.11,  0.07,  0.08,  0.08,  0.11,
                    -0.08,  0.08,  0.11, -0.11,  0.04,   0.1, -0.08,  0.08,  0.11,   0.0,
                    -0.14, -0.09,  0.04, -0.11,  -0.1,   0.0, -0.14, -0.09,  0.11,  0.04,
                      0.1,  0.08,  0.08,  0.11,  0.11,  0.04,   0.1, -0.08,  0.11,  0.07,
                    -0.08,  0.08,  0.11, -0.08,  0.11,  0.07, -0.04, -0.11,  -0.1,   0.0,
                    -0.14, -0.09, -0.04, -0.11,  -0.1,  0.08, -0.08, -0.11,  0.08, -0.11,
                    -0.07,  0.08, -0.08, -0.11,  0.13,   0.0,  0.09,  0.11,  0.04,   0.1,
                     0.13,   0.0,  0.09, -0.08,  0.14,  0.02, -0.08,  0.11,  0.07, -0.08,
                     0.14,  0.02,  0.11, -0.04,  -0.1,  0.08, -0.08, -0.11,  0.11, -0.04,
                     -0.1,  0.15,   0.0,  0.05,  0.13,   0.0,  0.09,  0.15,   0.0,  0.05,
                    -0.11,  0.11,   0.0, -0.08,  0.14,  0.02, -0.11,  0.11,   0.0,  0.13,
                      0.0, -0.09,  0.11, -0.04,  -0.1,  0.13,   0.0, -0.09, -0.13,  0.08,
                    -0.04, -0.11,  0.11,   0.0, -0.13,  0.08, -0.04,  0.15,   0.0, -0.05,
                     0.13,   0.0, -0.09,  0.15,   0.0, -0.05,  0.17,   0.0,   0.0,  0.15,
                      0.0,  0.05,  0.17,   0.0,   0.0, -0.15,  0.04, -0.02, -0.13,  0.08,
                    -0.04, -0.15,  0.04, -0.02,  0.15,  0.04, -0.02,  0.17,   0.0,   0.0,
                     0.15,  0.04, -0.02,  0.17,   0.0,   0.0,  0.15,   0.0, -0.05,  0.17,
                      0.0,   0.0, -0.05,   0.0,  0.16, -0.02, -0.04,  0.15, -0.05,   0.0,
                     0.16, -0.17,   0.0,   0.0, -0.15,  0.04, -0.02, -0.17,   0.0,   0.0,
                    -0.05,   0.0,  0.16, -0.02, -0.04,  0.15, -0.05,   0.0,  0.16,  0.17,
                      0.0,   0.0,  0.15,   0.0, -0.05,  0.17,   0.0,   0.0,  0.15,  0.04,
                    -0.02,  0.17,   0.0,   0.0,  0.15,  0.04, -0.02, -0.15,  0.04, -0.02,
                    -0.13,  0.08, -0.04, -0.15,  0.04, -0.02,  0.17,   0.0,   0.0,  0.15,
                      0.0,  0.05,  0.17,   0.0,   0.0,  0.15,   0.0, -0.05,  0.13,   0.0,
                    -0.09,  0.15,   0.0, -0.05, -0.13,  0.08, -0.04, -0.11,  0.11,   0.0,
                    -0.13,  0.08, -0.04,  0.13,   0.0, -0.09,  0.11, -0.04,  -0.1,  0.13,
                      0.0, -0.09, -0.11,  0.11,   0.0, -0.08,  0.14,  0.02, -0.11,  0.11,
                      0.0,  0.15,   0.0,  0.05,  0.13,   0.0,  0.09,  0.15,   0.0,  0.05,
                     0.11, -0.04,  -0.1,  0.08, -0.08, -0.11,  0.11, -0.04,  -0.1, -0.08,
                     0.14,  0.02, -0.08,  0.11,  0.07, -0.08,  0.14,  0.02,  0.13,   0.0,
                     0.09,  0.11,  0.04,   0.1,  0.13,   0.0,  0.09,  0.08, -0.08, -0.11,
                     0.08, -0.11, -0.07,  0.08, -0.08, -0.11, -0.04, -0.11,  -0.1,   0.0,
                    -0.14, -0.09, -0.04, -0.11,  -0.1, -0.08,  0.11,  0.07, -0.08,  0.08,
                     0.11, -0.08,  0.11,  0.07,  0.11,  0.04,   0.1,  0.08,  0.08,  0.11,
                     0.11,  0.04,   0.1,   0.0, -0.14, -0.09,  0.04, -0.11,  -0.1,   0.0,
                    -0.14, -0.09, -0.08,  0.08,  0.11, -0.11,  0.04,   0.1, -0.08,  0.08,
                     0.11,  0.08,  0.08,  0.11,  0.08,  0.11,  0.07,  0.08,  0.08,  0.11,
                     0.05, -0.14,  0.07,  0.02, -0.11,   0.1,  0.05, -0.14,  0.07,  0.06,
                     0.04,  0.13,  0.05,   0.0,  0.16,  0.06,  0.04,  0.13,  0.09, -0.11,
                     0.05,  0.05, -0.14,  0.07,  0.09, -0.11,  0.05,  0.05,   0.0,  0.16,
                      0.0,   0.0,  0.16,  0.05,   0.0,  0.16,  0.08,  0.11,  0.07,  0.08,
                     0.14,  0.02,  0.08,  0.11,  0.07,  0.04, -0.11,  -0.1,  0.08, -0.08,
                    -0.11,  0.04, -0.11,  -0.1,  0.08,  0.14,  0.02,  0.11,  0.11,   0.0,
                     0.08,  0.14,  0.02,  0.13,   0.0,   0.1,  0.13, -0.04,  0.07,  0.13,
                      0.0,   0.1,  0.08, -0.08, -0.11,  0.06, -0.04, -0.13,  0.08, -0.08,
                    -0.11,   0.0,   0.0,  0.16, -0.05,   0.0,  0.16,   0.0,   0.0,  0.16,
                     0.11,  0.11,   0.0,  0.13,  0.08, -0.04,  0.11,  0.11,   0.0,  0.13,
                    -0.08,  0.04,  0.09, -0.11,  0.05,  0.13, -0.08,  0.04,  0.06, -0.04,
                    -0.13,  0.05,   0.0, -0.16,  0.06, -0.04, -0.13, -0.05,   0.0,  0.16,
                    -0.06,  0.04,  0.13, -0.05,   0.0,  0.16,  0.13,  0.08, -0.04,  0.15,
                     0.04, -0.02,  0.13,  0.08, -0.04,  0.05,   0.0,  0.16,  0.09,   0.0,
                     0.13,  0.05,   0.0,  0.16,  0.05,   0.0, -0.16,   0.0,   0.0, -0.16,
                     0.05,   0.0, -0.16,  0.02,  0.04, -0.15,  0.05,   0.0, -0.16,  0.02,
                     0.04, -0.15,  0.13, -0.04,  0.07,  0.13, -0.08,  0.04,  0.13, -0.04,
                     0.07, -0.06,  0.04,  0.13, -0.08,  0.08,  0.11, -0.06,  0.04,  0.13,
                     0.05,   0.0, -0.16,  0.09,   0.0, -0.13,  0.05,   0.0, -0.16,   0.0,
                      0.0, -0.16, -0.05,   0.0, -0.16,   0.0,   0.0, -0.16, -0.08,  0.08,
                     0.11, -0.04,  0.11,   0.1, -0.08,  0.08,  0.11,  0.08, -0.14, -0.02,
                     0.04, -0.14, -0.05,  0.08, -0.14, -0.02, -0.05,   0.0, -0.16, -0.06,
                    -0.04, -0.13, -0.05,   0.0, -0.16,  0.09,   0.0,  0.13,  0.13,   0.0,
                      0.1,  0.09,   0.0,  0.13, -0.04,  0.11,   0.1,   0.0,  0.14,  0.09,
                    -0.04,  0.11,   0.1,  0.09,   0.0, -0.13,  0.13,   0.0,  -0.1,  0.09,
                      0.0, -0.13,  0.05, -0.14,  0.07,  0.06, -0.14,  0.02,  0.05, -0.14,
                     0.07, -0.06, -0.04, -0.13, -0.08, -0.08, -0.11, -0.06, -0.04, -0.13,
                      0.0,  0.14,  0.09,  0.04,  0.11,   0.1,   0.0,  0.14,  0.09,  0.13,
                      0.0,  -0.1,  0.13,  0.04, -0.07,  0.13,   0.0,  -0.1,  0.02, -0.04,
                     0.15,  0.05,   0.0,  0.16,  0.02, -0.04,  0.15, -0.08, -0.08, -0.11,
                    -0.04, -0.11,  -0.1, -0.08, -0.08, -0.11, -0.11, -0.11,   0.0, -0.08,
                    -0.14, -0.02, -0.11, -0.11,   0.0,  0.04,  0.11,   0.1,  0.08,  0.08,
                     0.11,  0.04,  0.11,   0.1,  0.13,  0.04, -0.07,  0.13,  0.08, -0.04,
                     0.13,  0.04, -0.07,   0.0, -0.08,  0.14,  0.02, -0.04,  0.15,   0.0,
                    -0.08,  0.14, -0.08, -0.14, -0.02, -0.08, -0.11, -0.07, -0.08, -0.14,
                    -0.02,  0.04, -0.11,  -0.1,  0.08, -0.08, -0.11,  0.08, -0.08, -0.11,
                     0.08,  0.14,  0.02,  0.04,  0.14,  0.05,  0.08,  0.14,  0.02,  0.09,
                     0.11, -0.05,  0.05,  0.14, -0.07,  0.09,  0.11, -0.05, -0.08, -0.11,
                    -0.07, -0.08, -0.08, -0.11, -0.08, -0.11, -0.07,  0.06, -0.14,  0.02,
                     0.08, -0.14, -0.02,  0.06, -0.14,  0.02,  0.05,  0.14, -0.07,  0.02,
                     0.11,  -0.1,  0.05,  0.14, -0.07, -0.08, -0.08, -0.11, -0.11, -0.04,
                     -0.1, -0.08, -0.08, -0.11,  0.08, -0.14, -0.02,  0.04, -0.14, -0.05,
                     0.08, -0.14, -0.02,  0.04,  0.14,  0.05,   0.0,  0.14,  0.08,  0.04,
                     0.14,  0.05,  0.02, -0.11,   0.1,   0.0, -0.08,  0.14,  0.02, -0.11,
                      0.1,  0.02,  0.11,  -0.1,   0.0,  0.08, -0.14,  0.02,  0.11,  -0.1,
                    -0.11, -0.04,  -0.1, -0.13,   0.0, -0.09, -0.11, -0.04,  -0.1,   0.0,
                     0.14,  0.08, -0.04,  0.14,  0.05,   0.0,  0.14,  0.08,   0.0, -0.08,
                     0.14,  0.02, -0.04,  0.15,   0.0, -0.08,  0.14,   0.0,  0.08, -0.14,
                     0.02,  0.04, -0.15,   0.0,  0.08, -0.14, -0.13,   0.0, -0.09, -0.15,
                      0.0, -0.05, -0.13,   0.0, -0.09, -0.13,  0.04, -0.07, -0.13,   0.0,
                     -0.1, -0.13,  0.04, -0.07, -0.04,  0.14,  0.05, -0.08,  0.14,  0.02,
                    -0.04,  0.14,  0.05, -0.13,   0.0,  -0.1, -0.09,   0.0, -0.13, -0.13,
                      0.0,  -0.1, -0.15,   0.0, -0.05, -0.17,   0.0,   0.0, -0.15,   0.0,
                    -0.05, -0.08,  0.14,  0.02, -0.06,  0.14, -0.02, -0.08,  0.14,  0.02,
                     0.02, -0.04,  0.15,  0.05,   0.0,  0.16,  0.02, -0.04,  0.15, -0.17,
                      0.0,   0.0, -0.15, -0.04,  0.02, -0.17,   0.0,   0.0,  0.05,   0.0,
                     0.16,  0.09,   0.0,  0.13,  0.05,   0.0,  0.16, -0.06,  0.14, -0.02,
                    -0.05,  0.14, -0.07, -0.06,  0.14, -0.02, -0.09,   0.0, -0.13, -0.05,
                      0.0, -0.16, -0.09,   0.0, -0.13, -0.15, -0.04,  0.02, -0.13, -0.08,
                     0.04, -0.15, -0.04,  0.02, -0.05,  0.14, -0.07,   0.0,  0.14, -0.07,
                    -0.05,  0.14, -0.07,  0.09,   0.0,  0.13,  0.13,   0.0,   0.1,  0.09,
                      0.0,  0.13, -0.05,   0.0, -0.16, -0.02,  0.04, -0.15, -0.05,   0.0,
                    -0.16, -0.13, -0.08,  0.04, -0.11, -0.11,   0.0, -0.13, -0.08,  0.04,
                     0.13,   0.0,   0.1,  0.13, -0.04,  0.07,  0.13,   0.0,   0.1, -0.02,
                    -0.04,  0.15,   0.0, -0.08,  0.14, -0.02, -0.04,  0.15,   0.0,  0.14,
                    -0.07,  0.05,  0.14, -0.07,   0.0,  0.14, -0.07, -0.02,  0.04, -0.15,
                      0.0,  0.08, -0.14, -0.02,  0.04, -0.15,   0.0, -0.08,  0.14, -0.02,
                    -0.11,   0.1,   0.0, -0.08,  0.14,  0.05,  0.14, -0.07,  0.06,  0.14,
                    -0.02,  0.05,  0.14, -0.07,  0.13, -0.04,  0.07,  0.13, -0.08,  0.04,
                     0.13, -0.04,  0.07,   0.0,  0.08, -0.14, -0.02,  0.11,  -0.1,   0.0,
                     0.08, -0.14,  0.13, -0.08,  0.04,  0.09, -0.11,  0.05,  0.13, -0.08,
                     0.04, -0.02,  0.11,  -0.1, -0.05,  0.14, -0.07, -0.02,  0.11,  -0.1,
                    -0.02, -0.11,   0.1, -0.05, -0.14,  0.07, -0.02, -0.11,   0.1,  0.09,
                    -0.11,  0.05,  0.05, -0.14,  0.07,  0.09, -0.11,  0.05, -0.05,  0.14,
                    -0.07, -0.09,  0.11, -0.05, -0.05,  0.14, -0.07, -0.05, -0.14,  0.07,
                    -0.09, -0.11,  0.05, -0.05, -0.14,  0.07,  0.05, -0.14,  0.07,  0.02,
                    -0.11,   0.1,  0.05, -0.14,  0.07,  0.08, -0.11, -0.07,  0.08, -0.14,
                    -0.02,  0.08, -0.11, -0.07, -0.09,  0.11, -0.05, -0.13,  0.08, -0.04,
                    -0.09,  0.11, -0.05, -0.09, -0.11,  0.05, -0.13, -0.08,  0.04, -0.09,
                    -0.11,  0.05,  0.08, -0.14, -0.02,  0.11, -0.11,   0.0,  0.08, -0.14,
                    -0.02, -0.13,  0.08, -0.04, -0.13,  0.04, -0.07, -0.13,  0.08, -0.04,
                    -0.13, -0.08,  0.04, -0.13, -0.04,  0.07, -0.13, -0.08,  0.04, -0.11,
                     0.04,   0.1, -0.13,   0.0,  0.09, -0.11,  0.04,   0.1, -0.13,   0.0,
                     0.09, -0.15,   0.0,  0.05, -0.13,   0.0,  0.09, -0.13, -0.04,  0.07,
                    -0.13,   0.0,   0.1, -0.13, -0.04,  0.07,  0.11, -0.11,   0.0,  0.13,
                    -0.08,  0.04,  0.11, -0.11,   0.0, -0.13,   0.0,   0.1, -0.09,   0.0,
                     0.13, -0.13,   0.0,   0.1,  0.13, -0.08,  0.04,  0.15, -0.04,  0.02,
                     0.13, -0.08,  0.04, -0.15,   0.0,  0.05, -0.17,   0.0,   0.0, -0.15,
                      0.0,  0.05, -0.09,   0.0,  0.13, -0.05,   0.0,  0.16, -0.09,   0.0,
                     0.13,  0.15, -0.04,  0.02,  0.17,   0.0,   0.0,  0.15, -0.04,  0.02,
                     0.08,  0.08,  0.11,  0.06,  0.04,  0.13,  0.08,  0.08,  0.11, -0.04,
                     0.14,  0.05, -0.08,  0.11,  0.07, -0.04,  0.11,   0.1, -0.06,  0.14,
                    -0.02, -0.09,  0.11, -0.05, -0.11,  0.11,   0.0,   0.0,  0.14, -0.07,
                     0.02,  0.11,  -0.1, -0.02,  0.11,  -0.1,  0.06,  0.14, -0.02,  0.11,
                     0.11,   0.0,  0.09,  0.11, -0.05,  0.04,  0.14,  0.05,  0.04,  0.11,
                      0.1,  0.08,  0.11,  0.07, -0.09,   0.0,  0.13, -0.05,   0.0,  0.16,
                    -0.06,  0.04,  0.13, -0.15,   0.0,  0.05, -0.15, -0.04,  0.02, -0.13,
                    -0.04,  0.07, -0.09,   0.0, -0.13, -0.06, -0.04, -0.13, -0.11, -0.04,
                     -0.1,  0.09,   0.0, -0.13,  0.13,   0.0,  -0.1,  0.13,   0.0, -0.09,
                    -0.15,   0.0, -0.05, -0.17,   0.0,   0.0, -0.15,  0.04, -0.02, -0.02,
                     0.04, -0.15,  0.02,  0.04, -0.15,   0.0,   0.0, -0.16,  0.13,  0.04,
                    -0.07,  0.15,  0.04, -0.02,  0.15,   0.0, -0.05,   0.0,   0.0,  0.16,
                    -0.05,   0.0,  0.16, -0.05,   0.0,  0.16,  0.11,  0.04,   0.1,  0.06,
                     0.04,  0.13,  0.09,   0.0,  0.13,  0.15,   0.0,  0.05,  0.13,   0.0,
                     0.09,  0.13,   0.0,   0.1, -0.06, -0.14,  0.02, -0.05, -0.14,  0.07,
                    -0.09, -0.11,  0.05,  0.06, -0.14,  0.02,  0.08, -0.14, -0.02,  0.11,
                    -0.11,   0.0, -0.08, -0.11, -0.07, -0.04, -0.11,  -0.1, -0.04, -0.14,
                    -0.05, -0.02, -0.11,   0.1,   0.0, -0.14,  0.07,  0.02, -0.11,   0.1 ];

    const fullposition = refmesh.map((v, i) => position[i % 3] + v);
    const fullcolor = refmesh.map((v, i) =>  i % 3 ? 0 : 1); //return color[i % 3]
    let shape = new NGL.Shape("clash");
    let meshBuffer = new NGL.MeshBuffer({
        position: new Float32Array(fullposition),
        color: new Float32Array(fullcolor)
    });
    shape.addBuffer(meshBuffer);
    let shapeComp = stage.addComponentFromObject(shape);
    shapeComp.addRepresentation("buffer");
    if (!myData.spinningTimer) {
        myData.spinningTimer = [];
    }
    myData.spinningTimer.push(setInterval(function () {
        try {
            shapeComp.controls.spin([1, 0, 0], 30)
        } catch (e) {
            //pass. it dissapeared ungracefully!
        }

    }, 100));
    //spikyball made and added.
};

NGL.specialOps.hardReset = function () {  //when the page is faux-refreshed.
    Object.entries(NGL.stageIds).forEach(([k, v]) => $('#' + k).children().detach());
    window.myData = undefined;
    NGL.stageIds = {};
    window.stage = undefined;
    if (NGL.Debug) {
        console.log('HARD RESET.');
    }
};

NGL.specialOps.removeImg = function () {
    var img = '#' + myData.id + ' img';
    if (!!$(img).length) { //there is an image. Remove and get the sizes
        var w = $(img).width();
        var h = $(img).height();
        $(img).detach();
        $('#' + myData.id).css('width', w).css('height', h);
    }
};

NGL.specialOps._run_loadFx = function (protein, fx) {
    if (typeof fx === 'function') {
        fx(protein)
    } else if (typeof fx === 'string') {
        var fxname = fx.replace(/\W/g, '');
        if (window[fxname] !== undefined) {
            setTimeout(() => window[fxname](protein), 100)
        } else {
            setTimeout(() => NGL.specialOps._run_loadFx(protein, fxname), 500)
        } //ansync issue.
    } //prevent XSS
    else {
        //blank? chainbow.
        protein.addRepresentation("cartoon", {smoothSheet: true});
        protein.autoView();
    }
    return protein;
};

NGL.specialOps.load = function (option, noLoadFun) {
    // super extreme case. No multiLoad has been called to initialise the scene. This a last ditch attempt.
    NGL.specialOps.postInitialise();
    // determine what option is.
    var index;
    if (typeof option === "undefined") {
        index = myData.currentIndex;
    } //use is lazy.
    else if (typeof option === "number") {
        index = option;
    } //user gave index.
    else if (typeof option === 'object') { //user gave a protein object
        myData.proteins.push(object);
        index = myData.proteins.length - 1;
    } else if ((typeof option === "string") && (myData.proteins.some(v => v.name === option))) {
        index = myData.proteins.map(v => v.name).indexOf(option);
    } else if ((typeof option === "string") && (myData.proteins.some(v => v.value === option))) {
        index = myData.proteins.map(v => v.value).indexOf(option);
    } else if ((! isNaN(parseInt(option))) && (parseInt(option) < myData.proteins.length)) { //user gave a number as a string.
        index = parseInt(option);
    } else if ((typeof option === "string") && (option.length === 4)) { // user gave pdb code that is new.
        myData.proteins.push({type: 'rcsb', value: option.slice(0, 4)}); //no chains please.
        index = myData.proteins.length - 1;
    } else {
        throw `No idea what this "${option}" user-submitted option is for Michelanglo.js.`
    }
    // check if the one asked for is loaded.
    if ((index === myData.currentIndex)) {
        let proteins = NGL.stageIds[myData.id].getComponentsByType('structure');
        //if (typeof myData.proteins[index].loadFx === 'function') {myData.proteins[index].loadFx(protein)};
        return Promise.all(proteins.map(protein => new Promise(function (resolve, reject) {resolve(protein)})));
    } else {
        myData.currentIndex = index;
        myData.currentChain = myData.proteins[index].chain
    }
    // deal with image.
    if ($('#' + myData.id + ' img')) {
        NGL.specialOps.removeImg();
    }
    // toggle structure
    // - check if there is a stage.
    if (!NGL.getStage(myData.id)) {
        NGL.stageIds[myData.id] = new NGL.Stage(myData.id, {backgroundColor: myData.backgroundColor});
        window.addEventListener("resize", function (event) {
            NGL.stageIds[myData.id].handleResize();
        }, false);
    } else { //tabula rasa!
        NGL.getStage(myData.id).removeAllComponents();
    }
    //new model. Force reset
    if (myData.proteins[index].type === 'url') {
        return NGL.stageIds[myData.id].loadFile(myData.proteins[index].value, {'firstModelOnly': true}).then(function (protein) {
            if (noLoadFun === false || noLoadFun === undefined) {
                NGL.specialOps._run_loadFx(protein, myData.proteins[index].loadFx);
            }
        });
    } else if (myData.proteins[index].type === 'data') {
        var ext = myData.proteins[index].ext || 'pdb';
        if (!! myData.proteins[index].isVariable) {
            let varname = myData.proteins[index].value.replace(/\W/g, '');
            if (window[varname] !== undefined) {
                return NGL.stageIds[myData.id].loadFile(new Blob([window[varname], {type: 'text/plain'}]), {
                    ext: ext,
                    firstModelOnly: true
                })
                    .then(function (protein) {
                        if (noLoadFun === false || noLoadFun === undefined) {
                            NGL.specialOps._run_loadFx(protein, myData.proteins[index].loadFx);
                        }
                    });
            } else { //async issue.
                setTimeout(() => NGL.specialOps.load(option, noLoadFun), 300);
            }
        } else if (typeof myData.proteins[index].value === 'string') {
            return NGL.stageIds[myData.id].loadFile(new Blob([myData.proteins[index].value, {type: 'text/plain'}]), {
                ext: ext,
                firstModelOnly: true
            }).then(function (protein) {
                if (noLoadFun === false || noLoadFun === undefined) {
                    NGL.specialOps._run_loadFx(protein, myData.proteins[index].loadFx);
                }
            });
        } else { //is a blob already
            return NGL.stageIds[myData.id].loadFile(myData.proteins[index].value, {
                ext: ext,
                firstModelOnly: true
            }).then(function (protein) {
                if (noLoadFun === false || noLoadFun === undefined) {
                    NGL.specialOps._run_loadFx(protein, myData.proteins[index].loadFx);
                }
            });
        }
    } else if (myData.proteins[index].type === 'none') {
        myData.currentIndex = -1;  //pass. Super odd backdoor. Why is it needed? Let's keep it secret in case I think it's too weird.
    } else if (myData.proteins[index].value.replace('rcsb://', '').trim().length === 4) { //PDB code.
        return NGL.stageIds[myData.id].loadFile('rcsb://' + myData.proteins[index].value.replace('rcsb://', '').toLowerCase().slice(0, 4), {firstModelOnly: true}).then(function (protein) {
            if (noLoadFun === false || noLoadFun === undefined) {
                NGL.specialOps._run_loadFx(protein, myData.proteins[index].loadFx);
            }
        });
    } else {
        throw 'No idea what this is.';
    }
};

NGL.specialOps.showTitle = function (id, title) {
    // shows a temporary title, which is actually a label element with a for attribute pointing to the viewport id.
    // Consequently if one wanted to override it's location one could add <code>&lt;label for="viewport">&lt;/label></code> where desired.
    if (title) {
        var titleEl = 'label[for="' + id + '"]';
        if (!$(titleEl).length) {
            $('#' + id).after('<label for="' + id + '" style="text-align: center; display: block;">TITLE</label>');
        }
        $(titleEl).html(title).fadeIn(1000).fadeOut(1000);
    }

};

NGL.specialOps.multiLoader = function (id, proteins, backgroundColor, startIndex) {
    /*
    Note that the multiloader does not support multiple viewports.
    id is the id.
    proteins is a list of {name: 'unique_name', type: 'rcsb' (default) | 'file' | 'data', value: xxx, 'ext': 'pdb' , loadFx: xxx}
    where loadFx is the function to run after loading.
    background is a color (def white).
    The multiLoader calls the load function with an index of startIndex or zero.
    Do note that the function load returns a pr
     */
    startIndex = startIndex || 0;
    if (NGL.Debug) {
        console.log('starting multiloader');
        console.log(proteins);
    }
    // prevent body scrolling
    NGL.specialOps._preventScroll(id);
    // check for awkard case it has already been started.
    if (typeof window.myData === 'object') {
        window.myData.proteins.push(...proteins);
    } else {
        window.myData = {currentIndex: -1, proteins: proteins, id: id, backgroundColor: backgroundColor || 'white'};
    }
    var img = $('#' + id + ' img');
    if (img.length) {
        img.css('cursor', 'pointer');
        NGL.specialOps.showTitle(id, 'Click to interact with the protein structure.');
        $('#viewport_menu_popover').click(() => NGL.specialOps.load(startIndex));
        $('#' + id).prepend(`<div style="position:absolute; bottom:2rem; left:2rem; z-index:1001" id="img_label"><i class="far fa-mouse-pointer"></i> Click to intereact</div>`);
        img.click(() => {
            NGL.specialOps.load(startIndex);
            $('#img_label').detach();
        });
    } else {
        return NGL.specialOps.load(startIndex);
    }
};

NGL.specialOps.postInitialise = function () {
    //this should not be used routinely!
    if (typeof window.myData === "undefined") {
        console.log('WARNING. initilise the scene with NGL.specialOps.multiLoader!');
        window.myData = {currentIndex: -1, proteins: [], id: 'viewport', backgroundColor: 'white'};
        NGL.specialOps._preventScroll('viewport');
    }
};

NGL.specialOps._preventScroll = function (id) {
    $('#' + id).on('mousewheel DOMMouseScroll', function (e) {
        var e0 = e.originalEvent,
            delta = e0.wheelDelta || -e0.detail;
        this.scrollTop += (delta < 0 ? 1 : -1) * 30;
        e.preventDefault();
    });
    // fix weid overflow.
    // something somewhere is adding an overflow hidden??
    setTimeout(() => $('#' + myData.id).css('overflow', 'visible'), 1000)
};

// make a scheme based on a color for carbons.
NGL.specialOps.schemeMaker = CarbonColor => NGL.ColormakerRegistry.addScheme(function(params) {
                                            this.atomColor = function (atom) {
                                            let ColorMap = {'N': 0x3333ff, 'C': CarbonColor, 'O': 0xff4c4c, 'S': 0xe5c53f, 'P': 0xff7f00};
                                            if (atom.element in ColorMap) {return +ColorMap[atom.element]}
                                            else {return 0xdcdcdc} //gainsboro
                                            };});

///////////////////////////// NGL.Stage monkeypatching ///////////////

// NGL.Stage.prototype.getComponentByType = function(type) {
//     //gets first structure
//     type = type || 'structure';
//     for (var component in this.compList) {
//         if (this.compList[component].type === type) {return this.compList[component]}
//     }
//     return undefined;
// };

NGL.Stage.prototype.getComponentByType = function (type) {
    // gets first component. If there is none of that type? ouch.
    const components = this.getComponentsByType(type);
    if (components.leght === 0) throw `There is nothing of type ${type}`;
    return components[0];
};


NGL.Stage.prototype.getComponentsByType = function (type) {
    //gets all structure
    type = type || 'structure';
    return this.compList.filter(component => component.type === type);
};

NGL.Stage.prototype.removeComponentsbyName = function (name) {
    // forEach on a shrinking list problem.
    var comps = this.getComponentsByName(name).list;
    var maxi = comps.length;
    for (var i = maxi; i >= 0; i--) {
        this.removeComponent(comps[i]);
    }
};

NGL.Stage.prototype.removeClashes = function () {
    // clashes are special as they have timers.
    if (!myData.spinningTimer) {
        return null;
    }
    this.removeComponentsbyName('clash');
    myData.spinningTimer.forEach(t => clearInterval(t));
    myData.spinningTimer = [];
};

///////////////////////////// activate data-toggle='protein' ///////////////

NGL.specialOps.prolink = function (prolink) { //prolink is a JQuery object.
    //parse
    var selection = $(prolink).data('selection'); //mandatory
    if (typeof selection === 'number') {
        selection = selection.toString()
    }
    var color = $(prolink).data('color'); //optional settings in methods
    var radius = $(prolink).data('radius');
    var tolerance = $(prolink).data('tolerance');
    var structure = $(prolink).data('load');
    var view = $(prolink).data('view');
    var id = 'viewport';
    if ($(prolink).data('target')) {
        id = $(prolink).data('target').replace('#', '')
    } else if (!!$(prolink).attr('href') && !!$(prolink).attr('href').replace('#', '')) { // # alone is not enough
        id = $(prolink).attr('href');
    }
    var title = $(prolink).data('title');
    var focus = $(prolink).data('focus'); // residue | domain | clash
    var hetero = $(prolink).data('hetero') || false;
    var label = $(prolink).data('label');
    if (label === undefined) {
        label = true
    }
    var cartoonScheme = $(prolink).data('cartoonscheme');

    // title.
    NGL.specialOps.showTitle(id, title);

    // prep the action
    function move() {
        let stage = NGL.getStage(id);
        if (view === 'auto') { //special view case.
            stage.getComponentsByType('structure').map(protein => protein.addRepresentation("cartoon", {smoothSheet: true}));
            stage.autoView(2000);
        } else if (view === 'reset') { //special view case.
            // FLAG REFACTOR
            NGL.specialOps._run_loadFx(stage.getComponentByType('structure'), myData.proteins[myData.currentIndex].loadFx);
        } else if ((!!view) && (view !== 'auto') && (typeof view === "string") && (view.match(/^\w+$/) !== null)) { //not auto but different custom fx.
            if (typeof window[view] === 'function') {
                // FLAG REFACTOR
                window[view](stage.getComponentByType('structure'));
            }
        } else if ((!!view) && (!selection)) {  //view, no selection.
            NGL.specialOps.slowOrient(id, view);
        } else if (focus === 'residue') {
            NGL.specialOps.showResidue(id, selection, color, radius, view, label, cartoonScheme);
        } else if (focus === 'domain' || focus === 'region' || focus === undefined) {
            NGL.specialOps.showDomain(id, selection, color, view);
        } else if (focus === 'clash') {
            NGL.specialOps.showClash(id, selection, color, radius, tolerance, view, label, cartoonScheme);
        } else if (focus === 'surface') {
            NGL.specialOps.showSurface(id, selection, view);
        } else if ((focus === 'blur') || (focus === 'bfactor')) {
            NGL.specialOps.showBlur(id, selection, color, radius, view, undefined, label);
        } else if ((focus.includes('domain-overlay'))) {
            let partner = focus.match(/domain-overlay.*?([\w\_]+)/)[1]
            NGL.specialOps.showDomainOverlay(id, partner, selection, color, view, label);
        } else if ((focus.includes('overlay'))) {
            let partner = focus.match(/overlay.*?([\w\_]+)/)[1]
            NGL.specialOps.showOverlay(id, partner, selection, color, radius, view, label);
        } else if (structure !== undefined) { //structure is a string/number argument (e.g. '1UBQ', 1, 'myProteinName')
            console.log('Please add view-reset if you are changing structure as its too ambiguous otherwise.');
        } else {
            throw 'ValueError: odd data-focus tag.'
        }
        // hetero flag is a hack.
        if (!!hetero) {
            stage.getComponentsByType('structure').map(protein => protein.addRepresentation("licorice", {
                colorScheme: "element",
                multipleBond: "symmetric",
                sele: "hetero"
            }))
        }
    }

    // action!
    if (structure !== undefined) { //structure is a string/number argument (e.g. '1UBQ', 1, 'myProteinName')
        NGL.specialOps.load(structure, true).then(move);
    } else {
        move();
    }
};

$.prototype.protein = function () {
    $(this).click(function () {
        NGL.specialOps.prolink(this);
    });
};

$.prototype.viewport = function () {
    if (!$(this).length) {
        return undefined
    }
    // fix width:100%; height: 0; padding-bottom: 100%;
    if (NGL.Debug) {
        console.log('old viewport sizes:' + $(this).width() + 'x' + $(this).height());
    }
    if ($(this).has('img').length === 0) {
        if ($(this).width() === 0) {
            $(this).css('width', '100%');
        }
        if ($(this).height() === 0) {
            let h = Math.min($(this).width(), window.innerHeight - $(this).offset().top - 10);
            h = Math.max(h, 300);
            $(this).height(h);
            //$(this).css('padding-bottom','100%');
            if (NGL.Debug) {
                console.log('new viewport sizes:' + $(this).width() + 'x' + $(this).height());
            }
        }
    }
    // set bare minima.
    if ($(this).height() < 400) {
        $(this).height(400)
    }
    if ($(this).width() < 300) {
        $(this).width(300)
    }
    // sort attributes
    if (!$(this).attr('id')) {
        $(this).attr('id', 'NGLViewport')
    }
    var backgroundcolor = $(this).data('backgroundcolor') || 'white';
    var data = $(this).data('proteins');
    if (typeof data == "object") {/*pass*/
    } else if (data === 'ERROR') {
        throw 'The data-protein is attribute is literally ERROR'
    } else if (typeof data == "string") {
        console.log(data);
        data = JSON.parse(data);
    } else if ($(this).data('load')) {
        data = $(this).data('load').split(',').map(v => ({name: v, value: v, type: 'rcsb'}));
    } else {
        data = [];
    }
    var promise = NGL.specialOps.multiLoader($(this).attr('id'), data, backgroundcolor);
    if ($(this).data('focus') || $(this).data('view')) {
        if ($(this).has('img').length !== 0) {
            $(this).children('img').on("click", e => setTimeout(() => NGL.specialOps.prolink(this), 500));
            //could this be done with a promise?
        } else {
            var prolink = this;
            promise.then(function () {
                    NGL.specialOps.prolink(prolink)
                }
            )
        }
    }
};


$(document).ready(function () { //
    //activate prolinks
    $('[data-toggle="protein"]:not([role="NGL"])').protein();
    //activate viewport
    $('[role="NGL"],[role="proteinViewport"],[role="proteinviewport"],[role="protein_viewport"]').viewport();
});
