<div class="modal-content"  id="password-content" >
  <div class="modal-header">
    <h5 class="modal-title">Password reset</h5>
    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
      <span aria-hidden="true">&times;</span>
    </button>
  </div>
  <div class="modal-body">
      <div class="row">
          <div class="col-12">
              <div class="input-group mb-3">
      <div class="input-group-prepend">
        <span class="input-group-text" id="username-label">Email/username</span>
      </div>
          <span class="input-group-text" id="username-label">${user.name}</span>

    </div>
          </div>
          <div class="col-12">
              <div class="input-group mb-3">
              <div class="input-group-prepend">
                <span class="input-group-text" id="password-label">Old password</span>
              </div>
              <input type="password" class="form-control rounded-right" placeholder="*****" aria-label="Password" aria-describedby="password-label" id="password">
              <div class="invalid-feedback" id="password_error">The password is invalid</div>
            </div>
          </div>
          <div class="col-12">
              <div class="input-group mb-3">
              <div class="input-group-prepend">
                <span class="input-group-text" id="neopassword-label">New password</span>
              </div>
              <input type="password" class="form-control rounded-right" placeholder="*****" aria-label="Password" aria-describedby="neopassword-label" id="neopassword">
              <div class="invalid-feedback" id="neopassword_error">The password is invalid</div>
            </div>
          </div>
          <div class="col-12">
              <div class="input-group mb-3">
              <div class="input-group-prepend">
                <span class="input-group-text" id="eupassword-label">Repeat new password</span>
              </div>
              <input type="password" class="form-control rounded-right" placeholder="*****" aria-label="Password" aria-describedby="eupassword-label" id="eupassword">
              <div class="invalid-feedback" id="eupassword_error">The password does not match</div>
            </div>
          </div>

      </div>

  </div>
  <div class="modal-footer">
      <div class="px-3 mx-3 border-right">
                <button type="button" class="btn btn-outline-warning" id="logout-btn" onclick="doModalAction('logout')">Logout</button>
            </div>

    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
    <button type="button" class="btn btn-primary" id="change_password-btn" onclick="doModalAction('change_password')">Change</button>
  </div>
</div>
