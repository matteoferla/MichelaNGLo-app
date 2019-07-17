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

    ### REP 0 stick > licorice
    % if structure.sticks:
        let sticks = new NGL.Selection( "${' or '.join(structure.sticks)}" );
        % if stick_format == 'sym_licorice':
        protein.addRepresentation( "licorice", {${color_str} sele: sticks.string, multipleBond: "symmetric", opacity: ${1-structure.stick_transparency} } );
        % elif stick_format == 'licorice':
        protein.addRepresentation( "licorice", {${color_str}  sele: sticks.string, opacity: ${1-structure.stick_transparency}} );
        % elif stick_format == 'hyperball':
        protein.addRepresentation( "hyperball", {${color_str}  sele: sticks.string, opacity: ${1-structure.stick_transparency}} );
        % elif stick_format == 'ball':
        protein.addRepresentation( "ball+stick", {${color_str}  sele: sticks.string, multipleBond: "symmetric", opacity: ${1-structure.stick_transparency}} );
        % endif
    % endif

    ### REP 1 self.spheres > spacefill
    % if structure.spheres:
        let spacefill = new NGL.Selection( "${' or '.join(structure.spheres)}" );
        protein.addRepresentation( "spacefill", {${color_str} sele: spacefill.string, opacity: ${1-structure.sphere_transparency}} );
    % endif

    ### REP 2 self.surface > surface
    % if structure.surface:
        let surf = new NGL.Selection( "${' or '.join(structure.surface)}" );
        protein.addRepresentation( "surface", {${color_str} sele: surf.string, opacity: ${1-structure.surface_transparency}} );
    % endif

    ### REP 3 self.label > label
    % if structure.label:
        %for sele in structure.label:
            protein.addRepresentation("label",{labelType: "text", labelText: ["${structure.label[sele]}"], sele: "${sele}" });
        %endfor
    % endif

    ### REP 5 self.cartoon > cartoon
    % if structure.cartoon:
        let cartoon = new NGL.Selection( "${' or '.join(structure.cartoon)}" );
        myData.current_cartoonScheme = protein.addRepresentation( "cartoon", {${color_str}  sele: cartoon.string, smoothSheet: true, opacity: ${1-structure.cartoon_transparency}} );
    % endif

    ### REP 6 self.ribbon > backbone
    % if structure.ribbon:
        let backbone = new NGL.Selection( "${' or '.join(structure.ribbon)}" );
        protein.addRepresentation( "backbone", {${color_str} sele: backbone.string, opacity: ${1-structure.ribbon_transparency}} );
    % endif

    ### REP 7 self.lines > line
    % if structure.lines:
        let line = new NGL.Selection( "${' or '.join(structure.lines)}" );
        protein.addRepresentation( "line", {${color_str} sele: line.string} );
    % endif

    ### REP 8 self.mesh > surface
    % if structure.mesh:
        let mesh = new NGL.Selection( "${' or '.join(structure.mesh)}" );
        protein.addRepresentation( "surface", {${color_str} sele: mesh.string, contour: true} );
    % endif

    ### REP 9 self.dots > point
    % if structure.dots:
        let point = new NGL.Selection( "${' or '.join(structure.dots)}" );
        protein.addRepresentation( "point", {${color_str} sele: point.string} );
    % endif

    ### REP 11 self.cell > cell
    % if structure.cell and 1==0:
        let cell = new NGL.Selection( "${' or '.join(structure.cell)}" );
        protein.addRepresentation( "cell", {${color_str} sele: cell.string} );
    % endif

    ### REP 12 self.putty > tube
    % if structure.putty:
    let putty = new NGL.Selection( "${' or '.join(structure.putty)}" );
    protein.addRepresentation( "tube", {${color_str}  sele: putty.string, radiusType: "bfactor", radiusScale: 0.05,} );
    % endif

    ### distances
    %if structure.distances:
        %for d in structure.distances:
    protein.addRepresentation( "distance", { atomPair: [
                %for p in d['pairs']:
    ["${p['atom_A'].resi}:${p['atom_A'].chain}.${p['atom_A'].name}","${p['atom_B'].resi}:${p['atom_B'].chain}.${p['atom_B'].name}"],
                %endfor
    ], colorValue: ${structure.swatch[d['color']].hex} } );
        %endfor
    %endif

    ### triang
    %if structure.custom_mesh:
        let shape = new NGL.Shape("shape");
        %for meshgroup in structure.custom_mesh:
            let refmesh=${meshgroup['triangles']};
            let meshBuffer = new NGL.MeshBuffer( {
                position: new Float32Array(refmesh),
                color: new Float32Array(Array(refmesh.length).fill(1).map(function (v,i) {return i % 3 ? 0 : 1}))});
            shape.addBuffer(meshBuffer);
        %endfor
        stage.addComponentFromObject(shape).addRepresentation("buffer");
    %endif

    //orient
    stage.viewerControls.orient((new NGL.Matrix4).fromArray(${structure.m4.reshape(16, ).tolist()}));
    stage.setParameters({ cameraFov: ${structure.fov}, fogNear: ${structure.fog}}); //clipFar: ${structure.slab_far}, clipNear: ${structure.slab_near}
}
