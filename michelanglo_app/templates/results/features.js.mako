####### THIS IS A JS FILE ##########################
####### THE EXTENSION IS MAKO AS THE RENDERER IS MAKO
####### THIS IS NOT GREAT CODING.
// <script>



### see get_uniprot item of choose_pdb route
<%!
    import json
%>

### copied from results.js.mako in VENUS
###################################################
window.ft = new FeatureViewer('${protein.sequence}',
           '${featureView}',
            {
                showAxis: true,
                showSequence: true,
                brushActive: true, //zoom
                toolbar:true, //current zoom & mouse position
                bubbleHelp:false,
                zoomMax:50 //define the maximum range of the zoom
            });

const addFeatureTooltip = (featLabel, text) => $('.yaxis:contains('+featLabel+')').parent().tooltip({title: text, trigger: 'hover focus'});



################### Own SNV #######################

## %if hasattr(protein, 'mutation'):
##     ft.addFeature({
##             data: [{'x':${protein.mutation.residue_index},'y': ${protein.mutation.residue_index}, 'id': 'our_${protein.mutation.residue_index}', 'description': 'p.${str(protein.mutation)}'}],
##             name: "Candidate SNP",
##             className: "our_SNP",
##             color: "indianred",
##             type: "unique",
##             filter: "Variant"
##         });
## %endif

################### Domains #######################
%if 'domain' in protein.features:
    ft.addFeature({
        data: ${str(protein.features['domain'])|n},
        name: "Domain",
        className: "domain",
        color: "lightblue",
        type: "rect",
        filter: "Domain"
    });
    addFeatureTooltip("Domain", "Domain annotation from Uniprot entry, derived in turn from PFam");
%endif

<%

    def feature_viewer_standardise(dex):
        for entry in dex:
            if 'x' not in entry and 'residue_index':
                entry['x'] = entry['residue_index']
                if 'y' not in entry:
                    entry['y'] = entry['residue_index']
            if 'description' not in entry:
                if 'ptm' in entry:
                    entry['description'] = entry['from_residue']+str(entry['residue_index'])+entry['ptm']
            if 'id' not in entry and 'description' in entry:
                    entry['id'] = entry['description'].replace(' ','_')
        return dex


    combo_roi=[]
    for key in ('transmembrane region','intramembrane region','region of interest','peptide','site','active site','binding site','calcium-binding region','zinc finger region','metal ion-binding site','DNA-binding region','lipid moiety-binding region', 'nucleotide phosphate-binding region'):
        if key in protein.features:
            combo_roi.extend(feature_viewer_standardise(protein.features[key]))

    combo_other=[]
    for key in ('propeptide','signal peptide','repeat','coiled-coil region','compositionally biased region','short sequence motif','topological domain','transit peptide'):
        if key in protein.features:
            combo_other.extend(feature_viewer_standardise(protein.features[key]))

    combo_ptm=[]
    for key in ('initiator methionine','modified residue','glycosylation site','non-standard amino acid'):
        if key in protein.features:
            combo_ptm.extend(feature_viewer_standardise(protein.features[key]))

    combo_ss=[]
    for key in ('helix', 'turn', 'strand'):
        if key in protein.features:
            combo_ss.extend(feature_viewer_standardise(protein.features[key]))
%>
%if combo_roi:
    ft.addFeature({
        data: ${str(combo_roi)|n},
        name: "region of interest",
        className: "domain",
        color: "teal",
        type: "rect",
        filter: "Domain"
    });

    addFeatureTooltip("region of interest", "A collection of various Uniprot annotations: 'transmembrane region','intramembrane region','region of interest','peptide','site','active site','binding site','calcium-binding region','zinc finger region','metal ion-binding site','DNA-binding region','lipid moiety-binding region', 'nucleotide phosphate-binding region'");
%endif

%if combo_other:
    ft.addFeature({
        data: ${str(combo_other)|n},
        name: "other regions",
        className: "domain",
        color: "lavender",
        type: "rect",
        filter: "Domain"
    });
    addFeatureTooltip("other regions", "A collection of various Uniprot annotations: 'propeptide','signal peptide','repeat','coiled-coil region','compositionally biased region','short sequence motif','topological domain','transit peptide'");
