<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
    <style>
        pre code {
          background-color: #eee;
          border: 1px solid #999;
          display: block;
          padding: 20px;
        }
    </style>
</head>
<body>
<div id="viewport" style="width:100%; height: 0; padding-bottom: 100%;"></div>
<pre><code>
Code to copy:
    reset_angle();
    reset_origin();
    reset_scale();

    m4=stage.viewerControls.getOrientation()
        var tmpP=new THREE.Vector3, tmpQ=new THREE.Quaternion, tmpS=new THREE.Vector3;
        m4.decompose(tmpP, tmpQ, tmpS)
    tmpP
    tmpQ
    tmpS

    stage.makeImage( {
      trim: true,
      antialias: true,
      transparent: false }).then(function (img) {window.img=img; saveAs(img, {type:'mime'},'snapshot.png');});

</code></pre>
<div>${transpiler.notes}</div>
<script src="ngl.js" type="text/javascript"></script>
<script src="three.js" type="text/javascript"></script>
<script src="FileSaver.min.js" type="text/javascript"></script>

<script type="text/javascript">
    var stage = new NGL.Stage( "viewport",{backgroundColor: "white"});
    //variables from python
    var position = (new THREE.Vector3).fromArray(${transpiler.position.tolist()});
    var teleposition =(new THREE.Vector3).fromArray(${transpiler.teleposition.tolist()});
    var antiteleposition = (new THREE.Vector3).fromArray([-teleposition.x,-teleposition.y,-teleposition.z]);
    var antiposition = (new THREE.Vector3).fromArray([-position.x,-position.y,-position.z]);
    var scale = (new THREE.Vector3).fromArray([0,0,${transpiler.z}]);
    var rotation = (new THREE.Matrix3).fromArray(${transpiler.rotation.reshape(9,).tolist()});
    var m4 = (new THREE.Matrix4).fromArray(${transpiler.m4.reshape(16,).tolist()});
    
    % if transpiler.validation:
        //axes
        var shape = new NGL.Shape( "shape" );
        //addArrow(position1: Vector3 | Array, position2: Vector3 | Array, color: Color | Array, radius: Float, name: String)
        shape.addArrow(position1=[0,0,0],position2=[50,0,0],color=[1, 0, 0],radius=1,name='redX');
        shape.addArrow(position1=[-50,0,0],position2=[0,0,0],color=[0.5, 0, 0],radius=1,name='NegRedX');
        shape.addArrow(position1=[0,0,0],position2=[0,50,0],color=[0, 1, 0],radius=1,name='greenY');
        shape.addArrow(position1=[0,-50,0],position2=[0,0,0],color=[0, 0.5, 0],radius=1,name='NegGreenY');
        shape.addArrow(position1=[0,0,0],position2=[0,0,50],color=[0, 0, 1],radius=1,name='blueZ');
        shape.addArrow(position1=[0,0,-50],position2=[0,0,0],color=[0, 0, 0.5],radius=1,name='NegBlueZ');
        var shapeComp=stage.addComponentFromObject( shape );
        shapeComp.addRepresentation( "buffer" );

        //camera vector
        var shape2 = new NGL.Shape( "shape" );
        shape2.addArrow(position1=teleposition,position2=position,color=[0,0,0],radius=1,name='camera');
        var shapeComp2 =stage.addComponentFromObject(shape2);
        shapeComp2.addRepresentation( "buffer" );
    % endif


    function reset_angle(unQ) {
        unQ = unQ || new THREE.Quaternion;
        m4=stage.viewerControls.getOrientation();
        var tmpP=new THREE.Vector3, tmpQ=new THREE.Quaternion, tmpS=new THREE.Vector3;
        m4.decompose(tmpP, tmpQ, tmpS);
        stage.viewerControls.orient(m4.compose(tmpP,unQ,tmpS))
    }

    function reset_origin(unP) {
        unP = unP || new THREE.Vector3;
        m4=stage.viewerControls.getOrientation();
        var tmpP=new THREE.Vector3, tmpQ=new THREE.Quaternion, tmpS=new THREE.Vector3;
        m4.decompose(tmpP, tmpQ, tmpS);
        stage.viewerControls.orient(m4.compose(unP,tmpQ,tmpS))
    }

    function reset_scale(unS) {
        unS = unS || (new THREE.Vector3).fromArray([20,20,20]);
        if (! unS.isVector3) {
            unS = (new THREE.Vector3).fromArray([unS,unS,unS]);
        }
        m4=stage.viewerControls.getOrientation();
        var tmpP=new THREE.Vector3, tmpQ=new THREE.Quaternion, tmpS=new THREE.Vector3;
        m4.decompose(tmpP, tmpQ, tmpS);
        stage.viewerControls.orient(m4.compose(tmpP,tmpQ,unS))
    }

    var file = 'rcsb://';
    % if len(transpiler.pdb) == 4:
        file+='${transpiler.pdb}';
    % else:
        file='${transpiler.pdb}';
    % endif
    stage.loadFile( file, { defaultRepresentation: true } ).then(function (o) {
        stage.viewerControls.orient(m4);
    });
</script>
</body>
</html>
