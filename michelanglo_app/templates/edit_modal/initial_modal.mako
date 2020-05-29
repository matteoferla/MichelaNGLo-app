<div class="modal fade" tabindex="-1" role="dialog" id="initial_modal">
    <br/>
  <div class="modal-dialog modal-xl">
    <div class="modal-content">
        <div class="modal-header">
            <h5 class="modal-title"><i class="far fa-hammer"></i> View builder for loading</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
        <div class="modal-body">
            <div class="alert alert-danger" role="alert" id="warnAboutLoadfun">
              This page has a custom load function, which will be lost with this option!
                <b>Are you really sure you want to continue?</b>
                If unsure, please cancel this window!
            </div>
            <div class="alert alert-warning" role="alert" id="warnAboutRevisions">
              No revisions for this are kept. Any edits cannot be rolled back.
            </div>
            <div class="row">
          <div class="col-12 col-md-8">
              <p>This tool allows you to alter the initial view of the protein that is seen once it is loaded.
                  See <a href="/docs/markup">documentation</a> for more.</p>
            <div id="markup_formAlt"><!--#markup_form will be place here.--></div>

          </div>
          <!-- RHS-->
          <div class="col-12 col-md-4" id="modal_viewport_boxAlt">
          </div>
      </div>
    </div>
        </div>
  </div>
</div>