<%inherit file="layout_components/layout.mako"/>
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
                The administrators of this site take no legal responsibility for the content of this page, if you believe this page is in violation of the law, <a href="#" id="report">please report it</a>.
            % else:
                generated on the ${date}.
            %endif
             </small>
    </div>
    % if not no_buttons:
        <%include file="layout_components/vertical_menu_buttons.mako" args='tour=True'/>
    % endif
</div>

<%
    if location_viewport == 'left':
        part_order = ['order-1','order-2']
    else:
        part_order = ['order-2','order-1']
%>

<div class='row p-4'>
    % if columns_viewport>0:
    <div class='col-12 col-lg-${columns_viewport} ${part_order[0]}'>
        <div class='card shadow'>
            <div class="card-body">
                <div id="viewport" role="NGL" data-proteins='${proteinJSON|n}' data-backgroundcolor="${backgroundcolor}" ${data_other|n}>
                    %if image:
                        <img src="${image}" class="w-100"/>
                    %endif
                </div>
            </div>
        </div>
    </div>
    % endif

    %if columns_text>0:
    <div class='col-12 col-lg-${columns_text} ${part_order[1]}'>
        %if model:
            <div class="alert alert-warning alert-dismissible fade show" role="alert">
              <strong>Model warning</strong> One or more structures presented here are computational models and not experimental determination, consequently should be treated with caution.
              <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                <span aria-hidden="true">&times;</span>
              </button>
            </div>
        %endif
        <div class="card shadow" role="tooltip">
            ${descr_header|n}

            <div class="card-body">
            %if columns_viewport:
                %if location_viewport == 'left':
                    <div class="arrow-left d-none d-lg-block"></div>
                %else:
                    <div class="arrow-right d-none d-lg-block"></div>
                %endif
            %endif

                    %if editable and not no_user:
                        <div class="float-right">
                            <span title="Edit the content of this page" data-toggle="tooltip">
                                <button type="button" class="btn btn-outline-primary my-1" id="edit_btn" data-target="#edit_modal" data-toggle="modal"><i class="far fa-edit"></i></button>
                            </span>
                            <br/>
                            <button type="button" class="btn btn-outline-primary my-1" id="tour" title="Tutorial to explain how to navigate this page." data-toggle="tooltip" style="width: 2.75rem;"><i class="far fa-info"></i></button>
                        </div>
                    %endif
                <p>${descr_mdowned|n}</p>
                <hr/>
                %if not no_user:
                    <button type="button" class="btn btn-outline-primary w-100 my-1" id="getimplement" data-toggle="tooltip" title="Show instructions on how to create a view on a different site you control"><i class="far fa-code"></i> Implementation code</button>
                %endif
                <button type="button" class="btn btn-outline-success w-100 my-1" id="save" data-toggle="tooltip" title="Save a PNG of the current view"><i class="far fa-camera"></i> Save image</button>
                %if not no_user:
                    <a href="/data/${page}?no_user=1&remote=1&no_buttons=1&key=${key}" class="btn btn-outline-success w-100 my-1"  download="page.html"  data-toggle="tooltip" title="Download this page. Requires an internet connection to access third party libraries."><i class="far fa-download"></i> Download html file</a>
                    %if len(structure_info) == 1:
                        <a href="/save_pdb?uuid=${page}&key=${key}&index=0" class="btn btn-outline-success w-100 my-1"  download="model.pdb" data-toggle="tooltip" title="Download the structure from this page."><i class="far fa-map"></i> Download PDB file</a>
                    %else:
                        <div class="dropdown" id="downloadDropdown">
                          <button class="btn btn-outline-success dropdown-toggle w-100 my-1 " type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false" data-toggle="tooltip" title="Download the nth structure from this page.">
                            <i class="far fa-map"></i> Download PDB file
                          </button>
                          <div class="dropdown-menu " aria-labelledby="dropdownMenuButton">
                              %for i in range(len(structure_info)):
                                <a href="/save_pdb?uuid=${page}&key=${key}&index=${i}" class="dropdown-item"  download="model.pdb"><i class="far fa-map"></i> Download structure &#8470; ${i} (${structure_info[i]["value"] if "value" in structure_info[i] else 'no name on record'})</a>
                              %endfor

                          </div>
                        </div>

                %endif
                %endif
                ###<button type="button" class="btn btn-outline-primary w-100 my-1" data-toggle="modal" data-target="#basics"><i class="far fa-cubes"></i> Protein basics</button>
                %if remote:
                    <button type="button" class="btn btn-outline-primary w-100 my-1" data-toggle="modal" data-target="#about"><i class="far fa-quote-right"></i> Credits</button>
                %endif
                </div>
        </div>
    </div>
    %endif
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
<%include file='edit_modal/mutate_modal.mako'/>
    %if firsttime:
        <%include file='results/wrong.mako'/>
    %endif


</%block>

<%block name='script'>
<script type="text/javascript">
    %if isinstance(pdb,str):
var pdb = `REMARK 666 Note that the indent is important, as is the secondary structure def
${pdb|n}`;
    %elif isinstance(pdb,list):
        %for n,seq in pdb:
var ${n} = `REMARK 666 Note that the indent is important, as is the secondary structure def
${seq|n}`;
        %endfor
    %endif

${loadfun|n}

$(document).ready(function () {
    $('#save').click(function () {
        NGL.getStage('viewport').makeImage({trim: true, antialias: true, transparent: false}).then(NGL.download);
    });

    <%include file="edit_modal/implement_modal.js"/>

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
        <%include file="edit_modal/mutate_modal.js"/>



        $('#report').click((event) => $.ajax({url: "/msg",
                                            data: {'text': prompt("Reason for flagging?", "Data breach"),
                                                    page: "${page}",
                                                    event: 'report'
                                                  },
                                            method: 'POST'
                                        })
                        .done((msg) => ops.addToast('userreportedgood','Reported','Thank you! The site admin will look at the page shortly.', 'bg-success'))
                        .fail(ops.addErrorToast)
                    ); //click.

    %endif

    %if firsttime:
        ops.addToast('isWrong','<i class="far fa-bell"></i> Correct conversion?', 'If the conversion differs from what you were expecting <a href="#" data-toggle="modal" data-target="#wrong_modal"> click here.','bg-warning');
    %endif

    if (window.location.search !== '') {
        var urlParams = new URLSearchParams(window.location.search);
        if (urlParams.has('fbclid')) ops.addToast('fbclid','Debug','Hello Facebook user '+urlParams.get('fbclid'), 'bg-info');
        if (urlParams.has('gclid')) ops.addToast('gclid','Debug','Hello Google user '+urlParams.get('gclid'), 'bg-info');
        if (urlParams.has('prolink')) setTimeout(n => $('.prolink').eq(n).click(), 500, parseInt(urlParams.get('prolink')));

    }


}); //ready
<%include file="edit_modal/tour.js"/>
</script>
</%block>
