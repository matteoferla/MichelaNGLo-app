<!DOCTYPE html>
<html lang="en">
<%page args="bootstrap='4', remote=False, no_user=False, public=True, confidential=False, no_analytics=False, title='Michelaɴɢʟo'"/>

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="${meta_description}">
    <meta name="author" content="Matteo Ferla et al. 2019">
    <meta property="og:title" content="${meta_title}">
    <meta property="og:description" content="${meta_description}">
    <meta property="og:image" content="${meta_image}">
    <meta property="og:url" content="${meta_url}">
    <link rel="icon" href="/favicon.ico">
    %if not public:
        <meta name="robots" content="none">
    %endif

    <title>${title}</title>
    % if bootstrap == 'materials':
        <link href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.3.1/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/mdbootstrap/4.7.6/css/mdb.min.css" rel="stylesheet">
    % else:
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
    % endif

    <!-- Custom styles for this scaffold -->
    <!--<link href="/static/theme.css" rel="stylesheet">-->
    <!--<link rel="stylesheet" href="https://pro.fontawesome.com/releases/v5.6.3/css/all.css" integrity="sha384-LRlmVvLKVApDVGuspQFnRQJjkv0P7/YFrw84YYQtmYG4nK8c+M+NlmYDCv0rKWpG" crossorigin="anonymous">-->
    <link rel="stylesheet" href="/static/ThirdParty/Font-Awesome-Pro/css/all.min.css" crossorigin="anonymous">
    <link rel="stylesheet" href="/static/ThirdParty/bootstrap-tourist/bootstrap-tourist.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-colorpicker/3.0.0-beta.3/css/bootstrap-colorpicker.css">
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
  -ms-transform: translate(0px,-1em); /* IE 9 */
  -webkit-transform: translate(0px,-1em); /* Safari prior 9.0 */
  transform: translate(0px,-1em); /* Standard syntax */
}

.prolink-icon {
    position: relative;
	padding-left: 1.2em;
}

.prolink-icon::after{
    content: '';
    background-image: url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz48c3ZnIHZlcnNpb249IjEuMSIgaWQ9IkxheWVyXzEiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHg9IjBweCIgeT0iMHB4IiB2aWV3Qm94PSIwIDAgMTc0IDEzMCIgc3R5bGU9ImVuYWJsZS1iYWNrZ3JvdW5kOm5ldyAwIDAgMTc0IDEzMDsiIHhtbDpzcGFjZT0icHJlc2VydmUiPjxzdHlsZSB0eXBlPSJ0ZXh0L2NzcyI+LnN0MHtmaWxsOm5vbmU7c3Ryb2tlOiMwMTAxMDE7c3Ryb2tlLXdpZHRoOjIwO3N0cm9rZS1saW5lY2FwOnJvdW5kO3N0cm9rZS1taXRlcmxpbWl0OjEwO30uc3Qxe2ZpbGw6IzAxMDEwMTt9LnN0MntmaWxsOm5vbmU7c3Ryb2tlOiMwMTAxMDE7c3Ryb2tlLXdpZHRoOjQ7c3Ryb2tlLWxpbmVjYXA6cm91bmQ7c3Ryb2tlLW1pdGVybGltaXQ6MTA7fTwvc3R5bGU+PGc+PGc+PGxpbmUgY2xhc3M9InN0MCIgeDE9IjMyLjUiIHkxPSIzMi45IiB4Mj0iMTA1LjIiIHkyPSIzMi45Ii8+PGc+PHBvbHlnb24gY2xhc3M9InN0MSIgcG9pbnRzPSI5OS4zLDUyLjggMTMzLjksMzIuOSA5OS4zLDEyLjkgIi8+PC9nPjwvZz48Zz48bGluZSBjbGFzcz0ic3QwIiB4MT0iMTMzLjkiIHkxPSI3MCIgeDI9IjYxLjIiIHkyPSI3MCIvPjxnPjxwb2x5Z29uIGNsYXNzPSJzdDEiIHBvaW50cz0iNjcuMSw1MC4xIDMyLjUsNzAgNjcuMSw4OS45ICIvPjwvZz48L2c+PGc+PGxpbmUgY2xhc3M9InN0MCIgeDE9IjMyLjUiIHkxPSIxMDUuMSIgeDI9IjEwNS4yIiB5Mj0iMTA1LjEiLz48Zz48cG9seWdvbiBjbGFzcz0ic3QxIiBwb2ludHM9Ijk5LjMsMTI1LjEgMTMzLjksMTA1LjEgOTkuMyw4NS4yICIvPjwvZz48L2c+PHBhdGggY2xhc3M9InN0MiIgZD0iTTQyLjYsMjkuOWMwLDAtMzEsMC4xLTMxLDIwLjFjMCwyMC44LDMxLDIwLjEsMzEsMjAuMSIvPjxwYXRoIGNsYXNzPSJzdDIiIGQ9Ik0xMjkuMywxMDYuM2MwLDAsMjguNy0wLjEsMjguNy0xOC42YzAtMTkuMi0yOC43LTE4LjYtMjguNy0xOC42Ii8+PC9nPjwvc3ZnPg==);
	fill: currentColor;
    background-size:1em;
    position: absolute;
	padding-left: 1.2em;
    left: 0;
    top: 0;
    height: 100%;
}

