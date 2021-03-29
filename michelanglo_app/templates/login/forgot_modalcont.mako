<div class="modal-content"  id="forgot-content" >
  <div class="modal-header">
    <h5 class="modal-title">Forgotten password</h5>
    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
      <span aria-hidden="true">&times;</span>
    </button>
  </div>
  <div class="modal-body">
      <p>Enter the email you registered and you will get a new password sent.
          If you did not set an email, email the site admin so they can manually verify before resetting your password
          (a quick process).</p>
      <div class="input-group mb-3">
          <div class="input-group-prepend">
            <span class="input-group-text" id="email_label">email address</span>
          </div>
          <input type="text" class="form-control" placeholder="email@email.com" aria-label="email address" aria-describedby="email_label" id="email">
          <div class="input-group-append" id="button-addon4">
        <button class="btn btn-outline-secondary" type="button" onclick="doModalAction('forgot')">Submit</button>
  </div>
        </div>
      <div class="invalid-feedback" id="email_error">The email is invalid</div>

  </div>
  <div class="modal-footer">
            <div class="px-3 mx-3 border-right">
                <div class="btn-group" role="group">
                    <button type="button" class="btn btn-outline-success" id="register-switch-btn" onclick="getModalContent('login_modal')">Login</button>
                    <button type="button" class="btn btn-outline-primary" id="register-switch-btn" onclick="getModalContent('register_modal')">Register</button>
                </div>
            </div>

    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
  </div>
</div>
