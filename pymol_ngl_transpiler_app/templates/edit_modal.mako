
<div class="modal fade" tabindex="-1" role="dialog" id="edit_modal">
    <div class="modal-dialog modal-lg" role="document">
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
                </div>

                <%include file="markup/markup_builder_btn.mako"/>
                <hr/>
                <%include file="page_users.mako"/>
                <hr/>
                <div id="security"><a href="#" data-toggle="collapse" data-target="#security .collapse">Security <span class="collapse show"><i class="far fa-chevron-double-down"></i></span>
                            <span class="collapse"><i class="far fa-chevron-double-up"></i></span></a>

                <div class="collapse">
                    <p>Currently, the address to your data contains <a href="https://en.wikipedia.org/w/index.php?title=Universally_unique_identifier" target="_blank">a long id, which cannot be guessed (five undecillion combinations) <i class="far fa-external-link"></i></a>.
                    However, if the server is compromised or the administrator turns evil the data can be seen &mdash;note that this does not apply your password, which cannot be seen as it is stored hashed.
                        If your data is <i>extremely</i> sensitive, the data can be encrypted serverside. This requires the encryption key each time the data is requested to be viewed. <b>Note that, if you forget the key, the data is lost, so please proceed with care.</b></p>
                    <div class="input-group">
                  <div class="input-group-prepend">
                    <div class="input-group-text">
                        <input type="checkbox" aria-label="encryption key label" id="encryption"
                        %if encryption:
                            checked
                        %endif
                            >
                         &nbsp; use encryption
                    </div>
                  </div>

                            <input type="password" class="form-control" aria-label="encryption key" id="encryption_key" autocomplete="new-password"
                        %if encryption:
                            value="${encryption_key}"
                        %else:
                            placeholder="key"
                        %endif
                            >
                </div>
                    <div class="valid-feedback" id="encryption_key_error">No key provided</div>
                </div></div>
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
