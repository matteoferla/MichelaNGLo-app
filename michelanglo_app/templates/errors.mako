<%inherit file="layout_components/layout_w_card.mako"/>

<%block name="buttons">
            <%include file="layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>
<%block name="title">
            &mdash; Admin console (error logs)
</%block>
<%block name="subtitle">
            Restricted access.
</%block>


<%block name="main">
<%def name="traceback2li(traceback, cls_label)">
    <%
    ## traceback: types.TracebackType = error.__traceback__
    frame: types.FrameType = traceback.tb_frame
    def get_frames(frame):
        if frame.f_back:
            return [frame, *get_frames(frame.f_back)]
        return [frame]
    frames = get_frames(frame)
    collapsed = not any(['michelan' in frame.f_code.co_filename for frame in frames])
    %>
    ### <li class="list-group-item"><b>Line no</b> ${traceback.tb_lineno}</li>
    %for level, frame in enumerate(frames):
        <button class="${cls_label} ${'collapse' if collapsed else ''}
                    traceback
                     list-group-item list-group-item-action
                     list-group-item-${"success" if 'michelan' in frame.f_code.co_filename else "light"}"
            data-line="${frame.f_lineno}" data-filename="${frame.f_code.co_filename}"
        >
            <b>Method/function #${level}</b> ${frame.f_code.co_name} from ${frame.f_code.co_filename} — line ${frame.f_lineno}
        </button>
    %endfor

</%def>
% if user and user.role == 'admin':
    <%
    errors = request.registry.settings['caught_errors']
    %>
    <div id="carouselErrors" class="carousel slide" data-ride="carousel" data-interval="false">
        <ol class="carousel-indicators">
            <li data-target="#carouselErrors" data-slide-to="0" class="active"></li>
            %for i in range(1, 1+len(errors)):
                <li data-target="#carouselErrors" data-slide-to="${i}"></li>
            %endfor
        </ol>
        <div class="carousel-inner">
            %for i, error_data in enumerate(reversed(errors)):
                <%
                import types
                from typing import List
                import datetime as dt
                error: Exception = error_data['error']
                traceback: types.TracebackType = error.__traceback__
                frame: types.FrameType = traceback.tb_frame
                username: str= error_data['username']
                time: dt.datetime = error_data['time']
                routename: str = error_data['routename']
                # ## get previous errrors
                previous_tracebacks: List[Exception] = []
                previous_traceback = traceback
                while previous_traceback is not None:
                    previous_tracebacks.append(previous_traceback)
                    previous_traceback = previous_traceback.tb_next
                %>
                <div class="carousel-item ${'active' if not i else ''}">
                    <div class="row">
                        <div class="col-8 offset-2">
                            <h2>Error Nº${i} from last</h2>
                            <ul class="list-group  list-group-flush">
                                <li class="list-group-item"><b>Type</b> ${error.__class__.__name__}</li>
                                <li class="list-group-item"><b>Message</b> <pre><code>${error}</code></pre></li>
                                <li class="list-group-item"><b>User</b> ${username}</li>
                                <li class="list-group-item"><b>Time</b> ${time}</li>
                                <li class="list-group-item"><b>Page</b> ${routename}</li>
                                %for ptb_i, previous_traceback in enumerate(previous_tracebacks):
                                    <button class="list-group-item list-group-item-action"
                                        data-toggle="collapse" data-target=".tb${i}-${ptb_i}"
                                    >Traceback step #${ptb_i}
                                     <i class="fas fa-angle-up collapse tb${i}-${ptb_i} ${'show' if not collapsed else ''}"></i>
                                     <i class="fas fa-angle-down collapse tb${i}-${ptb_i} ${'show' if collapsed else ''}"></i>
                                    </button>

                                    ${traceback2li(previous_traceback, f'tb{i}-{ptb_i}')}
                                %endfor
                            </ul>
                            <h3>Global variables</h3>
                            <ul class="list-group  list-group-flush">
                                %for k, v in frame.f_globals.items():
                                    <li class="list-group-item"><b>${k}</b>${v}</li>
                                %endfor
                            </ul>
                            <h3>Local variables</h3>
                            <ul class="list-group  list-group-flush">
                                %for k, v in frame.f_locals.items():
                                    <li class="list-group-item"><b>${k}</b>${v}</li>
                                %endfor
                            </ul>
                        </div>
                    </div>

                </div>
            %endfor
        </div>
        <button class="carousel-control-prev" type="button" data-target="#carouselErrors" data-slide="prev">
            <span class="carousel-control-prev-icon" aria-hidden="true"></span>
            <span class="sr-only">Previous</span>
        </button>
        <button class="carousel-control-next" type="button" data-target="#carouselErrors" data-slide="next">
            <span class="carousel-control-next-icon" aria-hidden="true"></span>
            <span class="sr-only">Next</span>
        </button>
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

    <div class="modal" tabindex="-1" role="dialog" id="codeblock">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Code block</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <pre><code class="language-python"></code></pre>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" id="mod-save">Save changes</button>
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>
</%block>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.4.0/styles/dark.min.css" integrity="sha512-bfLTSZK4qMP/TWeS1XJAR/VDX0Uhe84nN5YmpKk5x8lMkV0D+LwbuxaJMYTPIV13FzEv4CUOhHoc+xZBDgG9QA==" crossorigin="anonymous" referrerpolicy="no-referrer" />
<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.4.0/highlight.min.js" integrity="sha512-IaaKO80nPNs5j+VLxd42eK/7sYuXQmr+fyywCNA0e+C6gtQnuCXNtORe9xR4LqGPz5U9VpH+ff41wKs/ZmC3iA==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.4.0/languages/python.min.js" integrity="sha512-efcjzRpCxyR9hzqNDmYMy202NuRdmiGm80QQg4o6Dh3DdU+fbnC6BKGuJrRMbLLYm70+lR55mkCMiZETYHKGVw==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/highlightjs-line-numbers.js/2.8.0/highlightjs-line-numbers.min.js"></script>
<%block name="script">
    % if user and user.role == 'admin':
        <script type="text/javascript">
            //<%text>
                  $('.traceback').click(event => {
                      const traceback = $(event.target);
                      $.get('/get', {'item': 'codeblock',
                                      'filename': traceback.data('filename')})
                                       .then(codebock => {$('#codeblock code').text(codebock);
                                           $('#codeblock').modal('show');
                                            hljs.highlightElement($('code')[0]);
                                            hljs.lineNumbersBlock($('code')[0]);
                       });
                  });


            //</%text>
        </script>
    %endif

</%block>