.arrow-left {
    left:-30px; top: 80px; position: absolute; width: 0; z-index:1000;
    height: 0;
    border-style: solid;
    border-width: 30px 30px 30px 0;
    border-color: transparent rgba(0, 0, 0, 0.125) transparent transparent;

}

.arrow-left:after {
    display: block;
    content: "";
    position: absolute;
    left: 1px; top: -30px;
    width: 0;
    height: 0;
    border-style: solid;
    border-width: 30px 30px 30px 0;
    z-index:1000;
    border-color: transparent white transparent transparent;
}

.arrow-right {
    right:-30px; top: 80px; position: absolute; width: 0; z-index:1000;
    height: 0;
    border-style: solid;
    border-width: 30px 0px 30px 30px;
    border-color: transparent transparent transparent rgba(0, 0, 0, 0.125);

}

.arrow-right:after {
    display: block;
    content: "";
    position: absolute;
    right: 1px; top: -30px;
    width: 0;
    z-index:1000;
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

.flip-card-inner > * {backface-visibility: hidden;}

/* Style the front side (fallback if image is missing) */
.flip-card-front {
}

/* Style the back side */
.flip-card-back {
  transform: rotateX(180deg);
}




html {
    position: relative;
    min-height: 100%;
    overflow-y:scroll;
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

    background:gainsboro;
    color: darkslategrey;
    font-family: monospace;
}

.custom-file-label:after {
    color: #fff;
    background-color: #1e7e34;
    border-color: #1c7430;
    pointer: cursor;
}

.popover{
    max-width: 90vw; /* Max Width of the popover (depending on the container!) */
}

.protein {
    width:100%;
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

.confidential-ribbon{
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
  box-shadow: 0 0 3px rgba(0,0,0,.3);
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
    <div class="confidential-ribbon shadow" data-toggle="tooltip" title="This page is confidential. Namely, the URL to this page and its contents have been shared with a specific addressee as a privileged communication that is intended to be read only by the specific addressee. The latter party, unless otherwise specified, is not at liberty to disclose this page and information with a third party."><i class="far fa-user-secret"></i> Confidential</div>
%endif
<div class="position-absolute w-100 d-flex flex-column p-4" id="toaster">
</div>

<main role='main' class="container-fluid p-0 w-100 mx-0">
    ${ next.body() }
</main>

<footer class="footer">
      <div class="container-fluid">
          <div class="row" style="line-height: 1rem;">
              <div class="col-5 offset-lg-1 text-muted p-3">
                  <small><a href="https://www.schrodinger.com/" target="_blank">PyMOL <i class="far fa-external-link-square"></i></a> is a trademark of <a href="https://pymol.org/2/" target="_blank">Schr&ouml;dinger , LLC <i class="far fa-external-link-square"></i></a>. The authors are not affiliated or involved with PyMOL or Schr&ouml;dinger.
                      <br/>Data is not kept for commercial, see data <a href="docs/users">policy documentation</a>.</small></div>
              <div class="col-5 offset-lg-1 p-2">
                  <img src="/static/ox_full.svg" alt="University of Oxford" class="footer-logo" onclick="window.location.href = 'http://www.ox.ac.uk/';">&nbsp;&nbsp;&nbsp;
                  <img src="/static/OxfordBRC-logo-2019.png" alt="BRC"   class="footer-logo" onclick="window.location.href = 'https://oxfordbrc.nihr.ac.uk/';">&nbsp;&nbsp;&nbsp;
                  <img src="/static/SGC_reverse_trans.png" alt="SGC"   class="footer-logo" onclick="window.location.href = 'https://www.sgc.ox.ac.uk/';">
              </div>
          </div>

      </div>
    </footer>


<!-- Bootstrap core JavaScript
================================================== -->
<!-- Placed at the end of the document so the pages load faster -->
<script src="https://code.jquery.com/jquery-3.3.1.min.js" integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8=" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
% if bootstrap == 'materials':
    <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mdbootstrap/4.7.6/js/mdb.min.js"></script>
% endif
<script src="https://unpkg.com/ngl@2.0.0-dev.34/dist/ngl.js" type="text/javascript"></script>
% if not remote:
    <script type="text/javascript" src="/static/michelanglo.js"></script>
    <script type="text/javascript" src="/static/michelanglo_menu.js"></script>
% else:
    <script type="text/javascript" src="https://michelanglo.sgc.ox.ac.uk/michelanglo.js"></script>
    <script type="text/javascript" src="https://michelanglo.sgc.ox.ac.uk/michelanglo_menu.js"></script>
% endif
<script src="https://cdnjs.cloudflare.com/ajax/libs/clipboard.js/2.0.0/clipboard.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-colorpicker/3.0.0-beta.3/js/bootstrap-colorpicker.min.js"></script>

<script src="/static/ThirdParty/bootstrap-tourist/bootstrap-tourist.js"></script>
<%block name="script"/>
% if not no_user:
    <%include file="../login/user_modal.mako"/>
% endif

<script type="text/javascript">
    $('[data-toggle="popover"]').popover();
    $('[data-toggle="tooltip"]').tooltip();
    $('#menu').on('shown.bs.popover', function () {
        $('.popover a').hover(function () {$('.popover-header').html($(this).attr('title'))});
    });
% if not no_user:
    <%include file="../login/user_icon_bar.js"/>
    <%include file="../login/user_modal.js"/>
    <%include file="toast.js"/>
    %if not user: ## unregistered and new visitor.
        if (! localStorage.getItem('cookiesAccepted')) {
            $('#toaster').append(`<%include file="toast.mako" args="toast_id='acceptCookies', toast_title='Cookies', toast_body='This site uses cookies to manage user authentication in order to allow users to keep track of pages users made and to control editing privileges.', toast_bg='bg-info', toast_autohide='false'"/>`);
            $('#acceptCookies').toast('show');
            $('#acceptCookies').on('hide.bs.toast',(event) => localStorage.setItem('cookiesAccepted',true));
        }
    %endif
    ${custom_messages|n}.forEach((v, i) => ops.addToast('custom_msg'+i, v.title, v.descr, v.bg));

$('#chat_send').click((event) => {
                    let msg = $('#chat_message').val();
                    $('#chat_modal').modal('hide');
                    if (msg) {$.ajax({url: "/msg",
                                data: {'text': msg,
                                       'page': window.location.pathname,
                                        'event': 'chat'
                                      },
                                method: 'POST'
                            })
                        .done((msg) => ops.addToast('userchatgood','Send','Thank you! The site admin will get back to you shortly.', 'bg-success'))
                        .fail(ops.addErrorToast)}
                    else {ops.addToast('emptymessage','Empty message','Ehhr. Somehow the message is empty.', 'bg-warning')}
                }) //click.

% endif
    $(document).on('show.bs.modal', '.modal', function () {
    var zIndex = 1040 + (10 * $('.modal:visible').length);
    $(this).css('z-index', zIndex);
    setTimeout(function() {
        $('.modal-backdrop').not('.modal-stack').css('z-index', zIndex - 1).addClass('modal-stack');
    }, 0);
});

    window.onerror = (msg, url, lineNo, columnNo, error) => ops.addToast('JSerror',
                                                                         'DEBUG: JS Error', [
                                                                                              'Message: ' + msg,
                                                                                              'URL: ' + url,
                                                                                              'Line: ' + lineNo,
                                                                                              'Column: ' + columnNo,
                                                                                              'Error object: ' + JSON.stringify(error)
                                                                                            ].join(' - '),
                                                                         'bg-danger')

</script>

% if not no_analytics:
<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=UA-66652240-5"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'UA-66652240-5');
</script>
% endif


</body>
</html>
