<%namespace file="../layout_components/labels.mako" name="info"/>
<%inherit file="../layout_components/layout_w_card.mako"/>

<%block name="buttons">
            <%include file="../layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>

<%block name="title">
            &mdash; VENUS
</%block>

<%block name="subtitle">
            Variant effect on structure
</%block>

<%block name="body">

    <%include file="docs_nav.mako"/>


<div class="row">
    <h3>Aim</h3>
    <p>This tool has the aim of aiding structure-based exploration by using all the gathered information from different
    third-party databases that are pertinent to a given variant of interest, creating a sharable MichelaNGLo page.</p>
    <h3>Parts</h3>
    <p>
        The program runs in four parts.
        * The first simply gets the information of protein, such as the feature viewer.
        * The second gives the effect of the mutation independent of the structural data
        * The third gives the location and neighbourhood of the residue
        * The fourth gives the change in energy potential resulting from the mutation

    <h3>Energetics of protein destabilisation</h3>
    <p>
        Protein folding is largely entropy driven. In fact, were a protein to fold by exploring all possible combinations,
        a scenario known as
        <a href="https://en.wikipedia.org/wiki/Levinthal%27s_paradox" target="_blank">
            Levinthal's paradox  <i class="far fa-external-link"></i></a>, it would take longer that the lifespan of the universe.
        As a consequence of the strong entropic component, a folded protein is energetically
        more favourable than an unfolded one (downhill). By unfolded, here is intended a hypothetical isolated unfolded protein one,
        not one that is part of a denatured aggregate.
        The Gibbs free energy is the potential energy of the protein (technically a combination of entropy, enthalpy and temperature).
        The difference in energy of a folded protein relative to the unfolded state is simply referred to as &Delta;G.
        This is a negative value as the protein released energy to fold: so the more negative a the Gibbs free energy is the more stable a protein is.
        This energy is dependant on pressure and temperature. At a given temperature the &delta;G is zero:
        this is the melting temperature of the protein where 50% is fold and 50% is unfolded
        (and the hypothetically uncrowded protein can return to a folded state).
        Therefore a deleterious mutation will have a positive difference in &Delta;G (&Delta;&Delta;G)
        and a lower theoretical melting temperature.
        A deleterious mutation, however, does not need to increase the &delta;G all the way to zero to be deleterious <i>in vivo</i>:
        a sufficiently large local destabilisation of the structure is sufficient to cause the protein to aggregate and therefore be targetted to the proteasome.
        The difference between wild type protein and a mutant is dictated by the strain on torsion angle of the atoms involved
        and by difference in non-covalent bonds.
        The units used to describe the Gibbs free energy and other energies in biochemistry is kcal/mol.
        An often cited value is that of the C-H bond, which is 100 kcal/mol, or that of a peptide bond (20 kcal/mol), but protein folding does not break bonds, so this is misleading.
        In fact, the strength of the interactions involved are smaller:
        <ul>
            <li>a hydrogen bond is between 1&ndash;3 kcal/mol</li>
            <li>a salt-bridge (<i>e.g.</i>lysine-glutamic acid) is about 4&ndash;5 kcal/mol</li>
            <li>a &pi;-&pi; interaction is between 2&ndash;3 kcal/mol</li>
            <li>a &pi;-sulfur interaction is between 0.5-2 kcal/mol</li>
        </ul>
        The non-crystalline water surrounding the protein in the meanwhile is colliding
        and the average collision has 0.7 kcal/mol, as determined by multiplying the
        <a href="https://en.wikipedia.org/wiki/KT_(energy)" target="_blank">
        Boltzmann constant by the temperature <i class="far fa-external-link"></i></a> (which for our discussion is 37&deg;C).
        For more see <a href="https://www.ncbi.nlm.nih.gov/books/NBK22567/" target="_blank">
        Chemical Bonds in Biochemistry in NCBI  <i class="far fa-external-link"></i></a>,
        <a href="https://en.wikipedia.org/wiki/Protein_folding" target="_blank">
            protein folding in Wikipedia  <i class="far fa-external-link"></i></a>



    </p>

    </p>
</div>
</%block>

<%block name='modals'>
</%block>
<%block name="script">
    <script type="text/javascript">
    </script>
</%block>

