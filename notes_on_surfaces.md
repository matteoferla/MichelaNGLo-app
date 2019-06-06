## Notes on surfaces

I was unable to reverse engineer "surfaces" on a few fronts.

### NGL mesh
NGL has a `map` component, visualisable with a `surface` representation,  and a `mesh` shape object. The former is your density map that can be carved with a &sigma; setting, while the latter is a generic 3D object, say a teapot.

In [michelanglo.sgc.ox.ac.uk/custom](michelanglo.sgc.ox.ac.uk/custom) one can convert an obj file, say downloaded from thingiverse or other 3D object provider.

And PyMol can save as obj file. So I naively thought I could use this as a plan B for things that could not be converted.
However, PyMOL obj saving is extremely poor and most data is lost, such as a PyMol `object:map` (isomesh cmd).

### Isomesh > NGL generic mesh
The data within `pymol.cmd.get_session('mapname')['names'][0][5]` does not contain the actual coordinates.
Therefore it is not possible to simply convert an isomesh map to a generic `mesh` object in NGL.

### Map of isomesh > NGL surface
Given that a PyMol `object:map` (isomesh cmd) does not convert as an object one would thing that one could easily save it as a format that NGL can read.
Oddly, there is no way &mdash;I could see&mdash; to save a ccp4 map. `save.ccp4` behaves as if it had worked &mdash;it does default to a `pdb`, but it is does not create a file.
So the only way to do this is by having a user supplied map.

The best bet is to manually add surfaces (cf. [http://nglviewer.org/ngl/gallery/](http://nglviewer.org/ngl/gallery/)).

### CGO
PyMOL `CGO` objects (e.g. arrows) do not export in a .obj.
