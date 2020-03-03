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
                          <p id="results_status" class="px-5">Error.</p>
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

##                           <div>
##                               <button class="btn btn-outline-secondary bindersCollapse collapse show" data-toggle="collapse" data-target=".bindersCollapse"><i class="far fa-eye"></i> Show PDB structure details</button>
##                               <button class="btn btn-outline-secondary bindersCollapse collapse" data-toggle="collapse" data-target=".bindersCollapse"><i class="far fa-eye-slash"></i> Hide PDB structure details</button>
##                           </div>
##                           <div id="matches_collapse" class="col-12 collapse bindersCollapse">
##                             <p>Proteins can be crystallised with ligands or binding partners and it is often beneficial to choose a specific one.</p>
##                             <div id="partner_table"></div>
##                         </div>
                      </div>
                    </div>
                    ##### secodn block: Mutation results
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

                      <div class="card-body p-0">
                          <div class="arrow-right"></div><div class="arrow-right2">
                          </div>
                      <ul class="list-group list-group-flush" id="results_mutalist">
                      </ul>
                      </div>
                      </div>
                </div>
                ######### structure
                <div class="col-6 mb-4 pr-4">
                    ###### Viewport
                    <!-- style="width:47vw; position:fixed; top:7rem; bottom: 24px; right: 24px;"-->
                    <div class="card mb-4 shadow-sm" id="vieport_side">
                        <div class="card-header"><h5 class="card-title">
                            <i class="far fa-cubes"></i> Structure
                        </h5></div>
                      <div class="card-body">
                        <div id="viewport" style="width:100%; height: 0; padding-bottom: 70%;">
                        </div>

                        <div>
                            <hr/>
                            ############ toggle
                            <div class="custom-control custom-switch">
                              <input type="checkbox" class="custom-control-input" id="showMutant">
                              <label class="custom-control-label" for="showMutant">Always show mutant</label>
                            </div>
                            ######################
                            <h3>Structure</h3>
                            <ul id="structureOption"><!--filled dynamically by venus.updateStructure()--></ul>
                            </div>
                      </div>
                    </div>
                </div>
    </div>
    <div class="row">
            </div>
</div>

################# MODALS

<div class="modal fade" id="ddG_extra" tabindex="-1" role="dialog" aria-labelledby="ddG_extra_title" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="ddG_extra_title">More ddG details</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        ERROR
      </div>
    </div>
  </div>
</div>

<div class="modal fade" id="gnomad_extra" tabindex="-1" role="dialog" aria-labelledby="gnomad_extra_title" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="gnomad_extra_title">gnomAD variants</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        ERROR
      </div>
    </div>
  </div>
</div>