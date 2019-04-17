% if error== '401':
    <div class="alert alert-danger" role="alert">
        <h4 class="alert-heading">Error 401</h4>
          You are not signed in.
    </div>
% elif error == '403':
    <div class="alert alert-danger" role="alert">
        <h4 class="alert-heading">Error 403</h4>
          You are not authorised to see this.
    </div>
% elif error == '404':
    <div class="alert alert-danger" role="alert">
        <h4 class="alert-heading">Error 404</h4>
          Part not found
    </div>
% elif error == '418':
    <div class="alert alert-danger" role="alert">
        <h4 class="alert-heading">Error 418</h4>
          I am a teapot!
    </div>
% else:
    <div class="alert alert-danger" role="alert">
        <h4 class="alert-heading">Error 501</h4>
          You really really should not have got this. Would you mind emailing Matteo?
    </div>
% endif
