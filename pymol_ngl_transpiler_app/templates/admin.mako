<%inherit file="layout_w_card.mako"/>

<%block name="buttons">
            <%include file="menu_buttons.mako" args='tour=False'/>
</%block>
<%block name="title">
            &mdash; Admin console
</%block>
<%block name="subtitle">
            Restricted access.
</%block>


<%block name="main">
% if user and user.role == 'admin':
    <%
        from pymol_ngl_transpiler_app.models import User
        users = self.context._data['request'].dbsession.query(User).all()
    %>
    <div class="card w-100 m-10">
        <div class="card-header">
                <h3 class="card-title">Admin console</h3>
            </div>
      <div class="card-body">
          <p class="card-text">
              There are ${len(users)} regististered users.
              <ul class="fa-ul">
                %for u in users:
                    <li data-user="${u.name}">
                        <a href="#mod" data-toggle="modal" data-target="#mod" data-user="${u.name}">
                        <span class="fa-li" >
                    %if u.role == 'admin':
                        <i class="far fa-user-crown"></i>
                    %else:
                        <i class="far fa-user"></i>
                    %endif
                    </span> ${u.name} </a></li>
                %endfor
              </ul>
          </p>
      </div>
    </div>
% else:
    <div class="card bg-warning my-3 w-100">
        <div class="card-header"><h5 class="card-title">Restricted</h5></div>
  <div class="card-body">
    <p class="card-text">Please log out and log in as admin. Then referesh the page. If you would like admin access, please email matteo.</p>
  </div>
</div>
% endif
</%block>



<%block name="modals">
    <div class="modal" tabindex="-1" role="dialog" id="mod">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">ERROR</h5>
            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div class="modal-body">
            <p>Error ah!</p>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-primary" id="mod-save">Save changes</button>
            <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
          </div>
        </div>
      </div>
    </div>
</%block>









<%block name="script">
    % if user and user.role == 'admin':
        <script type="text/javascript">
        <%include file="admin.js"/>
        </script>
    %endif

</%block>
