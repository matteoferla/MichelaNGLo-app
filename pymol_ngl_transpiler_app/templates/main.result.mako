<%page args="snippet='', snippet_run='', error='', error_msg='', error_title='', validation='', viewport='viewport', image=False, save=''"/>
<%namespace file="labels.mako" name="info"/>

<li class="list-group-item" id="results">
    <div class="float-right">
                <button type="button" class="btn btn-outline-secondary" id="tour_result"><i class="far fa-question"></i></button>
            </div>
    <h3>Results</h3>

    % if error:
        <div class="alert alert-${error}" role="alert">
            <h4 class="alert-heading">${error_title}</h4>
            <p>${error_msg}</p>
            <hr>
            <p class="mb-0">If you believe this is incorrect please let Matteo know!</p>
        </div>
    % endif

    % if snippet:
       #### tab control
    <nav>
      <div class="nav nav-tabs" id="nav-tab" role="tablist">
        <a class="nav-item nav-link active" id="nav-protein-tab" data-toggle="tab" href="#nav-protein" role="tab" aria-controls="nav-protein" aria-selected="true">Live</a>
        <a class="nav-item nav-link" id="nav-downloads-tab" data-toggle="tab" href="#nav-downloads" role="tab" aria-controls="nav-downloads" aria-selected="false">Shareables</a>
        <a class="nav-item nav-link" id="nav-implement-tab" data-toggle="tab" href="#nav-implement" role="tab" aria-controls="nav-implement" aria-selected="false">Instructions</a>
        <a class="nav-item nav-link" id="nav-code-tab" data-toggle="tab" href="#nav-code" role="tab" aria-controls="nav-code" aria-selected="false">Code</a>
        </div>
    </nav>
        <br/>
           #### tabs
    <div class="tab-content" id="nav-tabContent">

           #### first tab: live
      <div class="tab-pane fade show active" id="nav-protein" role="tabpanel" aria-labelledby="nav-protein-tab">


          % if image:
              <div id="${viewport}"><img src="images/clickmap.jpg" alt="clickmap" width='100%' style='cursor: pointer'></div>
          % else:
              <div id="${viewport}" style="width:100%; height: 0; padding-bottom: 100%;"></div>
          % endif
          <div class="row">
                  % if save:
                      <div class="col-12 col-md-3 m-2">
              <button type="button" class="btn btn-success w-100 my-1" id="${save}"><i class="far fa-camera"></i> Take snapshot</button>
                      </div>
                % endif

              <div class="col-12 col-md-3 m-2"><button type="button" class="btn btn-primary w-100 my-1" data-toggle="modal" data-target="#basics"><i class="far fa-cubes"></i> Protein basics</button></div>
              <div class="col-12 col-md-3 m-2"><button type="button" class="btn btn-primary w-100 my-1" data-toggle="modal" data-target="#about"><i class="far fa-code"></i> About</button></div>
          </div>

      </div>

            #### second tab: download
        <div class="tab-pane fade" id="nav-downloads" role="tabpanel" aria-labelledby="nav-downloads-tab">
            <div class="list-group border border-rounded">
                % if page:
              <a href="user-structures/${page}.html" class="list-group-item list-group-item-action">
                <i class="far fa-handshake"></i> Sharable and editable version
              </a>
                  % endif
              <a href="#" class="list-group-item list-group-item-action"><i class="far fa-download"></i> Download files</a>
              <a href="#" class="list-group-item list-group-item-action"><i class="far fa-map"></i> Download PDB</a>
            </div>
      </div>

        #### third tab: implement
      <div class="tab-pane fade" id="nav-implement" role="tabpanel" aria-labelledby="nav-implement-tab">
          <p>This tab guides you into implementing a NGL view on your website.</p>
           <h4>Adding raw HTML</h4>
           <p>First, you can only use the copy-pastable code if you have a website that you can edit as raw HTML.
           <a href="nav-implement" data-toggle="collapse" class="collapse show" data-target="#nav-implement .collapse">more...</a>
           <a href="nav-implement" data-toggle="collapse" class="collapse" data-target="#nav-implement .collapse">less...</a>
           </p>


           <div class="collapse">
               <p>Not necessarily of the whole page as only a small part is fine. For example:</p>
            <img src="images/WYSIWYG_editor.png" width="200">
            <img src="images/raw_editor.png" width="200">
               <p>In the first case, the HTML code is hidden as one sees what one gets as an end result. In the second case, the HTML code is visible: words between tags such as &lt;b&gt; are not styled. In most cases JS can be added here.</p>
               <p>If it does not work on your site, it may because some information is lost when you added it.</p>

               <p>Try adding to your page:</p>

               <pre><code>I am definitely in the correct HTML editor mode as this is &lt;b&gt;enboldened&lt;/b&gt; and this is &lt;span id='blue'&gt;blue&lt;/span&gt;.&lt;script type="text/javascript"&gt;document.getElementById("blue").style.color = "blue";&lt;/script&gt;&lt;</code></pre>

               <p>And view it.</p>
               <ul>
                   <li>If the emboldened text is not bold, but has <code>&amp;gt;b&amp;lt;</code> before it, you were ending your html page in an editor that showed you the end formatting (WYSIWYG) not the raw HTML code.</li>
                   <li>If the emboldened text was bold, but the ought-to-be blue text was not, they the editor may be stripping JS for security reasons or you switched from raw to WYSIWYG before saving and it stripped it.</li>
                   <li>If both displayed as hoped then it is trickier.</li>
               </ul>
               <p>On Chrome show the console. To do so press the menu button at the top right next to the your face, then "More tools..." then "Developer tools".
                   Here you can see what went wrong with your page. Is there a "resource not found error"? If so, you may have set it to fetch something that was not there or in that location.</p>

