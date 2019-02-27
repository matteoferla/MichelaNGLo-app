<%inherit file="layout.mako"/>

<div class="alert alert-info">Currently testing 'ngl.extension.js'</div>


<div class="card">
    <div class="card-header">
        <h1 class="card-title">Sandbox
            <%include file='menu_buttons.mako'/>
        </h1>
        <h3 class="card-subtitle mb-2 text-muted">Super secret</h3>
    </div>
    <div class="card-body">
        <div class='row'>
            <div class='col-6'>
                <h3>Skunkworks shed</h3>
                <ul>
                    <li>Let's check out <a href="#" data-toggle="protein" data-focus="residue" data-selection="30">residue 30</a>.</li>
                    <li>Let's check out <a href="#" data-toggle="protein" data-focus="clash" data-selection="1" data-tolerance="0.2">clash at residue 1 with tolerance set to 0.2</a>.</li>
                    <li>Let's check out <a href="#" data-toggle="protein" data-focus="domain" data-selection="10-20">residues 10-20</a>.</li>
                    <li>Let's check out <a href="#" data-toggle="protein" data-focus="domain" data-selection="73-76:A">residues 73-76</a>.

                </ul>

                <p>${'qwerty ' * 200}</p>
            </div>
            <div class='col-6'>
			<div id="viewport" class="protein"></div>
                </div>

	    </div>
    </div>
</div>
<%block name="script">
    <script type="text/javascript" src="static/ngl.extended.js"></script>
    <script type="text/javascript">
        //NGL.setDebug(true);
        NGL.stageIds['viewport'] =  new NGL.Stage( "viewport",{backgroundColor: "white"});
        window.addEventListener( "resize", function( event ){NGL.stageIds['viewport'].handleResize();}, false );
        NGL.stageIds['viewport'].loadFile('rcsb://1ubq', {defaultRepresentation: true});

    </script>
</%block>
