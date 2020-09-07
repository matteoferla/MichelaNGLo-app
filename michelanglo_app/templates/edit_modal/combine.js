//<%text>
window.combinePage = function (uuid) {

           let name = window.prompt("Name to call the structure to show the view (the value that goes in data-load='xxxxxxxx' in a prolink. (Note it's view will be called the same+Fx)","altStructure");
           let data = {
                'target_page': window.page,
                'donor_page': uuid,
                'task': 'both',
                'name': name
            };
           if (window.encryption_key !== undefined) {data.target_encryption_key = window.encryption_key}
           $.ajax({
            url: "/combine_user-page",
            type: 'POST',
            dataType: 'json',
            data: data
        }   )
        .done((msg) => location.reload())
        .fail((xhr) => ops.addToast('userpageerror','Error '+xhr.status,'An error occured. '+xhr.responseJSON.status));
        };

window.copyJSPage = function (uuid) {
     let name = window.prompt("Name to call the function to show the view (the value that goes in data-view='xxxxxxxx' in a prolink. ","altView");
     if (name === null) {ops.addToast('userCancel','Cancelled','User cancelled.','bg-warn')}
     else if (name in window)  {ops.addToast('nameTaken','Conflict','The name '+name+' appears already taken. Please try again with a different name.','bg-warn')}
     else {
         let data = {
                'target_page': window.page,
                'donor_page': uuid,
                'task': 'both',
                'name': name
            }
         if (window.encryption_key !== undefined) {data.target_encryption_key = window.encryption_key}
         $.ajax({
            url: "/combine_user-page",
            type: 'POST',
            dataType: 'json',
            data: data
        }   )
        .done((msg) => location.reload())
        .fail((xhr) => ops.addToast('userpageerror','Error '+xhr.status,'An error occured. '+xhr.responseJSON.status));
     }
};
//</%text>

