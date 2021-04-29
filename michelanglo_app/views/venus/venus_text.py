# "export contents"

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
    Disulfides are found in ER, Golgi or secreted protein in Eukaryotes,
    and in the periplasmic or secreted protein in bacteria.
    A potential lack of calculated destabilisation does not indicate that the protein is stable
    outside of the cytoplasm.
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
    ''')
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
                                 'If no structures are available, VENUS uses Swiss-Models. Other database of models exist, such as ModBase, as do modelling servers, such as Phyre or I-Tasser.',
                                 linker('https://swissmodel.expasy.org/'),
                                 'Bienert, S., Waterhouse, A., De Beer, T. A. P., Tauriello, G., Studer, G., Bordoli, L., & Schwede, T. (2017). The SWISS-MODEL Repository-new features and functionality. Nucleic Acids Research, 45(D1), D313–D319.' +
                                 linker('https://doi.org/10.1093/nar/gkw1132')
                                 ),
                     table_rower('PDB model depositors',
                                 'The paper associated with a structure (or the homologue used by Swiss-Model or other tools) generally contains a treasure trove of information',
                                 '&mdash;',
                                 'Context dependent fetched information'
                                 ),
                     table_rower('PhosphoSitePlus',
                                 'The paper associated with a structure (or the homologue used by Swiss-Model or other tools) generally contains a treasure trove of information',
                                 linker('https://www.phosphosite.org/'),
                                 'Guex, N., Peitsch, M. C., & Schwede, T. (2009). Automated comparative protein structure modeling with SWISS-MODEL and Swiss-PdbViewer: A historical perspective. ELECTROPHORESIS, 30(S1), S162–S173.' +
                                 linker('https://doi.org/10.1002/elps.200900140')
                                 ),
                     table_rower('Eukaryotic Linear Motif (ELM)',
                                 'The ELM database contains a myriad know linear motifs in Eukarytes',
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
