function loadfun (protein) {
    var stage=NGL.getStage('${viewport}'); //alter if not using multiLoader.

    //define colors
    var nonCmap = ${structure.elemental_mapping};
    var sermap=${structure.serial_mapping};
    var chainmap=${structure.catenary_mapping};
    var resmap=${structure.residual_mapping};
    var schemeId = NGL.ColormakerRegistry.addScheme(function (params) {
        this.atomColor = function (atom) {
            chainid=atom.chainid;
            if (! isNaN(parseFloat(chainid))) {chainid=atom.chainname} // hack for chainid/chainIndex/chainname issue if the structure is loaded from string.
            if (atom.serial in sermap)  {return +sermap[atom.serial]}
            else if (atom.element in nonCmap) {return +nonCmap[atom.element]}
            else if (atom.element in nonCmap) {return +nonCmap[atom.element]}
            else if (chainid+atom.resno in resmap) {return +resmap[chainid+atom.resno]}
            else if (chainid in chainmap) {return +chainmap[chainid]}
            else {return 0x7b7d7d} //black as the darkest error!
        };
    });

    //representations
    <%
        if structure.colors:
            color_str='color: schemeId,'
        else:
            color_str =''
    %>
    protein.removeAllRepresentations();
    % if structure.lines:
        var lines = new NGL.Selection( "${' or '.join(structure.lines)}" );
        myData.lineRepresentation = protein.addRepresentation( "line", {${color_str} sele: lines.string} );
    % endif
    % if structure.sticks:
        var sticks = new NGL.Selection( "${' or '.join(structure.sticks)}" );
        % if stick == 'sym_licorice':
        protein.addRepresentation( "licorice", {${color_str} sele: sticks.string, multipleBond: "symmetric"} );
        % elif stick == 'licorice':
        protein.addRepresentation( "licorice", {${color_str}  sele: sticks.string} );
        % elif stick == 'hyperball':
        protein.addRepresentation( "hyperball", {${color_str}  sele: sticks.string} );
        % elif stick == 'ball':
        protein.addRepresentation( "ball+stick", {${color_str}  sele: sticks.string, multipleBond: "symmetric"} );
        % endif
    % endif
    % if structure.cartoon:
    var cartoon = new NGL.Selection( "${' or '.join(structure.cartoon)}" );
    protein.addRepresentation( "cartoon", {${color_str}  sele: cartoon.string, smoothSheet: true} );
    % endif
    % if structure.surface:
    var surf = new NGL.Selection( "${' or '.join(structure.surface)}" );
    protein.addRepresentation( "surface", {${color_str} sele: surf.string} );
    % endif

    //orient
    stage.viewerControls.orient((new NGL.Matrix4).fromArray(${structure.m4.reshape(16, ).tolist()}));
}
