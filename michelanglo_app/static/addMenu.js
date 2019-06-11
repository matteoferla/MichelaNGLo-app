$('#viewport').prepend(`<button type="button"
    class="btn btn-outline-secondary rounded-circle bg-white"
    style="position:absolute; top:2rem; right:2rem; z-index:1001"
    id="viewport_menu_popover"
    >
    <b>&nbsp;<i class="far fa-ellipsis-v"></i>&nbsp;
    </b>
</button>`);



$('#viewport_menu_popover')
    .popover({html: true,
            trigger: "manual",
            title: "Options",
            content: "<div id='popbody'></div>"})
    .click(function(){
       if(! window.viewPopIsOpen ||  window.viewPopIsOpen === undefined) { //it is not open
           $(this).popover('show');
            window.viewPopIsOpen=true;}
       else {
           $(this).popover('hide');
           window.viewPopIsOpen=false;
       }
    }).on('shown.bs.popover',function() {
            $('#popbody').html(`
<div class="input-group mb-3">
  <div class="input-group-prepend">
    <span class="input-group-text" id="viewport_menu_selector_add">Focus on residue</span>
  </div>
  <input id="viewport_menu_selector_resi" type="number" class="form-control" placeholder="residue number" aria-label="residue" aria-describedby="viewport_menu_selector_add">
  <input id="viewport_menu_selector_chain" type="text" class="form-control" placeholder="chain" aria-label="chain" aria-describedby="viewport_menu_selector_add">
  <div class="input-group-append">
    <button class="btn btn-outline-secondary" type="button" id="viewport_menu_selector_go" data-toggle="tooltip" title="Go to residue"><i class="far fa-bullseye-arrow"></i></button>
  </div>
</div>
<h4>Controls</h4>
<p>The mouse and keyboard mappings are the standard NGL ones.</p>

<table class="table table-striped">
<tr><th>Key</th><th>Effect</th></tr>
<tr><td class="text-monospace">Scroll</td><td>zoom scene</td></tr>
<tr><td class="text-monospace">scroll-ctrl</td><td>move near clipping plane</td></tr>
<tr><td class="text-monospace">scroll-shift</td><td>move near clipping plane and far fog</td></tr>
<tr><td class="text-monospace">scroll-alt</td><td>change isolevel of isosurfaces</td></tr>
<tr><td class="text-monospace">drag-right</td><td>pan/translate scene</td></tr>
<tr><td class="text-monospace">drag-middle</td><td>zoom scene</td></tr>
<tr><td class="text-monospace">drag-left</td><td>rotate scene</td></tr>
<tr><td class="text-monospace">drag-shift-right</td><td>zoom scene</td></tr>
<tr><td class="text-monospace">drag-left+right</td><td>zoom scene</td></tr>
<tr><td class="text-monospace">drag-ctrl-right</td><td>pan/translate hovered component</td></tr>
<tr><td class="text-monospace">drag-ctrl-left</td><td>rotate hovered component</td></tr>
<tr><td class="text-monospace">clickPick-middle</td><td>auto view picked component element</td></tr>
<tr><td class="text-monospace">hoverPick</td><td>show tooltip for hovered component element</td></tr>
<tr><td class="text-monospace">i</td><td>toggle stage spinning</td></tr>
<tr><td class="text-monospace">k</td><td>toggle stage rocking</td></tr>
<tr><td class="text-monospace">p</td><td>pause all stage animations</td></tr>
<tr><td class="text-monospace">r</td><td>reset stage auto view</td></tr>
</table>`);

        $('#popbody [data-toggle="tooltip"]').tooltip();
        $('#viewport_menu_selector_go').click((e) =>
            NGL.specialOps.showResidue('viewport',$('#viewport_menu_selector_resi').val()+':'+$('#viewport_menu_selector_chain').val())
        );
    });





