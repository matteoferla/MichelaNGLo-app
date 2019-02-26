<li class="list-group-item" id="results">
% for i, obj in enumerate(mesh):

    <h3>${obj['o_name']}</h3>
        <pre class="p-2"><div class="float-right"><a href="#snippet${i}" data-clipboard-target="#snippet" id="copy_snippet${i}">Copy</a></div><code id="snippet${i}">${obj['triangles']}</code>
                </pre>
        <div id="viewport${i}" style="width:100%; height: 0; padding-bottom: 100%;"></div>
% endfor
</li>

<script type="text/javascript">
    window.stages =[];
    NGL.setDebug(true);
    % for i, obj in enumerate(mesh):
        refmesh=${obj['triangles']};
        stage =new NGL.Stage( "viewport${i}",{backgroundColor: "white"})
        window.stages.push(stage);
        window.addEventListener( "resize", function( event ){stage.handleResize();}, false );
        var shape = new NGL.Shape("shape");
        var meshBuffer = new NGL.MeshBuffer( {
            position: new Float32Array(refmesh),
            color: new Float32Array(Array(refmesh.length).fill(1).map(function (v,i) {return i % 3 ? 0 : 1}))});
        shape.addBuffer(meshBuffer);
        var shapeComp = stage.addComponentFromObject(shape);
        shapeComp.addRepresentation("buffer");
        shapeComp.autoView();
    % endfor

</script>
