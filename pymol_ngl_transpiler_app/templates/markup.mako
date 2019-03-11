<%namespace file="labels.mako" name="info"/>
<%inherit file="layout_w_card.mako"/>

<%block name="buttons">
            <%include file="menu_buttons.mako" args='tour=False'/>
</%block>

<%block name="title">
            Guiding links ("Prolinks")
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
                <p>This system to control the protein without any JS coding.</p>
                <h3>Demo</h3>
                <p><i class="far fa-hand-point-right"></i> This page is running on the <a href="static/ngl.extended.js">file ngl.extended.js</a></p>
                <p>Let's look at the structure of GFP. Overall is <span class="prolink" data-toggle="protein" data-target="viewport" data-focus="domain" data-selection="11-228" data-color="lime">a &beta;-barrel</span>,
                    but sports <span class="prolink" data-toggle="protein" data-target="#viewport" data-selection="54-82" data-color="purple">a loop that traverses the core</span>.</p>
                <p>In this loop, there are <span class="prolink" data-toggle="protein" data-target="#viewport"  data-focus="residue" data-selection="65-67" data-radius="2">three residues, SYG,</span> that mature to form a chromophore.</p>
                <p>Also, setting the tolerance to really low <span class="prolink" data-toggle="protein" data-target="#viewport"  data-focus="clash" data-selection="29" data-tolerance="0.1">we can see residues spuriously clashing</span>.  </p>
                <p>The camera can be set to <span class="prolink" href="#viewport" data-toggle="protein" data-view="[13.87245243079792,-18.27360233135557,63.99186261747443,0,-11.069766475366883,63.82311925112967,20.62517100777409,0,-65.62273457879594,-14.629178608334712,10.04847249632254,0,-0.7559999823570251,-65.44000244140625,5.427000045776367,1]" >predefined coordinates</span>.</p>
                <p>This can be combined to allow <span class="prolink" data-toggle="protein" data-target="#viewport"  data-focus="residue" data-selection="65-67" data-radius="2" data-view="[21.083709695256083,3.2638383176464822,-24.800012660489337,0,-25.012283268399123,3.115199733699885,-20.8541914098467,0,0.28098794552718936,32.40152732655437,4.503127326542097,0,-11.023754117672173,-71.66366796614918,6.221244923015376,1]">selection of a given set of residues, such as the chromophore, but to manually fix an obstructed view</span></p>
                <%include file='markup_builder_btn.mako'/>
            </div>
            <div class='col-12 col-sm-6'>
			<div id="viewport" style="width:100%; height: 0; padding-bottom: 100%;"></div>
		</div>
        </div>
