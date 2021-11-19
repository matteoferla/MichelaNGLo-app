<div class="modal" tabindex="-1" role="dialog" id="transcriptModal">
    <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
                <i class="far fa-abacus"></i> Translate transcript</h5>
            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div class="modal-body">
              <p>Venus works at the protein level. It does not do operations at the nucleotide level.
                  It works with Uniprot IDs not ENSEMBL ids, therefore these need to be converted.<br/>
                  Venus uses the Uniprot canonical sequences only
                  —protein that differ from the Uniprot canonical protein
                  will be converted to the mutation in the Uniprot canonical protein.
                  The Uniprot canonical protein is in some instances different than the NCBI or, very rarely, the ENSEMBL one.
                  If you have a mutation in a different format or not in humans, visit a conversion site,
                  such <a href="https://mutalyzer.nl/" target="_blank">Mutalyzer <i class="far fa-external-link"></i></a> or
                  <a href="https://www.ensembl.org/Tools/VEP" target="_blank">VEP online <i class="far fa-external-link"></i></a>.
                  <br/>
                  To convert a genes (ENSG), transcripts (ENST) or protein (ENSP) (only one required) to Uniprot use the following:
              </p>
              <div class="row">
                  <div class="col-5 col-md-12">
                   <div class="input-group">
                          <div class="input-group-prepend">
                              <span class="input-group-text">ENSEMBL ID</span>
                          </div>
<input type="text" aria-label="ENST" class="form-control" id="transcript_ensg" placeholder="ENSG">
                          <div class="invalid-feedback" id="transcript_ensg_error">Inalid gene</div>
                          <input type="text" aria-label="ENST" class="form-control" id="transcript_enst" placeholder="ENST">
                          <div class="invalid-feedback" id="transcript_enst_error">Inalid transcript</div>
<input type="text" aria-label="ENST" class="form-control" id="transcript_ensp" placeholder="ENSP">
                          <div class="invalid-feedback" id="transcript_ensp_error">Inalid protein</div>
                      </div>
                  </div>
                   <div class="col-5 col-md-12">
                   <div class="input-group">
                          <div class="input-group-prepend">
                              <span class="input-group-text">AA mutation</span>
                          </div>
                          <input type="text" aria-label="mutation" class="form-control" id="transcript_mutation">
                          <div class="invalid-feedback" id="transcript_mutation_error">Invalid mutation</div>
                      </div>
                  </div>
                  <div class="col-1 col-md-12">
                      <!-- transcriptConvert in venus.js -->
                      <button class="btn btn-success w-100" type="button" id="transcript_convert"><i class="far fa-truck"></i>
                          Convert
                      </button>

                  </div>
              </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
          </div>
        </div>
      </div>
    </div>