<!DOCTYPE html>
<html lang="en">
    <%page args="bootstrap='4', remote=False, offline=False, no_user=False, public=True, confidential=False, no_analytics=False, title='Michelaɴɢʟo'"/>

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="${meta_description}">
    <meta name="author" content="Matteo Ferla et al. 2020">
    <meta name="twitter:card" content="summary"/>
    <meta property="og:title" content="${meta_title}">
    <meta property="og:description" content="${meta_description}">
    <meta property="og:image" content="${meta_image}">
    <meta property="og:url" content="${meta_url}">
    <link rel="icon" href="/favicon.ico">
    <meta name="google-site-verification" content="rR92bqgvkgg-_WdvMvGpwrtt-vFHXM8-dfV_t3UoI6g"/>
    %if not public:
        <meta name="robots" content="none">
    %endif

    <title>${title}</title>
    % if offline:
        <style>
            ${open('michelanglo_app/static/ThirdParty/bootstrap/dist/css/bootstrap.min.css').read()|n}
        </style>
    % elif bootstrap == 'materials':
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" integrity="sha384-JcKb8q3iqJ61gNV9KGb8thSsNjpSL0n8PARn9HuZOnIxN0hoP+VmmDGMN5t9UJ0Z" crossorigin="anonymous">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/mdbootstrap/4.7.6/css/mdb.min.css" rel="stylesheet">
    % else:
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" integrity="sha384-JcKb8q3iqJ61gNV9KGb8thSsNjpSL0n8PARn9HuZOnIxN0hoP+VmmDGMN5t9UJ0Z" crossorigin="anonymous">
    % endif

    #### Non-critical stylesheets at bottom of page for speed.

    <style>

        .footer {
            position: absolute;
            bottom: 0;
            width: 100%;
            /* Set the fixed height of the footer here */
            height: 60px;
            line-height: 60px; /* Vertically center the text there */
            background-color: #f5f5f5;
        }

        .footer-logo {
            height: 3em;
            display: inline-block;
        }

        .footer-logo:hover {
            height: 4em;
            display: inline-block;
            cursor: pointer;
            -ms-transform: translate(0px, -1em); /* IE 9 */
            -webkit-transform: translate(0px, -1em); /* Safari prior 9.0 */
            transform: translate(0px, -1em); /* Standard syntax */
        }

        .prolink-icon {
            position: relative;
            padding-left: 1.2em;
        }

        .prolink-icon::after {
            content: '';
            background-image: url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz48c3ZnIHZlcnNpb249IjEuMSIgaWQ9IkxheWVyXzEiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHg9IjBweCIgeT0iMHB4IiB2aWV3Qm94PSIwIDAgMTc0IDEzMCIgc3R5bGU9ImVuYWJsZS1iYWNrZ3JvdW5kOm5ldyAwIDAgMTc0IDEzMDsiIHhtbDpzcGFjZT0icHJlc2VydmUiPjxzdHlsZSB0eXBlPSJ0ZXh0L2NzcyI+LnN0MHtmaWxsOm5vbmU7c3Ryb2tlOiMwMTAxMDE7c3Ryb2tlLXdpZHRoOjIwO3N0cm9rZS1saW5lY2FwOnJvdW5kO3N0cm9rZS1taXRlcmxpbWl0OjEwO30uc3Qxe2ZpbGw6IzAxMDEwMTt9LnN0MntmaWxsOm5vbmU7c3Ryb2tlOiMwMTAxMDE7c3Ryb2tlLXdpZHRoOjQ7c3Ryb2tlLWxpbmVjYXA6cm91bmQ7c3Ryb2tlLW1pdGVybGltaXQ6MTA7fTwvc3R5bGU+PGc+PGc+PGxpbmUgY2xhc3M9InN0MCIgeDE9IjMyLjUiIHkxPSIzMi45IiB4Mj0iMTA1LjIiIHkyPSIzMi45Ii8+PGc+PHBvbHlnb24gY2xhc3M9InN0MSIgcG9pbnRzPSI5OS4zLDUyLjggMTMzLjksMzIuOSA5OS4zLDEyLjkgIi8+PC9nPjwvZz48Zz48bGluZSBjbGFzcz0ic3QwIiB4MT0iMTMzLjkiIHkxPSI3MCIgeDI9IjYxLjIiIHkyPSI3MCIvPjxnPjxwb2x5Z29uIGNsYXNzPSJzdDEiIHBvaW50cz0iNjcuMSw1MC4xIDMyLjUsNzAgNjcuMSw4OS45ICIvPjwvZz48L2c+PGc+PGxpbmUgY2xhc3M9InN0MCIgeDE9IjMyLjUiIHkxPSIxMDUuMSIgeDI9IjEwNS4yIiB5Mj0iMTA1LjEiLz48Zz48cG9seWdvbiBjbGFzcz0ic3QxIiBwb2ludHM9Ijk5LjMsMTI1LjEgMTMzLjksMTA1LjEgOTkuMyw4NS4yICIvPjwvZz48L2c+PHBhdGggY2xhc3M9InN0MiIgZD0iTTQyLjYsMjkuOWMwLDAtMzEsMC4xLTMxLDIwLjFjMCwyMC44LDMxLDIwLjEsMzEsMjAuMSIvPjxwYXRoIGNsYXNzPSJzdDIiIGQ9Ik0xMjkuMywxMDYuM2MwLDAsMjguNy0wLjEsMjguNy0xOC42YzAtMTkuMi0yOC43LTE4LjYtMjguNy0xOC42Ii8+PC9nPjwvc3ZnPg==);
            fill: currentColor;
            background-size: 1em;
            position: absolute;
            padding-left: 1.2em;
            left: 0;
            top: 0;
            height: 100%;
        }

        .arrow-left {
            left: -30px;
            top: 80px;
            position: absolute;
            width: 0;
            z-index: 1000;
            height: 0;
            border-style: solid;
            border-width: 30px 30px 30px 0;
            border-color: transparent rgba(0, 0, 0, 0.125) transparent transparent;

        }

        .arrow-left:after {
            display: block;
            content: "";
            position: absolute;
            left: 1px;
            top: -30px;
            width: 0;
            height: 0;
            border-style: solid;
            border-width: 30px 30px 30px 0;
            z-index: 1000;
            border-color: transparent white transparent transparent;
        }

        .arrow-right {
            right: -30px;
            top: 80px;
            position: absolute;
            width: 0;
            z-index: 1000;
            height: 0;
            border-style: solid;
            border-width: 30px 0px 30px 30px;
            border-color: transparent transparent transparent rgba(0, 0, 0, 0.125);

        }

        .arrow-right:after {
            display: block;
            content: "";
            position: absolute;
            right: 1px;
            top: -30px;
            width: 0;
            z-index: 1000;
            height: 0;
            border-style: solid;
            border-width: 30px 0px 30px 30px;
            border-color: transparent transparent transparent white;
        }


        /* The flip card container - set the width and height to whatever you want. We have added the border property to demonstrate that the flip itself goes out of the box on hover (remove perspective if you don't want the 3D effect */
        .flip-card {
            background-color: transparent;
            padding-top: 10%;
            height: 300px;
            /*perspective: 200px; /* Remove this if you don't want the 3D effect */
        }

        /* This container is needed to position the front and back side */
        .flip-card-inner {
            position: relative;
            width: 100%;
            height: 100%;
            text-align: center;
            transition: transform 2s;
            transform-style: preserve-3d;
        }

        /* Position the front and back side */
        .flip-card-front, .flip-card-back {
            position: absolute;
            padding-top: 10%;
            width: 100%;
            height: 100%;
            backface-visibility: hidden;
        }

        .flip-card-inner > * {
            backface-visibility: hidden;
        }

        /* Style the front side (fallback if image is missing) */
        .flip-card-front {
        }

        /* Style the back side */
        .flip-card-back {
            transform: rotateX(180deg);
        }

        .pdb, .swiss, .itasser, .phyre, .alphafold {
            cursor: pointer;
        }

        .pdb:hover, .swiss:hover, .:hover, .phyre:hover, .alphafold:hover {
            fill: GreenYellow;
        }


        html {
            position: relative;
            min-height: 100%;
            overflow-y: scroll;
        }

        body {
            /* Margin bottom by footer height */
            margin-bottom: 60px;
        }

        main {
            /* bg image*/
            /* Use "linear-gradient" to add a darken background effect to the image (photographer.jpg). This will make the text easier to read */
            background-image: linear-gradient(rgba(255, 255, 255, 0.9), rgba(255, 255, 255, 0.9)), url('/static/background_blur.png');

            /* Set a specific height */
            height: 50%;

            /* Position and center the image to scale nicely on all screens */
            background-position: center;
            background-repeat: no-repeat;
            background-size: cover;
            position: relative;
        }

        pre {

            background: gainsboro;
            color: darkslategrey;
            font-family: monospace;
        }

        .custom-file-label:after {
            color: #fff;
            background-color: #1e7e34;
            border-color: #1c7430;
            pointer: cursor;
        }

        .popover {
            max-width: 90vw; /* Max Width of the popover (depending on the container!) */
        }

        .protein {
            width: 100%;
            height: 0;
            padding-bottom: 100%;
        }

        .prolink {
            color: mediumseagreen;
        }

        .prolink:hover {
            color: seagreen;
            cursor: pointer;
            text-decoration: underline;
        }

        .confidential-ribbon {
            z-index: 1050;
            width: 200px;
            background: #e43;
            position: fixed;
            top: 25px;
            left: -50px;
            text-align: center;
            line-height: 50px;
            letter-spacing: 1px;
            color: #f0f0f0;
            transform: rotate(-45deg);
            -webkit-transform: rotate(-45deg);
            box-shadow: 0 0 3px rgba(0, 0, 0, .3);
        }

        .hypercard:hover {
            cursor: pointer;
            border-width: 2px;
            background: whitesmoke;
        }

        .hypercard > img:hover {
            opacity: 0.7;
        }

        ::placeholder {
            color: gainsboro !important; /* normally BS is #6c757d */
        }

        .underlined {
            text-decoration-line: underline;
            text-decoration-style: dotted;
        }

    </style>

    <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
    <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
    <script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
    <![endif]-->
