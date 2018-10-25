# PyMOL-to-NGL-transpiler
A script to transpile a PyMOL PSE file to a NGL.js view.

*Status*: unfinished, but core functionality present.

## Parts to convert
Three parts are needed to convert a `.pse` file into a NGL view.
* the model
* orientation
* representation
    * lines, sticks, cartoon etc.
    * colors
    * surface (handled differently in NGL)

Additionally, there are
* text/labels which are normally added in photoshop by people...
* arrows, which are great, but in PyMol are from the add-on script `cgo_arrows` and not part of the native code

## Script functionality
The script `PyMOL_to_NGL.py` has the class `PyMolTranspiler`, which can be initialised thusly:

    >>> trans = PyMolTranspiler(view=get_view_output_as_string, reps=interate_output_as_string, pdb=file_of_saved_pdb)
    >>> trans.to_html_line()

        <!-- **inserted code**  -->
        <script src="https://cdn.rawgit.com/arose/ngl/v0.10.4-1/dist/ngl.js" type="text/javascript"></script>
        <script type="text/javascript">
                    var stage = new NGL.Stage( "viewport",{backgroundColor: "white"});
                    stage.loadFile( "rcsb://1UBQ").then(function (protein) {
                        window.protein=protein;
                        var m4 = (new NGL.Matrix4).fromArray([0.7028832919662867, -15.555627368224188, -42.22285806091866, 0.0, 44.899153041969875, 3.027791553007612, -0.36819969318162726, 0.0, 2.968061030936039, -42.12016318698766, 15.567270234463177, 0.0, -26.235111237, -28.054784775, -3.878722429, 1.0]);
                        stage.viewerControls.orient(m4);
                        protein.removeAllRepresentations();
                        var sticks = new NGL.Selection( "1.N or 1.CA or 1.C or 1.O or 1.CB or 1.CG or 1.SD or 1.CE or 30.N or 30.CA or 30.C or 30.O or 30.CB or 30.CG1 or 30.CG2 or 30.CD1" );
                        protein.addRepresentation( "licorice", { sele: sticks.string} );
                        var cartoon = new NGL.Selection( "14 or 15 or 19 or 1 or 13 or 16 or 11 or 17 or 12 or 20 or 18 or 10 or 2" );
                        protein.addRepresentation( "cartoon", { sele: cartoon.string} );
                        stage.viewerControls.orient(m4);
                    });
        </script>
        <!-- **end of code** -->
        
The source of the NGL code can be changed:

    >>> trans.to_html_line(ngl='ngl.js')
    
## To do
* Add color and surface.
* Maybe arrows and labels.
* Automate the retrieval of PyMOL data: currently text output is parsed. But a wrapper for the application or using the pymol library would be best.
* Make a server.

## Notes on PSE side
A Pse is encoded, so there is no way to read it except with Pymol. But Pymol can reveal it's secrets.
### Orientation
I was driven spare with converting the orientation. It simply was a question of inverting the sign on the $\vec{x}$ and $\vec{z}$ of the rotational matrix, multiplying it by the absolute of the scale and adding the origin of rotation's position with inverted sign.
For more see [my notes on the conversion of the view](notes_on_view_conversion.md)

### Representation
The atom information is kept in `reps`. Say `PyMOL>iterate 1UBQ, print resi, resn,name,ID,reps`.
This is an integer with no information give. However, looking at how it behaves it is clear it is a binary number where each position controls lines, sticks, cartoon and surface.
0. Sticks
1. Spheres
2. Surface
3. Label (needs additional variable)
4. Non-bounded spheres
5. Cartoon
    * putty is a special cartoon rapresentation: `iterate sele, resi,name,reps,cartoon`
6. Ribbon
7. Lines
8. Mesh
9. Dots
11. Non-bounded &mdash;Ligand (HETATM) properties are otherwise the same
12. Cell
