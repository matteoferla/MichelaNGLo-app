<%namespace file="../layout_components/labels.mako" name="info"/>
<%inherit file="../layout_components/layout_w_card.mako"/>

<%block name="buttons">
    <%include file="../layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>

<%block name="title">
    &mdash; VENUS
</%block>

<%block name="subtitle">
    Variant effect on structure — Other free energy calculators
</%block>

<%block name="body">
    <%namespace file="../layout_components/common_methods.mako" name="common"/>
    <%include file="subparts/docs_nav.mako"/>
        <%include file="subparts/docs_venus_nav.mako" args='topic="energy"'/>
        <h3>Other tools</h3>
        <div class="alert alert-warning alert-dismissible fade show" role="alert">
            <strong>Disclaimer</strong>: The list below is by no means exhaustive or is an endorsement of these
            and the order is not indicative of preference.
        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
        <span aria-hidden="true">&times;</span>
        </button>
        </div>
        <p>
            Venus is not the only tool to calculate ∆∆G available online.
            There are two main approaches: the <b>molecular mechanics based approach</b>, such as used in Venus,
            wherein the forces between the atoms is calculated, and the <b>machine learning approach</b>,
            wherein certain parameters are fed into a model, which in several cases do not require a structure.
            <br/>
            The following list with some different tools is presented to
            help determine the certainty of a hypothesis generated, for example if a mutation is
            unanimously predicted to be destabilising.
            Obviously, this list is in no way intended to encourage
            the practice known as p-value shopping, therefore,
            in the case of discordance, please refer to one of the many reviews that
            compare these tools
            (e.g. ${common.external('https://bmcbioinformatics.biomedcentral.com/articles/10.1186/s12859-021-04238-w', 'ref')}
            or ${common.external('https://academic.oup.com/bib/article/22/6/bbab184/6289890', 'ref')})
            <br/>
            Please note most of these tools require a structure or a PDB ID to be provided
            and also that
            Venus renumbers structures to match the canonical isoform in Uniprot (see ${common.docs('gene')}).
            whereas many PDB structures are number by the construct used to produce the protein
            for the experiment.
        </p>
        <ul class="fa-ul">

            <%common:ext_item link='https://foldxsuite.crg.eu/' name='FoldX', icon='fa-atom'>
                This is a ${common.wiki('Force_field_(chemistry)', 'forcefield')} based approach,
                similar to Rosetta, but utilising a different framework and different approximations for certain terms.
                For example, in Rosetta, the Lennard-Jones potential is split into its attractive and repulsive terms
                    allowing for differential weighting, both use implicit solvent, but with different solvatation
                    energy calculations etc.
                The server is free to use for academics upon registration.
            </%common:ext_item>

            <%common:ext_item link='https://mutpred.mutdb.org/index.html' name='MutPred2', icon='fa-sparkles'>
                This powerful tool gives its top scoring prediction of what may be disrupted by the mutation
                (stability, ligand binding, interface _etc._) starting solely from primary sequence.
                These features are predicted by the neural network and are not annotations,
                therefore, unlike Venus, which is limited by being strictly empirical evidence based,
                is able to suggest certain effects even if there no evidence for it.
            </%common:ext_item>

            <%common:ext_item link='https://missense3d.bc.ic.ac.uk/missense3d/' name='Missense3D', icon='fa-fire'>
                This tool uses a panel of critical structural hallmarks that would disrupt a protein,
                such as broken disulfides, altered buried hydrophobics, charge switch, proline in helices
                and so forth. A destabilisation prediction is also given using MolProbity.
            </%common:ext_item>

            <%common:ext_item link='https://marid.bioc.cam.ac.uk/sdm2/' name='SDM', icon='fa-table'>
                This longstanding tool, now in its second iteration as SDM2
                (${common.external('https://www-cryst.bioc.cam.ac.uk/%E2%88%BCsdm/sdm.php', 'previous version')}), is a hybrid
                    mechanistic and statistical approach wherein specific substitute tables are consulted
                    based on key molecular mechanical properties.
            </%common:ext_item>

            <%common:ext_item link='https://biosig.unimelb.edu.au/dynamut/' name='DynaMut', icon='fa-shipping-fast'>
                This tool applies a method that mimics MD in creating an ensemble of conformations
                    which are scored with a panel of different algorithms (DUET, mCSM, SDM and ENCoM).
            </%common:ext_item>

            <%common:ext_item link='https://cupsat.tu-bs.de/' name='CUPSAT', icon='fa-paw-claws'>
                This tool is part of the ${common.external('https://www.brenda-enzymes.org/', 'BRENDA enzyme database')}).
                It uses key forcefield terms quantify the protein environment to determine the scores.
            </%common:ext_item>

            <%common:ext_item link='https://dezyme.com/en/Software' name='Music suite', icon='fa-music'>
                This set of tools (PoPMuSiC, HoTMuSiC and SNPMuSiC),
                which requires registration for use, use neural network models based on either sequence or
                    structural (including molecular mechanical terms as is the case of SNPMuSiC).
            </%common:ext_item>

            <%common:ext_item link='https://pbl.biotech.iitm.ac.in/pPerturb' name='pPerturb', icon='fa-telescope'>
                This tool focuses on the effect a mutation has on the wider shell of residues
                    by analysing their interactions.
            </%common:ext_item>

            <%common:ext_item link='https://ncblab.nchu.edu.tw/iStable2' name='iStable2', icon='fa-link'>
                This tool combines eleven different scoring models in order to give a consensus score.
            </%common:ext_item>

            <%common:ext_item link='https://babylone.3bio.ulb.ac.be/MutaFrame/' name='MutaFrame', icon='fa-camera-movie'>
                ## This is the tool asked by reviewer 2. It is unusable.
                This tool combines two predictors SNPMuSiC and DEOGEN2 in an animated interface.
            </%common:ext_item>

            <%common:ext_item link='https://structure.bioc.cam.ac.uk/duet' name='Duet', icon='fa-dice-two'>
            This tool amalgamates the results from two predicts (mCSM and SDM) with a consensus approach.
            </%common:ext_item>
        </ul>
        
</%block>

<%block name='modals'>
</%block>
<%block name="script">
    <script type="text/javascript">
    </script>
</%block>

