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
    <p>This form simply searches for PDBs that match your protein for your convenience. It does not account for homologues or models. Also it does not know if the protein has a shape-change, for which reading the litterature is required. For information on how to get the perfect model for your protein see <a href="/docs/gene">documentation</a>.</p>
    <div class="row">

        <div class="col-12 col-lg-5">
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

        <div class="col-12 col-lg-5">
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
        <div class="col-12 col-lg-2">
            <button type="button" class="btn btn-outline-primary w-100" id="pdb_fetch" style="display: none;">Fetch</button>
        </div>



        </div>
    <div class="row">
        <div class="col-12">
            <div id="fv"></div>
        </div>

        <div class="col-12" id="matches">

        </div>

        <div class="col-12" id="ext_links">

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

        $('#species').on('keyup', event => {
            let species = $('#species');
            window.taxid ='ERROR';
            $('#error_species,#taxid,#uniprot').hide();
            species.removeClass('is-valid').removeClass('is-invalid').popover('dispose');
            if (window.species_xhr !== undefined) {
                window.species_xhr.abort();}
            window.reset_gene();
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
                     error: (xhr) => {if (xhr.statusText =='abort' || xhr.status === 0 || xhr.readyState === 0) {return;} else {ops.addErrorToast(xhr)}}
            });
    });
        // starting value. Cannot guarantee the default/stored value is correct.
        let species = $('#species');
        if (species.val().toLowerCase() === 'human') {species.val('Human'); window.taxid=9606; species.addClass('is-valid'); $('#taxid').show().text('Taxid: 9606');}
        else { species.trigger('input');}
        // gene.
        window.uniprot = 'ERROR';
        $('#gene').on('keyup', event => {
            if (window.gene_xhr !== undefined) {
                window.gene_xhr.abort();}
            if (window.taxid === 'ERROR') {
                //ops.addToast('taxid','Issue','Please check species is correct.','bg-info');
                $('#species').addClass('is-invalid');
                $('#error_species').show().text('Unknown species');
                return 0;
            }
            let gene = $('#gene');
            let error_gene = $('#error_gene');
            window.reset_gene();
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
                                          window.uniprot = msg.uniprot;
                                          window.pdbs = msg.pdbs;
                                          $('#uniprot').show().html('Uniprot: <a href="https://www.uniprot.org/uniprot/'+msg.uniprot+'" target="_blank">'+msg.uniprot+' <i class="far fa-external-link-alt"></i></a>');
                                          $('#pdb_fetch').show();
                                          if (event.keyCode === 13) {$('#pdb_fetch').click()}
                                      }
                                    },
                     error: ops.addErrorToast
                    });

        });

        window.get_pdbs = pdbs => {
            if (window.taxid === 'ERROR') {
                //ops.addToast('taxid','Issue','Please check species is correct.','bg-info');
                $('#species').addClass('is-invalid');
                $('#error_species').show().text('Unknown species');
                return 0;
            }
            if (window.pdbs_xhr !== undefined) {
                window.pdbs_xhr.abort();}
            window.pdbs_xhr = $.ajax({
                url: "/choose_pdb",
                data: {
                    'item': 'get_pdbs',
                    'entries': pdbs,
                    'uniprot': window.uniprot,
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
                error: (xhr) => {if (xhr.statusText =='abort' || xhr.status === 0 || xhr.readyState === 0) {return;} else {ops.addErrorToast(xhr)}}
            });
        };

        window.get_uniprot = () => $.ajax({
                url: "/choose_pdb",
                data: {
                    'item': 'get_uniprot',
                    'uniprot': window.uniprot,
                    'species': window.taxid
                },
                method: 'POST',
                success: msg => eval(msg),
                error: ops.addErrorToast
            });

        window.load_pdb = pdb => {
            $('#staging').show();
            window.pdb = pdb;
            window.myData = undefined;
            NGL.stageIds = {};
            $('#viewport').html('');
            $('#viewcode').text('<div role="NGL" data-load="'+pdb+'" ></div>');
            NGL.specialOps.multiLoader('viewport',[{'type': 'rcsb','value': pdb}]);
            NGL.specialOps.showTitle('viewport', 'Loaded: '+ pdb);
            interactive_builder();
            $('html, body').animate({
                    scrollTop: $('#staging').offset().top
                }, 2000);
        };

        $('#pdb_fetch').click(event => {
            $(event.target).hide();
            $('#ext_links').html('<p>For more information see the <a href="https://www.rcsb.org/pdb/protein/'+window.uniprot+'" target="_blank">PDB entry <i class="far fa-external-link-alt"></i></a>. If no structures are available see <a href="https://swissmodel.expasy.org/repository/uniprot/'+window.uniprot+'" target="_blank">Swiss-Model entry <i class="far fa-external-link-alt"></i></a>.</p>');
            get_uniprot();
            let matches = $('#matches');
              if (window.pdbs.length > 0) {
                  matches.html(window.pdbs.map(v => v+' <i class="fas fa-spinner fa-spin"></i>').join(' <br/> '));
                  get_pdbs(window.pdbs);
              } else {
                  matches.html('No crystal structures to show.');
              }
        });

        window.reset_gene = () => {
            $('#gene').removeClass('is-valid').removeClass('is-invalid');
            $('#error_gene').hide();
            $('#matches').html(' ');
            $('#fv').html(' ');
            $('#ext_links').html(' ');
            $('#pdb_fetch').hide();
        };


        <%include file="markup/markup_builder_modal.js"/>

        <%include file="pdb_staging_insert.js"/>

    });
</script>
    <link rel="stylesheet" href="https://www.matteoferla.com//feature-viewer/css/style.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.17/d3.js"></script>
    <script src="https://cdn.rawgit.com/calipho-sib/feature-viewer/v1.0.0/dist/feature-viewer.min.js"></script>
</%block>