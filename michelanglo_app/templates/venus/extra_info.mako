<%
    # move to Python when done.
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
        '''),
]
%>

% for entry in contents:
    <div class="modal" tabindex="-1" role="dialog" id="${entry['id']}">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title"><i class="far fa-lightbulb-on"></i> ${entry['title']}</h5>
            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div class="modal-body">
              <p>${entry['description']|n}</p>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
          </div>
        </div>
      </div>
    </div>
% endfor