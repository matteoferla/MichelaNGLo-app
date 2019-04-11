<div class="modal-content" id="logout-content">
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

      <div class="px-3 mx-3 border-right">
      <div class="btn-group" role="group">
        <button type="button" class="btn btn-outline-danger" id="change-password-btn" onclick="getModalContent('password')">Change pwd</button>
        <button type="button" class="btn btn-outline-warning" id="logout-btn" onclick="doModalAction('logout')">Logout</button>
      </div>
  </div>

    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
  </div>
</div>
