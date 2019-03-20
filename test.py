from PyMOL_to_NGL import PyMolTranspiler

transpiler = PyMolTranspiler(file='pymol_ngl_transpiler_app/demo/1gfl.pse')
#print(transpiler.get_view())
#print(transpiler.get_reps())
print(transpiler.get_loadfun_js(tag_wrapped=True,viewport='viewport'))
