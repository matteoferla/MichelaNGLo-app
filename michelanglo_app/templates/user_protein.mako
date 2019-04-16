<%inherit file="layout_components/layout.mako"/>

<div class="jumbotron clearfix">
    <div class="float-left ml-3">
        <h1>${title}</h1>
        <small class="text-muted">The content of this page was
            %if authors:
                edited by ${' and '.join(authors)} on the ${date}.<br/>
                The administrators of this site take no legal responsibility for the content of this page, if you believe this page is in violation of the law, please report it.
            % else:
                generated on the ${date}.
            %endif
             </small>
    </div>
    % if not no_buttons:
        <%include file="layout_components/menu_buttons.mako" args='tour=False'/>
    % endif

</div>

<div class='row p-4'>
    <div class='col-${columns_viewport}'>
        <div class='card shadow'>
            <div class="card-body">
                <div id="viewport" role="NGL" data-proteins='${proteinJSON|n}' data-backgroundcolor="${backgroundcolor}" ${data_other|n}></div>
            </div>
        </div>
    </div>


    <div class='col-${columns_text}'>
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
                % if key:
                    <a href="/data/${page}?no_user=1&remote=1&no_buttons=1" class="btn btn-outline-success w-100 my-1"  download="page.html"><i class="far fa-download"></i> Download file</a>
                    <a href="/save_pdb?uuid=${page}" class="btn btn-outline-success w-100 my-1"  download="model.pdb"><i class="far fa-map"></i> Download PDB</a>
                % else:
                    <a href="/data/${page}?no_user=1&remote=1&no_buttons=1&key=${key}" class="btn btn-outline-success w-100 my-1"  download="page.html"><i class="far fa-download"></i> Download file</a>
                    <a href="/save_pdb?uuid=${page}&key=${key}" class="btn btn-outline-success w-100 my-1"  download="model.pdb"><i class="far fa-map"></i> Download PDB</a>
                % endif




                <button type="button" class="btn btn-outline-primary w-100 my-1" id="getimplement"><i class="far fa-code"></i> Implementation code</button>
                <button type="button" class="btn btn-outline-primary w-100 my-1" data-toggle="modal" data-target="#basics"><i class="far fa-cubes"></i> Protein basics</button>
                <button type="button" class="btn btn-outline-primary w-100 my-1" data-toggle="modal" data-target="#about"><i class="far fa-quote-right"></i> Credits</button>
            </div>
        </div>
    </div>
</div>

<%block name="modals">
%if editable:
    <%include file='edit_modal/edit_modal.mako'/>
%endif
<%include file="userpage_components/about.mako"/>
<%include file="userpage_components/basics.mako"/>
<%include file="markup/markup_builder_modal.mako"/>
<%include file='edit_modal/implement_modal.mako'/>


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

    $('#getimplement').click(function () { //this is available to all in case a guest makes a page.
        $('#implement_modal .modal-body').html('<p><i class="far fa-dna fa-spin"></i> Data is loading...</p>');
        $('#implement_modal').modal('show');
        $.ajax({url: "/get",
                data: {page: "${page}",
                    %if key:
                        key: "${key}",
                    %endif
                       item: 'implement'},
                method: 'POST'
            }).done( (msg) => {$('#implement_modal .modal-body').html(msg); new ClipboardJS('.clipboard');})
                .fail((msg) => $('#implement_modal .modal-body').html('<p><i class="far fa-biohazard"></i> An error occurred and has been logged.</p>'));
    });

    %if editable:
    <%include file="markup/markup_builder_modal.js"/>
    <%include file="edit_modal/edit_modal.js"/>
    %endif
}); //ready

</script>
</%block>
