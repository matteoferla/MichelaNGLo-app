<%inherit file="../layout_components/layout_w_card.mako"/>

<%block name="buttons">
            <%include file="../layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>

<%block name="title">
            &mdash; Image to NGL
</%block>

<%block name="subtitle">
            Construction of a pretty picture that turns into a NGL view
</%block>


    <%include file="docs_nav.mako"/>


<div class='row'>
            <div class='col-12 col-sm-6'>
                <h3>Reason</h3>
                <p>The logic is simple: images get made in PyMol and then heavily photoshopped or powerpoint-shopped and there is no way to have that level of annotation without making the editor become a god of PyMol or NGL. In fact, arrows are not a default feature in PyMOL and few know how to use them. This way, the editor gets both the simplicity of making powerpoint annotated PDB images and allows the users to play with their protein.</p>

                <h3>Notes</h3>
                <ul>
                    <li>make sure that the image is added with only a <code>&lt;img src="&hellip;" &hellip;&gt;</code> tag, without a wrapping anchor element or positioning div as happens in the WordPress editor</li>
                    <li>The viewer will have the same dimensions as the image &mdash;the example has <code>width='100%'</code> attribute to rescale the image to occupy the available space to it.</li>
                    <li>The user needs to know that it can be clicked adding the attribute <code>style='cursor: pointer'</code>, will change the cursor to a <span style='cursor: pointer; text-decoration-style: dotted;'>pointer</span></li>
                    <li>The viewport div can be activated without JS by using the <code>role='NGL'</code> attribute or by using the multiLoader (see <a href="/docs/markup">markup</a>). Example of the former is <code>&lt;div role="NGL" data-load="1gfl" data-view="[3.14, &hellip]"&gt;&lt;img src="gfp.jpg" width="100%" style="cursor: pointer"&gt;&lt;div&gt;</code> </li>
                </ul>
                </div>
            <div class='col-12 col-sm-6'>
                <p>This is an image that was annotated. Clicking will switch it to NGL.</p>
                <div id="viewport"><img src="/static/gfp.jpg" alt="LZTR1" width='100%' style='cursor: pointer'> </div>
		</div>
</div>

