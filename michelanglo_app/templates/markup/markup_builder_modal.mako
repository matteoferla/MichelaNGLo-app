<div class="modal fade" tabindex="-1" role="dialog" id="markup_modal">
    <br/>
  <div class="modal-dialog modal-xl">
    <div class="modal-content">
        <div class="modal-header">
            <h5 class="modal-title"><i class="far fa-hammer"></i> View builder</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
        <div class="modal-body">
            <div class="row">
          <div class="col-12 col-md-8">
              <p>This tool allows you to create custom anchor elements that control the protein. See <a href="/docs/markup">documentation</a> for more.</p>
            <%include file="markup_builder_content.mako"/>

          </div>
          <!-- RHS-->
          <div class="col-12 col-md-4" id="modal_viewport_box">
          </div>
      </div>
    </div>
        </div>
  </div>
</div>

<%include file="markup_builder_select_modal.mako"/>