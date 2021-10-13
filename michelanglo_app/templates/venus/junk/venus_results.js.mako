<script type="text/javascript">
// feature
//fix d3 version issue.
//d3.scale={linear: d3.scaleLinear};

$('#main_card').hide(1000);

myData = {currentIndex: -1, proteins: [], id: "viewport", backgroundColor: "white", currentChain: 'A'};


get_uniprot().then(msg => {
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


});  //then end.



###  structure ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### python proteins.pdbs was a list of {'description': elem.attrib['id'], 'id': elem.attrib['id']+'_'+chainid, 'x': loca[0], 'y': loca[1]}
### JS proteins is a list of {name: 'unique_name', type: 'rcsb' (default) | 'file' | 'data', value: xxx, 'ext': 'pdb' , loadFx: xxx}

### THIS CODE NO LONGER WORKS AS STRUCTURES ARE NOW NOT DICTS>
/*
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
%endif

    if (!! collectedData) {
        NGL.specialOps.multiLoader("viewport",collectedData,"white",0);
        NGL.specialOps.showTitle("viewport",'PDB: '+data[0].name);
    } else {
        $('#viewport').append('<p><i class="far fa-dumpster-fire"></i> No model available.</p>');
    }

*/

//$('.prolink').each((i,e) => $(e).data('selection',$(e).data('selection').replace(/:\w+/,':'+myData.currentChain)));
$('#results [data-toggle="protein"]').protein();
$('[data-toggle="tooltip"]').tooltip();


######################## reset

$('#new_analysis').click(function () {
    $('#main_card').show(1000);
    $('#results').detach();
    myData = undefined;
    NGL.stageIds = [];
});

</script>
