
<div class="modal fade" tabindex="-1" role="dialog" id="edit_modal" style="overflow:scroll;">
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
                    <div class="offset-1 col-11 pb-1">
                        <div class="btn-group" role="group" aria-label="formatting" id="formatting">
                          <button type="button" class="btn btn-outline-secondary" id="formatting_h3"><i class="far fa-h3"></i></button>
                          <button type="button" class="btn btn-outline-secondary" id="formatting_bold"><i class="far fa-bold"></i></button>
                          <button type="button" class="btn btn-outline-secondary" id="formatting_italic"><i class="far fa-italic"></i></button>
                          <button type="button" class="btn btn-outline-secondary" id="formatting_link"><i class="far fa-link"></i></button>
                          <button type="button" class="btn btn-outline-secondary" id="formatting_list"><i class="far fa-list"></i></button>
                          <button type="button" class="btn btn-outline-secondary" id="formatting_list-ol"><i class="far fa-list-ol"></i></button>
                          <button type="button" class="btn btn-outline-secondary" id="formatting_quote"><i class="far fa-quote-left"></i></button>
                          <button type="button" class="btn btn-outline-secondary" id="formatting_code"><i class="far fa-code"></i></button>
                            <!--
                          <button type="button" class="btn btn-outline-secondary" id="formatting_sub"><i class="far fa-subscript"></i></button>
                          <button type="button" class="btn btn-outline-secondary" id="formatting_super"><i class="far fa-superscript"></i></button>
                          -->
                          <button type="button" class="btn btn-outline-secondary" id="formatting_alpha">&alpha;</button>
                          <button type="button" class="btn btn-outline-secondary" id="formatting_beta">&beta;</button>
                          <button type="button" class="btn btn-outline-secondary" id="formatting_gamma">&gamma;</button>
                          <button type="button" class="btn btn-outline-secondary" id="formatting_delta">&delta;</button>
                          <button type="button" class="btn btn-outline-secondary" id="formatting_mu">&mu;</button>
                          <button type="button" class="btn btn-outline-secondary" id="formatting_Aring">&Aring;</button>
                          <button type="button" class="btn btn-outline-secondary" id="formatting_Delta">&Delta;</button>
                          <button type="button" class="btn btn-outline-info" id="formatting_help"><i class="far fa-question"></i></button>
                        </div>

                    </div>

                       <div class="offset-1 col-11 pb-1">
                            <span data-toggle="tooltip" title="Create links that control the protein view (prolinks)">
                                <%include file="../markup/markup_builder_btn.mako"/>
                            </span>
                           <span data-toggle="tooltip" title="Copy over into this page the structure (or the view only) from another page you have access to &mdash;added structure will appear as a different model (see fa-load in documentation).">
                               <button type="button" class="btn btn-outline-info" data-toggle="modal" data-target="#combine_modal"><i class="far fa-paperclip"></i> Add additional model</button>
                           </span>
                           <span data-toggle="tooltip" title="Create point mutations in this structure &mdash;mutant structure will appear as a different model (see fa-load in documentation)">
                                <button type="button" class="btn btn-outline-info" data-toggle="modal" data-target="#mutate_modal"><i class="far fa-biohazard"></i> Make mutations</button>
                           </span>
                               <button class="btn" data-toggle="tooltip" title="Collapse prolinks. Prolinks are the protein view links that can be created with the builder tool. They can be collapsed into a compact form or written in full as a HTML element. If you plan on moving them around, duplicating them or changing the values expand them. Otherwise keep this checked.">
                              <div class="input-group-prepend">
                                <div class="input-group-text">
                                  <div class="custom-control custom-switch">
                                      <input type="checkbox" id="collapse_prolinks" class="custom-control-input">
                                        <label class="custom-control-label" for="collapse_prolinks">Collapse prolinks</label>
                                      </div>
                                    </div>
                                </div>
                              </button>
                    </div>
                    </div>
                <div class="input-group mb-3">
                    <div class="input-group-prepend">
                        <span class="input-group-text" aria-label="edit_description" aria-describedby="description-addon1">Sidebar<br/>Description</span>
                    </div>
                    <%
                        escaped_description = description.replace('<br/>','\n').replace('<br>','\n').replace('&','&amp;').replace('>','&gt;').replace('<','&lt;').replace('\n','<br/>')
                    %>
                    <div id="edit_description"
                         contenteditable="true"
                         class="form-control border" style="height: 15rem; resize: vertical; overflow: auto; white-space: pre-wrap;">${escaped_description|n}</div>
                </div>

                <div class="row">
                    <div class="col-12 col-xl-4 col-lg-6">
                        <div class="input-group mb-3">
                    <div class="input-group-prepend">
                        <span class="input-group-text" id="columns_viewport_label">Viewport size</span>
                    </div>
                    <div class="border rounded-right px-3 py-1">
                        <input type="range" min="1" max="12" value="${columns_viewport}" step="1" class="custom-range" id="columns_viewport">
                    </div>
                </div>
                    </div>
                    <div class="col-12 col-xl-4 col-lg-6">
                        <div class="input-group mb-3">
                            <div class="input-group-prepend">
                                <span class="input-group-text" id="location_viewport_label">Viewport location</span>
                            </div>
                            <div class="btn-group btn-group-toggle" data-toggle="buttons">
                              <label class="btn btn-secondary active">
                                <input type="radio" name="location_viewport" id="location_viewport_left" autocomplete="off"
                                       %if location_viewport == 'left':
                                       checked
                                       %endif
                                       value="left"><i class="far fa-caret-square-left"></i>&nbsp; Left
                              </label>
                              <label class="btn btn-secondary">
                                <input type="radio" name="location_viewport" id="location_viewport_right" autocomplete="off"
                                       %if location_viewport != 'left': ##right.
                                       checked
                                       %endif
                                       value="right"> Right <i class="far fa-caret-square-right"></i>
                              </label>
                            </div>
                        </div>
                    </div>
                    <div class="col-12 col-xl-4 col-lg-6">
                        <div class="input-group mb-3" data-toggle="toolip" title="To use an image add a URL point to that image. Note, we will not host images here.">
                            <div class="input-group-append">
                            <span class="input-group-text" id="image_label">Use image</span>
                          </div>
                          %if image:
                          <input id="image" type="text" class="form-control"  value="${image}"  aria-label="None" aria-describedby="image_label">
                          % else:
                          <input id="image" type="text" class="form-control" placeholder="No image" aria-label="None" aria-describedby="image_label">
                          %endif
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
