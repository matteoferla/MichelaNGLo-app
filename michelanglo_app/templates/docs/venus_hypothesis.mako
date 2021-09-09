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
            To pinpoint what it could be in order to direct further studies a variety of factors need to be considered.
            Several of these hypothesis could be combined or manifest at different severity. This is not meant to
            be an exhaustive list, but simply an aid for thought.
            <br/>
            gnomAD is very resource for untangling the effect. However, the sampling in <b>gnomAD is not exhaustive</b> (16k samples for the v3 control set). A heterozygous variant more frequent
            than 5e-5 may be found homozygously in the population, but has not been sampled yet.
            The square of the frequency gives a ballpark figure of how many one would expect to find homozygously
            (erroneously assuming homogeneity in the human population).
        </p>

        <h4>Truncation</h4>
        <p><i>Hypothesis:</i> truncation (frameshift and nonsense) of all domains, simply results in less protein.<br/>
            <i>Details:</i>
        If heterozygous, in a simple system there should be 50% less functional protein.
        If homozygous, there should be no functional protein.
        The heterozygous pathogenic case is referred to <b>haploinsufficiency</b>. If a heterozygous truncation is tolerated
            it is referred to <b>dosage balanced</b>.
            <br/><i>gnomAD:</i>
        in gnomAD controls, one would expect no similar case, bar possibly for truncations at the very end of the C-terminal.
        <br/>
            Venus does not do predictions on truncation, but a silent mutation will provide with domain information.
        </p>

        <h4>Interdomain truncation</h4>
        <p><i>Hypothesis:</i> truncation of regulatory domains, resulting in misregulation.<br/>

            <i>Details:</i>
        Whereas it is true that nonsense-mediated mRNA decay will decrease the level of the transcribed protein of that allele,
            it is not complete, therefore if the remnant is stable, some 20%-30% of it may be made,
            which may be sufficient to cause an effect.
        </p>

        <h4>Destabilisation</h4>
        <p><i>Hypothesis:</i> The protein is destabilised and less active
            <br/><i>Details:</i>
        This is the classic case of loss of function.
            The protein may aggregate and/or more easily targeted for degradation.
            In the most simple/severe case it is no different from a truncation.
            However, the variant may be less functional and not fully non-functional, so a gradient of severity may be present.
            The case where a domain is destabilised and less active, but the rest of the protein is functional is a more complicated situation.
            <br/><i>gnomAD:</i> To be a valid hypothesis one would not expect there to be
            any truncations at a similar zygosity in the gnomAD control set.<br/>
            If the variant is part of a cohort, the absence of truncations in the cohort but not in gnomAD, would indicate
            other effects are at play (e.g. sequestration etc.). If there are no truncation is either and the cohort is large,
            it could be that the mutation is so pathogenic that it is <b>embryonically lethal</b> and therefore not detected (<a
                    href="https://en.wikipedia.org/wiki/Survivorship_bias" target="_blank">survivorship bias</a>)
        </p>

        <h4>Weaker interface</h4>
        <p><i>Hypothesis:</i> The protein is less able to bind a partner protein
            <br/><i>Details:</i>
        If the partner protein is kept in check by the protein, the disruption will deregulate the former, potentially manifesting
            in a dominant manner.
            A variant of this is when a regulatory domain is part of the same protein (cf. 'Domain destabilisation').
            <br/><i>gnomAD:</i> To be valid, one would not expect similarly severe
            gnomAD variants at a similar zygousity on the surface in question.
        </p>


                <h4>Inactivatable</h4>
        <p><i>Hypothesis:</i> The protein loses its catalytic activity or is unable to switch conformation
            <br/><i>Details:</i>
        In the simplest case it is the same as a truncation or simple destabilisation.
            However, it may still bind to another protein, effectively sequestering it (see sequestration).
        </p>

        <h4>Sequestration</h4>
        <p><i>Hypothesis: The protein inactive but still binds a partner protein decreasing functional concentration of the latter</i>
            <br/><i>Details:</i>This scenario may present a worse phenotypic consequence than a truncation or severe destabilisation.
            However, to be valid it must form a complex with another protein that is intolerant to decreased protein levels.
            For example, in RPB1 (POLR2A-encoded) missense variants that abrogate activity are worse than nonsense variants
            potentially due to RPABC3 (POLR2H) sequestration.
        </p>

        <h4>Non-functional oligomer</h4>
        <p><i>Hypothesis: A single variant chain makes the complex non functional to some degree</i>
            <br/><i>Details:</i>The back-of-the-evelope maths for the number of complex without no variant chain
            is <code> 0.5^n</code>, where n is the number of chains in an oligomer. This is value higher than for
            a homozygous truncation (>0), unless the protein forms a hetero-olgomer with a homologue (see sequestration).
        </p>

        <h4>Deregulation via post-translation site</h4>
        <p><i>Hypothesis: loss of a post-translation site</i>
            <br/><i>Details:</i>Phosphorylation and other modifications are used to control the conformation of protein
            (e.g. hRas), which controls their activity, or are used to target the protein for degradation.
            <br/><i>gnomAD:</i> Different post-translation sites have different strengths/effects, so
            gnomAD variants affecting other predicted post-translation sites does not invalidate this hypothesis,
            however, mutations adjacent to the one in question do.
        </p>



        <h4>Domain destabilisation</h4>
        <p><i>Hypothesis: the mutation destabilises a regulatory domain, but not the whole protein</i>
            <br/><i>Details:</i>Exposed hydrophobic residues does result in higher aggregation and degradation,
            but a limited destabilisation may abrogate the activity (if it is via inter-domain binding, then it would
            be no different than the weaker interface scenario already discussed).
            If the domain is at the C-terminus, then truncations that do not affect the preceeding domains
            (cf. 'interdomain truncation' above) would have a similar effect albeit affected by missense mRNA decay.
            <br/><i>gnomAD:</i>One would not expect severe mutations in the domain.
        </p>

        <h4>Altered catalysis</h4>
        <p><i>Hypothesis: a mutation alters the specificity of the protein</i>
            <br/><i>Details:</i>albeit it possible, most active site mutations are likely to cause a loss of activity,
            not alter its specificity. It is presented here for completeness.
        </p>

        <h4>Mislocalisation</h4>
        <p><i>Hypothesis: loss of localisation signal</i>
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