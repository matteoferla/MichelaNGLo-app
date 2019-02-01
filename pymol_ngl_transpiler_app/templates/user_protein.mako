<%inherit file="layout.mako"/>

<h1>${title}</h1>

<div class='container-fluid'>
	<div class='row'>
		<div class='col-9'>
			<div id="viewport"style="width:100%; height: 0; padding-bottom: 100%;"></div>
		</div>
		<div class='col-3'>
            <div class="card">
                <div class="card-body">
                    <h3>Description</h3>
                    <div class="float-right"><button type="button" class="btn btn-outline-primary my-1" id="edit_btn" data-target="#edit_modal" data-toggle="modal"><i class="far fa-edit"></i></button></div>
                        <p>${description}</p>
                        <hr/>
                        <button type="button" class="btn btn-success w-100 my-1" id="save"><i class="far fa-camera"></i> Take snapshot</button>
                        <div class="dropdown">
			  <button class="btn btn-secondary dropdown-toggle w-100" type="button" id="residueButton" data-toggle="residue" aria-haspopup="true" aria-expanded="false">
				<i class="far fa-search"></i> Zoom to a residue
			  </button>
			  <div class="dropdown-menu" aria-labelledby="residueMenuButton" id='residue'>
			  </div>
			</div>
                <button type="button" class="btn btn-primary w-100 my-1" data-toggle="modal" data-target="#basics"><i class="far fa-cubes"></i> Protein basics</button>
                <button type="button" class="btn btn-primary w-100 my-1" data-toggle="modal" data-target="#about"><i class="far fa-code"></i> Credits</button>
                    </div></div>
                </div>
        </div>
    </div>
</div>

<div class="modal fade" tabindex="-1" role="dialog" id="edit_modal">
  <div class="modal-dialog modal-lg" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title"><i class="far fa-pen-alt"></i> Edit</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        <div class="input-group mb-3">
          <div class="input-group-prepend">
            <span class="input-group-text" id="title-addon1">Title</span>
          </div>
          <input type="text" class="form-control" value="${title}" aria-label="Title" aria-describedby="title-addon1" id="edit_title">
        </div>
          <div class="input-group mb-3">
              <div class="input-group-prepend">
                <span class="input-group-text" aria-label="edit_description" aria-describedby="description-addon1">Description</span>
              </div>
              <textarea class="form-control" aria-label="With textarea" id="edit_description">${description}</textarea>
            </div>
          <div class="input-group mb-3">
              <div class="input-group-prepend" title="Input for residues to focus on. Write on seperate lines, the resi number with colon and chain id if multichain (e.g. '12:A') followed by a space and a word or two to describe it (e.g. 'p.D12R from DirEvo round 2').">
                <span class="input-group-text">Residue focus</span>
              </div>
              <textarea class="form-control" aria-label="With textarea" id="edit_residues">${residues}</textarea>
            </div>

        <div class="modal-footer">
        <button type="button" class="btn btn-primary" id="edit_submit">Save changes</button>
        <button type="button" class="btn btn-secondary" data-dismiss="modal">Discard</button>
      </div>
    </div>
  </div>
</div>
</div>


<%include file='about.mako'/>
<%include file='basics.mako'/>

<%block name='script'>
<script type="text/javascript" id="code">
${code}
$( document ).ready(function () {
    $('#save').click(function () {
       stage.makeImage( {trim: true, antialias: true, transparent: false }).then(function (img) {window.img=img; NGL.download(img);});
    });
    $('#edit_submit').click(function () {
        $.ajax({
            url: "/edit_user-page",
            type: 'POST',
            dataType: 'json',
            data: {
                'title': $('#edit_title').val(),
                'description': $('#edit_description').val(),
                'code': $('#code').html(),  //in future I will make an edit code modal.
                'page': $(location).attr("href").split('/').pop().split('.')[0],  //just in case someone wants to API it...
                'residues': $('#edit_residues').val()
            },
            success: function(result) {location.reload();}

        });
    });



$('#residue').append('<a class="dropdown-item" href="#" id="main_view">main view</a>');
$('#main_view').click(function() {load_file (); stage.viewerControls.orient(myData.main_view);});
if (myData.alt_view) {
    $('#residue').append('<a class="dropdown-item" href="#" id="alt_view">alt view</a>');
    $('#alt_view').click(function() {load_file (); stage.viewerControls.orient(myData.alt_view);});
}
var residuedex=`${residues}`.split('\n');
for (var i=0; i < residuedex.length; i++) {
    if (!!residuedex[i]) {
        var r=residuedex[i].split(' ');
        var label=r[0];
        if (r.length > 1) {
            label = r.splice(1).join(' ');
        }
        $('#residues').append('<a class="dropdown-item residue" href="#" data-selection="'+r[0]+'">'+label+'</a>');
    }
}
$('.residue').click(function() {
            load_file ();
            show_residue($( this ).data('selection'));
            });

});
</script>
</%block>
