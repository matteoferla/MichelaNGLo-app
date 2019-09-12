## route name: /name
## this view is for Gene name/accession id to pdb
<%namespace file="../layout_components/labels.mako" name="info"/>
<%inherit file="../layout_components/layout_w_card.mako"/>
<%block name="buttons">
            <%include file="../layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>
<%block name="title">
            &mdash; VENUS MOD
</%block>
<%block name="subtitle">
            ???????????
</%block>

<%block name="main">
    <p>TEST.</p>
    <div class="row">
        <div class="col-12 col-lg-4">
            <div class="input-group mb-3" data-toggle="tooltip"
                                     title="Species">
                <div class="input-group-prepend">
                    <span class="input-group-text">Species</span>
                </div>
                <input type="text" class="form-control rounded-right" id="species" autocomplete="new-password" value="human">
                <div class="invalid-feedback" id="error_species">Unrecognised name</div>
                <div class="valid-feedback" id="taxid">Error</div>
            </div>
        </div>

        <div class="col-12 col-lg-4">
            <div class="input-group mb-3" data-toggle="tooltip"
                                     title="A gene name, protein name or Uniprot accession.">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text">Gene/prot. name</span>
                                    </div>
                                    <input type="text" class="form-control rounded-right" id="gene" autocomplete="new-password">
                                    <div class="invalid-feedback" id="error_gene">Unrecognised name</div>
                                    <div class="valid-feedback" id="uniprot">Error</div>
                                </div>
        </div>

        <div class="col-12 col-lg-4">
            <div class="input-group mb-3" data-toggle="tooltip"
                                     title="A protein mutation within the canonical transcript of the chosen gene (e.g. p.A20W)">
                                <div class="input-group-prepend">
                                    <span class="input-group-text">Mutation</span>
                                </div>
                                <input type="text" class="form-control rounded-right" id="mutation" autocomplete="new-password">
                                <div class="invalid-feedback" id="error_mutation">Unrecognised mutation</div>
                                <div class="valid-feedback" id="mutation_valid">Error</div>
                            </div>
        </div>

        <div class="col-12 offset-lg-4 col-lg-4">
            <button type="button" class="btn btn-outline-primary w-100" id="venus_calc" style="display: none;">Analyse</button>
        </div>
    </div>

</%block>

<%block name='modals'>
</%block>

<%block name='script'>
<script type="text/javascript">
    $(document).ready(function () {
        <%include file="../name.js"/>
        const vbtn = $('#venus_calc');
        $('#mutation').keyup(e => {if ($(e.target).val().search(/\d+/) !== -1 && uniprotValue !== 'ERROR') {
                                                vbtn.show();
                                                $('#error_mutation').hide();
                                                $(e.target).removeClass('is-invalid');
                                                if (event.keyCode === 13) vbtn.click();
                                        } else {vbtn.hide();}
                                    });
        vbtn.click(e => {
            if (taxidValue === 'ERROR') {$('#error_species').show(); return 0;}
            if (uniprotValue === 'ERROR') {$('#error_gene').show(); return 0;}
            if ($('#mutation').val().search(/\d+/) === -1) {$('#error_mutation').show(); return 0;}

                $.ajax({
        type: "POST",
        url: "venus_analyse",
        data:  {uniprot: uniprotValue,
                species: taxidValue,
                mutation: $('#mutation').val()}
    })
        .done(function (msg) {
            if (msg.error) {
                $('#error_'+msg.error).show();
                $('#'+msg.error).addClass('is-invalid');
                ops.addToast('error','Error - '+msg.error,'<i class="far fa-bug"></i> An issue arose analysing the results.<br/>'+msg.msg,'bg-warning');}
            else {
                $('#retrieval_card').hide(1000);
            $('#input_card').hide(1000);
            $('main').append(msg);
            $('#new_analysis').show();
            $('#report-btn').show();
            }
        })
        .fail(ops.addErrorToast);
        });
    });
    ####include file="../markup/markup_builder_modal.js"/>
    window.interactive_builder = () => undefined; //burn the call.
</script>
    <link rel="stylesheet" href="https://www.matteoferla.com//feature-viewer/css/style.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.17/d3.js"></script>
    <script src="https://cdn.rawgit.com/calipho-sib/feature-viewer/v1.0.0/dist/feature-viewer.min.js"></script>
</%block>