<div class="modal-content"  id="login-content" >
  <div class="modal-header">
    <h5 class="modal-title">Login</h5>
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
          <input type="text" class="form-control rounded-right" placeholder="Username" aria-label="Username" aria-describedby="username-label" id="username">
          <div class="invalid-feedback" id="username_error">The username is invalid</div>

    </div>
          </div>
          <div class="col-12">
              <div class="input-group mb-3">
              <div class="input-group-prepend">
                <span class="input-group-text" id="password-label">Password</span>
              </div>
              <input type="password" class="form-control rounded-right" placeholder="*****" aria-label="Password" aria-describedby="password-label" id="password">
              <div class="invalid-feedback" id="password_error">The password is invalid</div>
            </div>
          </div>

          <div class="col-12" style="display: none;" data-toggle="tooltip" title="Your email is required only if *you* get in contact regarding an account problem.">
              <div class="input-group mb-3">
              <div class="input-group-prepend">
                <span class="input-group-text" id="email-label">Email</span>
              </div>
              <input type="text" class="form-control rounded-right" placeholder="me@email.com" aria-label="Email" aria-describedby="email-label" id="email">
              <div class="invalid-feedback" id="email_error">The email is invalid</div>
            </div>
          </div>

      </div>

  </div>
  <div class="modal-footer">
    <button type="button" class="btn btn-outline-primary" id="register-switch-btn">Register</button>
    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
    <button type="button" class="btn btn-success" id="login-btn">Login</button>
  </div>
</div>
