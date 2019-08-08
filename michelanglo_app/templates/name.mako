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
    <p>This form simply searches for PDBs that match your protein. It does not account for homologues or models. For information on how to get the perfect model for your protein see <a href="/docs/gene">documentation</a>.</p>
    <div class="row">

        <div class="col-12 col-lg-6">
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

        <div class="col-12 col-lg-6">
            <div class="input-group mb-3" data-toggle="tooltip"
                                     title="A gene name, protein name or Uniprot accession.">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text">Gene/protein name</span>
                                    </div>
                                    <input type="text" class="form-control rounded-right" id="gene" autocomplete="new-password">
                                    <div class="invalid-feedback" id="error_gene">Unrecognised name</div>
                                    <div class="valid-feedback" id="uniprot">Error</div>
                                </div>
        </div>



        </div>
    <div class="row">
        <div class="col-12" id="ext_links">

        </div>
        <div class="col-12" id="matches">

        </div>
    </div>
    <div id="staging" style="display: none;">
        <%include file="pdb_staging_insert.mako"/>
    </div>

</%block>

<%block name='modals'>
    <%include file="markup/markup_builder_modal.mako"/>
</%block>

<%block name='script'>
<script type="text/javascript">
    $(document).ready(function () {
        $('#species').on('input', event => {
            let species = $('#species');
            window.taxid ='ERROR';
            $('#error_species,#taxid,#uniprot').hide();
            species.removeClass('is-valid').removeClass('is-invalid').popover('dispose');
            if (window.species_xhr !== undefined) {
                window.species_xhr.abort();}
            $('#matches').html(' ');
            $('#ext_links').html(' ');
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
        // starting value. Cannot guarantee the default/stored value is correct.
        let species = $('#species');
        if (species.val().toLowerCase() === 'human') {species.val('Human'); window.taxid=9606; species.addClass('is-valid'); $('#taxid').show().text('Taxid: 9606');}
        else { species.trigger('input');}
        // gene.
        $('#gene').on('input', event => {
            if (window.gene_xhr !== undefined) {
                window.gene_xhr.abort();}
            let gene = $('#gene');
            let error_gene = $('#error_gene');
            gene.removeClass('is-valid').removeClass('is-invalid');
            error_gene.hide();
            $('#matches').html(' ');
            $('#ext_links').html(' ');
            window.gene_xhr = $.ajax({url: "/choose_pdb",
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
                                          $('#uniprot').show().html('Uniprot: <a href="https://www.uniprot.org/uniprot/'+msg.uniprot+'" target="_blank">'+msg.uniprot+' <i class="far fa-external-link-alt"></i></a>');
                                          $('#ext_links').html('<a>View <a href="www.rcsb.org/pdb/protein/'+msg.uniprot+'" target="_blank">PDB entry</a> for more information. If no structures are available see <a href="https://swissmodel.expasy.org/repository/uniprot/'+msg.uniprot+'" target="_blank">Swiss-Model entry</a>.</p>');
                                          let matches = $('#matches');
                                          if (msg.pdbs.length > 0) {
                                              matches.html(msg.pdbs.map(v => v+' <i class="fas fa-spinner fa-spin"></i>').join(' <br/> '));
                                              get_pdbs(msg.pdbs);
                                          } else {
                                              matches.html('No crystal structures to show.');
                                          }
                                      }
                                    },
                     error: ops.addErrorToast
                    });

        });

        window.get_pdbs = pdbs => {
            $.ajax({
                url: "/choose_pdb",
                data: {
                    'item': 'get_pdbs',
                    'entries': pdbs,
                    'species': window.taxid
                },
                method: 'POST',
                success: msg => {
                    if (msg.descriptions !== undefined) {
                        $('#matches').html(msg.descriptions);
                        $('[name="pdb"]').click(event => load_pdb( $( event.target).data('code') ) );
                    }
                    else {ops.addToast('issue', 'Issue', JSON.stringify(msg),'bg-danger');}
                },
                error: ops.addErrorToast
            });
        };

        window.load_pdb = pdb => {
            $('#staging').show();
            window.pdb = pdb;
            window.myData = undefined;
            NGL.stageIds = {};
            $('#viewport').html('');
            $('#viewcode').text('<div role="NGL" data-load="'+pdb+'" ></div>');
            NGL.specialOps.multiLoader('viewport',[{'type': 'rcsb','value': pdb}]);
            NGL.specialOps.showTitle('viewport', 'Loaded: '+ pdb);
            $('html, body').animate({
                    scrollTop: $('#staging').offset().top
                }, 2000);
        };

        <%include file="markup/markup_builder_modal.js"/>

        <%include file="pdb_staging_insert.js"/>


    });

</script>
</%block>