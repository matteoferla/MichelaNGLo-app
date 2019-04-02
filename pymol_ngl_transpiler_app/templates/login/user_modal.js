//////////////// login
$('#login-btn,#register-btn,#logout-btn').click( function () {
    $('.is-invalid').removeClass('is-invalid');
    $('.is-valid').removeClass('is-valid');
    $('.invalid-feedback').hide();
    var action = $(this).attr('id').replace('-btn','');
    $.ajax({url: "/login",
            data: {username: $('#username').val(),
                   password: $('#password').val(),
                   action: action},
            method: 'POST'
        })
        .done(function (msg) {
            console.log(msg);
            /// deal with parts to show in modal
            if ((action === 'login') || (action === 'register')) {
                $("#login-content").hide(1000);
                $("#logout-content").show(1000);
                $("#username-name").text(msg.name);
                $("#username-rank").text(msg.rank);

                //setTimeout(() => $('#login').modal('hide'),1500);

            } else if (action === 'logout') {
                $("#logout-content").hide(1000);
                $("#page-content").detach();
                $("#login-content").show(1000);
            }
            // deal with header in main page

            if (action === 'login') {
                set_username (msg.name, msg.rank);
                $('#pages-content').detach();
                $.ajax({url: "/get",
                    data: {username: $('#username').val(),
                           item: 'pages'},
                    method: 'POST'
                }).done( (msg) => $('#login .modal-body').append(msg));

            }
            else if (action === 'register') {set_username (msg.name,'new');}
            else if (action === 'logout') {
                set_username ();
                $('#pages-content').detach();
            }
            else {set_username ('<b>Impossible</b>','hacker');}

            })
        .fail(function (msg) {
            console.log('Fail!');
            if (msg.responseJSON) {
                console.log(msg);
                if (msg.responseJSON.status === 'wrong username') {
                    $('#username').addClass('is-invalid');
                    $('#username_error').show();
                }
                else if (msg.responseJSON.status === 'wrong password') {
                    $('#password').addClass('is-invalid');
                    $('#password_error').show();
                }
            }
        })
});

window.deletePage = function (id) {
$.ajax({
    url: "/delete_user-page",
    type: 'POST',
    dataType: 'json',
    data: {
        'type': 'delete',
        'page': id
    }
}).done(()=> $('[data-page="'+id+'"]').detach());
}
