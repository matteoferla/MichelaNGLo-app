/* This script monkeypatches NGL to have the following...

* store stage in NGL.
* NGL-controlling HTML markup
* clash adding

*/

NGL.stageIds = {};

NGL.specialOps = {'note': 'This is a monkeypatch to allow HTML control of the structure using the markup defined in ngl.matteoferla.com/markup'};

NGL.specialOps.show_region = function (id, selection, color) {};

NGL.specialOps.show_residue = function (id, resi, color, radius) {};


$(document).ready(function () {
    $('[data-toggle="protein"]').click(function() {
            var selection =$(this).data('selection');
            var color = $(this).data('color');
            var radius = $(this).data('radius');
            var id = $(this).data('target');
            var title = $(this).data('title');
            var focus = $(this).data('focus'); // residue | region | clash
            if (focus == 'residue'){
                NGL.specialOps.show_residue(id, selection, color, radius);
            }
            else if (focus == 'region'){
                NGL.specialOps.show_region(id, selection, color);
            }
            else if (focus == 'clash'){
                NGL.specialOps.show_clash(id, selection);
            }
            else {throw 'no data-region or data-residue tag.'}
            if (title) {
                id = id || 'viewport';
                $('#'+id+'_title').html(title);
                $('#'+id+'_title').show(1000);
                $('#'+id+'_title').hide(1000);
            }
        });
}
