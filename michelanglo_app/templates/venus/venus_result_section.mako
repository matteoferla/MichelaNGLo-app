### This section is filled by JS.
<div class="container-fluid" id="results" style="display: none;">
    <div class="row">
                <!-- Main menu -->
                <div class="offset-3 col-6 mb-4 py-4">
                    <div class="card shadow-sm bg-light">
                        <div class="card-body  text-center">
                            <div class="btn-group" role="group" aria-label="Basic example">
                              <button type="button" class="btn btn-outline-warning" id="new_analysis">
                                  <i class="far fa-undo  fa-lg"></i> Analyse another
                              </button>
                                <button class="btn btn-outline-secondary" type="button" id="feedback-btn" data-toggle="modal" data-target="#modal_feedback">
                                    <i class="far fa-star"></i> Feedback
                                </button>
                                <button class="btn btn-outline-primary" type="button" id="report-btn" data-toggle="modal" data-target="#report">
                                    <i class="far fa-clipboard-list fa-lg"></i> Create a sharable page (Michelaɴɢʟo)
                                </button>
                            </div>
                            <hr>
                            <h3 id="result_title"></h3>
                        </div>
                    </div>
                </div>
    </div>
    <div class="row">
                ######### main results LHS
                <div class="col-6 mb-4 pl-4">
                    ##### first block: Feature
                    <div class="card mb-4 shadow-sm">
                        <div class="card-header"><h5 class="card-title">
                            <i class="far fa-dna"></i> Features
                        </h5><h6 class="card-subtitle mb-2 text-muted">
                            (Click on a feature to visualise it on the structure)
                        </h6></div>

                        ###################### arrow ###################################


                      <div class="card-body">
                        <div class="arrow-right"></div><div class="arrow-right2"></div>

                          ###################### end of arrow ###################################

                        <div id="fv"></div>

                          <div>
                              <button class="btn btn-outline-secondary bindersCollapse collapse show" data-toggle="collapse" data-target=".bindersCollapse"><i class="far fa-eye"></i> Show PDB structure details</button>
                              <button class="btn btn-outline-secondary bindersCollapse collapse" data-toggle="collapse" data-target=".bindersCollapse"><i class="far fa-eye-slash"></i> Hide PDB structure details</button>
                          </div>
                          <div id="matches_collapse" class="col-12 collapse bindersCollapse">
                            <p>Proteins can be crystallised with ligands or binding partners and it is often beneficial to choose a specific one.</p>
                            <div id="partner_table"></div>
                        </div>
                      </div>
                    </div>
                    ##### secodn block: results
                    <div class="card shadow-sm">
                        <div class="card-header">
                            <h5 class="card-title">
                                <i class="far fa-dna"></i> Mutation
                            </h5>
                            <h6 class="card-subtitle mb-2 text-muted">
                                Predicted effects
                            </h6>
                        </div>

                        ###################### lines ###################################

                      <div class="card-body">
                          <div class="arrow-right"></div><div class="arrow-right2">
                          </div>
                      <ul class="list-group list-group-flush" id="results_list">
                      </ul>
                      </div>
                      </div>
                </div>
                ######### structure
                <div class="col-6 mb-4 pr-4">
                    ###### Viewport
                    <!-- style="width:47vw; position:fixed; top:7rem; bottom: 24px; right: 24px;"-->
                    <div class="card mb-4 shadow-sm">
                        <div class="card-header"><h5 class="card-title">
                            <i class="far fa-cubes"></i> Structure
                        </h5></div>
                      <div class="card-body">
                        <div id="viewport" style="width:100%; height: 0; padding-bottom: 70%;">
                        </div>
                      </div>
                    </div>
                </div>
    </div>



    <div class="row">
            </div>
</div>