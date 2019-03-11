# Markup for protein
A system to control the protein without any JS coding.

See [ngl.matteoferla.com/markup](ngl.matteoferla.com/markup) for description and demo.
## NGL.extended.js
* NGL.stageIds an object taht stores id: stages
* NGL.getStage(id) is a getter for this.
* NGL.specialOps
** NGL.specialOps.showDomain(id, selection, color, view), which focuses stage to show the given selection with the given color
** NGL.specialOps.showResidue(id, selection, color, radius, view), which focuses on the selection and their neighbourhood by n radius
** NGL.specialOps.showClash(id, selection, color, radius, tolerance, view) which shows the clashes that selection may have
** NGL.specialOps.slowOrient deals with the view if provided for these previous three.
** NGL.specialOps.showTitle(id,text) shows the title.
** NGL.specialOps.multiLoader(id, proteins, backgroundColor, startIndex), see below about proteins object
** NGL.specialOps.postInitialise() gets called by load if the stage was not set via multiLoader
** NGL.specialOps.load(option)
** NGL.specialOps.removeImg() switches the image off
** NGL.specialOps._run_loadFx() and a few others.
* NGL.Stage extra prototypes
** NGL.Stage.prototype.getComponentByType allowing stage objects to return a component.
** NGL.Stage.prototype.removeComponentsbyName array version.
** NGL.Stage.prototype.removeClashes removes clashes and the rotation.
* $.prototype.protein to enable a link
NB. this file ends with `$('[data-toggle="protein"]').protein();` to activate all links.

proteins is an array of {name: 'unique_name', type: 'rcsb' (default) | 'file' | 'data', value: xxx, 'ext': 'pdb' (default), loadFx: xxx}
where the optional loadFx is a function that is run on loading.
