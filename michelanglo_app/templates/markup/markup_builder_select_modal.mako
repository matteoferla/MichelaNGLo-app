<div class="modal" tabindex="-1" role="dialog" id="selection_modal">
    <br/><br/>
  <div class="modal-dialog modal-lg float-left" role="document" style="padding-left: 32px !important;">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Selection</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">

          <h4><span class="text-muted">Option A.</span> Selection language</h4>
          <p><i>For more information on the NGL selection language see <a href="https://nglviewer.org/ngl/api/manual/selection-language.html">NGL manual <i class="far fa-external-link"></i></a></i></p>
        <p>This controls the residues to focus on. The selection uses the NGL selection language. <code>1:A</code> will select residue 1 of chain A, <code>1-20:B</code> the residues 1 to 20 of chain B, <code>*</code> for everything, <code>PLP</code> (or <code>[PLP]123:D</code>) will select the residue named PLP (a ligand).<br/>The logical operators <code>and</code> and <code>or</code> can also be used, e.g. <code>:B or :C</code> will select chains B & C. You can only select residues that exist in the structure, if not it will either show all or erroneously pan off camera.</p>
          <div class="input-group">
          <div class="input-group-prepend">
            <span class="input-group-text" id="sele_string_addon">Selection line</span>
          </div>
            <input type="text" class="form-control" placeholder="for example 1-10:A" id="sele_string" aria-describedby="sele_string_addon">
              <div class="input-group-append">
                <button class="btn btn-outline-info" type="button" onclick="$('#markup_view').val(''); interactive_changer();"; title="Zoom to residue, discarding current orientation." data-toggle="tooltip"><i class="fas fa-crosshairs"></i></button>
                <button class="btn btn-outline-success" type="button" id="sele_string_btn" data-toggle="tooltip" title="Use this selection"><i class="far fa-arrow-right"></i></button>
              </div>
        </div>
        <br/>
          <h4><span class="text-muted">Option B.</span> Build Selection</h4>
          <p>The following is simpler, but much more limited that the previous.</p>

            <div class="input-group mb-3">
              <div class="input-group-prepend">
                <span class="input-group-text" id="sele_resi_addon">Select a residue</span>
              </div>
              <input id="sele_resi" type="number" class="form-control" placeholder="residue number" aria-label="residue" aria-describedby="sele_resi_addon">
              <select class="custom-select" id="sele_chain">
              </select>
              <div class="input-group-append">

                <button class="btn btn-outline-info" type="button" onclick="$('#markup_view').val(''); interactive_changer();"; title="Zoom to residue, discarding current orientation." data-toggle="tooltip"><i class="fas fa-crosshairs"></i></button>
                <button class="btn btn-outline-success" type="button" id="sele_resi_btn" data-toggle="tooltip" title="Use this selection"><i class="far fa-arrow-right"></i></button>
              </div>
            </div>

          <p class="text-center">or</p>

            <div class="input-group mb-3">
              <div class="input-group-prepend">
                <span class="input-group-text" id="sele_range_addon">Select a residue range</span>
              </div>
              <input id="sele_from" type="number" class="form-control" placeholder="residue number" aria-label="residue" aria-describedby="sele_range_addon">
                <span class="input-group-text rounded-0 border-left-0 border-right-0">&ndash;</span>
                <input id="sele_to" type="number" class="form-control" placeholder="residue number" aria-label="residue" aria-describedby="sele_range_addon">
                <select class="custom-select" id="sele_chain2">
              </select>
              <div class="input-group-append">
                <button class="btn btn-outline-info" type="button" onclick="$('#markup_view').val(''); interactive_changer();"; title="Zoom to residue, discarding current orientation." data-toggle="tooltip"><i class="fas fa-crosshairs"></i></button>
                <button class="btn btn-outline-success" type="button" id="sele_range_btn" data-toggle="tooltip" title="Use this selection"><i class="far fa-arrow-right"></i></button>
              </div>
            </div>
          <hr>
          <p>What to show <a href="#selection_modal" onclick="$('#residue').click(); interactive_changer();">residue</a> and not the <a href="#selection_modal" onclick="$('#domain').click(); interactive_changer();">domain</a>, or vice-versa? For the full list close this, and select the appropriate focusing mode (labelled "zoom to"). </p>

      </div>
    </div>
  </div>
</div>