<%block name="script">

    <script type="text/javascript" src="/static/michelanglo.js"></script>
    <script type="text/javascript">
        function myView (protein) {
            var nonCmap = {"N": "0x3333ff", "O": "0xff4c4c", "H": "0xe5e5e5", "S": "0xe5c53f"};
            var sermap={};
            var chainmap={'A': '0x33ff33'};
            var resmap={'A65': '0x00ffff', 'A66': '0x00ffff', 'A67': '0x00ffff'};
            var schemeId = NGL.ColormakerRegistry.addScheme(function (params) {
                this.atomColor = function (atom) {
                    if (atom.serial in sermap)  {return +sermap[atom.serial]}
                    else if (atom.element in nonCmap) {return +nonCmap[atom.element]}
                    else if (atom.chainid+atom.resno in resmap) {return +resmap[atom.chainid+atom.resno]}
                    else if (atom.chainid in chainmap) {return +chainmap[atom.chainid]}
                    else {return 0x000000} //black as the darkest error!
                };
            });

            protein.removeAllRepresentations();
            var sticks = new NGL.Selection( ":A and (42.N or 42.CA or 42.C or 42.O or 42.CB or 42.CG or 42.CD1 or 42.CD2 or 42.H05 or 61.N or 61.CA or 61.C or 61.O or 61.CB or 61.CG1 or 61.CG2 or 61.H01 or 62.N or 62.CA or 62.C or 62.O or 62.CB or 62.CG2 or 62.OG1 or 62.H01 or 62.H02 or 63.N or 63.CA or 63.C or 63.O or 63.CB or 63.CG2 or 63.OG1 or 63.H01 or 63.H03 or 64.N or 64.CA or 64.C or 64.O or 64.CB or 64.CG or 64.CD1 or 64.CD2 or 64.CE1 or 64.CE2 or 64.CZ or 64.H02 or 65.N or 65.CA or 65.C or 65.CB or 65.OG or 65.H01 or 65.H02 or 66.N or 66.CA or 66.C or 66.O or 66.CB or 66.CG or 66.CD1 or 66.CD2 or 66.CE1 or 66.CE2 or 66.CZ or 66.OH or 66.H03 or 67.N or 67.CA or 67.C or 67.O or 68.N or 68.CA or 68.C or 68.O or 68.CB or 68.CG1 or 68.CG2 or 68.H01 or 69.N or 69.CA or 69.C or 69.O or 69.CB or 69.CG or 69.CD or 69.NE2 or 69.OE1 or 69.H01 or 69.H02 or 69.H03 or 94.N or 94.CA or 94.C or 94.O or 94.CB or 94.CG or 94.CD or 94.NE2 or 94.OE1 or 94.H01 or 94.H02 or 94.H03 or 96.N or 96.CA or 96.C or 96.O or 96.CB or 96.CG or 96.CD or 96.NE or 96.CZ or 96.NH1 or 96.NH2 or 96.H01 or 96.H02 or 96.H03 or 96.H04 or 96.H05 or 96.H06 or 145.N or 145.CA or 145.C or 145.O or 145.CB or 145.CG or 145.CD1 or 145.CD2 or 145.CE1 or 145.CE2 or 145.CZ or 145.OH or 145.H01 or 145.H03 or 148.N or 148.CA or 148.C or 148.O or 148.CB or 148.CG or 148.CD2 or 148.ND1 or 148.CE1 or 148.NE2 or 148.H01 or 148.H02 or 150.N or 150.CA or 150.C or 150.O or 150.CB or 150.CG1 or 150.CG2 or 150.H04 or 165.N or 165.CA or 165.C or 165.O or 165.CB or 165.CG or 165.CD1 or 165.CD2 or 165.CE1 or 165.CE2 or 165.CZ or 165.H04 or 167.N or 167.CA or 167.C or 167.O or 167.CB or 167.CG1 or 167.CG2 or 167.CD1 or 167.H05 or 203.N or 203.CA or 203.C or 203.O or 203.CB or 203.CG2 or 203.OG1 or 203.H01 or 203.H03 or 205.N or 205.CA or 205.C or 205.O or 205.CB or 205.OG or 205.H01 or 205.H04 or 220.N or 220.CA or 220.C or 220.O or 220.CB or 220.CG or 220.CD1 or 220.CD2 or 220.H01 or 222.N or 222.CA or 222.C or 222.O or 222.CB or 222.CG or 222.CD or 222.OE1 or 222.OE2 or 222.H01)" );
            protein.addRepresentation( "licorice", {color: schemeId, sele: sticks.string} );
            var cartoon = new NGL.Selection( ":A and (213 or 30 or 25 or 215 or 56 or 150 or 64 or 220 or 41 or 27 or 73 or 151 or 164 or 3 or 78 or 104 or 115 or 152 or 156 or 225 or 10 or 14 or 195 or 142 or 148 or 92 or 113 or 121 or 52 or 208 or 154 or 153 or 119 or 127 or 216 or 166 or 97 or 171 or 1 or 62 or 9 or 162 or 197 or 186 or 203 or 86 or 129 or 100 or 160 or 227 or 95 or 49 or 138 or 179 or 189 or 228 or 101 or 82 or 181 or 161 or 31 or 29 or 33 or 74 or 111 or 107 or 219 or 81 or 172 or 11 or 46 or 48 or 147 or 72 or 218 or 40 or 212 or 112 or 12 or 183 or 170 or 37 or 89 or 126 or 180 or 43 or 206 or 85 or 83 or 80 or 198 or 15 or 96 or 149 or 135 or 133 or 199 or 187 or 200 or 108 or 42 or 117 or 13 or 34 or 123 or 182 or 175 or 45 or 2 or 4 or 6 or 51 or 118 or 224 or 158 or 99 or 54 or 190 or 55 or 209 or 217 or 71 or 157 or 38 or 69 or 134 or 8 or 136 or 221 or 214 or 211 or 67 or 178 or 87 or 22 or 120 or 114 or 88 or 167 or 196 or 192 or 57 or 137 or 28 or 155 or 184 or 50 or 124 or 139 or 20 or 125 or 165 or 207 or 70 or 141 or 176 or 5 or 36 or 194 or 204 or 226 or 173 or 168 or 90 or 159 or 230 or 79 or 17 or 210 or 47 or 93 or 59 or 163 or 19 or 53 or 63 or 23 or 68 or 109 or 202 or 16 or 26 or 103 or 7 or 145 or 91 or 77 or 185 or 35 or 61 or 76 or 58 or 174 or 18 or 177 or 144 or 116 or 222 or 65 or 84 or 229 or 44 or 131 or 143 or 105 or 32 or 39 or 191 or 130 or 223 or 193 or 146 or 66 or 75 or 169 or 98 or 24 or 60 or 102 or 140 or 110 or 128 or 132 or 205 or 188 or 201 or 21 or 94 or 106 or 122)" );
            protein.addRepresentation( "cartoon", {color: schemeId, sele: cartoon.string} );

            var m4 = (new NGL.Matrix4).fromArray([-3.2057894279448815, -9.687703427955855, 8.764985244560128, 0.0, -0.8849437595937726, 9.165351141765429, 9.806529121864603, 0.0, -13.03434654791343, 1.7603573567195399, -2.821514810409626, 0.0, -8.704995155, -70.141929626, 6.034498692, 1.0]);
            NGL.stageIds.viewport.animationControls.orient(m4, 1000);
        }

        NGL.specialOps.multiLoader('viewport', [{type: 'rcsb', value: '1gfl', loadFx: myView}])

    </script>

</%block>
