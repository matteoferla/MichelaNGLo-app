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
                        <button class="btn btn-outline-success" type="button" id="feedback-btn" data-toggle="modal"
                                data-target="#modal_feedback">
                            <i class="far fa-star"></i> Feedback
                        </button>
                        <button class="btn btn-outline-primary" type="button" id="report-btn" data-toggle="modal"
                                data-target="#report">
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

            ##### first block: Structure
            %if mutation_mode == 'main':
            <div class="card mb-4 shadow-sm">
                <div class="card-header"><h5 class="card-title">
                    <i class="far fa-cubes"></i> Structure
                </h5><h6 class="card-subtitle mb-2 text-muted">
                    Override the automatic structure choice
                </h6></div>


                <div class="card-body">
                    ###################### arrow ###################################

                    <div class="arrow-right"></div>
                    <div class="arrow-right2"></div>
                    ###################### end of arrow ###################################

                    <div class="d-flex justify-content-between">
                        <div><i>Current model:</i> <span id="model_id">N/A</span></div>
                        <button type="button" class="btn btn-outline-primary"
                                data-toggle="modal" data-target="#change_modal"
                        ><i class="far fa-upload"></i> Change
                        </button>
                    </div>
                </div>
            </div>
            %endif

            ##### second block: Feature

            <div class="card mb-4 shadow-sm">
                <div class="card-header"><h5 class="card-title">
                    <i class="far fa-dna"></i> Features
                </h5><h6 class="card-subtitle mb-2 text-muted">
                    (Click on a feature to visualise it on the structure)
                </h6></div>

                ###################### arrow ###################################


                <div class="card-body">
                    <div class="arrow-right"></div>
                    <div class="arrow-right2"></div>

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



            #### Links to individual mutations
            %if mutation_mode == 'multi':
            <div class="card mb-4 shadow-sm">
                <div class="card-header"><h5 class="card-title">
                    <i class="far fa-ballot"></i> Mutations
                </h5><h6 class="card-subtitle mb-2 text-muted">
                </h6></div>


                <div class="card-body">
                    ###################### arrow ###################################

                    <div class="arrow-right"></div>
                    <div class="arrow-right2"></div>
                    ###################### end of arrow ###################################

                    <p ></p>
                    <ul class="list-group list-group-flush" id="result_mutation_list">

                    </ul>
                </div>
            </div>
            %endif



            ##### third block: Mutation results

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

                <div class="card-body p-0" id="results_card">
                    <div class="arrow-right"></div>
                    <div class="arrow-right2">
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
                        <div class="row">
                            <div class="col-12 col-lg-6">
                                ############ toggle

                                    <div class="custom-control custom-switch">
                                        <input type="checkbox" class="custom-control-input" id="showMutant">
                                        <label class="custom-control-label" for="showMutant">Always show mutant</label>
                                    </div>
                            </div>
                            <div class="custom-control custom-switch">
                                        <input type="checkbox" class="custom-control-input" id="showLigands">
                                        <label class="custom-control-label" for="showLigands">Always show ligands</label>
                                    </div>
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

<div class="modal fade" id="gnomad_extra" tabindex="-1" role="dialog" aria-labelledby="gnomad_extra_title"
     aria-hidden="true">
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


<div class="modal fade" id="change_modal" tabindex="-1" role="dialog" aria-labelledby="change_title"
     aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="change_title">Change structure</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p>Change the structure loaded.</p>
                <% valid_extensions = ['pdb']
                %>

                <div class="p-2 border rounded">
                    Note that the structure provided is assumed to be numbered in line with the Uniprot entry
                    and that the protein of interest is chain A.
                    For possible structures, please see <a href="/name">the structure by name page</a>.
                    <div class="input-group mb-3" data-toggle="tooltip"
                         title="Upload your coordinate file in in ${', '.join(valid_extensions)} format (will be converted to pdb).">
                        <div class="input-group-prepend">
                            <span class="input-group-text" id="upload_addon_pdb">Upload file</span>
                        </div>
                        <div class="custom-file">
                            <input type="file" class="custom-file-input" id="upload_pdb"
                                   aria-describedby="upload_addon_pdb"
                                   accept="${', '.join(['.'+str(e) for e in valid_extensions])}">
                            <label class="custom-file-label" for="upload_pdb">Choose PDB file</label>
                        </div>
                    </div>
                    <div class="invalid-feedback" id="error_upload_pdb">Please upload a valid pdb/mmCIF file.</div>


                    <p class="text-center">or</p>

                    <div class="input-group">
                        <div class="input-group-prepend">
                            <span class="input-group-text" id="changeByPage_label">Michelaɴɢʟo page</span>
                        </div>
                        <input type="text" class="form-control" placeholder="URL" aria-label="URL"
                               aria-describedby="changeByPage_label" id="changeByPage">
                        <div class="input-group-append">
                            <button class="btn btn-success" type="button" id="changeByPage_fetch"><i class="far fa-cloud-download"></i></button>
                          </div>
                    </div>
                    <div class="input-group mb-3">
                      <div class="input-group-prepend">
                        <label class="input-group-text" for="changeByPage_selector">Select structure</label>
                      </div>
                      <select class="custom-select" id="changeByPage_selector" disabled>
                        <option name="changeByPage" value="0" selected>Select page first</option>
                      </select>
                    </div>

                </div>
                <p class="mt-3">The energy calculations are done with Pyrosetta.
                    If there is a ligand it may be stripped because no topology is known for it.
                    Consequently, if a Rosetta params file is optionally uploaded, the ligand will be kept.
                    (viz. <a href="https://direvo.mutanalyst.com/params" target="_blank">online parameterisation tool <i class="far fa-external-link"></i></a>)
                    </p>
                <div class="input-group mb-3" data-toggle="tooltip"
                         title="Optionally upload params files for more accurate models.">
                        <div class="input-group-prepend">
                            <span class="input-group-text" id="upload_addon_params">Upload file</span>
                        </div>
                        <div class="custom-file">
                            <input type="file" class="custom-file-input" id="upload_params"
                                   aria-describedby="upload_addon_params"
                                   accept=".params"
                                    multiple>
                            <label class="custom-file-label" for="upload_pdb">Choose Params file</label>
                        </div>
                    </div>
                <button type="button" class="btn btn-primary w-100" id="change_model"><i class="far fa-chart-network"></i> Analyse</button>


            </div>
        </div>
    </div>
</div>

<div class="modal" tabindex="-1" role="dialog" id="createMikeModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Modal title</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        <p>A VENUS page is created anew on request. A Michelanglo page is stored and can be edited.
            To make a page that best suits your needs please consider the following:</p>
          <ul>
              <li>The initial view will be the current view. Please choose the desired model and orientation (<a href="#" data-dismiss="modal">close this modal</a>).</li>
              <li>The feature viewer will be in the modal that appears when the button at the bottom of the description is pressed.</li>
              <li>The blocks will be present in the description. Please rearrange and/or delete to suit (<a href="#" data-dismiss="modal">close this modal</a>).</li>
          </ul>
          <p>The following models can be included (please note about 20% of users visiting a page are on a mobile device and each structure is several megabytes).</p>
          <div id="modelOptions">

          </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
        <button type="button" class="btn btn-primary" id="createMike"><i class="far fa-hand-holding-magic"></i> Create</button>
      </div>
    </div>
  </div>
</div>