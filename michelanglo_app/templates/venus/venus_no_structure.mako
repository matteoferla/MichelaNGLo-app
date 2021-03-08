<div class="modal" tabindex="-1" role="dialog" id="modalStructureless">
  <div class="modal-dialog modal-lg" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h3 class="modal-title"><i class="far fa-empty-set"></i> No structure available</h3>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
          <h4><i class="far fa-tags"></i> Importance</h4>
        <p>The region of protein you are after does not appear to have a structure or model in SwissModel.</p>
          <p>NB. If you know that a new structure has been released in PDB,
              <a href="#chat_modal_btn" data-toggle="modal" data-target="#chat_modal">
    message the admin</a> asking for the PDB data to be reparsed.</p>
          <p>That a region or whole protein is not solved structurally does not imply that your residue is not important.
              In the cases of large protein, it is common practice to clone domains as opposed to the whole protein
              in order to avoid poor protein expression yields —different regions will behave differently, so, again,
              this is not a valid indicator of the importance of a residue.<br/>
              Reasons why a given protein is not solved may include:
          </p>
          <ul class="fa-ul">
              <li><span class="fa-li"><i class="far fa-search"></i></span> The protein was never a target for crystallisation —this is typical of protein for which little is known</li>
              <li><span class="fa-li"><i class="far fa-sparkles"></i></span> Whereas other parts of the protein may be crystallised, the region of interest was not cloned because nothing is known about it</li>
              <li><span class="fa-li"><i class="far fa-flask"></i></span> The protein or region did not crystallise for technical reasons</li>
              <li><span class="fa-li"><i class="far fa-oil-can"></i></span> The protein or region is membrane bound, which is very hard to express and crystallise</li>
              <li><span class="fa-li"><i class="far fa-waveform-path"></i></span> The protein or region is unstructured in an unbound form making it impossible to purify</li>
          </ul>
          <h4><i class="far fa-waveform-path"></i> Disordered</h4>
          In the plot of the features of the protein, there is a trace labelled 'flexibility'.
          If your mutation is in a flexible region, it is worth paying particular attention to post translational modifications,
          which may be listed in the 'Location' box. These are likely to control the levels of the protein.

          <h4><i class="far fa-hammer"></i> Model making</h4>
<p>There are several servers that model protein for you. First, determine the domains by looking in Uniprot or PDB protein feature view, because no modelling program deals with sequences larger than 500 amino acids &mdash;a lazy way of getting the sequence of a region is to click on a range for a domain in Uniprot and changing the numbers in the URL.
    <ul>
          <li><a href="https://zhanglab.ccmb.med.umich.edu/I-TASSER/" target="_blank">I-TASSER <i class="far fa-external-link"></i></a> is tool that consistently wins a model predicting challenge (CASP), but is slow (2-3 days).</li>
          <li><a href="http://www.sbg.bio.ic.ac.uk/phyre2/html/page.cgi?id=index" target="_blank">Phyre2 <i class="far fa-external-link"></i></a> is a lot quicker and also recently they have released a set of over 1,000 computed structures.</li>
          <li><a href="http://evfold.org/evfold-web/evfold.do" target="_blank">EVFold <i class="far fa-external-link"></i></a> is best for totally unknown structures, because it uses covariance to predict what should be close to what. Namely, Normally parts of a structures are threaded (the residues on the template are simply replace) or are computed <i>ab initio</i> using forcefield calculations.</li>
      </ul>
    About the latter, totally unknown genes are wholly imprecise, but the accuracy is increased by using the assumption that residues that change together are likely close.
    Do note that if you are opting for a model, keep track of what the closest template is and what is the root mean square deviation (low single digit numbers is best) and make it clear with other users that you are using a model.
</p>

      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>