<p>If you thing, the fault is in the code please email me.</p>


If the demo image gives you an unsolicited black, that means something went wrong with the parsing of the parts. See the `else {return 0x000000} //black as the darkest error!` line? That is there as a last ditch.
To debug this yourself, open the console and type `protein.structure.eachAtom(function(atom) {console.log(atom.chainid);});` or `atom.resno` or other property of `atom` until you figure out what is wrong with your structure.
I am aware of two unfixed bugs, one is the CD2 atom in histidine residues with different colored carbons and the other is the absence of shades of gray (_e.g._ `gray40`) in the color chart.
</p>
           </div>


           <h4>Add the viewport</h4>
          <p>Add wherever needed to the page add <code> &lt;div id="${viewport}" style="width:100%; height: 0; padding-bottom: 100%;"&gt;&lt;/div&gt;</code> or something similar.</p>
        <p>If you are adding an image, you might need to add it manually as many WYSIWYG editors with insert image buttons (<i>e.g.</i> Blogger) make images that when clicked result in a pop-up with the image fullsize, which is obviously incompatible.
        Therefore add or edit the image thusly: <code>&lt;div id="viewport"&gt; &lt;img src="my_protein.jpg" alt="my protein" width='100%' style='cursor: pointer'&gt;&lt;/div&gt;</code>.</p>
        <p>The CSS style can be different, but the important thing is that there is a <code>width</code> or a <code>min-width</code> and a <code>height</code> or a <code>min-height</code> &mdash;in
            this example the 0 height is a special case and results in the height being equal to the width.</p>
        <p>Then copy-paste the code to the bottom of the HTML document (with the editor in HTML mode).</p>
          % if validation:
        <p>For code that can be used to validate the orientation in PyMOL (i.e. gone full circle) <a href="#validation" data-toggle="collapse">press here.</a></p>
        <div class="collapse" id="validation">
            <pre class="p-2"><div class="float-right"><a href="#validation_code" data-clipboard-target="#validation_code" id="copy_validation">Copy</a></div>
                <code id="validation_code">${validation}</code></pre>
        </div>
    % endif
      </div>

       ### fourth tab: code
      <div class="tab-pane fade" id="nav-code" role="tabpanel" aria-labelledby="nav-code-tab">
        <pre class="p-2"><div class="float-right"><a href="#snippet" data-clipboard-target="#snippet" id="copy_snippet">Copy</a></div>
            <code id="snippet">snippet</code></pre>
      </div>

    </div>
    % endif
</li>


% if snippet:
    <script type="text/javascript">
        new ClipboardJS('#copy_snippet,#copy_validation');
        $(document).ready(function () {${snippet_run|n}});



        window.tour_result = new Tour({
          backdrop: true,
          orphan: true,
          onStart: function () {$('#nav-protein-tab').trigger('click');},
          steps: [
          {
            element: "#nav-protein-tab",
            title: "Example of interactive",
            content: `${info.attr.protein|n}`,
            placement: "top",
              onNext: function() {$('#nav-code-tab').trigger('click');}
          },{
            element: "#nav-code-tab",
            title: "Code to use",
            content: `${info.attr.code|n}`,
            placement: "top",
              onNext: function() {$('#nav-implement-tab').trigger('click');}
          },{
            element: "#nav-implement-tab",
            title: "Code to use",
            content: `${info.attr.implement|n}`,
            placement: "top",
              onNext: function() {$('#nav-downloads-tab').trigger('click');}
          },{
            element: "#nav-downloads-tab",
            title: "Code to use",
            content: `${info.attr.downloads|n}`,
            placement: "top",
              onNext: function() {$('#nav-downloads-tab').trigger('click');}
          }]});

        $('#tour_result').click(function () {
            // Initialize the tour
            tour_result.init();
            // Start the tour
            if (tour_result.ended()) {tour_result.goTo(0);}
            tour_result.start(true);
        });


    </script>
% endif
<%include file="about.mako"/>
<%include file="basics.mako"/>