</head>


<body>
    %if confidential:
        <div class="confidential-ribbon shadow" data-toggle="tooltip"
             title="This page is confidential. Namely, the URL to this page and its contents have been shared with a specific addressee as a privileged communication that is intended to be read only by the specific addressee. The latter party, unless otherwise specified, is not at liberty to disclose this page and information with a third party.">
            <i class="far fa-user-secret"></i> Confidential
        </div>
    %endif
<div id="toasterOuter" class="position-absolute m-0 w-100" style="z-index: 9999;">
    <div id="toaster" class="m-0 w-100 pl-3"
         style="position: fixed;  padding-top: 5em; pointer-events: none"></div>
</div>

<main role='main' class="container-fluid p-0 w-100 mx-0">
    ${ next.body() }
</main>

<%include file="chat.mako"/>

<footer class="footer">
    <div class="container-fluid">
        <div class="row" style="line-height: 1rem;">
            <div class="col-12 col-lg-5 text-muted px-3 pt-3">
                <small>Data is not kept for commercial purposes, see data <a href="/docs/users">policy
                        documentation</a>.<br>
                        See <a href="/docs/cite">documentation</a> for how to cite.</small></div>
            <div class="d-none d-lg-block col-5 offset-lg-1 pt-2">
                %if offline:
                    University of Oxford &mdash; NIHR: BRC &mdash; SGC
                %else:
                    ## same as if not remote:
                    <div class="d-flex">
                        <div class="px-2 flex-fill">
                            <img src="/static/ox_full.svg" alt="University of Oxford" class="footer-logo"
                         onclick="window.location.href = 'http://www.ox.ac.uk/';">
                        </div>
                        <div class="px-2 flex-fill">
                            <img src="/static/OxfordBRC-logo-2019.png" alt="BRC" class="footer-logo"
                         onclick="window.location.href = 'https://oxfordbrc.nihr.ac.uk/';">
                        </div>
                        <div class="px-2 flex-fill">
                            <img src="/static/cmd_logo.png" alt="CMD" class="footer-logo"
                         onclick="window.location.href = 'https://www.cmd.ox.ac.uk/';">
                        </div>
                    </div>
                %endif
            </div>
            <div class="d-block d-lg-none col-12">
                <a href='http://www.ox.ac.uk/'>University of Oxford</a>
                &mdash;
                <a href='https://oxfordbrc.nihr.ac.uk/'>BRC</a>
                &mdash;
                <a href='https://www.cmd.ox.ac.uk/'>CMD</a>
            </div>
        </div>

    </div>
