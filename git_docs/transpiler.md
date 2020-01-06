## Script functionality

**THE TRANSPILER FUNCTIONALITY NOW RESIDES IN [https://github.com/matteoferla/MichelaNGLo-transpiler](MichelaNGLo-transpiler).**


The script `PyMOL_to_NGL.py` has the class `PyMolTranspiler`. Which accepts different starting values.
If Pymol is installed on the system and the system is not a Windows machine, the filename of the PSE is passed and processed.

which can be initialised thusly:

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
        
The The class initialises as a blank object with default settings unless the `file` (filename of PSE file) or `view` and/or `reps` is passed.
For views see `.convert_view(view_string)`, which processes the output of PyMOL command `set_view`
For representation see `.convert_reps(reps_string)`, which process the output of PyMOL command `iterate 1UBQ, print resi, resn,name,ID,reps`
    
The source of the NGL code can be changed:

    >>> trans.to_html_line(ngl='ngl.js')
   

## Example
Here is a rather funny view in PyMOL and the equivalent snapshot transpiled to NGL.

<img src="images/example_pymol.png" width="200">
<img src="images/example_ngl.png" width="200">