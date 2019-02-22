<%inherit file="layout.mako"/>
<%namespace file="labels.mako" name="info"/>
<div class="card">
    <div class="card-header">
        <h1 class="card-title">Guiding links
            <div class="float-right d-flex flex-column" style="width: 42px;">
                <a class="btn btn-outline-secondary  my-1" href="/"><i class="far fa-home"></i></a>
                <button type="button" class="btn btn-outline-secondary my-1"><i class="fab fa-github"></i></button>
            </div>
        </h1>
        <h3 class="card-subtitle mb-2 text-muted">Construction of HTML anchor tags to guide the users to a residue or region</h3>
    </div>
    <div class="card-body">
        <div class='row'>
            <div class='col-6'>
                <h3>Demo</h3>
                <p>Let's look at the structure of GFP. Overall is <a href='#' data-toggle="protein" data-target="#viewport" data-region="11-228" data-color="lime">a &beta;-barrel</a>, but sports <a href='#' data-toggle="protein" data-target="#viewport" data-region="54-82" data-color="purple">a loop that traverses the core</a>.</p>
                <p>In this loop, there are <a href='#' data-toggle="protein" data-target="#viewport" data-residue="65-67" data-radius="2">three residues, SYG,</a> that mature to form a chromophore.</p>
                <h3>Aims</h3>
                <p>A simple to implement system to control the protein that does not require JS coding.</p>

                <h3>Basic terms</h3>
                <p>A HTML page is formed by various elements with the following syntax: <code>&lt;ELEMENT attribute="value"&gt; text &lt;/ELEMENT&gt;</code>.
                    The first part, called the opening tag, contains attributes. These include the unique <code>id</code> and CSS controlling <code>style</code> attributes.</p>
                <p>A special convention exist to store custom data in <code>data-*</code> attributes. For example, <code>&lt;span id='blaId' data-hello='world'&gt;bla bla&lt;span&gt;</code> appears simply as "bla bla" in the browser, but the JS can access this data, e.g. using JQuery <code>$('#blaId').data('hello')</code> one gets <code>world</code> back.</p>

                <h3>Markup</h3>
                <p>Following Bootstrap, the most common CSS framework, several <code>data-*</code> attributes are proposed and implemented to control what is shown.</p>
                <ul>
                    <li>To instruct the anchor element (link) to affect the protein use the attribute <code>data-toggle="protein"</code>.</li>
                    <li>To specify if to zoom to a residue neighbourhood add the attribute <code>data-residue="N"</code>, where <code>N</code> is a residue (or a valid NGL selection).</li>
                    <li>Alternatively, To specify a large region/domain add the attribute <code>data-domain="X-Y"</code>, where <code>X-Y</code> is the span from residue X to Y to highlight (or a valid NGL selection).</li>
                    <li>(opt.) To specify a colour, add the attribute <code>data-color="HTML_color"</code> where "HTML_color" is a valid html colour name or hex code.</li>
                    <li>(opt.) To specify how many &Aring;mstrongs to expand around in residue zooming mode <code>data-radius="N"</code></li>
                </ul>
                <p>The first link is: <code>&lt;a href='#' data-toggle="protein" data-target="#viewport" data-region="11-228" data-color="lime"&gt;a &beta;-barrel&lt;/a&gt;</code></p>

                <h3>Future</h3>
                <ul>
                    <li>The component object is simply dumped into the main namespace, which is not great &mdash;whereas it should be akin to BS4 <code>href="#viewport"</code> or <code>data-target="#viewport"</code>, should control the target. Also moneypatch the functions in NGL.</li>
                    <li>Make a <code>data-view="[1,2,3,4,5..]"</code> to set a view by giving the M4 matrix &mdash;with instructions on how to get it.</li>
                    <li>Make a handy/simple generator to make these links.</li>
                </ul>
            </div>
            <div class='col-6'>
			<div id="viewport"style="width:100%; height: 0; padding-bottom: 100%;"></div>

                <h3>Note</h3>
                <p>There are three underlying functions. These are surprisingly small. Two are also shared with the feature viewer.</p>
		</div>

	</div>
    </div>
</div>

<%block name="script">
    <script type="text/javascript">
        $(document).ready(function () {
            //I kept this part simple for you, spying user.
            //See the part custom parts.
        window.stage = new NGL.Stage( "viewport",{backgroundColor: "white"});
        stage.loadFile('static/gfp.pdb').then(function (component) {
            component.addRepresentation("cartoon",{smoothSheet: true});
            component.autoView();
            window.protein = component; //it is important to not lose stage or protein if we are to play with it.
            //stage.compList[0]
        });
		// Handle window resizing
        window.addEventListener( "resize", function( event ){stage.handleResize();}, false );

        // custom parts.
        window.show_region = function (resi, color) {
            color = color || "green";
            protein.removeAllRepresentations();
            var schemeId = NGL.ColormakerRegistry.addSelectionScheme([[color, resi],["white", "*"]]);
            protein.addRepresentation( "cartoon", {color: schemeId, smoothSheet: true});
            protein.autoView();
            protein.autoView(ab+'-'+ad, 2000);
        };

        window.show_residue = function (resi, color, radius) {
            color = color || "hotpink";
            radius = radius || 4;
            resi=resi.toString();
            // there should only be two representations...
            for (var i=2; i < protein.reprList.length; i++) {
                protein.removeRepresentation(protein.reprList[i]);
            }
            var selection = new NGL.Selection( resi );
            var schemeId = NGL.ColormakerRegistry.addSelectionScheme([
                [color,'_C'],["blue",'_N'],["red",'_O'],["white",'_H'],["yellow",'_S'],["orange","*"]
            ]);
            var atomSet = protein.structure.getAtomSetWithinSelection( selection, parseFloat(radius) );
            // expand selection to complete groups
            var atomSet2 = protein.structure.getAtomSetWithinGroup( atomSet );
            licoriceRep = protein.addRepresentation( "licorice", { sele: atomSet2.toSeleString()} );
            hyperRep = protein.addRepresentation( "hyperball", { sele: resi, color: schemeId} );
            window.zoom=atomSet2.toSeleString();
            protein.autoView(window.zoom, 2000);
        };

        $('[data-toggle="protein"]').click(function() {
            if ($(this).data('residue')){
                var i =$(this).data('residue');
                var color = $(this).data('color');
                var radius = $(this).data('radius');
                show_residue(i, color, radius);
            }
            else if ($(this).data('region')){
                var i = $(this).data('region');
                var color = $(this).data('color');
                show_region(i, color);
            }
            else {throw 'no data-region or data-residue tag.'}
            if ($(this).data('title')) {
                $('#viewport_title').html($(this).data('title'));
                $('#viewport_title').show(1000);
                $('#viewport_title').hide(1000);
            }
        });






        }); //ready
    </script>
</%block>
