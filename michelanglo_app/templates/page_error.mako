<%namespace file="layout_components/labels.mako" name="info"/>
<%inherit file="layout_components/layout_w_card.mako"/>

<%block name="buttons">
            <%include file="layout_components/horizontal_menu_buttons.mako" args='tour=False'/>
</%block>

<%block name="title">
            &mdash; ${self.attr.status_code} Error
</%block>

<%block name="subtitle">
            ${self.attr.status_msg}
</%block>

<%block name="body">
    ${self.attr.details|n}
    <div id="viewport" class="protein"></div>
</%block>

<%block name="script">
    <script type="text/javascript">
        NGL.specialOps.showTitle('viewport','<i class="far fa-dna fa-spin"></i> Loading...');
        window.stage = new NGL.Stage( "viewport",{backgroundColor: "white"});
        window.addEventListener( "resize", function( event ){stage.handleResize();}, false );
        stage.loadFile('rcsb://1ubq', {defaultRepresentation: true}).then(function (o) {
            stage.viewerControls.orient([-0.11828705773702654, -51.950191136265374, -13.209589158393797, 0, -42.97436794091654, 7.987455134594463, -31.02795283623524, 0, 32.03933995741459, 10.521777322982274, -41.66656325778385, 0, -32.41213789938769, -32.69523294873327, -12.418570248106695, 1]);
        });

        var shape = new NGL.Shape("shape");
        $.getJSON('/static/fly.json').done( function (fly) {
                var meshBuffer = new NGL.MeshBuffer( {
                position: new Float32Array(fly),
                color: new Float32Array(Array(fly.length).fill(0.8))});
                shape.addBuffer(meshBuffer);
                var shapeComp = stage.addComponentFromObject(shape);
                shapeComp.addRepresentation("buffer");
                }).fail(function( jqxhr, textStatus, error ) {
                var err = textStatus + ", " + error;
                console.log( "Request Failed: " + err );
            });
    </script>
</%block>
