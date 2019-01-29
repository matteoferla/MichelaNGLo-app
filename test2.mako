<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Example</title>
    <style>
        pre code {
          background-color: #eee;
          border: 1px solid #999;
          display: block;
          padding: 20px;
        }
    </style>
</head>
<body style="background-color: #eeeeee">
<h1>Check out my protein</h1>
<p>This is from a PyMOL view. <button onClick="javascript:saveImg()">Save</button></p>

<div style="max-width: 800px;"><div id="viewport" style="width:100%; height: 0; padding-bottom: 100%;"></div></div>


<script src="https://code.jquery.com/jquery-3.3.1.min.js" integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8=" crossorigin="anonymous"></script>
<script src="https://cdn.rawgit.com/arose/ngl/v0.10.4-1/dist/ngl.js" type="text/javascript"></script>

${code}



</body>
</html>
