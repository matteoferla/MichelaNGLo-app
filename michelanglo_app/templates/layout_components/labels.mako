<%!

# gets used on tour for h1
aim =  '''<p>This web app converts a PyMOL PSE view into a piece of JS code that can be used on parts of the web one curates.</p>
<p>The aim of this app is to provide a way for a user to easily generate a web-ready output that can be pasted into a webpage editor resulting in an iteractive protein view.
Specifically, the intended audience are biochemists that may not have any web knowledge that wish to display on their academic pages their researched protein.</p>
<p>In fact, nearly every biochemist uses PyMOL and makes protein figures for results sharing, for their websites, for their social media or for publications. In several of these online locations one is can add JS scripts, namely one can edit the page as raw HTML, for example in one's university userspace, on free website hosting pages, on blog pages, but not Twitter or Facebook or in journals &mdash;if this catches on, maybe we might be able to convince an editor or two.</p>
'''
#next
usable='''<p>The script output a secret temporary page that can be shared, but also a block of code that can be used by the user on their sites.
About the latter usage, to use the output code one needs access to the raw HTML. Not necessarily of the whole page as only a small part is fine. For example:</p>
<div class='row'>
<div class='col-6'><img src="/images/WYSIWYG_editor.png" width="100%">
<p>Here the HTML code is hidden as one sees what one gets as an end result</p>
</div>
<div class='col-6'><img src="/images/raw_editor.png" width="100%">
<p>Here the HTML code is visible: words between tags such as &lt;b&gt; are not styled. In most cases JS can be added here.</p>
</div>
</div>'''

github='''<p>The script for the converter is available on GitHub, along with detailed description of the workings.</p><p>NB. This repository contains both the web app (run <code>python3 app.py</code>) and the <code>PyMOL_to_NGL.py</code> script itself, which works alone bar for the output template <code>output.js.mako</code>.'''

mode='''<p>Two modes are available. The first, and main, one is by uploading the PSE file to convert. The second is for particular cases where one wants to manually input the view data from PyMOL &mdash;say to tinker with the zoom (the last parameter in the view matrix).</p>
'''
upload='''<p>Upload your PSE.</p>
<p>Choose your file. Only one file is allowed, but if you wanted to have a toggle on your site between your models, it is easily doable because in the output code the filename or PDB data are stored in an arrays already.</p>
'''

demo_pse='''<p>Alternatively, choose a demo PSE file from a list.</p>'''

pdb_string='''<p>In order to allow visitors to see files that are not from RCSB PDB, you need to either put them online somewhere or you can provide the PDB data in the code itself (which makes it big).</p>
<p>If you want to put them online somewhere, see <a href="#CDN_modal" data-toggle="modal" data-target="#CDN_modal" >this note</a>.'''


pdb='''<p>Two options: the PDB code from PDB or a web address to a file with suffix and all.</p>
<p>Regarding the latter, if you are just opening a .html file on your computer and the custom pdb file is next to the .html file, just write the name of the file (relative path).</p>
<p>Else, please opt for the inclusion of the PDB data in the code (previous option).</p>'''

uniform_non_carbon='''<p>It is unlikely that one purposefully wants a non-carbon element to be represented with different colors.</p>
<p>By checking this, the most common color for that element will be used.</p>'''

image='''<p>Use a static image that when clicked becomes the NGL interactive protein.</p>
<p>Whereas, the most commonly used protein viewing software is PyMol, most researchers render a view and label/draw upon it in Paint/Powerpoint/Photoshop.</p>
<p>Consequently, the code allows users to generate code than when a given static image is clicked it results in a NGL viewer div. <a href='http://michelanglo.sgc.ox.ac.uk/LZTR1.html' target='_blank'>See here for an example <i class="far fa-external-link-square"></i></a>.
The mouse image informing visitors of how to switch can be found <a href="/images/clickmap.jpg" download="clickmap.jpg">here</a>.'''

sticks='''<p>The equivalent of PyMOL sticks is liquorice in NGL, however, hyperball looks a lot nicer.
</p><img src='/images/stick.png' width='100px'><img src='/images/sym_stick.png' width='100px'><img src='/images/hyperball.png' width='100px'>'''

stick='''<p>The equivalent of PyMOL sticks is liquorice in NGL, however, hyperball looks nicer. Example of &ldquo;liquorice&rdquo; with no valency shown akin to PyMOL v1 default settings:</p><img src='/images/stick.png' width='100px'>'''

sym_stick='''<p>The equivalent of PyMOL sticks is liquorice in NGL, however, hyperball looks nicer. Example of &ldquo;liquorice&rdquo;  with valency shown akin to PyMOL v2 default settings:</p><img src='/images/sym_stick.png' width='100px'>'''

hyperball='''<p>The equivalent of PyMOL sticks is liquorice in NGL, however, hyperball looks nicer. Example of &ldquo;hyperball&rdquo;:</p><img src='/images/hyperball.png' width='100px'>'''


protein='''Here the code is seen in action. Any errors will appear in black &mdash; for example, if you have a chain that has a unicode character, &THORN;, PyMOL will make a mess of it. If you have residues with the same id or more than 500 ligand atoms but no connect map, these will be wrong.'''

code='''This the the HTML code to paste into your editor. Do note, the viewport needs to be specified'''

implement='''These are the instructions of how to add the viewport.'''

downloads='''These are links to the stand-alone page whose address can used for sharing or to download the results.'''

pdb_string="Basically, if you are using a PSE based on a RCSB PDB structure, don't tick this, but give the PDB code. Otherwise, tick this. For more info, press the question mark."

#### for markup builder



%>
