<%page args="structure, filename, m4, m4_alt=None, toggle_fx=False, raw_pdb='', sticks='', cartoon='', nonCmap={}, sermap={}, chainmap={}, resmap={}, viewport='viewport', variants=[], save_button='save_button', backgroundColor='white'"/>
<script type="text/javascript">
% if structure.raw_pdb:
    pdbData = `${structure.ss+'\n'+structure.raw_pdb}`;
% endif
var imagemode=true;



% if toggle_fx == True:
function show_region(ab,ad) {
	protein.removeAllRepresentations();
	var schemeId = NGL.ColormakerRegistry.addSelectionScheme([["green", ab.toString()+'-'+ad.toString()],["white", "*"]]);
	protein.addRepresentation( "cartoon", {color: schemeId });
	protein.autoView();
}
function show_residue(resi) {
    // there should only be two representations...
    for (var i=2; i < protein.reprList.length; i++) {
        protein.removeRepresentation(protein.reprList[i]);
    }
    var selection = new NGL.Selection( resi );
    var schemeId = NGL.ColormakerRegistry.addSelectionScheme([
        ["hotpink",'_C'],["blue",'_N'],["red",'_O'],["white",'_H'],["yellow",'_S'],["orange","*"]
    ]);
    var radius = 5;
    var atomSet = protein.structure.getAtomSetWithinSelection( selection, radius );
    // expand selection to complete groups
    var atomSet2 = protein.structure.getAtomSetWithinGroup( atomSet );
    licoriceRep = protein.addRepresentation( "licorice", { sele: atomSet2.toSeleString()} );
    hyperRep = protein.addRepresentation( "hyperball", { sele: resi, color: schemeId} );
    window.zoom=atomSet2.toSeleString();
    protein.autoView(window.zoom, 2000);
}
% endif

//save
$('#${save_button}').click(function () {
   stage.makeImage( {trim: true, antialias: true, transparent: false }).then(function (img) {window.img=img; NGL.download(img);});
});


function load_file(filename) {
	if (!! $('#${viewport} img').length) { //there is an image. Remove and get the sizes
		var w=$('#${viewport} img').width();
		var h=$('#${viewport} img').height();
		$('#${viewport} img').detach();
		$('#${viewport} p').detach();
		$('#${viewport}').css('width',w).css('height',h);
	}
	// cases...
	if (filename && window.stage) { //new model. Force reset
		stage.removeAllComponents();
	} else if (! window.stage) {
		filename=filename || '${filename}';
		window.stage = new NGL.Stage( "viewport",{backgroundColor: "${backgroundColor}"});
	} else {
		//nothing to be done.
		return true;
	}
	stage.loadFile(filename).then(function (protein) {
	   window.protein=protein;
		   //define colors
		var nonCmap = ${nonCmap};
		var sermap=${sermap};
		var chainmap=${chainmap};
		var resmap=${resmap};
		var schemeId = NGL.ColormakerRegistry.addScheme(function (params) {
			this.atomColor = function (atom) {
				chainid=atom.chainid;
				if (! isNaN(parseFloat(chainid))) {chainid=atom.chainname} // hack for chainid/chainIndex/chainname issue if the structure is loaded from string.
				if (atom.serial in sermap)  {return +sermap[atom.serial]}
				else if (atom.element in nonCmap) {return +nonCmap[atom.element]}
				else if (atom.element in nonCmap) {return +nonCmap[atom.element]}
				else if (chainid+atom.resno in resmap) {return +resmap[chainid+atom.resno]}
				else if (chainid in chainmap) {return +chainmap[chainid]}
				else {return 0x7b7d7d} //black as the darkest error!
			};
		});

		//representations
		protein.removeAllRepresentations();
		var sticks = new NGL.Selection( "${sticks}" );
		stickRep = protein.addRepresentation( "licorice", {color: schemeId, sele: sticks.string} );
		var cartoon = new NGL.Selection( "${cartoon}" );
		cartoonRep = protein.addRepresentation( "cartoon", {color: schemeId, sele: cartoon.string, smoothSheet: true} );

		//orient
		window.main_view = (new NGL.Matrix4).fromArray(${m4});
		% if m4_alt:
            window.alt_view = (new NGL.Matrix4).fromArray(${m4_alt});
        % endif
		stage.viewerControls.orient(main_view);
	});
}


$('#${viewport} img').click(function () {load_file('${filename}');});

// Handle window resizing
window.addEventListener( "resize", function( event ){
    stage.handleResize();
}, false );



var mutants=${variants};
$('#view_dropdown').append('<a class="dropdown-item" href="#" id="main_view">main view</a>');
$('#main_view').click(function() {load_file (); stage.viewerControls.orient(top_view);});
% if m4_alt:
$('#view_dropdown').append('<a class="dropdown-item" href="#" id="alt_view">alt view</a>');
$('#alt_view').click(function() {load_file (); stage.viewerControls.orient(alt_view);});
% endif
for (var i=0; i < mutants.length; i++) {
	var x=mutants[i];
	$('#view_dropdown').append('<a class="dropdown-item" href="#" id="'+x+'">'+x+'</a>');
	$('#'+x).click(function() {
		load_file ();
		show_residue($( this ).attr('id').slice(1,-1));
		});
}

var models=[{name:'phyre', file:'LZTR1_data/LZTR1_5A10_noPhospho.pdb',text: 'Phyre one-to-one (PDB:5A10) &mdash; unphosphorylated'},
			{name:'phyrep', file:'LZTR1_data/LZTR1_5A10.pdb',text: 'Phyre &mdash; phosphorylated (default)'},
			{name:'phyreras', file:'LZTR1_data/LZTR1_5A10_hRas.pdb',text: 'Phyre &mdash; with hRas (undocked, for size)'},
			{name:'iTasser', file:'LZTR1_data/LZTR1_iTasser.pdb',text: 'I-Tasser model'},
			{name:'iTassercul', file:'LZTR1_data/LZTR1_iTasser_4apf.pdb',text: 'I-Tasser model w N-terminus of Cullin-3 (PDB:4APF'}];

			//{name:'phyreu', file:'LZTR1_data/LZTR1_5A10_ubi.pdb',text: 'Phyre &mdash; itself ubiquinated'},
for (var i=0; i < models.length; i++) {
	var x=models[i];
	$('#dropdownModel').append('<a class="dropdown-item" href="#" id="'+x.name+'" data-file="'+x.file+'" data-text="'+x.text+'">'+x.text+'</a>');
	$('#'+x.name).click(function() {load_file ($(this).attr('data-file')); $('h1 small').html($(this).attr('data-text'));});
}


</script>
