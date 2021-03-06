window.set_username = function (name, role, quietly) {
    role = role || 'basic';
    if (! name) {name = '<i>Guest</i> <small>(Click to log-in or register)</small>'; role='guest'}
    else if (role === 'new') name +=' <small>(Click to see personal pages)</small>';
    var icon = {'basic': 'user', 'friend': 'user-tie', 'guest': 'user-secret', 'admin': 'user-crown', 'new': 'user-astronaut', 'hacker': 'user-ninja', 'trashcan': 'dumpster'}[role];
    $("#user").html('<a href="#" class="text-secondary" data-toggle="modal" data-target="#login"><i class="far fa-'+icon+'"></i> '+name+'</a>');
    if (! quietly) {
        $("#user").animate({fontSize: '3em'}, "fast").animate({fontSize: '1em'}, "slow");}
    };

    //__init__
    %if user:
        $('#login-content').hide();
        $('#logout-content').show();
        $("#username-name").text("${user.name}");
        $("#username-rank").text("${user.role}");
        set_username("${user.name}", "${user.role}", true);
    %else:
        set_username(null, null, true);
    %endif
