<div class="modal fade" tabindex="-1" role="dialog" id="wrong_modal" style="overflow:scroll;">
    <div class="modal-dialog modal-xl" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="far fa-bell"></i> Wrong?</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p>Sometimes something is not quite right with the conversion. Here are some possible solutions:</p>
                <ul class="list-group">

                  <li class="list-group-item">
                      <h3>Wrong protein off-camera</h3>
                      <p><b>Cause: </b>
                          <span class="text-muted">One of the options was whether to use a PDB 4-letter code (default) or to include the coordinate data in the page, this was not checked even if the coordinated data was unique.</span></p>
                      <p><b>Solution: </b>
                          <span class="text-muted">Check the include PDB coordinates.</span></p>
                  </li>

                  <li class="list-group-item">
                      <h3>Slightly-off orientation</h3>
                      <p><b>Cause: </b>
                          <span class="text-muted">The PyMol window shape and size and the viewport shape and size differ.</span></p>
                      <p><b>Solution: </b>
                          <span class="text-muted">Check the PSE file and reorient. If this is still odd and the field of view has been changed to something highly distorting, return to normal values.</span></p>
                  </li>

                  <li class="list-group-item">
                      <h3>My PSE had a disabled object, but not the NGL</h3>
                      <p><b>Cause: </b>
                          <span class="text-muted">Disabled objects are removed to save on data to send across the web.</span></p>
                      <p><b>Solution: </b>
                          <span class="text-muted">Enable it and change chain ID (Michelaɴɢʟo will do it, but you won't be told to what), but hide all its representations.</span></p>
                  </li>


                  <li class="list-group-item">
                      <h3>My PSE had a CGO object (e.g. arrow) or a map</h3>
                      <p><b>Cause: </b>
                          <span class="text-muted">mesh and map data does not appear to be extractable from PyMOL.</span></p>
                      <p><b>Solution: </b>
                          <span class="text-muted">Meshes and maps can be added in JS. As it's a corner case, please <a href="#" data-toggle="modal" data-target="#chat_modal">contact the admin</a> to get your protein fixed or get JS editing rights.</span></p>
                  </li>

                  <li class="list-group-item">
                      <h3>My huge membrane is not connected</h3>
                      <p><b>Cause: </b>
                          <span class="text-muted">NGL stops predicting connects for ligands (HETATMs) if they are too big.</span></p>
                      <p><b>Solution: </b>
                          <span class="text-muted">The PDB data needs CONECT lines, as it's a corner case, please <a href="#" data-toggle="modal" data-target="#chat_modal">contact the admin</a> to get your protein fixed or get JS editing rights.</span></p>
                  </li>

                  <li class="list-group-item">
                      <h3>My run failed</h3>
                      <p><b>Cause: </b>
                          <span class="text-muted">A myriad cases. But if it worked on a second try, then the server was busy with another request (PyMOL steps are not parallel) or similar.</span></p>
                      <p><b>Solution: </b>
                          <span class="text-muted">The admin gets notified of serverside errors.</span></p>
                  </li>

                <li class="list-group-item">
                  <h3>None of the above</h3>
                  <p><span class="text-muted">Please <a href="#" data-toggle="modal" data-target="#chat_modal">report to the admin</a> what the problem is.</span></p>
              </li>
                </ul>
            </div>
        </div>
    </div>
</div>