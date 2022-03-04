# "export contents"
# contents get filled out in the mako extra_info.

read_more = '''The next step would be to read if anything is known about this site.
The <a class="uniprotLink">Uniprot entry</a> may provide some information.'''

phospho = '''Phosphorylation sites perform a variety of tasks.
    {read_more}
    Some are known only from high throughput studies. Venus uses data from
    <a href="https://www.phosphosite.org/homeAction.action" target="_blank">PhosphositePlus</a>
    so a next step could be to see how common these are.
    It may be helpful to also check whether anything is known for paralogues of the protein.
    Also, if your variant is near a phosphorylated residue, but not one, check the "motif" section to see if a
    linear motif is predicted and whether it is likely to be affected (this is inexact, but can help).
    <br/>
    Loss of a post-translational modification could mean there is a loss of regulation. For example:
    <ul><li>
    If your variant is a de novo heterozygous mutation, you are likely looking at a gain of function,
    wherein the phosphorylation was meant to keep the protein in check.
    </li><li>
    If your variant is a compound heterozygous or homozygous, you are likely looking at a loss of function,
    wherein the phosphorylation was meant to activate the protein or allow an interaction with another protein.
    </li>
    </ul>
'''.format(read_more=read_more)

contents = [
dict(id='modalPhosphorylation',
    title='Lost phosphorylation site',
    description=phospho.format(extra='')),

dict(id='modalBuriedPhosphorylation',
    title='Lost buried phosphorylation site',
    description=phospho.format(extra='''Most are on the surface, however, some are buried or partially buried,
        which results in a significant rearrangement of the protein.
        If so, generally this is to activate the protein. A mutation can either abolish or mimic the
        change of the buried phosphorylation. Checking visually the effect may help (press overlay).
        .''')),

dict(id='modalDistortedPhosphorylation',
    title='Lost phosphorylation site that gets distorted',
    description=phospho.format(extra='''The mutation may distort the protein relative wildtype
        based on the high RSMD from the free energy calculations.
        This may simply result in a lost of phosphorylation, but the distorsion
        mimic the result of an activated protein.
        .''')),

dict(id='modalChargedPhosphorylation',
title='Phosphorylation site replaced with negatively charged residue',
description=phospho.format(extra='''The result of phosphorylation is a strong negative charge.
Here the site is replaced with a residue that is already phosphorylated, likely minimicking its effects.''')),

# --------------------------------------------------------------------------------------------------------------

dict(id='modalUbiquitination',
    title='Lost ubiquitination site',
    description='''Ubiquitination sites allow the protein's concentrations to be lowered.
        Venus uses data from
        <a href="https://www.phosphosite.org/homeAction.action" target="_blank">PhosphositePlus</a>
        so a next step could be to see how common these are.
        If this site is indeed common and your variant is a de novo heterozygous mutation,
        it is likely that your protein level are off balance. For example, if your protein is part of a complex
        where another protein is keeping it in balance (e.g. alpha subunit and beta-subunit of
        a G-protein), this would result in spurious 'activation'-like behaviour.
        The <a class="uniprotLink">Uniprot entry</a> may provide some information if this is the case.
    '''),

# --------------------------------------------------------------------------------------------------------------

dict(id='modalDisulfide',
    title='Lost disulfide',
    description='''Disulfides allow the protein to maintain structural cohesion in harsh environments.
    Disulfides are found in ER, Golgi or secreted protein in eukaryotes,
    and in the periplasmic or secreted protein in bacteria.
    A potential lack of calculated destabilisation does not indicate that the protein is stable
    outside of the cytoplasm.
    
    NB. that unfortunately the NGL.js library (used for the protein visualisation)
    does not show disulfides and cross-linked molecules connected if connected via LINK or SSBOND entries,
    only CONECT, which is non-standard. As a result the cross-link is present the calculations by PyRosetta,
    but visually it is not shown.
    '''),

# --------------------------------------------------------------------------------------------------------------

dict(id='modalDestabilisation',
    title='Destabilisation',
    description='''The mutation is predicted to lower the Gibbs free energy of folding
    according to force field calculations.
    A negative value is stabilising, and a value of 1-2 kcal/mol is neutral.
    A hydrogen bond has about 1-2 kcal/mol. For more see
    <a href="/docs/venus_energetics" target="_bank">documentation</a>.
    <br/>
    A destabilised protein is likely to still partially fold, but may have exposed hydrophobic surfaces,
    and as a result is targeted for destruction by proteasomes.
    There is not a universal formula to convert ∆∆G to % degradation.
    These correlate within a protein, but larger domains are more tollerant to do disruption than smaller ones.
    Also, different taxonomic clades have different threshhold of thermostability
    —E. coli protein are more stable than human proteins.
    Export machinery is less tolerant to partially unfolded protein.
    But generally a ∆∆G over +5 kcal/mol is unlikely to be anything but deleterious.
    '''),
dict(id='consurfModal',
     title='ConsurfDB',
     icon='scroll-old',
     description="""Conservation data is taken from 
     <a href="https://consurfdb.tau.ac.il/" target="_blank>ConsurfDB <i class="far fa-external-link"></i></a>.
     ConsurfDB is a site that provides pre-calculated conservation profiles for PDB structures
     as calculated by the tool <code>rates4sites</code>.
     In the case of <span style="font-variant: small-caps;">Swiss-Model</span> structures,
     Venus migrates the residue grades (and the conservation colour) from the template that
     was used for threading.
     <br/>
     Buried residues are expected to be more conserved in light of the fact that a mutation is generally
     structurally deleterious and may require a compensating mutation 
     (i.e. <a href="https://en.wikipedia.org/wiki/Epistasis" target="_blank">epistatis <i class="fab fa-wikipedia-w"></i></a>),
     however, surface mutations may also be conserved if they have a role, such as an interface with another protein.
     <br/>
     At present, there is no conservation data provided for AlphaFold2 models, but will be implemented soon.
     <br/>
     <b>Reference</b> <a href="https://doi.org/10.1002/pro.3779, 2020" target="_blank">
     Adi Ben Chorin, Gal Masrati, Amit Kessel, Aya Narunsky, Josef Sprinzak, Shlomtzion Lahav, Haim Ashkenazy, Nir Ben-Tal
     ConSurf-DB: An accessible repository for the evolutionary conservation patterns of the majority of PDB proteins
     Protein Science, 29:258–267 <i class="far fa-external-link"></i></a>
     <br/>See also <a href="#referenceModal" data-toggle="modal" data-target="#referenceModal">here for all relevant papers and resources</a>
     """),
dict(id='distanceModal',
     title='Residue distance',
     icon='ruler',
     description="""The distance between residues stated herein is the closest distance between any atom
     of the two residues
     in the given structure (before energy minimisation).
     Namely, it does not take into account<ul>
     <li>whether the two residue's sidechains may rotate making them closer
      (for which an MD simulation would be required)</li>
     <li>whether the side chains moved during minimisation (of the wild type or mutant)</li>
     <li>whether the side chain was placed incorrectly by Coot</li>
     </ul>
      Parenthetically, the neighbour for energy minimsation is calculated by PyRosetta 
      from C&beta; to C&beta; (a proxy for
      the baricentre of a residue).
     """),
dict(id='featureModal',
     title='Residue features',
     icon='medal',
     description="""
     This column collates information from a few sources.
     <ul class="list-group list-group-flush">
     <li class="list-group-item">
    <h3>Uniprot</h3>
    <a href="https://www.uniprot.org/uniprot/" target="_blank>Uniprot <i class="far fa-external-link"></i></a>
     is a database of manually curated entries with pieces of information taken from the literature,
    which in turn will have more information on that residues making it a logical next step in the exploration
    of the possible effects of a variant.
    <b>Reference</b> <a href="https://doi.org/10.1093/nar/gkaa1100" target="_blank"> 
    Bateman, A., Martin, M. J., Orchard, S., Magrane, M., Agivetova, R., Ahmad, S., Alpi, E., Bowler-Barnett, E. H., Britto, R., Bursteinas, B., Bye-A-Jee, H., Coetzee, R., Cukura, A., Silva, A. Da, Denny, P., Dogan, T., Ebenezer, T. G., Fan, J., Castro, L. G., … Zhang, J. (2021). UniProt: The universal protein knowledgebase in 2021. Nucleic Acids Research, 49(D1), D480–D489.
    <i class="far fa-external-link"></i></a>
    </li>
    <li class="list-group-item">
    <h3>gnomAD</h3>
     (human substitions only)<br>
    <a href="https://gnomad.broadinstitute.org/" target="_blank>gnomAD <i class="far fa-external-link"></i></a> 
     is a database that collects the variants found in the healthy wild type human population.
     As discussed in <a href="/docs/venus_hypothesis">the hypothesis generation notes</a>
     it is useful to see nearby residues for gnomAD variants as it is likely that they may have 
     a similar effect to the substitution investigated. However, some mutations may be conservative, 
     hence why the ∆∆G is calculated —greater than +2 kcal/mol is destabilising (to that conformation).
     Do note that if a variant is found in one or two individuals
     (as marked with <i class="fad fa-signal-slash"></i>) it should be treated with caution.
     Also note that gnomAD does not cover the entirety of the healthy human population,
     therefore a back-of-the-envelope calculation is in order to say what are the chances of one or more
      individuals with two copies of that allele (homozygous).
     <b>Reference</b> <a href="https://doi.org/10.1038/s41586-020-2308-7 " target="_blank">
     Karczewski, K. J., Francioli, L. C., Tiao, G., Cummings, B. B., Alföldi, J., Wang, Q., Collins, R. L., Laricchia, K. M., Ganna, A., Birnbaum, D. P., Gauthier, L. D., Brand, H., Solomonson, M., Watts, N. A., Rhodes, D., Singer-Berk, M., England, E. M., Seaby, E. G., Kosmicki, J. A., … MacArthur, D. G. (2020). The mutational constraint spectrum quantified from variation in 141,456 humans. Nature, 581(7809), 434–443. <i class="far fa-external-link"></i></a>
    </li>
    <li class="list-group-item">
    <h3>ClinVar</h3>
     (human substitions only)<br>
    <a href="https://www.ncbi.nlm.nih.gov/clinvar/" target="_blank>ClinVar <i class="far fa-external-link"></i></a> 
     collates indentified pathogenic variants.
     <b>Reference</b> <a href="https://doi.org/10.1093/nar/gkz972" target="_blank">
     Landrum, M. J., Chitipiralla, S., Brown, G. R., Chen, C., Gu, B., Hart, J., Hoffman, D., Jang, W., Kaur, K., Liu, C., Lyoshin, V., Maddipatla, Z., Maiti, R., Mitchell, J., O'Leary, N., Riley, G. R., Shi, W., Zhou, G., Schneider, V., Maglott, D., Holmes, J.B., Kattman, B. L. ClinVar: improvements to accessing data. Nucleic Acids Res. 2020;48(D1):D835-D844.
     <i class="far fa-external-link"></i></a>
    </li>
     <li class="list-group-item">
    <h3>PhosphoSitePlus</h3>
     (human substitions only)<br>
     <a href="https://www.phosphosite.org/" target="_blank>PhosphoSitePlus <i class="far fa-external-link"></i></a> 
     is a database collecting post-translational modifications from high throughput screens.
     This is useful as most post-translational modifications have not been investigated and some of which may have a
     strong functional role.
     <b>Reference</b> <a href="https://doi.org/10.1002/elps.200900140" target="_blank">
     Guex, N., Peitsch, M. C., & Schwede, T. (2009). Automated comparative protein structure modeling with SWISS-MODEL and Swiss-PdbViewer: A historical perspective. ELECTROPHORESIS, 30(S1), S162–S173.
     </li>
     </ul>
     <br/>See also <a href="#referenceModal" data-toggle="modal" data-target="#referenceModal">here for all relevant papers and resources</a>
     """),




dict(id='modalPore',
     title='Transmembrane',
     icon='archway',
     description="""
     <p>The mutation is in a transmembrane region as annotated in Uniprot.
     Mutations can have a variety of possible effects.</p>
     <p><b>Note</b> Venus calculates ∆∆G in a aqueous implicit solvent model
     even if the protein is marked as membrane bound, because it is a non-trivial process to set up due many corner cases.
     As a result do treat the difference in Gibbs free energy with caution.
     </p>
     <p>A substitution to a charged residue in the membrane may result 
     in an inability to be embedded —resulting in degradation by the quality control machinery, 
     making it a loss of function variant.</p>
     <p>In some protein, the transmembrane region alters conformation upon a conformational shift in an aqueous domains.
     In some protein transmembrane region features a pore or channel allowing ion or small molecule passage.
     This can be spotted by looking at the surface 
     (<a hfref='#' onclick="NGL.specialOps.showSurface('viewport', '*', undefined, 0.4, true)">show</span>).
     In many cases, the channel is closed but opens upon a conformational shift. Hydrophobic residues that form a barrier
     are normally referred to as a "gate", while charged residues controlling specificity as a "filter".
     the analysis of a substitution affecting a conformational change requires at least two or more conformations
     representing the open and closed states. Such a variant may favour one over the other —closed &rarr; LoF, open &rarr; GoF.
     Do note the effect may be partial and a full loss of gating or filter may be lethal for the cell —akin to an ionophore.
     """),
]

