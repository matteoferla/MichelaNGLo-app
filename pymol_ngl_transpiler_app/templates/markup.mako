<%namespace file="labels.mako" name="info"/>
<%inherit file="layout_w_card.mako"/>

<%block name="buttons">
            <%include file="menu_buttons.mako" args='tour=False'/>
</%block>

<%block name="title">
            Guiding links
</%block>

<%block name="subtitle">
            Construction of HTML anchor tags to guide the users to a residue or region
</%block>


<%block name="alert">
    <div class="alert alert-info py-5 alert-dismissible fade show" role="alert">
      This got revised. for the old see <a href="/markup?version=old">old version.</a>
        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
        <span aria-hidden="true">&times;</span>
      </button>
    </div>
</%block>

<div class='row'>
            <div class='col-12 col-sm-6'>

                <h3>Aims</h3>
                <p>A simple to implement system to control the protein that does not require JS coding.</p>
                <h3>Demo</h3>
                <p><i class="far fa-hand-point-right"></i> This page is running on the <a href="static/ngl.extended.js">file ngl.extended.js</a></p>
                <p>Let's look at the structure of GFP. Overall is <a href='#' data-toggle="protein" data-target="viewport" data-focus="domain" data-selection="11-228" data-color="lime">a &beta;-barrel</a>,
                    but sports <a href='#' data-toggle="protein" data-target="#viewport" data-selection="54-82" data-color="purple">a loop that traverses the core</a>.</p>
                <p>In this loop, there are <a href='#' data-toggle="protein" data-target="#viewport"  data-focus="residue" data-selection="65-67" data-radius="2">three residues, SYG,</a> that mature to form a chromophore.</p>
                <p>Also, setting the tolerance to really low <a href='#' data-toggle="protein" data-target="#viewport"  data-focus="clash" data-selection="29" data-tolerance="0.1">we can see residues spuriously clashing</a>.  </p>
                <%include file='markup_builder_btn.mako'/>
            </div>
            <div class='col-12 col-sm-6'>
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
                    <li>(opt.) <code>data-tolerance="N"</code> controls how much margin to give in the determining clashes, set to between 0.5-1</li>
                    <li>(opt.) <code>data-title='html text'</code> shows a temporary title, which is actually a label element with a for attribute pointing to the viewport id. Consequently if one wanted to override it's location one could add <code>&lt;label for="viewport">&lt;/label></code> where desired.</li>
                    <li>(opt.) <code>data-load</code> will load a new PDB, either as a 4 letter code or a index (see further). Do note it does not play well with data-focus for now. However, a more powerful option is available thanks to the MultiLoader.</li>
                    <li>(opt.) <code>data-view</code> accepts three possible values: an orientation matrix as begot from <code>stage.viewerControls.getOrientation()</code> or "auto" (autoview) or "reset" (loads the loadFx is available). Do note that the orientation matrix view transition is instantaneous unfortunately.</li>
                </ul>
                <p>The first link is: <code>&lt;a href='#viewport' data-toggle="protein" data-focus="domain" data-selection="11-228:A" data-color="lime" &gt;a &beta;-barrel&lt;/a&gt;</code></p>
    <p>When the dom loads the links are automatically enabled, however, if new links are added dynamically you have to activate them using <code>$(...).protein()</code>, for example <code>$('[data-toggle="protein"]').protein();</code></p>
    <h3>myData object and multiLoader</h3>
    <p>The load ability, which uses the add-on <code>NGL.specialOps</code>, works preferably in combination with the add-on <code>NGL.specialOps.multiLoad</code>,
                which can initialise the scene and handles such things.</p>
                <p>The data for load/multiLoader is stored in <code>myData object</code>, which has the property <code>myData.proteins</code>,
    which is a list of <code>{name: 'unique_name', type: 'rcsb' (default) | 'file' | 'data', value: xxx, 'ext': 'pdb' , loadFx: xxx}</code>.
    The optional argument loadFx is a function that accepts as argument a NGL protein (component) object and performs requested operations.</p>
    <p>The MultiLoader and load can handle img elements in the div, namely the case where you start with an image with labels etc and you click on it and it switches to the viewer.</p>
    <pre><code>
function nice_ubiquitin (protein) {
        protein.addRepresentation( "line", {color: ..., sele: ...} );
        bla bla
    }
NGL.specialOps.multiLoader('viewport', [{type: 'rcsb', value: '1ubq', loadFx: nice_ubiquitin}], 'aquamarine')
//////////////////////////////id/////////array of elements with loadFx//////////////   ////background
        </code></pre>
    <p>The <code>data-load</code> can load proteins from the myData.proteins (and run the custom function LoadFx) if an index is provided.</p>
    <h3 id="note">Note</h3>
                <p>There are three-plus underlying functions. They are in the file: <a href="static/ngl.extended.js">file ngl.extended.js</a>, which requires JQuery.</p>
            <p>One issue is holding onto the stage object in JS. Therefore the stage is added as follows: <code>NGL.stageIds['viewport'] = new Stage( ...</code>. However, a better feature is using the <code>NGL.specialOps.multiLoad</code>, which handles it.</p>





            <h3>Future</h3>
                <h3 id="basics">Basic terms</h3>
                <p>A HTML page is formed by various elements with the following syntax: <code>&lt;ELEMENT attribute="value"&gt; text &lt;/ELEMENT&gt;</code>.
                    The first part, called the opening tag, contains attributes. These include the unique <code>id</code> and CSS controlling <code>style</code> attributes.</p>
                <p>A special convention exist to store custom data in <code>data-*</code> attributes. For example, <code>&lt;span id='blaId' data-hello='world'&gt;bla bla&lt;span&gt;</code> appears simply as "bla bla" in the browser, but the JS can access this data, e.g. using JQuery <code>$('#blaId').data('hello')</code> one gets <code>world</code> back.</p>

        </div>

<%block name='modals'>
<%include file='markup_builder_modal.mako'/>
</%block>
<%block name="script">
    <script type="text/javascript" src="static/ngl.extended.js"></script>
    <script type="text/javascript">
        $(document).ready(function () {
        // one way to init is:
        // NGL.specialOps.multiLoader('viewport', [{type: 'rcsb', value: '1ubq', loadFx: nice_ubi}], 'aquamarine')
        // but let's say we don't want the multiloader... You will get a warning and all will work!
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


        <%include file='markup_builder_modal.js'/>
    </script>
</%block>

