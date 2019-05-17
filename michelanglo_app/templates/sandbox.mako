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
            <div id="viewport" role="NGL" data-load="1ubq" data-focus="residue" data-selection="30:A" data-view="[14.394873916666345, -34.468414027651484, -26.89843120480809, 0.0, 8.908257378315625, 30.036971428311332, -33.72296288243233, 0.0, 42.804746264306594, 5.340334488427436, 16.063898485372462, 0.0, -30.62681007385254, -30.35763931274414, -19.690916061401367, 1.0]"></div>
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
</%block>
