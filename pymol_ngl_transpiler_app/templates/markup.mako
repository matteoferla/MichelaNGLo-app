<%inherit file="layout.mako"/>
<%namespace file="labels.mako" name="info"/>

<div class="alert alert-info py-5 alert-dismissible fade show" role="alert">
  This got revised. for the old see <a href="/markup?version=old">old version.</a>
    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
    <span aria-hidden="true">&times;</span>
  </button>
</div>

<div class="card">
    <div class="card-header">
        <h1 class="card-title">Guiding links
            <%include file='menu_buttons.mako'/>
        </h1>
        <h3 class="card-subtitle mb-2 text-muted">Construction of HTML anchor tags to guide the users to a residue or region</h3>
    </div>
    <div class="card-body">
        <div class='row'>
            <div class='col-6'>

                <h3>Aims</h3>
                <p>A simple to implement system to control the protein that does not require JS coding.</p>
                <h3>Demo</h3>
                <p><i class="far fa-hand-point-right"></i> This page is running on the <a href="static/ngl.extended.js">file ngl.extended.js</a></p>
                <p>Let's look at the structure of GFP. Overall is <a href='#' data-toggle="protein" data-target="viewport" data-focus="domain" data-selection="11-228" data-color="lime">a &beta;-barrel</a>,
                    but sports <a href='#' data-toggle="protein" data-target="#viewport" data-selection="54-82" data-color="purple">a loop that traverses the core</a>.</p>
                <p>In this loop, there are <a href='#' data-toggle="protein" data-target="#viewport"  data-focus="residue" data-selection="65-67" data-radius="2">three residues, SYG,</a> that mature to form a chromophore.</p>
                <p>Also, setting the tolerance to really low <a href='#' data-toggle="protein" data-target="#viewport"  data-focus="clash" data-selection="29" data-tolerance="0.1">we can see residues spuriously clashing</a>.  </p>

            </div>
            <div class='col-6'>
			<div id="viewport" style="width:100%; height: 0; padding-bottom: 100%;"></div>
		</div>
        </div>
        <div class="col-12">

                <h3>Markup</h3>
                <p>Following Bootstrap, the most common CSS framework, several <code>data-*</code> attributes are proposed and implemented to control what is shown. If you are unfamilar with the terms "attribute" or "element" see <a href="#basics">basics</a>.</p>
                <ul>
                    <li>To instruct the anchor element (link) or similar element to affect the protein use the attribute <code>data-toggle="protein"</code></li>
                    <li>If there is no stage on <code>#viewport</code> or there are multiple stages and they were stored in <code>NGL.stageId</code> (see <a href="note">note</a>), use the attribute <code>data-target</code> pointing towards an id with or without the hash. As anchor elements don't look like links unless you have a <code>href</code> attribute, an href is a valid alternative.</li>
                    <li>The selection shown is controlled with <code>data-selection</code> with a <a href="http://nglviewer.org/ngl/api/manual/selection-language.html">valid NGL selection <i class="fas fa-external-link"></i></a>, for example a range is '1-20:A'.</li>
                    <li>To control whether to focus on a large region/domain, on a few residues and their neighbourhood, or on a clash. the attribute <code>data-focus</code> can be used with the choice of terms <code>'domain'</code>, <code>'residue'</code> or <code>'domain'</code> respectively.</li>
                    <li>(opt.) To specify a colour, add the attribute <code>data-color="HTML_color"</code> where "HTML_color" is a valid html colour name or hex code.</li>
                    <li>(opt.) To specify how many &Aring;mstrongs to expand around in residue zooming mode <code>data-radius="N"</code></li>
                </ul>
                <p>The first link is: <code>&lt;a href='#viewport' data-toggle="protein" data-focus="domain" data-selection="11-228:A" data-color="lime" &gt;a &beta;-barrel&lt;/a&gt;</code></p>
                <h3 id="note">Note</h3>
                <p>There are three-plus underlying functions. They are in the file: <a href="static/ngl.extended.js">file ngl.extended.js</a></p>
            <p>One issue is holding onto the stage object in JS. Therefore the object <code>NGL.stageIds['viewport'] = new Stage( ...</code></p>
            <h3>Future</h3>
                <ul>
                    <li>The code ought to moneypatch the component getter as a the prototype of stage of NGL.</li>
                    <li>Make a <code>data-view="[1,2,3,4,5..]"</code> to set a view by giving the M4 matrix &mdash;with instructions on how to get it.</li>
                    <li>Make a handy/simple generator to make these links.</li>
                    <li>Make a loader on a div? say <code>&lt;div id='viewport' data-toggle='protein' data-load='1UBQ'&gt;&lt;/div&gt;</code></li>
                </ul>
                <h3 id="basics">Basic terms</h3>
                <p>A HTML page is formed by various elements with the following syntax: <code>&lt;ELEMENT attribute="value"&gt; text &lt;/ELEMENT&gt;</code>.
                    The first part, called the opening tag, contains attributes. These include the unique <code>id</code> and CSS controlling <code>style</code> attributes.</p>
                <p>A special convention exist to store custom data in <code>data-*</code> attributes. For example, <code>&lt;span id='blaId' data-hello='world'&gt;bla bla&lt;span&gt;</code> appears simply as "bla bla" in the browser, but the JS can access this data, e.g. using JQuery <code>$('#blaId').data('hello')</code> one gets <code>world</code> back.</p>

        </div>


    </div>
</div>

<%block name="script">
    <script type="text/javascript" src="static/ngl.extended.js"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            //I kept this part simple for you, spying user.
            //See the part custom parts.
        window.stage = new NGL.Stage( "viewport",{backgroundColor: "white"});
        NGL.stageIds['vieport'] = stage;
        stage.loadFile('static/gfp.pdb').then(function (component) {
            component.addRepresentation("cartoon",{smoothSheet: true});
            component.autoView();
            window.protein = component; //it is important to not lose stage or protein if we are to play with it.
            //stage.compList[0]
        });
		// Handle window resizing
        window.addEventListener( "resize", function( event ){stage.handleResize();}, false );
        }); //ready
    </script>
</%block>

