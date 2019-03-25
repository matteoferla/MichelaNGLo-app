<%inherit file="layout_w_card.mako"/>
<%!
import os
from datetime import datetime
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
%if not admin:
    <div class="alert alert-info m-5">Password is "protein"</div>
%endif

% if status:
    <div class="alert alert-danger m-5" role="alert" id="alert">
      ${status}
    </div>
% endif
</%block>


<%block name="body">
% if admin:
    <ul class="list-group">
    %for url in os.listdir('pymol_ngl_transpiler_app/user'):
        %if '.html' in url:
        <li class="list-group-item" id="${url.replace('.html','')}">
            <h4>${url.replace('.html','')}</h4>
            <div class="row">
                <div class="col-5">
                    <p>
                        <div class="btn-group" role="group">
                            <a class="btn btn-primary" href="user-structures/${url}">Go to</a>
                            <button role="button" class="btn btn-danger text-white admin-delete" data-target="${url.replace('.html','')}">Delete</button>
                        </div>
                    </p>
                </div>
                <div class="col-1" title="This file has a separate uneditable JS to prevent XSS" data-toggle="tooltip">
                %if os.path.exists(os.path.join('pymol_ngl_transpiler_app','user',url.replace('.html','.js'))):
                    <i class="fab fa-js-square"></i>
                %endif
                </div>
                <div class="col-6">
                    <p>${datetime.fromtimestamp(os.stat(os.path.join('pymol_ngl_transpiler_app','user',url)).st_mtime).strftime("%A, %B %d, %Y %I:%M:%S")}</p>
                    %if os.path.exists(os.path.join('pymol_ngl_transpiler_app','user',url.replace('.html','.js'))):
                        <p>${int(os.stat(os.path.join('pymol_ngl_transpiler_app','user',url)).st_size)/1e6+int(os.stat(os.path.join('pymol_ngl_transpiler_app','user',url.replace('.html','.js'))).st_size)/1e6} MB</p>
                    %else:
                        <p>${int(os.stat(os.path.join('pymol_ngl_transpiler_app','user',url)).st_size)/1e6} MB</p>
                    %endif
                </div>
            </div>

        </li>
        %endif
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

        $('.admin-delete').click(function () {
            var target = $(this).data('target');
            $.post("/edit_user-page", {'type': 'delete','page': $(this).data('target')})
                    .done(function () {
                        $('#'+target).hide(2000);
                    });
        });


        $('#password_send').click(password_ajax);
    </script>
</%block>
