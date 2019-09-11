<script type="text/javascript">
// feature
//fix d3 version issue.
//d3.scale={linear: d3.scaleLinear};

myData = {currentIndex: -1, proteins: [], id: "viewport", backgroundColor: "white", currentChain: 'A'};

###################################################
window.ft = new FeatureViewer('${protein.sequence}',
           '#fv',
            {
                showAxis: true,
                showSequence: true,
                brushActive: true, //zoom
                toolbar:true, //current zoom & mouse position
                bubbleHelp:false,
                zoomMax:50 //define the maximum range of the zoom
            });

################### Own SNV #######################
%if protein.mutation is not None:
	ft.addFeature({
        data: [{'x':${protein.mutation.residue_index},'y': ${protein.mutation.residue_index}, 'id': 'our_${protein.mutation.residue_index}', 'description': 'p.${str(protein.mutation)}'}],
        name: "Candidate SNP",
        className: "our_SNP",
        color: "indianred",
        type: "unique",
        filter: "Variant"
    });
%endif

################### Structures #######################
%for title, data in (("Crystal structures",protein.pdbs), ("Swissmodel", protein.swissmodel), ("Homologue structures", protein.pdb_matches)):
    %if data:
    ft.addFeature({
        data: ${str(data)|n},
        name: "${title}",
        className: "pdb",
        color: "lime",
        type: "rect",
        filter: "Domain"
    });
    %endif
%endfor

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
%endif

<%
    combo=[]
    for key in ('transmembrane region','intramembrane region','region of interest','peptide','site','active site','binding site','calcium-binding region','zinc finger region','metal ion-binding site','DNA-binding region','lipid moiety-binding region', 'nucleotide phosphate-binding region'):
        if key in protein.features:
            combo.extend(protein.features[key])
%>
%if combo:
    ft.addFeature({
        data: ${str(combo)|n},
        name: "region of interest",
        className: "domain",
        color: "teal",
        type: "rect",
        filter: "Domain"
    });
%endif

<%
    combo=[]
    for key in ('propeptide','signal peptide','repeat','coiled-coil region','compositionally biased region','short sequence motif','topological domain','transit peptide'):
        if key in protein.features:
            combo.extend(protein.features[key])
%>
%if combo:
    ft.addFeature({
        data: ${str(combo)|n},
        name: "other regions",
        className: "domain",
        color: "lavender",
        type: "rect",
        filter: "Domain"
    });
%endif

<%
    combo=[]
    for key in ('initiator methionine','modified residue','glycosylation site','non-standard amino acid'):
        if key in protein.features:
            combo.extend(protein.features[key])
%>
%if combo:
    ft.addFeature({
        data: ${str(combo)|n},
        name: "Modified residues",
        className: "modified",
        color: "slateblue",
        type: "unique",
        filter: "Modified"
    });
%endif

<%
    combo=[]
    for key in ('helix', 'turn', 'strand'):
        if key in protein.features:
            combo.extend(protein.features[key])
%>
%if combo:
    ft.addFeature({
        data: ${str(combo)|n},
        name: "Secondary structure",
        className: "domain",
        color: "olive",
        type: "rectangle",
        filter: "Domain"
    });
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
%endif

%if 'splice variant' in protein.features:
    ft.addFeature({
        data: ${str(protein.features['splice variant'])|n},
        name: "splice variant",
        className: "domain",
        color: "sandybrown",
        type: "rectangle",
        filter: "Domain"
    });
%endif

%if protein.gNOMAD:
    ft.addFeature({
        data: ${str(protein.gNOMAD)|n},
        name: "gNOMAD",
        className: "modified",
        color: "skyblue",
        type: "unique",
        filter: "Modified"
    });
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
%endif

$('.dsB').each(function () {
        var id = $(this)[0].id;
        var ab = id.split('_')[1];
        var ad = id.split('_')[2];
        $(this).css('cursor', 'pointer');
        $(this).click(function () {
            NGL.specialOps.showResidue('viewport', ab+' or '+ad);
        });
    });

$('.domain').each(function () {
        var id = $(this)[0].id;
        var ab = id.split('_')[1];
        var ad = id.split('_')[2];
        $(this).css('cursor', 'pointer');
        $(this).click(function () {
            NGL.specialOps.showDomain('viewport', ab+'-'+ad);
        });
    });



