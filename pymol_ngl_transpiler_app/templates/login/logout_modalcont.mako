<div class="modal-content" id="logout-content" style="display: none;">
  <div class="modal-header">
    <h5 class="modal-title">User controls</h5>
    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
      <span aria-hidden="true">&times;</span>
    </button>
  </div>
  <div class="modal-body">
      <div class="row">
          <div class="col-12">
              <p>You are currently logged in as <span id="username-name"></span> (rank: <span id="username-rank"></span>).</p>
          </div>
      </div>

  #### pages
   <%include file="pages.mako"/>

  </div>
  <div class="modal-footer">
    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
    <button type="button" class="btn btn-success" id="logout-btn">Logout</button>
  </div>
</div>
