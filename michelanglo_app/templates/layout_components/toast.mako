<%page args="toast_id, toast_title='',toast_time='',toast_body='', toast_delay=1000, toast_bg='', toast_autohide='true'"/>

<div class="toast ml-auto w-100 ${toast_bg}" style="z-index:1050;" role="alert" aria-live="assertive" aria-atomic="true" id="${toast_id}" data-delay=${toast_delay} data-autohide="${toast_autohide}">
  <div class="toast-header">
    <strong class="mr-auto">${toast_title}</strong>
    <small>${toast_time}</small>
    <button type="button" class="ml-2 mb-1 close" data-dismiss="toast" aria-label="Close">
      <span aria-hidden="true">&times;</span>
    </button>
  </div>
  <div class="toast-body">
    ${toast_body}
  </div>
</div>