<div class="col-12">

                <h3>Markup</h3>
                <p>Following Bootstrap, the most common CSS framework, several <code>data-*</code> attributes are proposed and implemented to control what is shown. If you are unfamilar with the terms "attribute" or "element" see <a href="#basics">basics</a>.</p>
                <p>The first link is: <code>&lt;a href='#viewport' data-toggle="protein" data-focus="domain" data-selection="11-228:A" data-color="lime" &gt;a &beta;-barrel&lt;/a&gt;</code></p>
    <p>The attribute <code>data-toggle="protein"</code> is what tells the browser that the link controls the protein (<a href="#row_toggle">see below for more</a>), <code>data-focus="domain"</code> tells it how to zoom (domain | residue | clash) to use, while <code>data-selection="11-228:A"</code> controls what to zoom into.</p>
    <h4>List of attributes</h4>
    <table class="table table-striped">
        <thead>
        <tr>
            <th>Attribute</th>   <th>Default</th>  <th>Affects</th>   <th>Description</th>
        </tr>
        </thead>
        <tbody>
        <tr id="row_toggle">
            <td colspan="2"><code>data-toggle="protein"</code></td>
            <td>All</td>
            <td>Instructs that the anchor element (link) or similar element affects the protein. The NGL.extension.js script add a monkeypatches JQuery with the prototype <code>protein</code>, then runs <code>$('[data-toggle="protein"]').protein();</code> so all relevant elements existing when the document is loaded are enabled. If new are added they have to be activated manually in JS with <code>$('whatever').protein()</code>.</td>
        </tr>
        <tr id="row_target">
            <td><code>data-target</code></td>
            <td><code>'#viewport'</code></td>
            <td>All</td>
            <td>If there is no stage on <code>#viewport</code> or there are multiple stages and they were stored in <code>NGL.stageId</code> (see <a href="note">note</a>), use the attribute  pointing towards an id with or without the hash. As anchor elements are not styled as hyperlinks unless you have a <code>href</code> attribute, an href is a valid alternative.</td>
        </tr>
        <tr id="row_focus">
            <td><code>data-focus</code></td>
            <td><code>domain</code></td>
            <td>&mdash;</td>
            <td>To control whether to focus on a large region/domain, on a few residues and their neighbourhood, or on a clash. the attribute <code>data-focus</code> can be used with the choice of terms <code>'domain'</code>, <code>'residue'</code> or <code>'domain'</code> respectively.</td>
        </tr>
        <tr id="row_selection">
            <td><code>data-selection</code></td>
            <td> &mdash; (compulsory for <code>data-focus</code> instructions, use <code>'*'</code> to select all)</td>
            <td><code>data-focus</code></td>
            <td>The selection is controlled with a <a href="http://nglviewer.org/ngl/api/manual/selection-language.html">valid NGL selection <i class="fas fa-external-link"></i></a>, for example a range is '1-20:A'.</td>
        </tr>
        <tr id="row_color">
            <td><code>data-color</code></td>
            <td><code>'green'</code> (focus: domain) | <code>'hotpink'</code> (focus: residue)</td>
            <td><code>data-focus</code></td>
            <td>To specify a colour, add the attribute <code>data-color="HTML_color"</code> where "HTML_color" is a valid html colour name or hex code.</td>
        </tr>
        <tr id="row_radius">
            <td><code>data-radius="N"</code></td>
            <td><code>'5'</code> (Å)</td>
            <td><code>data-focus='residue'</code> and <code>data-focus='clash'</code></td>
            <td>Used to specify how many &Aring;mstrongs to expand around in residue zooming mode.</td>
        </tr>
        <tr id="row_tolerance">
            <td><code>data-tolerance</code></td>
            <td><code>'1'</code> (Å)</td>
            <td><code>data-focus='clash'</code></td>
            <td>The clashes are determined by finding distances less than the sum of the van der Waals radii. However, due to imprecise structures or sp2 orbitals it can be lower hence this optional factor</td>
        </tr>
        <tr id="title">
            <td><code>data-title</code></td>
            <td>Nothing shown</td>
            <td>All</td>
            <td>shows a temporary title, which is actually a label element with a for attribute pointing to the viewport id. Consequently if one wanted to override it's location one could add <code>&lt;label for="viewport">&lt;/label></code> where desired.</td>
        </tr>
        <tr>
            <td><code>data-load</code></td>
            <td>&mdash;</td>
            <td></td>
            <td>will load a new PDB, either as a 4 letter code or a index (see further). It plays well with data-focus or data-view, which are executed afterwards. However, a more powerful option is available thanks to the MultiLoader's loadFx.</td>
        </tr>
        <tr>
            <td><code>data-view</code></td>
            <td>&mdash;</td>
            <td></td>
            <td>accepts three possible values, one of these is an orientation matrix as begot from <code>stage.viewerControls.getOrientation()</code>. Do note that the orientation matrix view transition is instantaneous unfortunately.</td>
        </tr>
        <tr>
            <td colspan="2"><code>data-view='auto'</code></td>
            <td></td>
            <td>Uses the <code>.autoView()</code> function, which translates without rotation.</td>
        </tr>
        <tr>
            <td colspan="2"><code>data-view='reset'</code></td>
            <td></td>
            <td>If the stage was loaded with the multiLoader() and a loadFx was supplied with the protein it will run that, otherwise it will do the same as auto.</td>
        </tr>
        </tbody>
    </table>

    <h4>$('..').protein()</h4>
    <p>When the dom loads the links are automatically enabled, however, if new links are added dynamically you have to activate them using <code>$(...).protein()</code>, for example <code>$('[data-toggle="protein"]').protein();</code></p>
    <h4>myData object and multiLoader</h4>
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
        // but let's say we dovn't want the multiloader... You will get a warning and all will work!
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

