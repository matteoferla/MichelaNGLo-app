<!DOCTYPE html>
<html lang="{{ '${request.locale_name}' }}">
<%
    bootstrap='regular' # regular|materials
%>

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="PyMOL-NGL transpiler application">
    <meta name="author" content="Matteo Ferla">
    <link rel="shortcut icon" href="${request.static_url('pymol_ngl_transpiler_app:static/mashup.png')}">

    <title>PyMOL-NGL transpiler</title>
    % if bootstrap == 'materials':
        <link href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.1.3/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/mdbootstrap/4.6.1/css/mdb.min.css" rel="stylesheet">
    % else:
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css" integrity="sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO" crossorigin="anonymous">
    % endif

    <!-- Custom styles for this scaffold -->
    <link href="${request.static_url('pymol_ngl_transpiler_app:static/theme.css')}" rel="stylesheet">
    <link rel="stylesheet" href="https://pro.fontawesome.com/releases/v5.6.3/css/all.css" integrity="sha384-LRlmVvLKVApDVGuspQFnRQJjkv0P7/YFrw84YYQtmYG4nK8c+M+NlmYDCv0rKWpG" crossorigin="anonymous">
    <!--<link rel="stylesheet" href="http://www.matteoferla.com/Font-Awesome-Pro/css/all.min.css" crossorigin="anonymous">-->
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

html {
    position: relative;
    min-height: 100%;
    overflow-y:scroll;
}
body {
  /* Margin bottom by footer height */
    margin-bottom: 60px;
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

    </style>

    <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="//oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
      <script src="//oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
    <![endif]-->
</head>
<body>

<br/>
<br/>
<br/>
<br/>

<main role='main' class="container-fluid">
    <div class="row">
        <div class="col-lg-8 offset-lg-2">
            ${ next.body() }
        </div>
    </div>
</main>

<footer class="footer">
      <div class="container">
        <span class="text-muted">PyMOL(TM) is a trademark of Schrodinger, LLC.</span>
      </div>
    </footer>


<!-- Bootstrap core JavaScript
================================================== -->
<!-- Placed at the end of the document so the pages load faster -->
<script src="https://code.jquery.com/jquery-3.3.1.min.js" integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8=" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js" integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js" integrity="sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy" crossorigin="anonymous"></script>
% if bootstrap == 'materials':
    <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mdbootstrap/4.6.1/js/mdb.min.js"></script>
% endif
<script src="https://cdn.rawgit.com/arose/ngl/v0.10.4-1/dist/ngl.js" type="text/javascript"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/clipboard.js/2.0.0/clipboard.min.js"></script>
<%block name="script"/>
</body>
</html>
