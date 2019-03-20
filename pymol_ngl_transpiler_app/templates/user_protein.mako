<%inherit file="layout.mako"/>

<div class="jumbotron">
    <h1>${title}</h1>
</div>

<div class='row p-4'>
    <div class='col-9'>
        <div class='card'>
            <div class="card-body">
                <div id="viewport" role="NGL" data-proteins='${proteinJSON}' data-backgroundcolor="${backgroundcolor}"></div>
            </div>
        </div>
    </div>


    <div class='col-3'>
        <div class="card" role="tooltip">

            <div class="card-header"><h3 class="card-title">Description</h3></div>

            <div class="card-body">


            <div style="left:-30px; top: 80px; position: absolute; width: 0; z-index:1000;
                height: 0;
                border-style: solid;
                border-width: 30px 30px 30px 0;
                border-color: transparent rgba(0, 0, 0, 0.125) transparent transparent;">
            </div>

            <div style="left:-29px; top: 80px; position: absolute; width: 0; z-index:1000;
                height: 0;
                border-style: solid;
                border-width: 30px 30px 30px 0;
                border-color: transparent white transparent transparent;">
            </div>

                <div class="float-right">
                    <button type="button" class="btn btn-outline-primary my-1" id="edit_btn" data-target="#edit_modal" data-toggle="modal"><i class="far fa-edit"></i></button>
                </div>

                <p>${description|n}</p>
                <hr/>

                <button type="button" class="btn btn-outline-success w-100 my-1" id="save"><i class="far fa-camera"></i> Take snapshot</button>
                <button type="button" class="btn btn-outline-primary w-100 my-1" data-toggle="modal" data-target="#basics"><i class="far fa-cubes"></i> Protein basics</button>
                <button type="button" class="btn btn-outline-primary w-100 my-1" data-toggle="modal" data-target="#about"><i class="far fa-code"></i> Credits</button>
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
                        <span class="input-group-text" aria-label="edit_description" ro aria-describedby="description-addon1">Description</span>
                    </div>
                    <textarea class="form-control" aria-label="With textarea" id="edit_description">${description}</textarea>
                </div>

                <%include file='markup_builder_btn.mako'/>

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
<%include file='markup_builder_modal.mako'/>

<%include file="../user/${uuid}.js"/>

<%block name='script'>
    <script type="text/javascript">
        $(document).ready(function () {
            <%include file='markup_builder_modal.js'/>


            $('#save').click(function () {
                NGL.getStage('viewport').makeImage({trim: true, antialias: true, transparent: false}).then(NGL.download);
            });

            $('#edit_submit').click(function () {
                $.ajax({
                    url: "/edit_user-page",
                    type: 'POST',
                    dataType: 'json',
                    data: {
                        'title': $('#edit_title').val(),
                        'description': $('#edit_description').val(),
                        'page': $(location).attr("href").split('/').pop().split('.')[0],  //just in case someone wants to API it...
                        'residues': $('#edit_residues').val(),
                        'proteinJSON': JSON.stringify($('[role="NGL"]').data('proteins')),
                        'backgroundcolor': $('[role="NGL"]').data('backgroundcolor')
                    },
                    success: function (result) {
                        location.reload();
                    }

                });
            });

        }); //ready

    </script>
</%block>
