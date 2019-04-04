<%inherit file="layout.mako"/>

<div class="jumbotron clearfix">
    <div class="float-left ml-3">
        <h1>${title}</h1>
        <small class="text-muted">The content of this page was edited by ${' and '.join(authors)}. The administrators of this site take no legal responsibility for its content, if you believe this page is in violation of the law, please report it.</small>
    </div>
    <%include file="menu_buttons.mako" args='tour=False'/>
</div>

<div class='row p-4'>
    <div class='col-9'>
        <div class='card shadow'>
            <div class="card-body">
                <div id="viewport" role="NGL" data-proteins='${proteinJSON|n}' data-backgroundcolor="${backgroundcolor}" ${data_other|n}></div>
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
                    %if editable:
                        <div class="float-right">
                            <button type="button" class="btn btn-outline-primary my-1" id="edit_btn" data-target="#edit_modal" data-toggle="modal"><i class="far fa-edit"></i></button>
                        </div>
                    %endif

                <p>${description|n}</p>
                <hr/>

                <button type="button" class="btn btn-outline-success w-100 my-1" id="save"><i class="far fa-camera"></i> Take snapshot</button>
                <button type="button" class="btn btn-outline-primary w-100 my-1" data-toggle="modal" data-target="#basics"><i class="far fa-cubes"></i> Protein basics</button>
                <button type="button" class="btn btn-outline-primary w-100 my-1" data-toggle="modal" data-target="#about"><i class="far fa-code"></i> Credits</button>
            </div>
        </div>
    </div>
</div>

<%block name="modals">
%if editable:
    <%include file='edit_modal.mako'/>
%endif
<%include file='about.mako'/>
<%include file='basics.mako'/>
<%include file="markup/markup_builder_modal.mako"/>

</%block>

<%block name='script'>
<script type="text/javascript">
    %if pdb:
var pdb = `REMARK 666 Note that the indent is important as is the secondary structure def
${pdb|n}`;
    %endif

${loadfun|n}

$(document).ready(function () {
    $('#save').click(function () {
        NGL.getStage('viewport').makeImage({trim: true, antialias: true, transparent: false}).then(NGL.download);
    });

    %if editable:
    <%include file="markup/markup_builder_modal.js"/>

    $('#edit_submit').click(function () {
        if ($('#encryption').prop('checked')) {
            if (! $('#encryption_key').val) {return 0}
        }
        $.ajax({
            url: "/edit_user-page",
            type: 'POST',
            dataType: 'json',
            data: {
                'type': 'edit',
                'title': $('#edit_title').val(),
                'description': $('#edit_description').val(),
                'page': $(location).attr("href").split('/').pop().split('.')[0],  //just in case someone wants to API it and for admin console.
                'residues': $('#edit_residues').val(), //no longer valid.
                'proteinJSON': JSON.stringify($('[role="NGL"]').data('proteins')),
                'backgroundcolor': $('[role="NGL"]').data('backgroundcolor'),
                'new_editors': JSON.stringify($('.user-editable-state:checked').map((idx, item) => $(item).data('user')).toArray()),
                'encryption': $('#encryption').prop('checked'),
                'encryption_key': $('#encryption_key').val()
            },
            success: function (result) {
                location.reload();
            }

        });
    });

    $('#edit_delete').click(function () {
        if (confirm('Are you sure you want to remove this page?')) {
            $.ajax({
                url: "/delete_user-page",
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

    %endif

}); //ready

</script>
</%block>
