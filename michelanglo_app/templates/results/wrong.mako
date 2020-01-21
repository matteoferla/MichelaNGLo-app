<%def name="entry(title, cause, solution)">
<li class="list-group-item">
  <div class="row">
      <div class="col-10">
        <h3>${title|n}</h3>
          <p><b>Cause: </b>
      <span class="text-muted">${cause|n}</span></p>
  <p><b>Solution: </b>
      <span class="text-muted">${solution|n}</span></p>
      </div>
      <div class="col-2">
  <div class="btn-group-vertical float-right">
      <button type="button" class="btn btn-outline-success"><i class="far fa-thumbs-up"></i> <span class="badge badge-secondary">${votes[title]["up"] if title in votes else 0}</span></button>
      <button type="button" class="btn btn-outline-danger"><i class="far fa-thumbs-down"></i> <span class="badge badge-secondary">${votes[title]["down"] if title in votes else 0}</span></button>
    </div>
</div>
  </div>
</li>
</%def>

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
                    ${entry('Oohh buttons','You want to press a button, but don\t want to mess up our reports? <i class="far fa-ufo-beam"></i> ','Press this entry')}
                    ${entry('Wrong protein off-camera', 'One of the options was whether to use a PDB 4-letter code (default) or to include the coordinate data in the page, this was not checked even if the coordinated data was unique.', 'Check the include PDB coordinates.')}
                    ${entry('Slightly-off orientation', 'The PyMol window shape and size and the viewport shape and size differ.', 'Check the PSE file and reorient. If this is still odd and the field of view has been changed to something highly distorting, return to normal values.')}
                    ${entry('My PSE had a disabled object, but not the NGL', 'Disabled objects are removed to save on data to send across the web.', 'Enable it and change chain ID (Michelaɴɢʟo will do it, but you won\'t be told to what), but hide all its representations.')}
                    ${entry('My PSE had a CGO object (e.g. arrow) or a map', 'mesh and map data does not appear to be extractable from PyMOL.', 'Meshes and maps can be added in JS. As it\'s a corner case, please <a href="#" data-toggle="modal" data-target="#chat_modal">contact the admin</a> to get your protein fixed or get JS editing rights.')}
                    ${entry('My huge membrane is not connected', 'NGL stops predicting connects for ligands (HETATMs) if they are too big.', 'The PDB data needs CONECT lines, as it\'s a corner case, please <a href="#" data-toggle="modal" data-target="#chat_modal">contact the admin</a> to get your protein fixed or get JS editing rights.')}
                    ${entry('I had an ensemble','''In a file with multiple states only the first is used, while in a file with multiple objects these are merged into a single object.
                              The former is done to save memory and to not confuse the general user,
                              while the latter is because most often users have different objects that they would like to show with hydrogen bonds between them.''','Please <a href="#" data-toggle="modal" data-target="#chat_modal">contact the admin</a> who can fix this and needs to know if there is interest in ensembles.')}
                    ${entry('My run failed','A myriad cases. But if it worked on a second try, then the server was busy with another request (mutagenesis step is not parallel) or similar.','The admin gets notified of serverside errors.')}
                    ${entry('I need more','A GUI builder is a rather limited for the myriad possible requests','Upload a PyMOL PSE file or <a href="#" data-toggle="modal" data-target="#chat_modal">report to the admin</a>')}
                    ${entry('The series of representations chosen does not match','The representation selector (and prolinks in a text) purposefully does not reset the cartoon when a stick is shown, while the created representation has no memory of past representations','Create a PyMOL image for a more advanced representation or <a href="#" data-toggle="modal" data-target="#chat_modal">contact the admin</a>.')}
                    ${entry('None of the above','A novel scenario','Please <a href="#" data-toggle="modal" data-target="#chat_modal">report to the admin</a> what the problem is.')}
                    </ul>
            </div>
        </div>
    </div>
</div>


### Buttons are activated at the bottom of user_protein.mako