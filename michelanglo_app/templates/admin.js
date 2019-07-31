
/*
<%
    udex = [{a: getattr(u,a) if getattr(u,a) else "" for a in ('name', 'role', 'visited_pages', 'owned_pages')} for u in users]

%>
*/
window.userdata = ${str(udex)|n};
//<buttom role="button" class="btn btn-outline-info btn-sm" data-toggle="user" data-target="{u.name}"><i class="far "></i> make admin</buttom>
$("[data-target='#mod']").click(function () {
    $('#mod .modal-title').html('Loading error');
    $('#mod .modal-body').html('Loading error');
    window.currentUser = userdata.filter(u => u.name === $(this).data('user'))[0]; //if it crashes there should be error.
    // title
    $('#mod .modal-title').html('View/Edit user <code>'+currentUser.name+'</code>');
    // interact
    var btn = '<buttom role="button" class="btn btn-outline-primary w-100" id="ID"><i class="far ICON"></i> NAME</buttom>';
    $('#mod .modal-body').html('<div class="row"><div class="col-3"></div><div class="col-3"></div><div class="col-3"></div><div class="col-3"></div></div>');
    $('#mod .modal-body .col-3').eq(0).append(btn.replace('ID','pass').replace('NAME','Reset pwd').replace('ICON','fa-paint-roller'));
    $('#mod .modal-body .col-3').eq(1).append(btn.replace('ID','kill').replace('NAME','Delete').replace('ICON','fa-skull-crossbones'));
    $('#mod .modal-body').append('<hr/>');
    if (currentUser.role !== 'admin') {$('#mod .modal-body .col-3').eq(2).append(btn.replace('ID','adminize').replace('NAME','Mk admin').replace('ICON','fa-crown'));}
    if (currentUser.role !== 'friend') {$('#mod .modal-body .col-3').eq(3).append(btn.replace('ID','befriend').replace('NAME','Mk approved').replace('ICON','fa-thumbs-up'));}
    $('#adminize,#befriend').click(function () {
        var btn = $(this);
        var role = {'adminize':'admin','befriend': 'friend'}[btn.attr('id')];
        $.ajax({url: "/login",
            data: {username: currentUser.name,
                   password: null,
                   action: 'promote',
                   role: role},
            method: 'POST'
        })
        .done(function (msg) {
            console.log(msg);
            var li=$('li[data-user="'+currentUser.name+'"]');
            li.children('span').children('i').removeClass('fa-user').addClass('fa-user-crown');
            btn.detach();
        });
    });

    $('#kill').click(function () {
        $.ajax({url: "/login",
            data: {username: currentUser.name,
                   password: null,
                   action: 'kill'},
            method: 'POST'
        })
        .done(function (msg) {
            console.log(msg);
            var li=$('li[data-user="'+currentUser.name+'"]');
            li.detach();
            $('#mod').modal('hide');
        });
    });
    $('#pass').click(function () {
        $.ajax({url: "/login",
            data: {username: currentUser.name,
                   password: null,
                   action: 'reset'},
            method: 'POST'
        })
        .done(function (msg) {
            console.log(msg);
            $('#pass').detach();
            $('#mod .modal-body').prepend('<p>Password reset to <code>password</code></p>');
        });
    });
    /// pages
    $.ajax({url: "/get",
            data: {username: currentUser.name,
                   item: 'pages'},
            method: 'POST'
        }).done( (msg) => $('#mod .modal-body').append(msg));
});

window.setMsg = (bg) => {
    $.ajax({url: "/set",
            data: {item: 'msg',
                   title: $('#msg_title').val(),
                   descr: $('#msg_descr').val(),
                   bg: bg},
            method: 'POST'
        })
        .done((msg) => ops.addToast('done', 'Success', JSON.stringify(msg), 'bg-success'));
};
window.clearMsg = (bg) => {
    $.ajax({url: "/set",
            data: {item: 'clear_msg'},
            method: 'POST'
        })
        .done((msg) => ops.addToast('done', 'Success', JSON.stringify(msg), 'bg-success'));
};