# ===== Reference modal => special =====================================================================================

def linker(url):
    return f'<a href="{url}" target="_blank">{url} <i class="far fa-external-link-square"></i></a>'

def table_rower(*parts):
    joined = ' '.join([f'<td>{p}</td>' for p in parts])
    return f'<tr>{joined}</tr>'

ref_inner = ''.join([table_rower('VENUS',
                                 'This web app',
                                 linker('http://venus.cmd.ox.ac.uk/'),
                                 '<i>Manuscript in preparation</i>'
                                 ),
                     table_rower('Michelaɴɢʟo',
                                 'Results can be exported to Michelaɴɢʟo, edited and shared',
                                 linker('http://michelanglo.sgc.ox.ac.uk/'),
                                 'Ferla, M. P., Pagnamenta, A. T., Damerell, D., Taylor, J. C., & Marsden, B. D. (2020). MichelaNglo: Sculpting protein views on web pages without coding. Bioinformatics, 36(10), 3268–3270.' +
                                 linker('https://doi.org/10.1093/bioinformatics/btaa104')
                                 ),
                     table_rower('Uniprot',
                                 'Uniprot collates feature information. Within the entry for the protein are many useful pieces of information, including references.',
                                 linker('https://www.uniprot.org/uniprot/'),
                                 'Bateman, A., Martin, M. J., Orchard, S., Magrane, M., Agivetova, R., Ahmad, S., Alpi, E., Bowler-Barnett, E. H., Britto, R., Bursteinas, B., Bye-A-Jee, H., Coetzee, R., Cukura, A., Silva, A. Da, Denny, P., Dogan, T., Ebenezer, T. G., Fan, J., Castro, L. G., … Zhang, J. (2021). UniProt: The universal protein knowledgebase in 2021. Nucleic Acids Research, 49(D1), D480–D489.' +
                                 linker('https://doi.org/10.1093/nar/gkaa1100')
                                 ),
                     table_rower('gnomAD',
                                 'gnomAD provides information of variants in the human population. Within the site, the data can be filtered into controls only and allele frequency and zygosity can be found.',
                                 linker('https://gnomad.broadinstitute.org/'),
                                 'Karczewski, K. J., Francioli, L. C., Tiao, G., Cummings, B. B., Alföldi, J., Wang, Q., Collins, R. L., Laricchia, K. M., Ganna, A., Birnbaum, D. P., Gauthier, L. D., Brand, H., Solomonson, M., Watts, N. A., Rhodes, D., Singer-Berk, M., England, E. M., Seaby, E. G., Kosmicki, J. A., … MacArthur, D. G. (2020). The mutational constraint spectrum quantified from variation in 141,456 humans. Nature, 581(7809), 434–443.' +
                                 linker('https://doi.org/10.1038/s41586-020-2308-7')
                                 ),
                     table_rower('PDB',
                                 'VENUS automatically chooses the model for the user. But this may not be the most interesting',
                                 linker('https://www.rcsb.org/'),
                                 'Burley, S. K., Bhikadiya, C., Bi, C., Bittrich, S., Chen, L., Crichlow, G. V., Christie, C. H., Dalenberg, K., Di Costanzo, L., Duarte, J. M., Dutta, S., Feng, Z., Ganesan, S., Goodsell, D. S., Ghosh, S., Green, R. K., Guranovic, V., Guzenko, D., Hudson, B. P., … Zhuravleva, M. (2021). RCSB Protein Data Bank: Powerful new tools for exploring 3D structures of biological macromolecules for basic and applied research and education in fundamental biology, biomedicine, biotechnology, bioengineering and energy sciences. Nucleic Acids Research, 49(1), D437–D451.' +
                                 linker('https://doi.org/10.1093/nar/gkaa1038')
                                 ),
                     table_rower('Swiss-Model',
                                 'If no structures are available, VENUS uses Swiss-Models as these are threaded and may contain oligomers. Other database of models exist, such as ModBase, as do modelling servers, such as Phyre or I-Tasser.',
                                 linker('https://swissmodel.expasy.org/'),
                                 'Bienert, S., Waterhouse, A., De Beer, T. A. P., Tauriello, G., Studer, G., Bordoli, L., & Schwede, T. (2017). The SWISS-MODEL Repository-new features and functionality. Nucleic Acids Research, 45(D1), D313–D319.' +
                                 linker('https://doi.org/10.1093/nar/gkw1132')
                                 ),
                     table_rower('AlphaFold2',
                                 'If no suitable model can be found Venus uses the EBI-AlphaFold2 models.',
                                 linker('https://swissmodel.expasy.org/'),
                                 'Jumper, J et al. Highly accurate protein structure prediction with AlphaFold. Nature (2021).' +
                                 linker('https://www.nature.com/articles/s41586-021-03819-2')
                                 ),
                     table_rower('PDB model depositors',
                                 'The paper associated with a structure (or the homologue used by Swiss-Model or other tools) generally contains a treasure trove of information',
                                 '&mdash;',
                                 'Context dependent fetched information'
                                 ),
                     table_rower('PhosphoSitePlus',
                                 'PSP is a database collecting post-translational modifications from high throughput screens.',
                                 linker('https://www.phosphosite.org/'),
                                 'Guex, N., Peitsch, M. C., & Schwede, T. (2009). Automated comparative protein structure modeling with SWISS-MODEL and Swiss-PdbViewer: A historical perspective. ELECTROPHORESIS, 30(S1), S162–S173.' +
                                 linker('https://doi.org/10.1002/elps.200900140')
                                 ),
                     table_rower('Eukaryotic Linear Motif (ELM)',
                                 'The ELM database contains a myriad know linear motifs found in eukarytes',
                                 linker('https://elm.eu.org/'),
                                 'Kumar, M., Gouw, M., Michael, S., Sámano-Sánchez, H., Pancsa, R., Glavina, J., Diakogianni, A., Valverde, J. A., Bukirova, D., Signalyševa, J., Palopoli, N., Davey, N. E., Chemes, L. B., & Gibson, T. J. (2020). ELM-the eukaryotic linear motif resource in 2020. Nucleic Acids Research, 48(D1), D296–D306.' +
                                 linker('https://doi.org/10.1093/nar/gkz1030')
                                 ),
                     table_rower('ConSurf‐DB',
                                 'The ConSurf‐DB was used to get conservation profiles',
                                 linker('https://consurfdb.tau.ac.il/'),
                                 'Ben Chorin A, Masrati G, Kessel A, Narunsky A, Sprinzak J, Lahav S, Ashkenazy H, Ben-Tal N. ConSurf-DB: An accessible repository for the evolutionary conservation patterns of the majority of PDB proteins. Protein Sci. 2020 Jan;29(1):258-267.' +
                                 linker('https://doi.org/10.1002/pro.3779')
                                 )])



ref_description = f'''VENUS draws from a variety of sources without which this tool would not be possible.
If your mutation has a suggested effect based on one of these resources do check them out directly and remember to cite them!
(NB. We are not affiliate with the external resources)
<table class="table">
  <thead>
    <tr>
      <th scope="col">Resource name</th>
      <th scope="col">Role</th>
      <th scope="col">URL</th>
      <th scope="col">Reference</th>
    </tr>
  </thead>
  <tbody>
    {ref_inner}
  </tbody>
</table>
'''

contents.append(dict(id='referenceModal',
                title='References',
                description=ref_description,
                icon='books',
                xl=True))
