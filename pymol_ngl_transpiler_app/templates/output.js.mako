<%page args="structure, toggle_fx=True, viewport='viewport', variants=[], save=False, backgroundColor='white', lipid=False, image=False, tag_wrapped=False, **other" />
% if tag_wrapped:
    <script type="text/javascript">
% endif

$( document ).ready(function () {
    window.myData={current_index: 0, variants: []};
% if structure.raw_pdb:
    myData.pdbs = [new Blob( [ `${'\n'.join(structure.ss)+'\n'+structure.raw_pdb}` ], { type: "text/plain"} )];
    myData.imagemode=true;
% elif len(structure.pdb) == 4:
    myData.pdbs=['rcsb://${structure.pdb.upper()}'];
% else:
    myData.pdbs=['${structure.pdb}'];
% endif


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


%if save:
    //save button
    $('#${save}').click(function () {
   stage.makeImage( {trim: true, antialias: true, transparent: false }).then(function (img) {window.img=img; NGL.download(img);});
});
%endif


% if lipid:
    //lipid button
    window.lipidRepresentation=false;
    $('#${lipid}').click(function () {
	if (! myData.lipidRepresentation) {
		myData.lipidRepresentation=protein.addRepresentation("licorice",{sele:':C or :Z'});
	} else {
	protein.removeRepresentation(window.lipidRepresentation);
	window.lipidRepresentation=false;
	}
});
% endif

function _loading (protein) {
	   myData.protein=protein;
		   //define colors
		var nonCmap = ${structure.elemental_mapping};
		var sermap=${structure.serial_mapping};
		var chainmap=${structure.catenary_mapping};
		var resmap=${structure.residual_mapping};
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
        <%
            if structure.colors:
                color_str='color: schemeId,'
            else:
                color_str =''
        %>
        protein.removeAllRepresentations();
        % if structure.lines:
            var lines = new NGL.Selection( "${' or '.join(structure.lines)}" );
            myData.lineRepresentation = protein.addRepresentation( "line", {${color_str} sele: lines.string} );
        % endif
        % if structure.sticks:
            var sticks = new NGL.Selection( "${' or '.join(structure.sticks)}" );
            % if stick == 'sym_licorice':
                myData.stickRepresentation = protein.addRepresentation( "licorice", {${color_str} sele: sticks.string, multipleBond: "symmetric"} );
            % elif stick == 'licorice':
                myData.stickRepresentation = protein.addRepresentation( "licorice", {${color_str}  sele: sticks.string} );
            % elif stick == 'hyperball':
                myData.stickRepresentation = protein.addRepresentation( "hyperball", {${color_str}  sele: sticks.string} );
            % elif stick == 'ball':
                myData.stickRepresentation = protein.addRepresentation( "ball+stick", {${color_str}  sele: sticks.string, multipleBond: "symmetric"} );
            % endif
        % endif
        % if structure.cartoon:
            var cartoon = new NGL.Selection( "${' or '.join(structure.cartoon)}" );
            myData.cartoonRepresentation = protein.addRepresentation( "cartoon", {${color_str}  sele: cartoon.string, smoothSheet: true} );
        % endif
        % if structure.surface:
            var surf = new NGL.Selection( "${' or '.join(structure.surface)}" );
            myData.surfRepresentation = protein.addRepresentation( "surface", {${color_str} sele: surf.string} );
        % endif

		//orient
		myData.main_view = (new NGL.Matrix4).fromArray(${structure.m4.reshape(16, ).tolist()});
		% if structure.m4_alt:
            myData.alt_view = (new NGL.Matrix4).fromArray(${structure.m4_alt.reshape(16, ).tolist()});
        % endif
		stage.viewerControls.orient(myData.main_view);
	}

function load_file(index) { //has the potential of having structure toggle.
    if (typeof index != "number") {index = myData.current_index;} //"undefined"

    % if image:
        if (!! $('#${viewport} img').length) { //there is an image. Remove and get the sizes
		var w=$('#${viewport} img').width();
		var h=$('#${viewport} img').height();
		$('#${viewport} img').detach();
		$('#${viewport} p').detach();
		$('#${viewport}').css('width',w).css('height',h);
	}
    % endif

	// cases...
	if ( (index != myData.current_index) && window.stage) { //new model. Force reset
		stage.removeAllComponents();
	} else if (! window.stage) {
	    var pdb=myData.pdbs[index];
		window.stage = new NGL.Stage( "viewport",{backgroundColor: "${backgroundColor}"});
		// Handle window resizing
        window.addEventListener( "resize", function( event ){stage.handleResize();}, false );
	} else {
		//nothing to be done.
		return true;
	}
	% if structure.raw_pdb:
        stage.loadFile(pdb, { ext: "pdb" }).then(_loading);
    % else:
        stage.loadFile(pdb).then(_loading);
    % endif

}

% if image:
    $('#${viewport} img').click(function () {load_file();});
% else:
    load_file();
% endif



% if 1==0:
    % if variants:
        var mutants=${variants};
        $('#view_dropdown').append('<a class="dropdown-item" href="#" id="main_view">main view</a>');
        $('#main_view').click(function() {load_file (); stage.viewerControls.orient(top_view);});
        % if structure.m4_alt:
        $('#view_dropdown').append('<a class="dropdown-item" href="#" id="alt_view">alt view</a>');
        $('#alt_view').click(function() {load_file (); stage.viewerControls.orient(alt_view);});
        % endif
        for (var i=0; i < mutants.length; i++) {
            var x=mutants[i];
            $('#view_dropdown').append('<a class="dropdown-item" href="#" id="'+x+'">'+x+'</a>');
            $('#'+x).click(function() {
                show_residue($( this ).attr('id').slice(1,-1));
                });
        }
    % endif


var models=[{name:'phyre', file:'LZTR1_data/LZTR1_5A10_noPhospho.pdb',text: 'Phyre one-to-one (PDB:5A10) &mdash; unphosphorylated'},
			{name:'phyrep', file:'LZTR1_data/LZTR1_5A10.pdb',text: 'Phyre &mdash; phosphorylated (default)'},
			{name:'phyreras', file:'LZTR1_data/LZTR1_5A10_hRas.pdb',text: 'Phyre &mdash; with hRas (undocked, for size)'},
			{name:'iTasser', file:'LZTR1_data/LZTR1_iTasser.pdb',text: 'I-Tasser model'},
			{name:'iTassercul', file:'LZTR1_data/LZTR1_iTasser_4apf.pdb',text: 'I-Tasser model w N-terminus of Cullin-3 (PDB:4APF'}];

for (var i=0; i < models.length; i++) {
	var x=models[i];
	$('#dropdownModel').append('<a class="dropdown-item" href="#" id="'+x.name+'" data-file="'+x.file+'" data-text="'+x.text+'">'+x.text+'</a>');
	$('#'+x.name).click(function() {load_file ($(this).attr('data-file')); $('h1 small').html($(this).attr('data-text'));});
}

% endif
});//doc-ready
% if tag_wrapped:
    </script>
% endif