</footer>


<!-- Bootstrap core JavaScript-->
    %if offline:
        ## if you get an error here that the file jquery is missing it is because you did not npm built it!
        ## This assumes the current working dir: /Users/matteo/Coding/michelanglo/app
        <script type="text/javascript">${open('michelanglo_app/static/ThirdParty/jquery.min.js').read()|n}</script>
        <script type="text/javascript">${open('michelanglo_app/static/ThirdParty/bootstrap/dist/js/bootstrap.min.js').read()|n}</script>
        <!-- cannot compile popper -->
    %else:
        <script src="https://code.jquery.com/jquery-3.3.1.min.js"
                integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8=" crossorigin="anonymous"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js"
                integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1"
                crossorigin="anonymous"></script>
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js" integrity="sha384-B4gt1jrGC7Jh4AgTPSdUtOBvfO8shuf57BaghqFfPlYxofvL8/KUEfYiJOMMV+rV" crossorigin="anonymous"></script>
    %endif
    %if bootstrap == 'materials':
        <script type="text/javascript"
                src="https://cdnjs.cloudflare.com/ajax/libs/mdbootstrap/4.7.6/js/mdb.min.js"></script>
    % endif

    %if offline:
        <script type="text/javascript">${open('michelanglo_app/static/ThirdParty/ngl/dist/ngl.js').read()|n}</script>
        <script type="text/javascript">${open('michelanglo_app/static/michelanglo.js').read()|n}</script>
        <script type="text/javascript">${open('michelanglo_app/static/michelanglo_menu.js').read()|n}</script>
    %elif not remote:
        <script src="https://unpkg.com/ngl@2.0.0-dev.34/dist/ngl.js" type="text/javascript"></script>
        <script type="text/javascript" src="/static/michelanglo.js"></script>
        <script type="text/javascript" src="/static/michelanglo_menu.js"></script>
        <script src="/static/ThirdParty/bootstrap-tourist/bootstrap-tourist.js"></script>
    % else:
        <script src="https://unpkg.com/ngl@2.0.0-dev.34/dist/ngl.js" type="text/javascript"></script>
        <script type="text/javascript" src="https://michelanglo.sgc.ox.ac.uk/michelanglo.js"></script>
        <script type="text/javascript" src="https://michelanglo.sgc.ox.ac.uk/michelanglo_menu.js"></script>
        <!-- no turist -->
    % endif
