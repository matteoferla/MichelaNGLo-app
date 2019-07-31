window.ops={timer: null, i: 0};

/// okay. this is a bit weird. but what happens is that during template construction the large toast.mako block gets added to the append. The character exacaping is weird. Not sure if needed.
ops.addToast = function (id, title, body, bg) {
        id = id || 'T'+Date.now();
        $('#toaster').append(`<%include file="toast.mako" args="toast_id='${id}', toast_title='${title}', toast_body='${body}', toast_bg='${bg}', toast_autohide='true', toast_delay=5000 "/>`);
        $('#'+id).toast('show');

    };

ops.addErrorToast = (xhr) => {if (!! xhr.responseJSON) {
                                            ops.addToast('userpageerror','Error '+xhr.status,'An error occured.'+xhr.responseJSON.status, 'bg-danger');
                                                }
                              else if (!! xhr.responseText) {
                                            ops.addToast('userpageerror', 'Error ' + xhr.status, 'An error occured.' + xhr.responseText, 'bg-danger');
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


