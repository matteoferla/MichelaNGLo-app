window.combinePage = function (uuid) {
           var nProtein = myData.proteins.length;
           $.ajax({
            url: "/combine_user-page",
            type: 'POST',
            dataType: 'json',
            data: {
                'target_page': "${page}",
                %if key:
                'target_encryption_key': "${key}",
                %endif
                'donor_page': uuid,
                'task': 'both',
                'name': nProtein
            }
        }   )
        .done((msg) => location.reload())
        .fail((xhr) => ops.addToast('userpageerror','Error '+xhr.status,'An error occured. '+xhr.responseJSON.status));
        };

window.copyJSPage = function (uuid) {
     var name = window.prompt("Name to call the function. ","defaultText");
     if (name === null) {ops.addToast('userCancel','Cancelled','User cancelled.','bg-warn')}
     else if (name in window)  {ops.addToast('nameTaken','Conflict','The name '+name+' appears already taken. Please try again with a different name.','bg-warn')}
     else {
         $.ajax({
            url: "/combine_user-page",
            type: 'POST',
            dataType: 'json',
            data: {
                'target_page': "${page}",
                %if key:
                'target_encryption_key': "${key}",
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

