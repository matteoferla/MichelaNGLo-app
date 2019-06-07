<%inherit file="layout_components/layout.mako"/>
<%
    import markdown
%>
<div class="jumbotron clearfix py-4"
%if confidential:
    style="padding-left: 6rem;"
%endif
>
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
        <%include file="layout_components/vertical_menu_buttons.mako" args='tour=False'/>
    % endif

</div>

<%
    if location_viewport == 'left':
        part_order = ['order-1','order-2']
    else:
        part_order = ['order-2','order-1']
%>

<div class='row p-4'>
    <div class='col-${columns_viewport} ${part_order[0]}'>
        <div class='card shadow'>
            <div class="card-body">
                <div id="viewport" role="NGL" data-proteins='${proteinJSON|n}' data-backgroundcolor="${backgroundcolor}" ${data_other|n}></div>
            </div>
        </div>
    </div>


    <div class='col-${columns_text} ${part_order[1]}'>
        <div class="card shadow" role="tooltip">

            <div class="card-header"><h3 class="card-title">Description</h3></div>

            <div class="card-body">
            %if location_viewport == 'left':
                <div class="arrow-left"></div>
            %else:
                <div class="arrow-right"></div>
            %endif


                    %if editable:
                        <div class="float-right">
                            <button type="button" class="btn btn-outline-primary my-1" id="edit_btn" data-target="#edit_modal" data-toggle="modal"><i class="far fa-edit"></i></button>
                        </div>
                    %endif
                <p>${markdown.markdown(description)|n}</p>
                <hr/>
                <button type="button" class="btn btn-outline-primary w-100 my-1" id="getimplement"><i class="far fa-code"></i> Implementation code</button>

                <button type="button" class="btn btn-outline-success w-100 my-1" id="save"><i class="far fa-camera"></i> Save image</button>
                % if key:
                    <a href="/data/${page}?no_user=1&remote=1&no_buttons=1" class="btn btn-outline-success w-100 my-1"  download="page.html"><i class="far fa-download"></i> Download html file</a>
                    <a href="/save_pdb?uuid=${page}" class="btn btn-outline-success w-100 my-1"  download="model.pdb"><i class="far fa-map"></i> Download PDB</a>
                % else:
                    <a href="/data/${page}?no_user=1&remote=1&no_buttons=1&key=${key}" class="btn btn-outline-success w-100 my-1"  download="page.html"><i class="far fa-download"></i> Download html file</a>
                    <a href="/save_pdb?uuid=${page}&key=${key}" class="btn btn-outline-success w-100 my-1"  download="model.pdb"><i class="far fa-map"></i> Download PDB file</a>
                % endif





                ###<button type="button" class="btn btn-outline-primary w-100 my-1" data-toggle="modal" data-target="#basics"><i class="far fa-cubes"></i> Protein basics</button>

                %if remote:
                    <button type="button" class="btn btn-outline-primary w-100 my-1" data-toggle="modal" data-target="#about"><i class="far fa-quote-right"></i> Credits</button>

                %endif
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
<%include file='edit_modal/combine_modal.mako'/>


</%block>

<%block name='script'>
<script type="text/javascript">
    %if isinstance(pdb,str):
var pdb = `REMARK 666 Note that the indent is important as is the secondary structure def
${pdb|n}`;
    %elif isinstance(pdb,list):
        %for n,seq in pdb:
var ${n} = `REMARK 666 Note that the indent is important as is the secondary structure def
${seq|n}`;
        %endfor
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

    //move the viewport on scroll.
    $(window).scroll(function() {
	    var card = $('#viewport').parent().parent();
            var currentY = $(window).scrollTop();
	    var windowY = $(window).innerHeight();
	    var offsetY = card.offset().top - parseInt(card.css('top')) - 4;
            if ((currentY > offsetY) && (currentY + windowY > offsetY + card.height())) {
			$('#viewport').parent().parent().css('top', currentY - offsetY);
		}
	    else {$('#viewport').parent().parent().css('top', 0);}
	});


    %if not no_user:
        ###user mode is on.
        %if freelyeditable and not user:
            $('#toaster').append(`<%include file="layout_components/toast.mako" args="toast_id='pleaseLogin', toast_title='Page editing', toast_body='This page can be edited by anyone with the link. However, to prevent vandalism you have to be signed in.', toast_bg='bg-info', toast_autohide='false'"/>`);
            $('#pleaseLogin').toast('show');
        %endif

        <%include file="edit_modal/combine.js"/>

    %endif

}); //ready

</script>
</%block>
