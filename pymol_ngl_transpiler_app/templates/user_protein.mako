<%inherit file="layout.mako"/>

<div class="jumbotron">
    <h1>${title}</h1>
</div>

<div class='row p-4'>
    <div class='col-9'>
        <div class='card shadow'>
            <div class="card-body">
                <div id="viewport" role="NGL" data-proteins='${proteinJSON}' data-backgroundcolor="${backgroundcolor}"></div>
            </div>
        </div>
    </div>


    <div class='col-3'>
        <div class="card shadow" role="tooltip">

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

<%include file='edit_modal.mako'/>



<%include file='about.mako'/>
<%include file='basics.mako'/>
<%include file="markup/markup_builder_modal.mako"/>

<%include file="../user/${uuid}.js"/>

<%block name='script'>
    <script type="text/javascript">
        $(document).ready(function () {
            <%include file="markup/markup_builder_modal.js"/>


            $('#save').click(function () {
                NGL.getStage('viewport').makeImage({trim: true, antialias: true, transparent: false}).then(NGL.download);
            });

            $('#edit_submit').click(function () {
                $.ajax({
                    url: "/edit_user-page",
                    type: 'POST',
                    dataType: 'json',
                    data: {
                        'type': 'edit',
                        'title': $('#edit_title').val(),
                        'description': $('#edit_description').val(),
                        'page': $(location).attr("href").split('/').pop().split('.')[0],  //just in case someone wants to API it.
                        'residues': $('#edit_residues').val(),
                        'proteinJSON': JSON.stringify($('[role="NGL"]').data('proteins')),
                        'backgroundcolor': $('[role="NGL"]').data('backgroundcolor')
                    },
                    success: function (result) {
                        location.reload();
                    }

                });
            });

            $('#edit_delete').click(function () {
                if (confirm('Are you sure you want to remove this page?')) {
                    $.ajax({
                        url: "/edit_user-page",
                        type: 'POST',
                        dataType: 'json',
                        data: {
                            'type': 'delete',
                            'page': $(location).attr("href").split('/').pop().split('.')[0]
                        },
                        success: function (result) {
                            window.location.href = '/';
                        }
                    });
                }
            });
        }); //ready

    </script>
</%block>
