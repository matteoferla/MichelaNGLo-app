<%inherit file="layout_w_card.mako"/>
<%!
import os
        %>
<%block name="buttons">
            <%include file="menu_buttons.mako" args='tour=False'/>
</%block>
<%block name="title">
            &mdash; Admin console
</%block>
<%block name="subtitle">
            Restricted access.
</%block>

<%block name="alert">
<div class="alert alert-info m-5">Password is "protein"</div>

    % if status:
    <div class="alert alert-danger m-5" role="alert" id="alert">
      ${status}
    </div>
% endif
</%block>


<%block name="body">
% if admin:
    <ul>
    %for url in os.listdir('pymol_ngl_transpiler_app/user'):
        <li><a href="${url}">${url}</a></li>
    %endfor
    </ul>
% else:
    <div class="card text-white bg-danger my-3 w-100">
  <div class="card-header">Log-in required</div>
  <div class="card-body">
    <h5 class="card-title">To access admin zone, please provide the password</h5>
    <p class="card-text"><div class="input-group mb-3">
  <div class="input-group-prepend">
    <span class="input-group-text" id="basic-addon1">Password</span>
  </div>
  <input type="password" id='password' class="form-control" placeholder="*#€%£!!" aria-label="Username" aria-describedby="basic-addon1">
      <div class="input-group-append">
    <button class="btn btn-primary" type="button" id="password_send">Button</button>
  </div>
</div></p>
  </div>
</div>
% endif
</%block>


<%block name="script">
    <script type="text/javascript">
        $('#alert').hide(1000);

        function password_ajax() {
            $.post("/admin", {password: $('#password').val()}).done(function (data) {
                location.reload(true);
                /*
                window.data = data;
                $('main').detach();
                $('body').prepend($(data)[39]);
                $('#alert').hide(1000);
                $('#password_send').click(password_ajax);*/
            });
        }

        $('#password_send').click(password_ajax);
    </script>
</%block>