%endif

%if combo_ptm:
    ft.addFeature({
        data: ${str(combo_ptm)|n},
        name: "Modified residues",
        className: "modified",
        color: "slateblue",
        type: "unique",
        filter: "Modified"
    });
    addFeatureTooltip("Modified residues", "A collection of various Uniprot annotations: 'initiator methionine','modified residue','glycosylation site','non-standard amino acid'");
%endif

%if 'PSP_modified_residues' in protein.features and protein.features['PSP_modified_residues']:
    ft.addFeature({
        data: ${str(feature_viewer_standardise(protein.features['PSP_modified_residues']))|n},
        name: "Mod. residues (HT)",
        className: "modified",
        color: "slateblue",
        type: "unique",
        filter: "Modified"
    });
    addFeatureTooltip("Mod. residues (HT)", "Post translational modifications from Phosphosite-plus");
%endif



%if combo_ss:
    ft.addFeature({
        data: ${str(combo_ss)|n},
        name: "Secondary structure",
        className: "domain",
        color: "olive",
        type: "rect",
        filter: "Domain"
    });
    addFeatureTooltip("Secondary structure", "A collection of 'helix', 'turn', 'strand' Uniprot annotations.");
%endif



%if 'sequence variant' in protein.features:
    ft.addFeature({
        data: ${str(protein.features['sequence variant'])|n},
        name: "seq. variant",
        className: "modified",
        color: "firebrick",
        type: "unique",
        filter: "Modified"
    });
    addFeatureTooltip("seq. variant","Sequence variants from Uniprot, which is includes very common SNPs and pathogenic SNPs");
%endif

%if 'splice variant' in protein.features:
    ft.addFeature({
        data: ${str(protein.features['splice variant'])|n},
        name: "Splice variant",
        className: "domain",
        color: "sandybrown",
        type: "rect",
        filter: "Domain"
    });
    addFeatureTooltip("Splice variant","Regions that differ/absent in splice variants (according to Uniprot)");
%endif

%if protein.gnomAD:
    ft.addFeature({
        data: ${str([dict(snp._asdict()) for snp in protein.gnomAD])|n},
        name: "gnomAD",
        className: "modified",
        color: "skyblue",
        type: "unique",
        filter: "Modified"
    });
    addFeatureTooltip("gnomAD","gnomAD variant (i.e. variant in the healthy human population)");
%endif

%if 'disulfide bond' in protein.features:
    ft.addFeature({
        data: ${str(protein.features['disulfide bond'])|n},
        name: "disulfide bond",
        className: "dsB",
        color: "orange",
        type: "path",
        filter: "Modified Residue"
    });
    addFeatureTooltip("gnomAD","gnomAD variant (i.e. variant in the healthy human population)");
%endif

%if 'cross-link' in protein.features:
    ft.addFeature({
        data: ${str(protein.features['cross-link'])|n},
        name: "disulfide bond",
        className: "dsB",
        color: "orange",
        type: "path",
        filter: "Modified Residue"
    });
    addFeatureTooltip("disulfide bond","Disulfide bond in Uniprot entry. It may or may not be present under all conditions");
%endif

%if hasattr(protein, 'properties') and protein.properties:
    ft.addFeature({
        data: ${str([{'x': i+4, 'y': score} for i, score in enumerate(protein.properties["kd"])])|n},
        name: "Hydrophobilicity",
        className: "kyledolittle",
        color: "#008080",
        type: "line",
        height: 1,
        filter: "type2"
    });
    addFeatureTooltip("Hydrophobilicity","Kyle-Dolitte hydrophobilicity index: high hydrophobility generally means a structured protein");

        ft.addFeature({
        data: ${str([{'x': i+4, 'y': score - 1} for i, score in enumerate(protein.properties["Flex"])])|n},
        name: "Flexibility",
        className: "kyledolittle",
        color: "#ff7f50", //coral
        type: "line",
        height: 1,
        filter: "type2"
    });
    addFeatureTooltip("Flexibility","Flexibility predicted by amino acid identity. low flexibility generally means a structured protein");
