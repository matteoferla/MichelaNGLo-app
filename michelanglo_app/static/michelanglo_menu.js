$('#viewport').prepend(`<button type="button"
    class="btn btn-outline-secondary rounded-circle bg-white"
    style="position:absolute; top:2rem; right:2rem; z-index:1001"
    id="viewport_menu_popover"
    >
    <b>&nbsp;<i class="far fa-ellipsis-v"></i>&nbsp;
    </b>
</button>`);

let popbody = `
<div class="container">
<div class="row">
<div class="col-xl-6">
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
</div>
<div class="col-xl-6">
<div class="input-group mb-3">
  <div class="input-group-prepend">
  <span class="input-group-text" id="viewport_menu_ngl_add">NGL selection</span>
  </div>
  <input id="viewport_menu_ngl" type="text" class="form-control" placeholder="residueNumber:chainLetter.atomName" aria-label="NGL selection" aria-describedby="viewport_menu_ngl_add">
  <div class="input-group-append">
    <button class="btn btn-outline-secondary" type="button" id="viewport_menu_ngl_go" data-toggle="tooltip" title="Go to selection"><i class="far fa-bullseye-arrow"></i></button>
  </div>
</div>
</div>
<div class="col-lg-6 col-xl-4">
<div class="input-group mb-3">
<div class="input-group-prepend">
    <span class="input-group-text" id="viewport_menu_clipNear_add">Clip<sub>Near</sub></span>
</div>
<div class="border rounded-right px-3 py-1">
    <input type="range" min="0" max="100" value="0" step="5" class="custom-range" id="viewport_menu_clipNear" aria-label="ClipNear" aria-describedby="viewport_menu_clipNear_add">
</div>
</div>
</div>
<div class="col-lg-6 col-xl-4">
<div class="input-group mb-3">
    <div class="input-group-prepend">
        <span class="input-group-text" id="viewport_menu_clipFar_add">Clip<sub>Far</sub></span>
    </div>
    <div class="border rounded-right px-3 py-1">
        <input type="range" min="0" max="100" value="0" step="5" class="custom-range" id="viewport_menu_clipFar" aria-label="ClipFar" aria-describedby="viewport_menu_clipFar_add">
    </div>
</div>
</div>
<div class="col-lg-6 col-xl-4">

<div class="input-group mb-3">
    <div class="input-group-prepend">
        <span class="input-group-text" id="viewport_menu_clipDist_add">Clip<sub>Distance</sub></span>
    </div>
    <div class="border rounded-right px-3 py-1">
        <input type="range" min="0" max="10" value="0" step="1" class="custom-range" id="viewport_menu_clipDist" aria-label="ClipDist" aria-describedby="viewport_menu_clipDist_add">
    </div>
</div>
</div>
<div class="col-lg-6 col-xl-4">
<div class="input-group mb-3">
<div class="input-group-prepend">
    <span class="input-group-text" id="viewport_menu_fogNear_add">Fog<sub>Near</sub></span>
</div>
<div class="border rounded-right px-3 py-1">
    <input type="range" min="0" max="100" value="25" step="5" class="custom-range" id="viewport_menu_fogNear" aria-label="fogNear" aria-describedby="viewport_menu_fogNear_add">
</div>
</div>
</div>
<div class="col-lg-6 col-xl-4">
<div class="input-group mb-3">
<div class="input-group-prepend">
    <span class="input-group-text" id="viewport_menu_fogFar_add">Fog<sub>Far</sub></span>
</div>
<div class="border rounded-right px-3 py-1">
    <input type="range" min="0" max="100" value="50" step="5" class="custom-range" id="viewport_menu_fogFar" aria-label="fogFar" aria-describedby="viewport_menu_fogFar_add">
</div>
</div></div>
<div class="col-lg-6 col-xl-4"><button type="button" class="btn btn-info" data-toggle="modal" data-target="#controlguide_modal">Show Mouse Controls</div>
<div class="col-lg-6 col-xl-4"></div>
</div>
</div>
`;

$('#viewport_menu_popover')
    .popover({html: true,
            trigger: "manual",
            title: "Options",
            html: true,
            content: "<div id='popbody'>"+popbody+"</div>"})
    .click(function(){
       if(! window.viewPopIsOpen ||  window.viewPopIsOpen === undefined) { //it is not open
           $(this).popover('show');
            window.viewPopIsOpen=true;}
       else {
           $(this).popover('hide');
           window.viewPopIsOpen=false;
       }
    }).on('shown.bs.popover',function() {
            $('#popbody').html(popbody); //this seems insane but the HTML gets buggered in Moz otherwise and the position is all wtrong.

        $('#popbody [data-toggle="tooltip"]').tooltip();
        $('#viewport_menu_selector_go').click((e) => {
                NGL.specialOps.showResidue('viewport', $('#viewport_menu_selector_resi').val() + ':' + $('#viewport_menu_selector_chain').val());
                $('#viewport_menu_popover').popover('hide');
            }
        );
        $('#viewport_menu_ngl_go').click((e) => {
            NGL.specialOps.showResidue('viewport',$('#viewport_menu_ngl').val());
            $('#viewport_menu_popover').popover('hide');
        }
        );

        $('#viewport_menu_clipNear').change((e) => NGL.getStage().setParameters({'clipNear': parseInt($('#viewport_menu_clipNear').val())}));
        $('#viewport_menu_clipFar').change((e) => NGL.getStage().setParameters({'clipFar': parseInt($('#viewport_menu_clipFar').val())}));
        $('#viewport_menu_clipDist').change((e) => NGL.getStage().setParameters({'clipDist': parseInt($('#viewport_menu_clipDist').val())}));
        $('#viewport_menu_fogNear').change((e) => NGL.getStage().setParameters({'fogNear': parseInt($('#viewport_menu_fogNear').val())}));
        $('#viewport_menu_fogFar').change((e) => NGL.getStage().setParameters({'fogFar': parseInt($('#viewport_menu_fogFar').val())}));
        //$('.popover [type="range"]').on('mousedown', (e) => {$('.transparentable').hide(500); if (window.menu_timeout) {clearTimeout(menu_tineout)}})
         //                       .on('mouseup', (e) => setTimeout((e) => window.menu_timeout = $('.transparentable').show(1000), 3000));
        //worked with ... class='transparentable' style="transition: opacity 0.5s; -webkit-transition: opacity 0.5s;"
    });


$('body').append(`
<div class="modal" tabindex="-1" role="dialog" id="controlguide_modal">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Modal title</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
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
            </table>
      </div>
    </div>
  </div>
</div>
`);
setTimeout(()=> $('#controlguide_modal').on('show.bs.modal',(event) => $('#viewport_menu_popover').popover('hide')), 1000);
//cannae be bothered doing this properly, but the problem is that this should go only when the modal is added to the body.