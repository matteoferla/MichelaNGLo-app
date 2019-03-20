<%page args="viewport='error', proteinJSON='ERROR', backgroundcolor='red', image=False, loadfun='ERROR (child)', pdb=''" />

<p>This tab guides you into implementing a NGL view on your website.</p>

#################### raw
<%include file="../docs_raw.mako"/>

##################### viewpoer
<h4>Viewport</h4>
<p>Add where need the following for the viewport:</p>


% if image:
   <pre><div class="float-right"><a href="#viewport_code" data-clipboard-target="#snippet" class="clipboard">Copy</a></div><code id="viewport_code">&lt;div id="${viewport}" role="NGL" data-proteins='${proteinJSON}' data-backgroundcolor="${backgroundcolor}">&lt;img src="path/to_your_image.jpg" width="200px">&lt;/div></code></pre>
% else:
   <pre><div class="float-right"><a href="#viewport_code" data-clipboard-target="#snippet" class="clipboard">Copy</a></div><code id="viewport_code">&lt;div id="${viewport}" role="NGL" data-proteins='${proteinJSON}' data-backgroundcolor="${backgroundcolor}">&lt;/div></code></pre>
   <p>Optionally add <code>width="200px"</code> if you don't want it 100% width.</p>
% endif

###################### cdn
<%include file="../docs_cdn.mako"/>

##################### data
% if pdb:
    <h4>PDB string</h4>
<p>The PDB data needs to be embedded, therefore, below these add:</p>
    <pre><div class="float-right"><a href="#pdb_code" data-clipboard-target="#snippet" class="clipboard">Copy</a></div><code id="pdb_code">&lt;script type="text/javascript"&gt;
var pdb = `REMARK 666 Note that the indent is important as is the secondary structure def.
${pdb}`;
&lt;/script&gt;</code></pre>
% endif


###################### fun
<h4>Function</h4>
Below these add the following to all the custom representation and view of the protein:
<pre><div class="float-right"><a href="#fun_code" data-clipboard-target="#snippet" class="clipboard">Copy</a></div><code id="fun_code">&lt;script type="text/javascript"&gt;${loadfun}&lt;/script&gt;</code></pre>

<h4>Multiple representations</h4>
<p>If you want to have multiple representations or protein, triggerable with a <a href="/markup">guiding link</a>, simply upload a new PyMol file and combine the <code>data-proteins</code> attribute, change the name of the second function in both the <code>data-proteins</code> attribute and its declaration block.</p>


<!--
<h3 data-toggle="collapse" data-target=".docs_raw" style="cursor: pointer;">
   <span class="collapse show docs_raw">Show</span>
   <span class="collapse docs_raw">Hide</span> full guide
<span class="collapse show docs_raw"><i class="far fa-angle-double-down"></i></span>
<span class="collapse docs_raw"><i class="far fa-angle-double-up"></i></span></h3>
<div class="collapse docs_raw">
include file="docs_raw.mako"/>
</div>
-->



