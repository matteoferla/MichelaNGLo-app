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

${code}

<script type="text/javascript">
    function saveImg() {
        stage.makeImage( {
      trim: true,
      antialias: true,
      transparent: false }).then(function (img) {window.img=img; NGL.download(img);});
    }
</script>
</body>
</html>
