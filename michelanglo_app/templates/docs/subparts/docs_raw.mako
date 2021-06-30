<%namespace file="../../layout_components/common_methods.mako" import="copy_btn"/>
<h4>Raw HTML mode</h4>
<div id="raw_html">
    <p>First, you can only use the code if you have a website that you can edit as raw HTML. Otherwise, you can only share links or zipped html files.</p>
<p>
    <a href="raw_html" data-toggle="collapse" class="collapse show" data-target="#raw_html .collapse">more...</a>
    <a href="raw_html" data-toggle="collapse" class="collapse" data-target="#raw_html .collapse">less...</a>
</p>
<div class="collapse pl-3 ml-2 border-left">
   <p>Not necessarily of the whole page as only a small part is fine. For example:</p>
<img src="/images/WYSIWYG_editor.png" width="200" alt="WYSIWYG editor">
<img src="/images/raw_editor.png" width="200" alt="raw editor">
   <p>In the first case, the HTML code is hidden as one sees what one gets as an end result. In the second case, the HTML code is visible: words between tags such as &lt;b&gt; are not styled. In most cases JS can be added here.</p>
   <p>If it does not work on your site, it may because some information is lost when you added it.</p>

   <p>Try adding to your page:</p>

   <pre>${copy_btn('test_code')}<code id="test_code">I am definitely in the correct HTML editor mode as this is &lt;b&gt;enboldened&lt;/b&gt; and this is &lt;span id='blue'&gt;blue&lt;/span&gt;.
&lt;script type="text/javascript"&gt;document.getElementById("blue").style.color = "blue";&lt;/script&gt;</code></pre>

   <p>And view it.</p>
   <ul>
       <li>If the emboldened text is not bold, but has <code>&amp;gt;b&amp;lt;</code> before it, you were ending your html page in an editor that showed you the end formatting (WYSIWYG) not the raw HTML code.</li>
       <li>If the emboldened text was bold, but the ought-to-be blue text was not, they the editor may be stripping JS for security reasons or you switched from raw to WYSIWYG before saving and it stripped it.</li>
       <li>If both displayed as hoped then it is trickier.</li>
   </ul>
   <p>On Chrome show the console. To do so press the menu button at the top right next to the your face, then "More tools..." then "Developer tools".
       Here you can see what went wrong with your page. Is there a "resource not found error"? If so, you may have set it to fetch something that was not there or in that location.</p>




<p>If the demo image gives you an unsolicited black, that means something went wrong with the parsing of the parts. See the <code>else {return 0x000000} //black as the darkest error!</code> line, which is there as a last ditch.
To debug this yourself, open the console and type <code>protein.structure.eachAtom(function(atom) {console.log(atom.chainid);});</code> or in the inner bit <code>atom.resno</code> or other property of <code>atom</code> until you figure out what is wrong with your structure.
The variable protein can be obtained with <code>stage.compList[0]</code> if the stage is exposed or if you are using NGL extended script <code>NGL.getStage('viewport').compList[0]</code> or <code>NGL.getStage('viewport').getComponentByType('structure')</code>.</p>
<p>If you thing, the fault is in the code please email me. I am aware of two unfixed bugs, one is the CD2 atom in histidine residues with different colored carbons and the other is the absence of shades of gray (_e.g._ `gray40`) in the color chart.
</p>
</div>
</div>
