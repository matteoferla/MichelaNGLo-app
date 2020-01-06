## mmCIF problem

PyMOL saved mmCIF and mmTF files do not load in NGL.

In [specs for NGL](http://nglviewer.org/ngl/api/manual/file-formats.html#mmcif), the mmCIF ought to contain 'auth_seq_id' and 'auth_asym_id'.

The `label_` forms of these are there, but not the `auth_`. Without these nothing loads.

Changing the `label_seq_id` and `label_asym_id` to these in the header block gives:

    STAGE LOG error loading file: 'TypeError: h[z] is undefined'

Copying the `_struct.title` from a correct file fixes it.
Well, the SS is missing obviously (`_struct_sheet_range` and `_struct_conf`) and the presumably the `_struct_conn` (`LINK`).
So why did changing `label_seq_id` and `label_asym_id` kill it?

`Bio.PDB.MMCIF2Dict import MMCIF2Dict` does not have a reverse (`Dict2MMCIF`), but doing a round trip in `Bio.PDB` fixes it:

    # PyMOL
    if __name__ == '__main__':
        pymol_argv = ['pymol', '-qc']
    else:
        import __main__
        __main__.pymol_argv = ['pymol', '-qc']
    
    import pymol
    pymol.finish_launching()
    
    # Bio.PDB
    from Bio.PDB.MMCIF2Dict import MMCIF2Dict
    from Bio.PDB.MMCIFParser import MMCIFParser
    from Bio.PDB.mmcifio import MMCIFIO
    
    # Round trip in PyMOL
    pymol.cmd.fetch('6ucs')
    pymol.cmd.save('test.cif')
    pymol.cmd.delete('all')
    
    # Second round trip, but in Bio.PDB
    s = MMCIFParser().get_structure('tester', 'test.cif')
    io = MMCIFIO()
    io.set_structure(s)
    io.save('out.cif')
    
    # What's new?
    ori = MMCIF2Dict('6ucs.cif')
    mod = MMCIF2Dict('test.cif')
    print('Final_key', 'in_original?', 'in_PyMOL?')
    for k in MMCIF2Dict('out.cif').keys():
        if '_atom_site' in k:
            print(k, k in ori, k in mod)


## mmTF

mmTF has issues too.

TypeError: `p.atomIdList` is undefined.