%endif
################### Structures #######################
<%
    limited = 45
    if include_pdb:
        p = sorted(protein.pdbs, key=lambda n: n.y - n.x, reverse=True)[0:limited]
        s = sorted(protein.swissmodel, key=lambda n: n.y - n.x, reverse=True)[0:limited-len(protein.pdbs)]
        m = sorted(protein.pdb_matches, key=lambda n: n.y - n.x, reverse=True)[0:limited-len(protein.pdbs)-len(protein.swissmodel)]
    else:
        p = []
        s = []
        m = []
%>
%for title, data, color, classname in (("Crystal structures",p, 'lime', 'pdb'), ("Swissmodel", s, 'GreenYellow', 'swiss'), ("Homologue structures", m, 'khaki', 'homo')):
    %if data:
    ft.addFeature({
        data: ${str([structure.to_dict() for structure in data])|n},
        name: "${title}",
        className: "${classname}",
        color: "${color}",
        type: "rect",
        filter: "Domain"
    }); addFeatureTooltip("${title}", "Click on the span to load this structure.")
    %endif
%endfor

%if len(p)+len(s)+len(m) >= limited:
    $('#fv').prepend('<div class="alert alert-warning mb-3">The entry contains ${len(protein.pdbs)} PDB entries, but the feature viewer been limited to the 45 longest (its max). For full list, see PDB website.</div>');
%endif

$('.pdb').click(function () {
    let id = $(this).attr('id').slice(1); //remove the first 'f'
    load_pdb(id.split('_')[0]);
});

$('.swiss').click(function () {
    const entries = ${str({s.id: s.url for s in protein.swissmodel})|n};
    let id = $(this).attr('id').slice(1); //remove the first 'f'
    load_pdb(entries[id]);
});

$('#label_protName').html("${protein.recommended_name} (encoded by <i>${protein.gene_name}</i>)");

############################################ This is the table #############
% if include_pdb:
window.pdbOptions = ${json.dumps([s.__dict__ for s in protein.pdbs])|n};
% else:
    window.pdbOptions = [];
% endif

