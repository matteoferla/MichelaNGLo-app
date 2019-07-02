<div class="modal fade" tabindex="-1" role="dialog" id="chat_modal">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content shadow">
            <div class="modal-header">
                <h5 class="modal-title"><i class="far fa-comments"></i> Message admin</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p>Confused about something? Struggling markdown? Something not quite right?
                    Send a message to the admin, who will get back to you by email as soon as they can.</p>

                %if user:
                    <div class="input-group mb-3">
                  <div class="input-group-prepend">
                    <span class="input-group-text" id="chat_message_label">Message</span>
                  </div>
                  <input type="text" class="form-control" placeholder="your message here" aria-label="message" aria-describedby="chat_message_label" id="chat_message">
                </div>
                % else:
                    <div class="alert alert-warning" role="alert">Logged in users only. Sorry.</div>
                %endif
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" id="chat_send" ${'disabled' if not user else ''}><i class="far paper-plane"></i> Send</button>
                    <button type="button" class="btn btn-secondary" data-dismiss="modal"><i class="far fa-sign-out"></i> Close</button>
                </div>
            </div>
        </div>
    </div>
</div>
