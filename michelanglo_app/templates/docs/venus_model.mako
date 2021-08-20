<%namespace file="../layout_components/labels.mako" name="info"/>
<%inherit file="../layout_components/layout_w_card.mako"/>

### /docs/venus_model

<%block name="buttons">
    <%include file="../layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>

<%block name="title">
    &mdash; VENUS — URLs
</%block>

<%block name="subtitle">
    Variant effect on structure — Model choice
</%block>

<%block name="body">

    <%include file="subparts/docs_nav.mako"/>

        <%include file="subparts/docs_venus_nav.mako" args='topic="model"'/>
         <h3>Decision tree</h3>
    <p>The structure shown is one of four, in the following preference:</p>
        <ol>
        <li>a submitted model,</li>
        <li>a PDB crystal structure, </li>
        <li>a Swissmodel model or</li>
        <li>or an AlphaFold2 model</li>
    </ol>
    <p>These can be disabled or altered within the advanced options menu.
        However, to qualify the candidate structure/model must contain the residue of interest.</p>
    <h4>PDB</h4>
    <p>For the PDB structure with the finest resolution is chosen.
        For more options for a given protein see <a href="/name">the Michelanglo creation by protein name</a>
    and use that structure: for example one may wish to use a structure not with best resolution, but with an interface.
    </p>
    <h4>SwissModel</h4>
    <p>SwissModel structures are threaded and as a result maintain the oligomerisation of the template, but also the conformation of the template.
        As a result, for close homologues the other chains from the template are migrated (albeit requiring caution hence the colour warning in the list of chains).
        As a result these models are preferable to AlphaFold2. For example, R24D in the MEF2C transcription factor, is a surface mutation on a single chain,
        but actually is a phosphate binding residue.<br/>
        The qMean is a quality metric, where larger is best. If the model is bad (and the filters lowered), this will be flagged.
    </p>
    <h4>AlphaFold2</h4>
    <p>EBI AlphaFold2 models are of complete protein, but as monomers and not complexes with other protein or small molecules.
        A common feature in many models are long loops with low confidence, these may be important
        and involved in complexes. In MEF2C, the C-terminal loop wraps around other proteins or DNA, because after all,
        a transcript factor DNA recognition domain by its own just binds DNA, while the rest of the protein recruits the mediator complex etc.
        For more details about what to look out for in an AlphaFold2 model see this
        <a href="https://blog.matteoferla.com/2021/07/what-to-look-out-for-with-alphafold2.html">blog post by Matteo Ferla (author of Michelanglo)</a>.
        Also, it is possible to model oligomers and complexes, as seen in the notebooks
        <a href="https://github.com/sokrypton/ColabFold" target="_blank">in the ColabFold GitHub repo by Sergey Ovchinnikov</a>.
    </p>
</%block>

<%block name='modals'>
</%block>
<%block name="script">
    <script type="text/javascript">
    </script>
</%block>

