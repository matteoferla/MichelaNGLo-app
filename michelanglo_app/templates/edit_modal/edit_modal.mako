
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
                <div class="input-group mb-3">
                    <div class="input-group-prepend">
                        <span class="input-group-text" id="title-addon1">Title</span>
                    </div>
                    <input type="text" class="form-control" value="${title}" aria-label="Title" aria-describedby="title-addon1" id="edit_title">
                </div>
                <div class="input-group mb-3">
                    <div class="input-group-prepend">
                        <span class="input-group-text" aria-label="edit_description" ro aria-describedby="description-addon1">Description</span>
                    </div>
                    <textarea class="form-control" rows=6 aria-label="With textarea" id="edit_description">${description}</textarea>

                    <div id="textarea" rows="3" contenteditable="true" class="border" style="height: 5em; resize: vertical;">Hello <code>world</code> froddm Mars.</div>
                </div>

                <%include file="../markup/markup_builder_btn.mako"/>
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
