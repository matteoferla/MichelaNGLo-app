
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
                <div class="input-group mb-3" data-toggle="tooltip" title="This is the description text in markdown format (same as Reddit, GitHub and others, for more see one of the many guides).">
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

                <%include file="../markup/markup_builder_btn.mako"/>
                <button type="button" class="btn btn-outline-info mb-2" data-toggle="modal" data-target="#combine_modal"><i class="far fa-paperclip"></i> Add additional model</button>
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
