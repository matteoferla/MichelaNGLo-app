## Advance notes
Corner cases arise when dealing with chains, segments and models.

### Background
In a PDB file a `chain` is... a chain. ie. a polypeptide possibly with gaps representing disorder.
If a polypeptide is cleaved in vitro/vivo it will be represented by two chains generally.

Segments, `segi` in PyMOL, are an obsolete subdivision of a polypeptide. Technically for things like ligands,
ie. different molecules get a differ segment. Chimera still uses it, so it's not really obsolete.
But in the cases of complexes of more than 26 polypeptides, such as a virus particle, these are used as a second digit for chains.

There there is `model`. Models, as defined in a PDB file, are meant for different states (MD or NMR).
PyMOL can have more than one object open in the viewer, these are not called models anywhere.
I have never encountered a model of two different protein objects as different models.
Different objects can be merged with the `create` command.

Likewise, NGL can have more than one `polypeptide` (protein) object in a scene.
However, unlike PyMOL, selection is *protein* based, not scene.

PyMOL has an extra top level boolean toggle for protein objects. They can be `enabled` or not.
The atoms still have representation regardless.

The chain has to be ASCII for PyMOL to read it or you will get a curious shape.
![rod of missing byte](images/rod_of_missing_byte.png)
You cannot use non-ASCII in PyMOL command line or API either. However, A-Z are treated differently than a-z.
ASCII non-letter symbols are superficially accepted, like `?`, but most cause havoc with selections.

NGL on the other hand happily accepts up Latin-1 (say `ß` or `þ` or `À`),
but anything higher gets interpreted as the last two digits of the hex code for that glyph.
However, with structures of over 100 chains, running out of letters is the last of your worrries.

## Operations
* Not `enabled` objects are ignored
* segments (`segi`) are ignored &mdash;too ambiguous
* Blank chain (`chain ''`) peptides are given a chain letter
* Multiple `objects:molecule` in a view are collapsed into a single object with unique chain letters.
* Only the first `model`/`state` is taken.

Whereas NGL handles multiple `polypeptide` components, the selection are specific to these, making it impossible to select across different components.

If any of this is no good for you, see the method `fix_structure` in `transpiler.py`.



