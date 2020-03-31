<%namespace file="../layout_components/labels.mako" name="info"/>
<%inherit file="../layout_components/layout_w_card.mako"/>

<%block name="buttons">
    <%include file="../layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>

<%block name="title">
    &mdash; VENUS
</%block>

<%block name="subtitle">
    Variant effect on structure — Free energy
</%block>

<%block name="body">

    <%include file="subparts/docs_nav.mako"/>
        <%include file="subparts/docs_venus_nav.mako" args='topic="energy"'/>
        <h3>Energetics of protein destabilisation</h3>
        <h4>Free energy of folding</h4>
        <p>
            <div class="w-25 float-right p-3">
        <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Folding_funnel_schematic.svg/1024px-Folding_funnel_schematic.svg.png" alt="wiki" class="w-100">
        <i>Protein folding funnel (figure credit: Wikipedia)</i>
    </div>
            Protein folding is largely entropy driven. In fact, were a protein to fold by exploring all possible
            combinations,
            a scenario known as
            <a href="https://en.wikipedia.org/wiki/Levinthal%27s_paradox" target="_blank">
                Levinthal's paradox <i class="far fa-external-link"></i></a>, it would take longer that the lifespan of
            the universe.
            As a consequence of the strong entropic component, a folded protein is energetically
            more favourable than an unfolded one (downhill). By unfolded, here is intended a hypothetical isolated
            unfolded protein one,
            not one that is part of a denatured aggregate.
        </p><p>
            The Gibbs free energy is the potential energy of the protein (technically a combination of entropy, enthalpy
            and temperature).
            The difference in energy of a folded protein relative to the unfolded state is simply referred to as &Delta;G.
            This is a negative value as the protein released energy to fold: so the more negative a the Gibbs free
            energy is the more stable a protein is.
            This energy is dependant on pressure and temperature. At a given temperature the &Delta;G is zero:
            this is the melting temperature of the protein where 50% is fold and 50% is unfolded
            (and the hypothetically uncrowded protein can return to a folded state).</p>
        <p>
            Therefore a deleterious mutation will have a positive difference in &Delta;G (&Delta;&Delta;G)
            and a lower theoretical melting temperature.
            A deleterious mutation, however, does not need to increase the &Delta;&Delta;G all the way to zero to be
            deleterious <i>in vivo</i>:
            a sufficiently large local destabilisation of the structure is sufficient to cause the protein to aggregate
            and therefore be targetted to the proteasome.
            </p><p>
            The difference between wild type protein and a mutant is dictated by the strain on torsion angle of the
            atoms involved
            and by difference in non-covalent bonds.
</p>
    <h4>The meaning of kcal/mol</h4>
    <p>
            The units used to describe the Gibbs free energy and other energies in biochemistry is kcal/mol.
            Although, like for Kelvin and Celcius, kJ/mol may be used, 4 kJ/mol are 1 kcal/mol.

            An often cited value is that of the C-H bond, which is 100 kcal/mol, or that of a peptide bond (20
            kcal/mol), but protein folding does not break bonds, so this is misleading.
            In fact, the strength of the interactions involved are smaller:</p>
        <ul>
            <li>a hydrogen bond is between 1&ndash;3 kcal/mol</li>
            <li>a salt-bridge (<i>e.g.</i>lysine-glutamic acid) is about 4&ndash;5 kcal/mol</li>
            <li>a &pi;-&pi; interaction is between 2&ndash;3 kcal/mol</li>
            <li>a &pi;-sulfur interaction is between 0.5-2 kcal/mol</li>
            <li>an alanine residues in a cis conformation has penalty of 3-7 kcal/mol (<a href="https://onlinelibrary.wiley.com/doi/full/10.1002/jcc.25589" target="_blank"> ref <i class="far fa-external-link"></i></a>)</li>
        </ul>
        <p>
        The non-crystalline water surrounding the protein in the meanwhile is colliding
        and the average collision has 0.7 kcal/mol, as determined by multiplying the
        <a href="https://en.wikipedia.org/wiki/KT_(energy)" target="_blank">
            Boltzmann constant by the temperature <i class="far fa-external-link"></i></a> (which for our discussion is
        37&deg;C).
        </p>
        <h4>Pyrosetta</h4>
        <p>
    <div class="w-25 float-right p-3">
        <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/MM_PEF.png/1280px-MM_PEF.png" alt="wiki" class="w-100">
        <i>Different terms are combined to form the energy function (figure credit: Wikipedia)</i>
    </div>
            The potential energy of a small molecule or a macromolecule can be described by an equation that is the sum of a variety of
            terms that describe the interations between each atom of the molecule. This equation use a parameterises derived from specific physicochemical data.
            Such a combination of a function and the parameters is a
            <a href="https://en.wikipedia.org/wiki/Force_field_(chemistry)" target="_blank">
            full-atom classical-mechanical force-field model <i class="far fa-external-link"></i></a>. Different force-field models exist.
            In VENUS the calculations are done with pyrosetta.
            This is not technically a traditional classical-mechanics force-field as it includes terms derived from empirical data
        that better fit the protein, such as improved hydrogen bonding between distant residues.
        Nevertheless, the units of the score function used,
            <a href=https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5717763/" target="_blank">
            ref2015 score function <i class="far fa-external-link"></i></a>, are approximately equal to kcal/mol at room temperature.
        </p>
        <h4>Limitations</h4>
        <p>However, other properties impact on the behaviour of a protein, independently of its interactions.
        For example, the isoeletric point (pI) of a protein has profound effects on its solubility regardless of how stably it is folded.
        Specifically, a protein is less soluble (i.e. will aggregate) if the pI is close to the pH of its environment, supposedly pH 7.4.
        Another example, is the presence of a large hydrophobic path, which physiologically behaves differently than in similations of an isolated protein,
            namely by forming aggregates.</p>
        <h4>Further reading</h4>
    <p>
        For more see <a href="https://www.ncbi.nlm.nih.gov/books/NBK22567/" target="_blank">
        Chemical Bonds in Biochemistry in NCBI <i class="far fa-external-link"></i></a>,
        <a href="https://en.wikipedia.org/wiki/Protein_folding" target="_blank">
            protein folding in Wikipedia <i class="far fa-external-link"></i></a>
        </p>
</%block>

<%block name='modals'>
</%block>
<%block name="script">
    <script type="text/javascript">
    </script>
</%block>

