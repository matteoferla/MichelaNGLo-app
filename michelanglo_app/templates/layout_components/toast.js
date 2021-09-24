//<%text>

window.ops={timer: null, i: 0, debug: false};

ops.addToast = function (id, title, body, bg, autohide, delay, subtitle) {
    /* adds a toast to the toaster! */
        id = id || 'T'+Date.now();
        autohide = autohide || true;
        delay=delay || 5000;
        subtitle = subtitle || '';
        bg = bg || 'bg-info';
        $('#'+id).detach(); //duplicate id!
        $('#toaster').append(`<div class="toast ml-auto w-100 ${bg}" 
                                    style="z-index:9000; pointer-events: auto"
                                    role="alert" aria-live="assertive" aria-atomic="true"
                                    id="${id}" data-delay=${delay} data-autohide="${autohide}">
                                  <div class="toast-header">
                                    <strong class="mr-auto">${title}</strong>
                                    <small>${subtitle}</small>
                                    <button type="button" class="ml-2 mb-1 close" data-dismiss="toast" aria-label="Close">
                                      <span aria-hidden="true">&times;</span>
                                    </button>
                                  </div>
                                  <div class="toast-body">
                                    ${body}
                                  </div>
                                </div>`);
    $('#'+id).toast('show');
    };

ops.addErrorToast = (xhr) => {if (!! xhr.responseJSON) {
                                            ops.addToast('userpageerror','Error '+xhr.status,'The request could not be completed because '+xhr.responseJSON.status, 'bg-danger');
                                                }
                              else if (!! xhr.responseText) {
                                            if (ops.debug) {
                                                ops.addToast('userpageerror', 'Error ' + xhr.status, 'An unknown error occured serverside and the admin has been notified.' + xhr.responseText, 'bg-danger');
                                            }
                                            else {
                                                ops.addToast('userpageerror', 'Error ' + xhr.status, 'An unknown error occured serverside and the admin has been notified.', 'bg-danger');
                                            }
                                        }
                              else if (!! xhr.statusText) {
                                  ops.addToast('userpageerror','Error '+xhr.status,'An unknown error occured. '+ xhr.statusText, 'bg-danger');
                                     }
                              else {
                                  ops.addToast('userpageerror','Error '+xhr.status,'An unknown error occured.', 'bg-danger');
                                     }
                             };

ops.halt = function () {
    clearTimeout(ops.timer);
    $('#analyse').removeAttr('disabled');
    setTimeout(ops.halt,100);
};

ops.reset_warnings = function () {
    $('.invalid-feedback,valid-feedback').hide();
    $('.is-invalid').removeClass('is-invalid');
    $('.is-valid').removeClass('is-valid');
};

ops.statusCheck = function (data) {
        if (ops.timer === false) { ops.halt();}
        if (ops.timer === null) {ops.timer=setTimeout(function() {ops.statusCheck(data);}, 1000);}
      ops.i++; // user for unique ids
      var i=ops.i;
      $.ajax({
        type: "POST",
        url: "task_check",
        processData: false,
        cache: false,
        contentType: false,
        data:  data
    })  .done(function (msg) {
        ops.addToast(undefined, msg.title,msg.body, msg.color);
        if (msg.codition !== 'running') {ops.halt(); return 0}
        else {ops.timer = setTimeout(()=> ops.statusCheck(data),1000); return 1}
      })
        .fail(function () {
            ops.addToast('error_step'+i,'Error','<i class="far fa-bug"></i> An issue arose. Please review and try again','bg-danger');
            ops.halt();
            return 0;
        });
};
//</%text>