<script src="https://cdnjs.cloudflare.com/ajax/libs/clipboard.js/2.0.0/clipboard.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-colorpicker/3.0.0-beta.3/js/bootstrap-colorpicker.min.js"></script>
<script type="text/javascript">
    <%include file="toast.js"/>
    % if user and user.role == 'admin':
        window.ops.debug = true;
    % endif
</script>
    <%block name="script"/>
    % if not no_user:
        <%include file="../login/user_modal.mako"/>
    % endif

<script type="text/javascript">
    $('[data-toggle="popover"]').popover();
    $('[data-toggle="tooltip"]').tooltip();
    $('#menu').on('shown.bs.popover', function () {
        $('.popover a').hover(function () {
            $('.popover-header').html($(this).attr('title'))
        });
    });
        % if not no_user:
            <%include file="../login/user_icon_bar.js"/>
            <%include file="../login/user_modal.js"/>
            %if not user: ## unregistered and new visitor.
            if (!localStorage.getItem('cookiesAccepted')) {
                    ops.addToast('acceptCookies',
                                 'Cookies',
                                 `This site uses cookies to manage user authentication in order
                                 to allow users to keep track of pages users made and to control editing privileges.`,
                                 'bg-info',
                                 false);
                    $('#acceptCookies').toast('show');
                    $('#acceptCookies').on('hide.bs.toast', (event) => localStorage.setItem('cookiesAccepted', true));
                }
            %endif
                ${custom_messages|n}.forEach((v, i) => ops.addToast('custom_msg' + i, v.title, v.descr, v.bg));

                $('#chat_send').click((event) => {
                    let msg = $('#chat_message').val();
                    $('#chat_message').val('');
                    $('#chat_modal').modal('hide');
                    if (msg) {
                        $.ajax({
                            url: "/msg",
                            data: {
                                'text': msg,
                                'page': window.location.pathname,
                                'event': 'chat'
                            },
                            method: 'POST'
                        })
                                .done((msg) => ops.addToast('userchatgood', 'Send', 'Thank you! The site admin will get back to you shortly.', 'bg-success'))
                                .fail(ops.addErrorToast)
                    } else {
                        ops.addToast('emptymessage', 'Empty message', 'Ehhr. Somehow the message is empty.', 'bg-warning')
                    }
                }) //click.
        % endif
    $(document).on('show.bs.modal', '.modal', function () {
        var zIndex = 1040 + (10 * $('.modal:visible').length);
        $(this).css('z-index', zIndex);
        setTimeout(function () {
            $('.modal-backdrop').not('.modal-stack').css('z-index', zIndex - 1).addClass('modal-stack');
        }, 0);
    });

    window.onerror = (msg, url, lineNo, columnNo, error) => ops.addToast('JSerror' + Math.floor(Math.random() * 1000),
            'DEBUG: JS Error', [
                'Message: ' + msg,
                'URL: ' + url,
                'Line: ' + lineNo,
                'Column: ' + columnNo,
                'Error object: ' + JSON.stringify(error)
            ].join(' - '),
            'bg-danger');

    window.toggleAccessible = () => {
        const accessible = !! document.getElementById('accessibilityCSS');
        if (accessible) {
            document.getElementById('accessibilityCSS').remove();
            document.getElementsByClassName('fa-eye')[0].classList.replace('fa-eye', 'fa-eye-slash');
            $('#user').removeClass('btn btn-outline-secondary m-1 d-none d-lg-block')
            localStorage.setItem('accessible', false);
        } else {
            document.getElementsByClassName('fa-eye-slash')[0].classList.replace('fa-eye-slash', 'fa-eye');
            const accessibilityElement = document.createElement('link');
            accessibilityElement.id = 'accessibilityCSS';
            accessibilityElement.rel = 'stylesheet';
            accessibilityElement.href = '/static/accessible.css';
            document.head.appendChild(accessibilityElement);
            localStorage.setItem('accessible', 'true');
            if (localStorage.getItem('accessible_toast_shown') !== 'true') {
                localStorage.setItem('accessible_toast_shown', 'false');
            }
        }
        // gets stuck
        $('#accessibility_btn').tooltip('hide');
    };
    $('#accessibility_btn').click(window.toggleAccessible);
    if ((localStorage.getItem('accessible') === 'true') && (localStorage.getItem('accessible_toast_shown') === 'false')) {
        ops.addToast('accessibletoast','High constrast mode - privacy notice',
                'You have previously clicked to enable high-contrast mode. This information is stored in your browser and not serverside.',
                'bg-white');
        localStorage.setItem('accessible_toast_shown', 'true');
        window.toggleAccessible();
    } else if (localStorage.getItem('accessible') === 'true') {
        window.toggleAccessible();
    }

