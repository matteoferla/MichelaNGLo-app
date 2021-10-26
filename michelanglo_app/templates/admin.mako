<%inherit file="layout_components/layout_w_card.mako"/>

<%block name="buttons">
            <%include file="layout_components/vertical_menu_buttons.mako" args='tour=False'/>
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
        icon = {'basic': 'user', 'friend': 'user-tie', 'guest': 'user-secret', 'admin': 'user-crown', 'new': 'user-astronaut', 'hacker': 'user-ninja', 'trashcan': 'dumpster'}

        import logging
        log = logging.getLogger()
        filehandlers = [handler for handler in log.handlers if isinstance(handler, logging.FileHandler)]
        if len(filehandlers):
            log = ''.join(reversed(open(filehandlers[0].baseFilename,'r').readlines()[-500:]))
        else:
            log = 'No logging enabled'

        from michelanglo_app.models import Doi
        shortened = [(d.long, d.short) for d in request.dbsession.query(Doi).all()]

    %>
    <h3>Users</h3>
    <p class="card-text">There are ${len(users)} regististered users.</p>

    <ul class="fa-ul">
            %for u in users:
                <li data-user="${u.name}">
                    <a href="#mod" data-toggle="modal" data-target="#mod" data-user="${u.name}">
                    <span class="fa-li" >
                %if u.role in icon:
                    <i class="far fa-${icon[u.role]}" title="This user has the role: ${u.role}"></i>
                %else:
                    <i class="far fa-user-ninja" title="This user has a weird role: ${u.role}!?"></i>
                %endif
                </span> ${u.name} </a></li>
            %endfor
        </ul>
    <h3>Redirects</h3>
        <div class="row border rounded w-100 p-2 m-2">
            % for long, short in shortened:
                <div class="col-2"><a class="btn btn-outline-info w-100" href="data/${long}">${short}</a> </div>
            % endfor
        </div>
        <p></p>
    <h3>PSAs</h3>
        <div class="row border rounded w-100 p-2 m-2">
                <div class="col-lg-3">
                <div class="input-group">
                  <div class="input-group-prepend">
                    <span class="input-group-text" id="msg_title_label">Title</span>
                  </div>
                  <input type="text" class="form-control" placeholder="Title" aria-label="title" aria-describedby="msg_title_label" id="msg_title">
                </div>
            </div>
                <div class="col-lg-5">
                <div class="input-group">
                  <div class="input-group-prepend">
                    <span class="input-group-text" id="msg_descr_label">Msg</span>
                  </div>
                  <input type="text" class="form-control" placeholder="Title" aria-label="title" aria-describedby="msg_descr_label" id="msg_descr">
                </div>
            </div>
                <div class="col-lg-2">
                    <div class="btn-group">
                      <button type="button" class="btn  btn-outline-secondary dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                        Add
                      </button>
                      <div class="dropdown-menu">
                      % for bg in ('danger', 'warning', 'info', 'success', 'primary', 'secondary'):
                          <a class="dropdown-item bg-${bg}" onclick="setMsg('bg-${bg}')">As ${bg}</a>
                      % endfor
                        <div class="dropdown-divider"></div>
                        <a class="dropdown-item" onclick="setMsg('')">in white</a>
                      </div>

                      <button type="button" class="btn btn-outline-secondary" onclick="clearMsg()">Clear</button>
                    </div>
                </div>


        </div>

    <h3>Task controls</h3>
        <p>See <code>scheduler.py</code>. Note kill kills all stuck threads, not termininates the app.</p>
        <div class="row border rounded w-100 p-2 m-2">
                % for task in ('kill','monitor','daily', 'spam','unjam','clear_buffer'):
                    <div class="col-2"><a class="btn btn-outline-info" href="set?item=task&task=${task}">${task}</a></div>
                % endfor
        </div>
    <h3>Reset app</h3>
        <p>Reset the app by killing the process, which gets respawned by the michelanglo.service. It is not graceful.
        The secret code is the one in <code>request.registry.settings['michelanglo.secretcode']</code>.
        </p>
        <div class="row border rounded w-100 p-2 m-2">
        <div class="input-group mb-3">
          <input type="text" class="form-control" id="secretcode" placeholder="secret code"
                 aria-label="secret code" aria-describedby="resetter">
          <div class="input-group-append">
            <button class="btn btn-outline-secondary" type="button" id="resetter">Reset</button>
          </div>
        </div>
        </div>
    <h3>Reversed request log</h3>
    <div style="height: 70vh; overflow: scroll;">
        <pre><code>${log}</code></pre>
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
      <div class="modal-dialog modal-lg" role="document">
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
