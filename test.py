from michelanglo_app.transplier import PyMolTranspiler

transpiler = PyMolTranspiler(file='michelanglo_app/demo/1gfl.pse')
#print(transpiler.get_view())
#print(transpiler.get_reps())
print(transpiler.get_loadfun_js(tag_wrapped=True,viewport='viewport'))
