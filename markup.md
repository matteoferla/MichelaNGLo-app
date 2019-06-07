# Markup for protein
A system to control the protein without any JS coding.

To activate the script `NGL.extended.js` ([link](https://github.com/matteoferla/MichelaNGLo/blob/master/michelanglo_app/static/ngl.extended.js)) needs to be loaded after `NGL.js`.

See [ngl.matteoferla.com/markup](ngl.matteoferla.com/markup) for description and demo. Alternatively, if you like second best, a description only can be found in this document.

## NGL.extended.js
NGL.exteneded.js adds the following functions:

* NGL.stageIds an object taht stores id: stages
* NGL.getStage(id) is a getter for this.
* NGL.specialOps
** NGL.specialOps.showDomain(id, selection, color, view), which focuses stage to show the given selection with the given color
** NGL.specialOps.showResidue(id, selection, color, radius, view), which focuses on the selection and their neighbourhood by n radius
** NGL.specialOps.showBlur(id, selection, color, radius, view), which shows the b-factor putty. With optional residue selection
** NGL.specialOps.showSurface(id, selection, view), shows the surface
** NGL.specialOps.showClash(id, selection, color, radius, tolerance, view) which shows the clashes that selection may have
** NGL.specialOps.slowOrient deals with the view if provided for these previous three.
** NGL.specialOps.showTitle(id,text) shows the title.
** NGL.specialOps.multiLoader(id, proteins, backgroundColor, startIndex), see below about proteins object
** NGL.specialOps.postInitialise() gets called by load if the stage was not set via multiLoader
** NGL.specialOps.load(option)
** NGL.specialOps.removeImg() switches the image off
** NGL.specialOps._run_loadFx() and a few others.
* NGL.Stage extra prototypes
** NGL.Stage.prototype.getComponentByType allowing stage objects to return a component.
** NGL.Stage.prototype.removeComponentsbyName array version.
** NGL.Stage.prototype.removeClashes removes clashes and the rotation.
* $.prototype.protein to enable a link
NB. this file ends with `$('[data-toggle="protein"]').protein();` to activate all links.

proteins is an array of {name: 'unique_name', type: 'rcsb' (default) | 'file' | 'data', value: xxx, 'ext': 'pdb' (default), loadFx: xxx}
where the optional loadFx is a function that is run on loading.

## Markup

Following Bootstrap, the most common CSS framework, several `data-*` attributes are proposed and implemented to control what is shown. If you are unfamilar with the terms "attribute" or "element" see [basics](#basics).

The first link is: `<a href='#viewport' data-toggle="protein" data-focus="domain" data-selection="11-228:A" data-color="lime" >a β-barrel</a>`. Actually, it is `<span class="prolink" data-target="viewport" …></span>` in order to add custom CSS styling (green).

The attribute `data-toggle="protein"` is what tells the browser that the link controls the protein ([see below for more](#row_toggle)), `data-focus="domain"` tells it how to zoom (domain | residue | clash | surface) to use, while `data-selection="11-228:A"` controls what to zoom into.

#### List of attributes for prolinks

<table>

<thead>

<tr>

<th>Attribute</th>

<th>Default</th>

<th>Affects</th>

<th>Description</th>

</tr>

</thead>

<tbody>

<tr id="row_toggle">

<td colspan="2">`data-toggle="protein"`</td>

<td>All</td>

<td>Instructs that the anchor element (link) or similar element affects the protein. The NGL.extension.js script add a monkeypatches JQuery with the prototype `protein`, then runs `$('[data-toggle="protein"]').protein();` so all relevant elements existing when the document is loaded are enabled. If new are added they have to be activated manually in JS with `$('whatever').protein()`.</td>

</tr>

<tr id="row_target">

<td>`data-target`</td>

<td>`'#viewport'`</td>

<td>All</td>

<td>If there is no stage on `#viewport` or there are multiple stages and they were stored in `NGL.stageId` (see [note](note)), use the attribute pointing towards an id with or without the hash. As anchor elements are not styled as hyperlinks unless you have a `href` attribute, an href is a valid alternative.</td>

</tr>

<tr id="row_focus">

<td>`data-focus`</td>

<td>`domain`</td>

<td>—</td>

<td>To control whether to focus on a large region/domain, on a few residues and their neighbourhood, surface, blur-factor or on a clash. the attribute `data-focus` can be used with the choice of terms `'domain'` (or `'region'`), `'residue'`, `'clash'`, `'bfactor'` (or `'blur'`) or `'surface'` respectively.</td>

</tr>

<tr id="row_selection">

<td>`data-selection`</td>

<td>— (compulsory for `data-focus` instructions, use `'*'` to select all)</td>

<td>`data-focus`</td>

<td>The selection is controlled with a [valid NGL selection ](http://nglviewer.org/ngl/api/manual/selection-language.html), for example a range is '1-20:A'.</td>

</tr>

<tr id="row_color">

<td>`data-color`</td>

<td>`'green'` (focus: domain) | `'hotpink'` (focus: residue)</td>

<td>`data-focus` (except `="surface"`)</td>

<td>To specify a colour, add the attribute `data-color="HTML_color"` where "HTML_color" is a valid html colour name or hex code. In the case of `data-focus="blur"`, both `data-selection` and `data-color`, if present, control the residues to show.</td>

</tr>

<tr id="row_radius">

<td>`data-radius`</td>

<td>`'5'` (Å)</td>

<td>`data-focus='residue'` and `data-focus='clash'`</td>

<td>Used to specify how many Åmstrongs to expand around in residue zooming mode.</td>

</tr>

<tr id="row_tolerance">

<td>`data-tolerance`</td>

<td>`'1'` (Å)</td>

<td>`data-focus='clash'`</td>

<td>The clashes are determined by finding distances less than the sum of the van der Waals radii. However, due to imprecise structures or sp2 orbitals it can be lower hence this optional factor</td>

</tr>

<tr id="title">

<td>`data-title`</td>

<td>Nothing shown</td>

<td>All</td>

<td>shows a temporary title, which is actually a label element with a for attribute pointing to the viewport id. Consequently if one wanted to override it's location one could add `<label for="viewport"></label>` where desired.</td>

</tr>

<tr>

<td>`data-load`</td>

<td>—</td>

<td></td>

<td>will load a new PDB, either as a 4 letter code or a index (see further). It plays well with data-focus or data-view, which are executed afterwards. However, a more powerful option is available thanks to the MultiLoader's loadFx.</td>

</tr>

<tr>

<td>`data-view`</td>

<td>—</td>

<td></td>

<td>accepts three possible values, one of these is an orientation matrix as begot from `stage.viewerControls.getOrientation()`. The 16-dimension vector can be used to manually correct residue selections (data-focus) by using both.</td>

</tr>

<tr>

<td colspan="2">`data-view='auto'`</td>

<td></td>

<td>Uses the `.autoView()` function, which translates without rotation.</td>

</tr>

<tr>

<td colspan="2">`data-view='reset'`</td>

<td></td>

<td>If the stage was loaded with the multiLoader() and a loadFx was supplied with the protein it will run that, otherwise it will do the same as auto.</td>

</tr>

</tbody>

</table>

### $('..').protein()

When the dom loads the links are automatically enabled, however, if new links are added dynamically you have to activate them using `$(...).protein()`, for example `$('[data-toggle="protein"]').protein();`

#### Viewport

##### Best option

The recomended way (simple/powerful) is have the viewport declared (in the correct location) like so `<div role="NGL" proteins="[{...}]"></div>`, where the JSON string value (=in quotes) of `proteins` is an array of objects like this: `{type: 'rcsb|file|data', value: 'PDB id|path|multiline string', loadFx: myOptionalFancyLoadFunction}`. Where the optional load function can be added to a script element and can be made from a PyMol file ([see PyMol converter](/pymol)).

##### Full options

There are four inter-compatible ways to declare the viewport.

*   <span class="fa-li"></span>**old way.** In JS you load it as the NGL suggests, but keeping the stage object globally declared as `stage`: `window.stage = new NGL.Stage( "viewport",{backgroundColor: "white"}); stage.loadFile('static/gfp.pdb')` — adding `stage` as a property of `window` (_i.e._`window.stage = …`) is the same as declaring without `var` (_i.e._`stage = …`; _cf._ `var stage = …`).
*   <span class="fa-li"></span>**Modded old way.** As above but you add your stage to the object `NGL.stageId` thusly `var id = "viewport"; NGL.stageIds[id] = new NGL.Stage( id,{backgroundColor: "white"}); NGL.stageIds[id].loadFile('static/gfp.pdb')`
*   <span class="fa-li"></span>**MultiLoader way.** Using the `multiLoader` function described below (`NGL.specialOps.multiLoader('viewport', [{type: 'rcsb', value: '1ubq', loadFx: myFancyLoadFunction}], 'gainsboro')`), which allows `data-load` prolinks to toggle between multiple proteins (pdb strings, custom pdb files or RCSB pdb entries) each with an optional load function.
*   <span class="fa-li"></span>**No JS way.** Using the attribute `role="NGL"` on the viewer div-element in combination with prolink `data-*` attributes, _e.g._ `<div id="viewport" role="NGL" data-load="1ubq" data-focus="residue" data-selection="30:A" data-view="[…]">`. If multiple PDB proteins are required, use `data-proteins` as opposed to load where the value is a comma separated space free list of codes (not array), these can be accessed via `data-load=3` prolinks as usual (this is less clear than simply specifying prolinks with `data-load` with a file or PDB code, but has the sole benefit that, data-load='1ubq' will re-load the file even if 1ubq is loaded, while data-load=2 will not if the current index is 2, however in future unique names will be implemented to avoid this drama). Note that the height issue is sorted and that it can be combined like everything else with click-to-enable-NGL images.

##### Image

If you are adding an image (as [described here](/imagetoggle)), you might need to add it manually as many WYSIWYG editors with insert image buttons (_e.g._ Blogger) make images that when clicked result in a pop-up with the image fullsize, which is obviously incompatible. Therefore add or edit the image thusly: `<div id="viewport"> <img src="my_protein.jpg" alt="my protein" width='100%' style='cursor: pointer'></div>`.

The CSS style can be different, but the important thing is that there is a `width` or a `min-width` and a `height` or a `min-height` —in this example the 0 height is a special case and results in the height being equal to the width.

#### myData object and multiLoader

The load ability, which uses the add-on `NGL.specialOps`, works preferably in combination with the add-on `NGL.specialOps.multiLoad`, which can initialise the scene and handles such things.

The data for load/multiLoader is stored in `myData object`, which has the property `myData.proteins`, which is a list of `{name: 'unique_name', type: 'rcsb' (default) | 'file' | 'data', value: xxx, 'ext': 'pdb' , loadFx: xxx}`. The optional argument loadFx is a function that accepts as argument a NGL protein (component) object and performs requested operations.

The MultiLoader and load can handle img elements in the div, namely the case where you start with an image with labels etc and you click on it and it switches to the viewer.

    function nice_ubiquitin (protein) {
            protein.addRepresentation( "line", {color: ..., sele: ...} );
            bla bla
        }
    NGL.specialOps.multiLoader('viewport', [{type: 'rcsb', value: '1ubq', loadFx: nice_ubiquitin}], 'aquamarine')
    //////////////////////////////id/////////array of elements with loadFx//////////////   ////background

The `data-load` can load proteins from the myData.proteins (and run the custom function LoadFx) if an index is provided.

<%include file="docs/docs_viewport.mako"/>

### Note

There are a bunch of underlying functions. They are in the file: [file michelanglo.js](https://github.com/matteoferla/MichelaNGLo/blob/master/michelanglo_app/static/michelanglo.js), which requires JQuery and NGL, which works as usual*. So at the end of your documents you should have:

    <script src="https://code.jquery.com/jquery-3.3.1.min.js" integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8=" crossorigin="anonymous"></script>
    <script src="https://unpkg.com/ngl@2.0.0-dev.34/dist/ngl.js" type="text/javascript"></script>
    <script src="https://michelanglo.sgc.ox.ac.uk/michelanglo.js" type="text/javascript"></script>

∗One issue is holding onto the stage object in JS. Therefore the stage is added as follows: `NGL.stageIds['viewport'] = new Stage( ...`. However, a better feature is using the `NGL.specialOps.multiLoad`, which handles it.

### Basic terms

A HTML page is formed by various elements with the following syntax: `<ELEMENT attribute="value"> text </ELEMENT>`. The first part, called the opening tag, contains attributes. These include the unique `id` and CSS controlling `style` attributes.

A special convention exist to store custom data in `data-*` attributes. For example, `<span id='blaId' data-hello='world'>bla bla<span>` appears simply as "bla bla" in the browser, but the JS can access this data, e.g. using JQuery `$('#blaId').data('hello')` one gets `world` back.
