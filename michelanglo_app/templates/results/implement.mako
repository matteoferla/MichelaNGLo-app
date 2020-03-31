<%page args="viewport='error', proteinJSON='ERROR', backgroundcolor='red', image=False, loadfun='ERROR (child)', pdb=''" />
<%namespace file="../layout_components/common_methods.mako" import="copy_btn"/>
<p>This modal guides you into implementing a NGL view on your website.</p>

#################### raw
<%include file="../docs/subparts/docs_raw.mako"/>



##################### viewpoer
<h4>Viewport</h4>
<p>Add where need the following for the viewport:</p>

<%
    viewport = 'viewport'
%>


% if image:
   <pre>${copy_btn('viewport_code')}<code id="viewport_code">&lt;div id="${viewport}" role="NGL" data-proteins='${proteinJSON}' data-backgroundcolor="${backgroundcolor}">&lt;img src="path/to_your_image.jpg" width="200px">&lt;/div></code></pre>
% else:
   <pre>${copy_btn('viewport_code')}<code id="viewport_code">&lt;div id="${viewport}" role="NGL" data-proteins='${proteinJSON}' data-backgroundcolor="${backgroundcolor}">&lt;/div></code></pre>
   <p>Optionally add <code>width="200px"</code> if you don't want it 100% width.</p>
% endif

###################### cdn
<%include file="../docs/subparts/docs_cdn.mako"/>

##################### data
% if pdb:
    <h4>PDB string</h4>
<p>The PDB data needs to be embedded, therefore, below these add. Do note that the indent is important &mdash;as is the secondary structure definition.</p>
    <pre style="overflow: scroll; height: 5.5rem;">${copy_btn('pdb_code')}<code id="pdb_code">&lt;script type="text/javascript"&gt;
        %if isinstance(pdb, str):
var pdb = `${pdb|n}`;
        %else:
            %for name, structure in pdb:
var ${name} = `${structure|n}`;
            %endfor
        %endif

&lt;/script&gt;</code></pre>
%else:
    <h4>PDB Code</h4>
    <p>The structure is retrieved from the PDB, so there is no need to do anything for the structural data.</p>
% endif


###################### fun
%if loadfun:
    <h4>Function</h4>
Below these add the following to all the custom representation and view of the protein:
<pre style="overflow: scroll; height: 5.5rem;">${copy_btn('fun_code')}<code id="fun_code">&lt;script type="text/javascript"&gt;${loadfun|n}&lt;/script&gt;</code></pre>

<h4>Multiple representations</h4>
<p>If you want to have multiple representations or protein, triggerable with a <a href="/docs/markup">guiding link</a>, simply upload a new PyMol file and combine the <code>data-proteins</code> attribute, change the name of the second function in both the <code>data-proteins</code> attribute and its declaration block.</p>

%endif


###################### description

<%
    import markdown, re
    descr_mdowned = markdown.markdown(description)
%>
<h4>Description</h4>
Lastly, if you want to use the text you created with all the prolinks add the following:
#### The descr_mdowned _has_ to be converted. Do not add the n flag.
<pre style="overflow: scroll; height: 5.5rem;">
    ${copy_btn('desc_code')}
    <code id="desc_code">${descr_mdowned|h}</code></pre>
<script>
    new ClipboardJS('#descr_btn', {
        text: () => $('#desc_code').html()
    });
</script>
<p>Do note that you will need to add style to the <code>class="prolinks"</code>. Within Michelanglo, the style is simply:</p>
<pre>${copy_btn('green_code')}<code id="green_code">&lt;style>
    .prolink {
	color: mediumseagreen;
    }

    .prolink:hover {
        color: seagreen;
        cursor: pointer;
        text-decoration: underline;
    }
&lt;/style>
</code></pre>
<p>But you can do what ever you fancy from a very trendy teal, mustard (<code>#ffdb58</code>) or coral to a very 90s-web neon green, yellow and pink &mdash;I hear apricot (<code>#fbceb1</code>) is in this year.</p>
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