$('.variant,.modified,.our_SNP').each(function () {
        var id = $(this)[0].id;
        var ab = id.split('_')[1];
        $(this).css('cursor', 'pointer');
        $(this).click(function () {
            NGL.specialOps.showResidue('viewport', ab); //(id, selection, color, radius)
        });
    });

$('.pdb').click(function () {
    var id = $(this).attr('id').slice(1); //remove the first 'f'
    console.log(id);
    for (var i=0; i < myData.proteins.length; i++) {
        if (myData.proteins[i].name === id) {
            console.log(id +' is '+i.toString());
            NGL.specialOps.load(i);
            NGL.specialOps.showTitle("viewport",id);
            //if (data[i].name.search('_') !== -1) {myData.currentChain = myData.proteins[i].name.split('_')[1]} else {myData.currentChain ='A'}
            myData.currentChain = myData.proteins[i].chain;
            $('.prolink').each((i,e) => $(e).data('selection',$(e).data('selection').replace(/:\w+/,':'+myData.currentChain)));
            return 1}
    }

    console.log('Failed.');
});


###  structure ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### python proteins.pdbs was a list of {'description': elem.attrib['id'], 'id': elem.attrib['id']+'_'+chainid, 'x': loca[0], 'y': loca[1]}
### JS proteins is a list of {name: 'unique_name', type: 'rcsb' (default) | 'file' | 'data', value: xxx, 'ext': 'pdb' , loadFx: xxx}

var collectedData = [];

%if protein.pdbs:

    var data = ${str(protein.pdbs)|n}.map(function (prot) {
        return {name: prot.id, type: 'rcsb', value: prot.id.split('_')[0], descrition: prot.description, chain: prot.id.split('_')[1]}
    });

    collectedData.push(...data);

%endif
%if protein.swissmodel:

    var data = ${str(protein.swissmodel)|n}.map(function (prot) {
        return {name: prot.id, type: 'file', value: prot.url, chain: 'A'}
    });

    collectedData.push(...data);

%endif
%if protein.pdb_matches:

    var data = ${str(protein.pdb_matches)|n}.map(function (prot) { //fblastpdb_4I1L_339_410_A
    return {name: prot.id, type: 'rcsb', value: prot.id.split('_')[1], chain: prot.id.split('_')[4]}
    });
    if (data[0].name.search('_') !== -1) {
        myData.currentChain = data[0].name.split('_')[1]}
        else {myData.currentChain ='A'}

    collectedData.push(...data);

    $('#save').click(function () {
       stage.makeImage( {trim: true, antialias: true, transparent: false }).then(function (img) {window.img=img; NGL.download(img);});
    });
%endif

    if (!! collectedData) {
        NGL.specialOps.multiLoader("viewport",collectedData,"white",0);
        NGL.specialOps.showTitle("viewport",'PDB: '+data[0].name);
    } else {
        $('#viewport').append('<p><i class="far fa-dumpster-fire"></i> No model available.</p>');
    }




########### popover
% if protein.pdbs+protein.pdb_matches+protein.swissmodel:
$('#viewport_menu_popover')
    .click(function(){
       if(! window.viewPopIsOpen ||  window.viewPopIsOpen === undefined) { //it is not open
           $(this).popover('show');
            window.viewPopIsOpen=true;}
       else {
           $(this).popover('hide');
           window.viewPopIsOpen=false;
       }
    }).on('shown.bs.popover',function() {
            $('#save').click(function () {
               NGL.getStage('viewport').makeImage( {trim: true, antialias: true, transparent: false }).then(function (img) {window.img=img; NGL.download(img);});
            });
    });
% endif
$('.prolink').each((i,e) => $(e).data('selection',$(e).data('selection').replace(/:\w+/,':'+myData.currentChain)));
$('#results [data-toggle="protein"]').protein();
$('[data-toggle="tooltip"]').tooltip();


######################## reset

$('#new_analysis').click(function () {
    NGL.specialOps.hardReset();
    $('#retrieval_card').show(1000);
    $('#input_card').show(1000);
    $('#results').detach();
});

</script>
