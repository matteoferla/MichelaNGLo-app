## Technicalities
### Parts to convert
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

### Notes on PSE side
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

### Primitive equivalence table

| PyMol  | PyMol reps bit | NGL |
| ------------- | --- |------------- |
| `spheres`  | 000000000010 | `spacefill` |
| NA | &mdash; | `ball+stick` |
| NA | &mdash; | `helixorient` |
| `lines`  | 000010000000 | `line` |
| `sticks`  | 000000000001 | `licorice`  |
| NA | &mdash; | `hyperball` |
| NA | &mdash; | `trace` |
| `ribbon` | 000001000000 | `backbone` |
| NA | &mdash; | `ribbon` |
| `cartoon` | 000000100000 | `cartoon` |
| `surface` | 000000000100 | `surface` | 
| `label` | 000000001000 | `label` |
| `non-bounded spheres` | 000000010000 | &lowast; |
| NA | &mdash; |`rope`|
| "putty"* | &mdash; | `tube` |
| `mesh`   | 000100000000 | &lowast; |
| `dots`  | 001000000000 | `point` |
| `non-bounded` | 010000000000 | &lowast; |
| `cell` | 100000000000 | `cell` |

&lowast;) The two differ in how this is handled.

### The SS problem
NGL does not assign secondary structure. Therefore, if not specified everything will be a turn/loop, so both the helices and sheet (especially) will look anemic.

<img src="images/sheeted.png" width="200">
<img src="images/unsheeted.png" width="200">

The script `SS.py` can generate this in PDB file via PyMol. However, the generated `SHEET` definition is not as it ought to be, as it gives out mulitple separate strands as opposed to a single multistrand sheet &mdash;It works though, so who cares? 

### Multiple objects
[PyMOL_model_chains_segi](PyMOL_model_chains_segi.md)

### Complicated?
The code seems a bit complex when it comes to selections. The most obvious thing to do is to just have a list of the atoms with a given color and representation. However, this has two problems:
first, the NGL atom serial does not always map to the same PyMOL atom ID as both try to fix issues in PDB atom id, the second is that having a list of thousands of ids quickly becomes heavy.