</script>

    % if not no_analytics:
        <!-- Global site tag (gtag.js) - Google Analytics -->
        <script async src="https://www.googletagmanager.com/gtag/js?id=UA-66652240-5"></script>
        <script>
            window.dataLayer = window.dataLayer || [];

            function gtag() {
                dataLayer.push(arguments);
            }

            gtag('js', new Date());
            gtag('config', 'UA-66652240-5');
        </script>
    % endif
<!-- Custom styles for this scaffold that are not time critical-->
<!--<link href="/static/theme.css" rel="stylesheet">-->
<!--<link rel="stylesheet" href="https://pro.fontawesome.com/releases/v5.6.3/css/all.css" integrity="sha384-LRlmVvLKVApDVGuspQFnRQJjkv0P7/YFrw84YYQtmYG4nK8c+M+NlmYDCv0rKWpG" crossorigin="anonymous">-->

<script type="text/javascript">
    // append last!
    $(document).ready(() => $('head').append(`<link rel="stylesheet" href="/static/ThirdParty/Font-Awesome-Pro/css/all.min.css" crossorigin="anonymous">
    <link rel="stylesheet" href="/static/ThirdParty/bootstrap-tourist/bootstrap-tourist.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-colorpicker/3.0.0-beta.3/css/bootstrap-colorpicker.css">`));

    //Don't have FA-pro in your local deployment?
    //Then uncomment here:
    //$('.far').addClass('fas').removeClass('far');

</script>


</body>
</html>
