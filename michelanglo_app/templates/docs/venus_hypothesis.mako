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
        <%include file="subparts/docs_venus_nav.mako" args='topic="hypothesis"'/>
        <h3>Hypothesis generation</h3>
        <p>A mutation may have a variety of possible effects at the cellular level.
            Several of these hypothesis could be combined or manifest at different severity.
            To pinpoint what it could be in order to direct further studies a variety of factors need to be considered.
            <br/>
            <a href="https://gnomad.broadinstitute.org/" target="_blank">gnomAD<i class="far fa-external-link"></i></a>,
            a repository of genome and exome sequencing data, isthe ideal resource for untangling the effect,
            however, the sampling in <b>gnomAD is not exhaustive</b> (16k samples for the v3 control set).
            Consequently, a heterozygous variant more frequent than 10<sup>-5</sup> may be found homozygously in the population,
            but be absent from the gnomAD database.
            The square of the frequency gives a <u>ballpark figure</u> of how many one would expect to find homozygously
            (erroneously assuming homogeneity in the human population).

            <br/>
This is The list of hypotheses below is not meant to be an exhaustive list, but simply an aid for thought.
        </p>

        <h4>Truncation</h4>
        <p><i>Hypothesis:</i> truncations (frameshift and nonsense) of all domains, simply result in less protein.<br/>
            <i>Details:</i>
        If heterozygous, in a simple system there should be 50% less functional protein.
        If homozygous, there should be no functional protein.
        The heterozygous pathogenic case is referred to as <b>haploinsufficiency</b>. If a heterozygous truncation is tolerated
            it is referred to as <b>dosage balanced</b>.
            <br/><i>C-terminal truncations</i>
            The C-terminal is frequently disordered, but can have a structural role and in some cases
            the carboxylate forms a buried salt bridge, or can be highly subjected to post-translational modifications.
            A well studied example of the latter is DNA polymerase.
            <br/><i>gnomAD:</i>
        In gnomAD controls, one would expect no similar case of truncations,
            bar possibly for truncations at the very end of the C-terminal, unless this is structural of modified as mentioned.
<br/><i>NB:</i>
            Venus does not do predictions on truncation, but if one were to want to use Venus for a
            truncation submitting a silent mutation (an identity) it will provide with domain information...
        </p>

        <h4>Interdomain truncation</h4>
        <p><i>Hypothesis:</i> truncation of regulatory domains result in misregulation.<br/>

            <i>Details:</i>
