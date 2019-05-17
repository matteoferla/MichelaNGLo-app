<%inherit file="layout_components/layout.mako"/>

<div class="alert alert-info">Currently testing multiloader</div>


<div class="card">
    <div class="card-header">
        <h1 class="card-title">Sandbox
            <%include file="layout_components/vertical_menu_buttons.mako"/>
        </h1>
        <h3 class="card-subtitle mb-2 text-muted">Super secret</h3>
    </div>
    <div class="card-body">
        <div class='row'>
            <div class='col-6'>
                <h3>Skunkworks shed</h3>
                <ul>
                    <li>Let's check out <a href="#" data-toggle="protein" data-focus="residue" data-selection="30" data-title="residue 30">residue 30</a>.</li>
                    <li>Let's check out <a href="#" data-toggle="protein" data-focus="clash" data-selection="1" data-tolerance="0.2">clash at residue 1 with tolerance set to 0.2</a>.</li>
                    <li>Let's check out <a href="#" data-toggle="protein" data-focus="domain" data-selection="10-20">residues 10-20</a>.</li>
                    <li>Let's check out <a href="#" data-toggle="protein" data-focus="domain" data-selection="73-76:A">residues 73-76</a>.
                    <li>Let's check out <a href="#" data-title='fooo' data-toggle="protein" data-focus="domain" data-selection="73-76:A">residues 73-76</a>.
                    <li>Let's check out <a href="#" data-toggle="protein" data-load="6FWW" data-selection="66-68:A">GFP</a>.
                    <li>Let's check out <a href="#" data-toggle="protein" data-view="[23.56205753705434, 25.14142618843425, -41.75561022036051, 0, 8.490802888119923, 43.55229529131292, 31.01445762029925, 0, 47.995088814712744, -20.04741983120362, 15.012169978727327, 0, -30.62681007385254, -30.35763931274414, -19.690916061401367, 1]">the underside</a> </li>
                    <li>Let's reset things <a href="#" data-toggle="protein" data-view="reset">reset</a></li>
                </ul>

                <p>${'qwerty ' * 100}</p>
            </div>
            <div class='col-6'>
            <div id="viewport" class="protein"></div>
            </div>
            <div class="col-12">
                <pre><code>quaxk.
                </code></pre>
            </div>

	    </div>
    </div>
</div>
<%block name="script">
    <script type="text/javascript" src="static/ngl.extended.js"></script>
    <script type="text/javascript">
        //NGL.setDebug(true);
        //NGL.stageIds['viewport'] =  new NGL.Stage( "viewport",{backgroundColor: "white"});
        //window.addEventListener( "resize", function( event ){NGL.stageIds['viewport'].handleResize();}, false );
        //NGL.stageIds['viewport'].loadFile('rcsb://1ubq', {defaultRepresentation: true});




         function nice_ubi (protein) {
            var stage = NGL.stageIds[myData.id];
            var nonCmap = {'N': '0x3333ff', 'O': '0xff4c4c', 'S': '0xe5c53f'};
		var sermap={110: '0x00ff7f', 501: '0x00ff7f', 556: '0x00ff7f', 88: '0xff00ff', 447: '0xff00ff', 91: '0xff00ff', 93: '0xff00ff', 450: '0xff00ff', 453: '0xff00ff', 454: '0xff00ff', 113: '0x00ff7f', 504: '0x00ff7f', 508: '0x00ff7f', 509: '0x00ff7f', 559: '0x00ff7f'};
		var chainmap={'A': '0x00ffff'};
		var resmap={'A12': '0xff00ff', 'A15': '0x00ff7f', 'A58': '0xff00ff', 'A64': '0x00ff7f', 'A71': '0x00ff7f'};
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
            var lines = new NGL.Selection( "8:A.N or 8:A.CA or 8:A.C or 8:A.O or 8:A.CB or 8:A.CG or 8:A.CD1 or 8:A.CD2" );
            myData.lineRepresentation = protein.addRepresentation( "line", {color: schemeId, sele: lines.string} );
            var sticks = new NGL.Selection( "74:A.N or 74:A.CA or 74:A.C or 74:A.O or 74:A.CB or 74:A.CG or 74:A.CD or 74:A.NE or 74:A.CZ or 74:A.NH1 or 74:A.NH2" );
                myData.stickRepresentation = protein.addRepresentation( "licorice", {color: schemeId, sele: sticks.string, multipleBond: "symmetric"} );
            var cartoon = new NGL.Selection( "9:A or 46:A or 59:A or 54:A or 13:A or 66:A or 5:A or 56:A or 70:A or 42:A or 64:A or 26:A or 4:A or 22:A or 71:A or 36:A or 25:A or 39:A or 24:A or 38:A or 48:A or 7:A or 43:A or 68:A or 76:A or 73:A or 62:A or 41:A or 72:A or 37:A or 57:A or 3:A or 74:A or 61:A or 52:A or 10:A or 67:A or 19:A or 60:A or 27:A or 6:A or 30:A or 21:A or 15:A or 40:A or 69:A or 45:A or 23:A or 47:A or 31:A or 32:A or 50:A or 55:A or 1:A or 8:A or 28:A or 75:A or 17:A or 11:A or 16:A or 29:A or 63:A or 58:A or 12:A or 44:A or 33:A or 65:A or 2:A or 35:A or 49:A or 51:A or 53:A or 14:A or 18:A or 34:A or 20:A" );
            myData.cartoonRepresentation = protein.addRepresentation( "cartoon", {color: schemeId,  sele: cartoon.string, smoothSheet: true} );

		//orient
		myData.main_view = (new NGL.Matrix4).fromArray([14.394873916666345, -34.468414027651484, -26.89843120480809, 0.0, 8.908257378315625, 30.036971428311332, -33.72296288243233, 0.0, 42.804746264306594, 5.340334488427436, 16.063898485372462, 0.0, -30.62681007385254, -30.35763931274414, -19.690916061401367, 1.0]);
		stage.viewerControls.orient(myData.main_view);
        };

        NGL.specialOps.multiLoader('viewport', [{type: 'rcsb', value: '1ubq', loadFx: nice_ubi}], 'aquamarine')

    </script>
</%block>
