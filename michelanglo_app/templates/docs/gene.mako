<%namespace file="../layout_components/common_methods.mako" import="copy_btn"/>
<%namespace file="../layout_components/labels.mako" name="info"/>
<%inherit file="../layout_components/layout_w_card.mako"/>
<%block name="buttons">
            <%include file="../layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>
<%block name="title">
            &mdash; Documentation
</%block>
<%block name="subtitle">
            Starting with a gene
</%block>

<%block name="main">

<%include file="docs_nav.mako"/>

<h4>Step one: get a structure</h4>
<p>If you known your gene name, head to the <a href="http://www.rcsb.org/" target="_blank">PDB <i class="far fa-external-link"></i></a> to look for crystal structures. Often there will be either none or a couple.</p>
<p>When you click on one, keep an eye out for the organism. Also look at the feature view (<i>e.g.</i> <a href="https://www.rcsb.org/pdb/protein/P42212" target="_blank">ID:P42212 <i class="far fa-external-link"></i></a>), this provides a really nice overview of your protein, showing what the lengths are of the crystals.
    If you cannot find your protein use your uniprot ID and add it to the end of the URL <code>www.rcsb.org/pdb/protein/</code>.
    At the bottom is the premade Swissmodel structure based on homologues and will be longer that the crystal structures, but is a threaded structure, so cannot be fully trusted without checking whether any observations are true for the template model.</p>
<p>If you don't find a structure, there are several servers that model protein for you. First, determine the domains by looking in Uniprot or PDB protein feature view, because no modelling program deals with sequences larger than 500 amino acids &mdash;a lazy way of getting the sequence of a region is to click on a range for a domain in Uniprot and changing the numbers in the URL.
    <a href="https://zhanglab.ccmb.med.umich.edu/I-TASSER/" target="_blank">I-TASSER <i class="far fa-external-link"></i></a> is tool that consistently wins a model predicting challenge (CASP), but is slow (2-3 days).
    <a href="http://www.sbg.bio.ic.ac.uk/phyre2/html/page.cgi?id=index" target="_blank">Phyre2 <i class="far fa-external-link"></i></a> is a lot quicker and also recently they have released a set of over 1,000 computed structures.
    <a href="http://evfold.org/evfold-web/evfold.do" target="_blank">EVFold <i class="far fa-external-link"></i></a> is best for totally unknown structures, because it uses covariance to predict what should be close to what. Namely, Normally parts of a structures are threaded (the residues on the template are simply replace) or are computed <i>ab initio</i> using forcefield calculations.
    The latter is wholly imprecise, but the accuracy is increased by using the assumption that residues that change together are likely close.
    Do note that if you are opting for a model, keep track of what the closest template is and what is the root mean square deviation (low single digit numbers is best) and make it clear with other users that you are using a model.
</p>
<p>It the case of crystal structures, often the protein with bound partners are found. The identity of each chain can be found in the PDB entry in the "Structure summary" tab (first one) in the card "Macromolecules". Sometimes protein from different organism are bound to interesting protein and it may be worth using that instead.
Which bound macromolecule or small molecule is up to you, but if in doubt, check the Uniprot entry or better still the literature to find out what the proteins are.</p>
<h4>Step two: Michelaɴɢʟo</h4>
<p><a href="https://michelanglo.sgc.ox.ac.uk/pdb" target="_blank">Michelaɴɢʟo: PDB conversion</a> and enter your PDB code (four letters) or upload the PDB file and then choose the view that suits best.</p>
<p>If you want to show one or more mutations go to edit (pencil button in the description card visible when logged in) and then press the button that says "Make mutations". Enter the chain and the mutations in the form M1W or A2D etc. separated by spaces. The program will do the rest.</p>
<h4>Bonus: add bilayer</h4>
<p>If for illustrative purposes you want to add a lipid bilayer, I recommend using <a href="http://www.charmm-gui.org/?doc=input/membrane.bilayer" target="_blank">Charmm-GUI membrane builder <i class="far fa-external-link"></i></a> and going a few steps in and stopping at solvating the molecule &mdash;Charmm is a MD simulator. Another feature offered is <a href="http://www.charmm-gui.org/?doc=input/pdbreader" target="_blank">modifying residues by phosphorylation, chemical attack or linkage with a few cyanine dyes<i class="far fa-external-link"></i><</a>.</p>
<p>Not all residue changes are possible, for another approach (using Rosetta see <a href="https://blog.matteoferla.com/2019/01/phosphorylated-pdb-files.html">this post</a>).</p>
</%block>