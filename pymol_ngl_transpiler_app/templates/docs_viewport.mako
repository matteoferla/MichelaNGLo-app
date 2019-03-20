<h4>Viewport</h4>
<h5>Best option</h5>
The recomended way (simple/powerful) is have the viewport declared (in the correct location) like so <code>&lt;div role="NGL" proteins="[{...}]">&lt;/div></code>, where the JSON string value (=in quotes) of <code>proteins</code> is an array of objects like this: <code>{type: 'rcsb|file|data', value: 'PDB id|path|multiline string', loadFx: myOptionalFancyLoadFunction}</code>. Where the optional load function can be added to a script element and can be made from a PyMol file (<a href="/pymol">see PyMol converter</a>).

<h5>Full options</h5>
<p>There are four inter-compatible ways to declare the viewport.</p>
<ul class="fa-ul">
    <li><span class="fa-li" ><i class="far fa-scroll-old"></i></span> <b>old way.</b> In JS you load it as the NGL suggests, but keeping the stage object globally declared as <code>stage</code>: <code>window.stage = new NGL.Stage( "viewport",{backgroundColor: "white"}); stage.loadFile('static/gfp.pdb')</code> &mdash; adding <code>stage</code> as a property of <code>window</code> (<i>i.e.</i><code>window.stage = &hellip;</code>) is the same as declaring without <code>var</code> (<i>i.e.</i><code>stage = &hellip;</code>; <i>cf.</i> <code>var stage = &hellip;</code>).</li>
    <li><span class="fa-li" ><i class="far fa-scroll"></i></span> <b>Modded old way.</b> As above but you add your stage to the object <code>NGL.stageId</code> thusly <code>var id = "viewport"; NGL.stageIds[id] = new NGL.Stage( id,{backgroundColor: "white"}); NGL.stageIds[id].loadFile('static/gfp.pdb')</code></li>
    <li><span class="fa-li" ><i class="far fa-bolt"></i></span> <b>MultiLoader way.</b> Using the <code>multiLoader</code> function described below (<code>NGL.specialOps.multiLoader('viewport', [{type: 'rcsb', value: '1ubq', loadFx: myFancyLoadFunction}], 'gainsboro')</code>), which allows <code>data-load</code> prolinks to toggle between multiple proteins (pdb strings, custom pdb files or RCSB pdb entries) each with an optional load function.</li>
    <li><span class="fa-li" ><i class="far fa-robot"></i></span> <b>No JS way.</b> Using the attribute <code>role="NGL"</code> on the viewer div-element in combination with prolink <code>data-*</code> attributes, <i>e.g.</i> <code>&lt;div id="viewport" role="NGL" data-load="1ubq" data-focus="residue" data-selection="30:A" data-view="[&hellip;]"&gt;</code>. If multiple PDB proteins are required, use <code>data-proteins</code> as opposed to load where the value is a comma separated space free list of codes (not array), these can be accessed via <code>data-load=3</code> prolinks as usual (this is less clear than simply specifying prolinks with <code>data-load</code> with a file or PDB code, but has the sole benefit that, data-load='1ubq' will re-load the file even if 1ubq is loaded, while data-load=2 will not if the current index is 2, however in future unique names will be implemented to avoid this drama). Note that the height issue is sorted and that it can be combined like everything else with click-to-enable-NGL images.</li>
</ul>

<h5>Image</h5>
<p>If you are adding an image (as <a href="/imagetoggle">described here</a>), you might need to add it manually as many WYSIWYG editors with insert image buttons (<i>e.g.</i> Blogger) make images that when clicked result in a pop-up with the image fullsize, which is obviously incompatible.
Therefore add or edit the image thusly: <code>&lt;div id="viewport"&gt; &lt;img src="my_protein.jpg" alt="my protein" width='100%' style='cursor: pointer'&gt;&lt;/div&gt;</code>.</p>
<p>The CSS style can be different, but the important thing is that there is a <code>width</code> or a <code>min-width</code> and a <code>height</code> or a <code>min-height</code> &mdash;in
this example the 0 height is a special case and results in the height being equal to the width.</p>

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
