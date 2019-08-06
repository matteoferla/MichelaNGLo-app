## route name: /name
## this view is for Gene name/accession id to pdb
<%namespace file="layout_components/labels.mako" name="info"/>
<%inherit file="layout_components/layout_w_card.mako"/>
<%block name="buttons">
            <%include file="layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>
<%block name="title">
            &mdash; Name to PDB
</%block>
<%block name="subtitle">
            Get a model of a protein by querying a name
</%block>

<%block name="main">
    <div class="row">

        <div class="col-12 col-lg-5">
            <div class="input-group mb-3" data-toggle="tooltip"
                                     title="Species">
                <div class="input-group-prepend">
                    <span class="input-group-text">Species</span>
                </div>
                <input type="text" class="form-control" id="species" autocomplete="new-password" value="human">
                <div class="invalid-feedback" id="error_species">Unrecognised name</div>
                <div class="valid-feedback" id="taxid">Error</div>
            </div>
        </div>

        <div class="col-12 col-lg-5">
            <div class="input-group mb-3" data-toggle="tooltip"
                                     title="A gene name, protein name or Uniprot accession.">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text">Gene/protein name</span>
                                    </div>
                                    <input type="text" class="form-control" id="gene" autocomplete="new-password">
                                    <div class="invalid-feedback" id="error_gene">Unrecognised name</div>
                                </div>
        </div>
        <div class="col-2 col-lg-1">
            <button class="btn btn-success" type="button" id="name_fetch">Go</button>
        </div>



        </div>
    <div class="row">
        <div class="col-12" id="matches">

        </div>
    </div>
    <p>For further steps see <a href="/docs/gene">documentation</a>.</p>

</%block>

<%block name='script'>
<script type="text/javascript">
    $(document).ready(function () {
        $('#species').on('input', event => {
            let species = $('#species');
            window.taxid ='ERROR';
            $('#error_species,#taxid').hide();
            species.removeClass('is-valid').removeClass('is-invalid').popover('dispose');
            if (window.species_xhr !== undefined) {
                window.species_xhr.abort();}
            window.species_xhr = $.ajax({url: "/choose_pdb",
                    data: {'item': 'match species',
                           'name': species.val()
                          },
                     method: 'POST',
                     success: msg => { if (msg.taxid !== undefined) {$('#taxid').show().text('Taxid: '+msg.taxid);
                                                                        window.taxid = msg.taxid;
                                                                        species.addClass('is-valid');}
                                       else if (msg.options === 'many') {$('#error_species').show().text('Type more')}
                                       else {
                                           const buttonise = el => `<a href='#' class="list-group-item list-group-item-action" name="species">${'${el}'}</a>`;
                                           let content;
                                           if (msg.options.length > 10) {content = '<div class="list-group">' + msg.options.splice(0,10).map(buttonise).join('')+'</div>'.replace(/\s+/mg,' ');}
                                           else {content = '<div class="list-group">' + msg.options.map(buttonise).join('')+'</div>'.replace(/\s+/mg,' ');}

                                           species.popover({content: content,
                                                            placement: 'bottom',
                                                            html: true})
                                                   .popover('show');
                                            $('.popover .list-group-item').click(event => {species.val($(event.target).text()); species.popover('dispose'); species.trigger('input');})
                                       }
                                     },
                     error: ops.addErrorToast
                    });
    });
        $('#species').trigger('input'); //Cannot guarantee the default/stored value is correct.
        $('#name_fetch').click(event => {
            $('#name_fetch').attr('disabled','disabled');
            let gene = $('#gene');
            let error_gene = $('#error_gene');
            gene.removeClass('is-valid').removeClass('is-invalid');
            error_gene.hide();
            $.ajax({url: "/choose_pdb",
                    data: {'item': 'match gene',
                           'gene': gene.val(),
                           'species': window.taxid
                          },
                     method: 'POST',
                     success: msg => {
                                      if (msg.invalid) {error_gene.show(); gene.addClass('is-invalid')}
                                      else {
                                          if (msg.corrected_gene) {gene.val(msg.corrected_gene)}
                                          gene.addClass('is-valid');
                                          $('#matches').html(msg.pdbs.join(' &mdash; '));}
                ops.addToast('xxx','xxx',JSON.stringify(msg),'bg-warning');
                                      $('#name_fetch').removeAttr('disabled');
                                    },
                     error: ops.addErrorToast
                    });

        });



    });

</script>
</%block>