if (pdbOptions.length) {
    $('#partner_table').html(`<table class="table table-hover" style="table-layout: fixed;"><thead class="thead-light"><tr>
                                        <th data-toggle="tooltip" title="PDB code of the structure. See RCSB PDB database for more.">Code</th>
                                        <th data-toggle="tooltip" title="The resolution of the structure. The lower the better. Say an electron microscopy structure at 3 &Aring; will be poor, while a proton beam structure at 1 &Aring; will even have hydrogens. Generally anything below 2 &Aring; is acceptable.">Resolution</th>
                                        <th data-toggle="tooltip" title="How much of the whole protein is covered (structures are often parts of a protein)">Span</th>
                                        <th data-toggle="tooltip" title="The residue index within the structure may differ from the one of the protein as a whole. Add this number to the PDB index to get the whole protein index">Offset</th>
                                        <th data-toggle="tooltip" title="What chain is my protein?">Protein of interest</th>
                                        <th data-toggle="tooltip" title="What other proteins are there?">Bound partner(s)</th>
                                        <th data-toggle="tooltip" title="What small molecules are in the structure?">Ligand(s)</th>
                                </tr></thead><tbody></tbody></table>`);
    $('#partner_table [data-toggle="tooltip"]').tooltip();
    const table = $('#partner_table tbody');
    const protLen = ${len(protein)};
    let partnerNames = [];
    //<%text>
    pdbOptions.forEach(v => {
                        if (v.chain_definitions === null) return 0;
                        //protein in question
                        let myChain = v.chain_definitions.filter(d => d.uniprot === uniprotValue).map(d => 'Chain '+d.chain).join(' + ');
                        let partners = v.chain_definitions.filter(d => d.uniprot !== uniprotValue)
                                                           .map(d => 'Chain '+d.chain+': <span name="'+d.uniprot+'"></span>')
                                                           .join(' + ');
                        let res = (v.resolution === -1) ? 'NMR' : v.resolution + '&Aring;';
                        let off = v.offset;
                        partnerNames = partnerNames.concat(v.chain_definitions.filter(d => d.uniprot !== uniprotValue)
                                                                  .map(d => d.uniprot));
                        table.append(`<tr onclick="load_pdb('${v.code}')">
                                            <td>${v.code}</td>
                                            <td  id="res_${v.code}">${res}</td>
                                            <th data-toggle="tooltip" title="${v.x}-${v.y}"><svg height="1em" width="100%" id="span_${v.code}"></svg></th>
                                            <td>${off}</td>
                                            <td>${myChain}</td>
                                            <td>${partners}</td>
                                            <td id="lig_${v.code}"><i class="fas fa-spinner fa-spin"></i></td>
                                          </tr>`);
                        $.getJSON({url: 'https://www.ebi.ac.uk/pdbe/api/pdb/entry/molecules/'+v.code, dataType: 'json', crossOrigin: true})
                            .then(response => { const components = response[v.code.toLowerCase()];
                                                $('#lig_'+v.code).html(  components.filter(e=>e.molecule_type !== 'polypeptide(L)')
                                                                                   .filter(e=> ! ['HOH', 'NA', 'GOL', 'CL', 'MG', 'K', 'BME', 'EDO', 'DMS', 'PGE'].includes(e.chem_comp_ids[0]))
                                                                                   .map(e => e.molecule_name[0].toLowerCase()+' ('+e.chem_comp_ids[0]+' in chain '+e.in_chains.join('&')+')')
                                                                                   .join(' + ')
                                                                     );

                                                let c = myChain.match(/Chain \w/g).map(t => t.replace('Chain ',''))[0];
                                                let mutants = components.filter(e=>e.molecule_type === 'polypeptide(L)').find(e => e.in_chains.includes(c)).mutation_flag;
                                                let res = $('#res_'+v.code);
                                                if (mutants !== null) {
                                                    res.html(res.html() + ` <i class="far fa-tools" data-toggle="tooptip" title="This structure contains mutated residues: ${mutants}"></i>`);
                                                }
                                                let textDump = JSON.stringify(response);
                                                if (['"MSE"', '"I3C"', '"B3C"'].some(e => textDump.match(e) !== null)) {
                                                            res.html(res.html() + ' <i class="far fa-stroopwafel" data-toggle="tooptip" title="This structure contains compounds added to solve the phase problem. Other structures may be better suited for your needs."></i>');
                                                        }
                                               }
                                    );

                        let svg=d3.select('#span_'+v.code);
                        // midline
                        svg.append("svg:line")
                                .attr("x1", 0)
                                .attr("y1", "0.5em")
                                .attr("x2", "100%")
                                .attr("y2", "0.5em")
                                .attr("stroke-width",3)
                                .attr('stroke','silver');
                        let group=svg.append("g");
                        group.append('rect')
                                .attr('x',(parseFloat(v.x)/protLen*100).toString()+"%")
                                .attr('width',((parseFloat(v.y)-parseFloat(v.x))/protLen*100).toString()+'%')
                                .attr("y", "0.1em")
                                .attr("height", "0.8em")
                                .attr("stroke-width",1)
                                .attr('stroke','black')
                                .attr('fill','gainsboro');
    });
    // partner fix...
    console.log(partnerNames);
    partnerNames.filter((v, i, a) => a.indexOf(v) === i)
                .forEach( v => $.getJSON({url: '/choose_pdb',
                                          data: {item: 'get_name',
                                                 species: taxidValue,
                                                 uniprot: v
                                                }
                                          })
                                .then(response => {
                                    let target = $('span[name="'+response.uniprot+'"]');
                                    target.css('text-decoration-line','underline');
                                    target.css('text-decoration-style','dotted');
                                    target.html(response.gene_name);
                                    //{'gene_name': protein.gene_name, 'recommended_name': protein.recommended_name, 'length': len(protein)}
                                    target.tooltip({title: `${response.gene_name} (${response.recommended_name})`});
                                    })
							);

    // add glove. Do this properly in a bit.
    $('#partner_table tbody tr').hover(e => $(e.target).css('cursor','pointer'));
    //</%text>
} else {
$('#partner_table').html('<p>No crystal structures to show.</p>');
}


// </script>