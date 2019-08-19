window.combinePage = function (uuid) {

           let name = window.prompt("Name to call the structure to show the view (the value that goes in data-load='xxxxxxxx' in a prolink. (Note it's view will be called the same+Fx)","altStructure");
           $.ajax({
            url: "/combine_user-page",
            type: 'POST',
            dataType: 'json',
            data: {
                'target_page': "${page}",
                %if encryption_key:
                'target_encryption_key': "${encryption_key}",
                %endif
                'donor_page': uuid,
                'task': 'both',
                'name': name
            }
        }   )
        .done((msg) => location.reload())
        .fail((xhr) => ops.addToast('userpageerror','Error '+xhr.status,'An error occured. '+xhr.responseJSON.status));
        };

window.copyJSPage = function (uuid) {
     let name = window.prompt("Name to call the function to show the view (the value that goes in data-view='xxxxxxxx' in a prolink. ","altView");
     if (name === null) {ops.addToast('userCancel','Cancelled','User cancelled.','bg-warn')}
     else if (name in window)  {ops.addToast('nameTaken','Conflict','The name '+name+' appears already taken. Please try again with a different name.','bg-warn')}
     else {
         $.ajax({
            url: "/combine_user-page",
            type: 'POST',
            dataType: 'json',
            data: {
                'target_page': "${page}",
                %if encryption_key:
                'target_encryption_key': "${encryption_key}",
                %endif
                'donor_page': uuid,
                'task': 'both',
                'name': name
            }
        }   )
        .done((msg) => location.reload())
        .fail((xhr) => ops.addToast('userpageerror','Error '+xhr.status,'An error occured. '+xhr.responseJSON.status));
     }
};