Premature terminations may lead to
            <a href="https://en.wikipedia.org/wiki/Nonsense-mediated_decay" target="_blank">nonsense mediated decay<i class="far fa-external-link"></i></a>,
            where the transcript gets degraded, resulting in a diminished but not absent level of translation from
            the defective allele. Therefore if the remnant is stable, some 20%-30% of it may be made,
            which may be sufficient to cause an effect, especially it the C-terminal domain was regulatory.
        </p>

        <h4>Destabilisation</h4>
        <p><i>Hypothesis:</i> The protein is destabilised and less active
            <br/><i>Details:</i>
        This is the classic case of loss of function.
            The protein may aggregate and/or more easily targeted for degradation.
            In the most simple/severe case the effect is no different from a truncation.
           However, cases can range from somewhat less functional to entirely non-functional, with a gradient of severity.
            An additional layer of complexity arises where a specific domain is destabilised and less active,
            while other domains are functional.

            <br/><i>gnomAD:</i> To be a valid hypothesis one would not expect there to be
            any truncations, before or within that domain, at a similar zygosity in the gnomAD control set.<br/>

            If the variant is part of a disease cohort and the control set includes truncations,
            this would indicate other effects are at play in the disease cohort (<i>e.g.</i> sequestration).
            If there are no truncations in either the control set or the cohort, assuming the cohort is large,
            it could be that truncation of the affected allele is <b>embryonically lethal</b> and therefore not detected
            (<a href="https://en.wikipedia.org/wiki/Survivorship_bias" target="_blank">survivorship bias <i class="far fa-external-link"></i></a>)
        </p>

        <h4>Weaker interface</h4>
        <p><i>Hypothesis:</i> The protein is less able to bind a partner protein
            <br/><i>Details:</i>
        If the partner protein is kept in check by the affected protein, the disruption will deregulate the partner protein,
            potentially manifesting in a dominant manner.
            A variant of this is when a regulatory domain is part of the same protein (see 'Domain destabilisation').
            <br/><i>gnomAD:</i> To be a valid hypothesis, one would not expect similarly severe
            variants at a similar zygousity affecting the same surface within the the gnomAD control set.
        </p>
                <h4>Compromised activity</h4>
        <p><i>Hypothesis:</i> The protein loses its catalytic activity or is unable to switch conformation
            <br/><i>Details:</i>
        In the simplest case the effect is the same as a truncation or severe destabilisation,
            <i>i.e.</i> there is no functional protein.
            However, it may still bind to a partner protein, effectively sequestering it (see 'Sequestration').
            <br/>
            Ideally, to study a protein that undergoes a conformational switch one would run a long term
            molecular dynamics simulation, however, calculating the ∆∆G of different conformations (single static snapshots)
            can be used as a proxy to assess whether a conformation is disfavoured or not, for example
            if an apo conformation has a worse ∆∆G, while a bound conformation has a neutral ∆∆G
            then potentially the latter state is favoured. To investigate this in Venus, one needs to understand
            what models represent which state and submit them as a custom model.
        </p>

        <h4>Sequestration</h4>
        <p><i>Hypothesis:</i> The protein is inactive but still binds a partner protein decreasing functional concentration of the latter
            <br/><i>Details:</i>This scenario may present a worse phenotypic consequence than a truncation or severe destabilisation.
            If a protein forms a complex with another protein that is intolerant to decreased protein levels
            and the function of the latter is affected by the interaction, an inactive affected protein would
            in effect sequester the latter keeping it out of service.
            For example, in RPB1 (POLR2A-encoded) missense variants that abrogate activity are worse than nonsense variants
            potentially due to RPABC3 (POLR2H) sequestration.
            <br>Some native protein are inactive when sequestered by another protein in a particular conformation,
            as is the case for the &beta;-&gamma; subunits of G-protein, which bind to the &alpha; subunit
            in the GDP bound conformation. Mutations therefore in the complex may result in a loss of sequestration
            of the &beta; subunit —whereas this interface on the &beta; subunit is also involved with its downstream target,
            it is a large surface, so differences can easily result in differential affinities for the different protein.
        </p>

        <h4>Non-functional oligomer</h4>
        <p><i>Hypothesis: A single variant chain makes the complex non functional to some degree</i>
            <br/><i>Details:</i>Theoretically, the number of complex without no variant chains
            is 0.5<sup><i>n</i></sup>, where <i>n</i> is the number of chains in an oligomer,
            assuming that the variant chain is at an equal concentration to the unaffected chain
            and has the same affinity.<br/>
            A homozygous truncation that abrogates the protein activity has a functionality of 0%.
            So the functional fraction of a pool of oligomers of two chains, one affected and one unaffected, is greater than this,
            but less than the functional fraction of a pool of mixed monomers (50%).
            If a complex is formed with a homologue of the variant, as is the case for some oligomers,
            then the relative activity may be lower than that seen for a homozygous truncation (see 'Sequestration').
            However, this back-of-the-evelope calculations, omit whether the variant chain is degraded more,
            less likely to form a complex and marginally active, which would nudge the relative activity more towards 50%.
        </p>

        <h4>Deregulation via post-translation site</h4>
        <p><i>Hypothesis:</i> loss of a post-translation site
            <br/><i>Details:</i>Phosphorylation and other modifications are used to control the conformation of protein
            (e.g. hRas), which controls their activity, or are used to target the protein for degradation.
            <br/><i>gnomAD:</i> Different post-translation sites have different strengths/effects, so
            the presence of variants within the gnomAD control dataset
            affecting other predicted post-translation sites may not invalidate this hypothesis,
            however, mutations adjacent to the one in question do.
        </p>



        <h4>Domain destabilisation</h4>
        <p><i>Hypothesis:</i> the mutation destabilises a regulatory domain, but not the whole protein
            <br/><i>Details:</i>As with destabilising mutations,
            variants that expose hydrophobic residues result in higher aggregation and degradation.
            A limited destabilisation may abrogate the activity: if it is via inter-domain binding, then it would
            be no different than the weaker interface scenario described above.
            If the domain is at the C-terminus, then truncations that do not affect the preceeding domains
            (see 'Interdomain truncations') would have a similar effect albeit affected by missense mRNA decay.
            <br/><i>gnomAD:</i>One would not expect severe mutations in the affected domain within the gnomAD control dataset.
        </p>

        <h4>Altered catalysis</h4>
    <p><i>Hypothesis:</i> a mutation alters the specificity of the protein
            <br/><i>Details:</i> While possible, this scenario is a much less likely outcome of active site mutations than a loss of activity.
        It is presented here for completeness.
        </p>

        <h4>Mislocalisation</h4>
        <p><i>Hypothesis:</i> loss of localisation signal
            <br/><i>Details:</i>A mutation in the localisation signal may result in loss of function or gain of function
            depending on whether the migration was required for its activity or repression.
            <br/><i>gnomAD:</i>In most cases it is not a structural effect, but a motif disruption so
            ∆∆G is not a valid metric to assess gnomAD variants in a signal.
        </p>

</%block>

<%block name='modals'>
</%block>
<%block name="script">
    <script type="text/javascript">
    </script>
</%block>