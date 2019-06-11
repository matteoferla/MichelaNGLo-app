
<div class="modal fade" tabindex="-1" role="dialog" id="edit_modal">
    <div class="modal-dialog modal-xl" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="far fa-pen-alt"></i> Edit</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <div class="input-group mb-3" data-toggle="tooltip" title="This is the title of the page and will appear both as the title of the browser tab and as the header at the top of the page.">
                    <div class="input-group-prepend">
                        <span class="input-group-text" id="title-addon1">Title</span>
                    </div>
                    <input type="text" class="form-control" value="${title}" aria-label="Title" aria-describedby="title-addon1" id="edit_title">
                </div>

                <div class="row">
                    <div class="offset-1 col-11">
                        <div class="btn-group" role="group" aria-label="formatting" id="formatting">
                          <button type="button" class="btn btn-outline-secondary" id="formatting_h3"><i class="far fa-h3"></i></button>
                          <button type="button" class="btn btn-outline-secondary" id="formatting_bold"><i class="far fa-bold"></i></button>
                          <button type="button" class="btn btn-outline-secondary" id="formatting_italic"><i class="far fa-italic"></i></button>
                          <button type="button" class="btn btn-outline-secondary" id="formatting_link"><i class="far fa-link"></i></button>
                          <button type="button" class="btn btn-outline-secondary" id="formatting_list"><i class="far fa-list"></i></button>
                          <button type="button" class="btn btn-outline-secondary" id="formatting_list-ol"><i class="far fa-list-ol"></i></button>
                          <button type="button" class="btn btn-outline-secondary" id="formatting_quote"><i class="far fa-quote-left"></i></button>
                            <!--
                          <button type="button" class="btn btn-outline-secondary" id="formatting_sub"><i class="far fa-subscript"></i></button>
                          <button type="button" class="btn btn-outline-secondary" id="formatting_super"><i class="far fa-superscript"></i></button>
                          -->
                          <button type="button" class="btn btn-outline-secondary" id="formatting_greek">&alpha;</button>
                          <button type="button" class="btn btn-outline-secondary" id="formatting_help"><i class="far fa-question"></i></button>
                        </div>
                        <%include file="../markup/markup_builder_btn.mako"/>
                        <button type="button" class="btn btn-outline-info" data-toggle="modal" data-target="#combine_modal"><i class="far fa-paperclip"></i> Add additional model</button>
                        <button type="button" class="btn btn-outline-info" data-toggle="modal" data-target="#mutate_modal"><i class="far fa-biohazard"></i> Make mutations</button>

                    </div>
                    </div>
                <div class="input-group mb-3">
                    <div class="input-group-prepend">
                        <span class="input-group-text" aria-label="edit_description" aria-describedby="description-addon1">Description</span>
                    </div>
                    <%
                        escaped_description = description.replace('<br/>','\n').replace('<br>','\n').replace('&','&amp;').replace('>','&gt;').replace('<','&lt;').replace('\n','<br/>')
                    %>
                    <div id="edit_description"
                         contenteditable="true"
                         class="form-control border" style="height: 15rem; resize: vertical; overflow: auto; white-space: pre-wrap;">${escaped_description|n}</div>
                </div>

                <div class="row">
                    <div class="col-12 col-lg-6">
                        <div class="input-group mb-3">
                    <div class="input-group-prepend">
                        <span class="input-group-text" id="columns_viewport_label">Viewport size</span>
                    </div>
                    <div class="border rounded-right px-3 py-1">
                        <input type="range" min="1" max="12" value="9" step="1" class="custom-range" id="columns_viewport">
                    </div>
                </div>
                    </div>
                    <div class="col-12 col-lg-6">
                        <div class="input-group mb-3">
                            <div class="input-group-prepend">
                                <span class="input-group-text" id="location_viewport_label">Viewport location</span>
                            </div>
                            <div class="btn-group btn-group-toggle" data-toggle="buttons">
                              <label class="btn btn-secondary active">
                                <input type="radio" name="location_viewport" id="location_viewport_left" autocomplete="off" checked value="left"><i class="far fa-caret-square-left"></i>&nbsp; Left
                              </label>
                              <label class="btn btn-secondary">
                                <input type="radio" name="location_viewport" id="location_viewport_right" autocomplete="off" value="right"> Right <i class="far fa-caret-square-right"></i>
                              </label>
                            </div>
                        </div>
                    </div>
                </div>

                <hr/>
                <%include file="page_users.mako"/>
                <hr/>
                <%include file="edit_security.mako"/>
                <hr/>
                <p><input type="checkbox" checked> <small>You declare that the content you are uploading does not contain copyrighted material
                    and that you are aware that the site admin can delete your page if deemed in breech of any law.</small></p>
                <div class="modal-footer">
                    <div class="btn-group" role="group">
                        <button type="button" class="btn btn-success" id="edit_submit"><i class="far fa-save"></i> Save changes</button>
                        <button type="button" class="btn btn-danger" id="edit_delete"><i class="far fa-trash-alt"></i> Scrap page</button>
                        <button type="button" class="btn btn-secondary" data-dismiss="modal"><i class="far fa-sign-out"></i> Discard changes</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>





<div class="modal" tabindex="-1" role="dialog" id="formatting_help_modal" data-backdrop="true">
  <div class="modal-dialog modal-dialog-centered" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Markdown</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        <p>This is the description text in markdown format (same as Reddit, GitHub and others). Here is an <a href="https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet">external guide on the topic <i class="far fa-external-link"></i></a>.</p>
        <p>There is some extra flavoring, namely:</p>
            <ul>
                <li><code>@prolink#1[text]</code> will insert a generated prolink.</li>
                <li><code>@fa[icon-name]</code> will insert a <a href="https://fontawesome.com/icons/">FontAwesome icon <i class="far fa-external-link"></i></a>, e.g. <code>@fa[external-link]</code> produces <i class="far fa-external-link"></i></li>
            </ul>

      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-primary">Save changes</button>
      </div>
    </div>
  </div>
</div>
