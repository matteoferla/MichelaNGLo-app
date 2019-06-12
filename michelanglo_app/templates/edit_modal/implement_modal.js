$('#getimplement').click(function () { //this is available to all in case a guest makes a page.
        $('#implement_modal .modal-body').html('<p><i class="far fa-dna fa-spin"></i> Data is loading...</p>');
        $('#implement_modal').modal('show');
        $.ajax({url: "/get",
                data: {page: "${page}",
                    %if key:
                        key: "${key}",
                    %endif
                       item: 'implement'},
                method: 'POST'
            }).done( (msg) => {$('#implement_modal .modal-body').html(msg); new ClipboardJS('.clipboard');})
                .fail((msg) => $('#implement_modal .modal-body').html('<p><i class="far fa-biohazard"></i> An error occurred and has been logged.</p>'));
    });