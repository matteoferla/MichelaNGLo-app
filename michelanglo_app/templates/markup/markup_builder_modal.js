

// this gets called only in modal mode. so it's fine.
$('#markup_modal').on('shown.bs.modal', function (e) {
    //move the viewport over...
  $('#viewport').after('<div id="moved_viewport"></div>');
  $('#modal_viewport_box').append($('#viewport').detach());
  NGL.getStage('viewport').handleResize();
  interactive_builder();
});

// as above
$('#markup_modal').on('hide.bs.modal', function (e) {
    $('#moved_viewport').before($('#viewport').detach());
    $('#viewport').after('<div id=""></div>');
    $('#moved_viewport').detach();
    NGL.getStage('viewport').handleResize();
});

// update on change (see interactive_builder)
window.interactive_changer = (event, noRun) =>  {
    $('.is-invalid').removeClass('is-invalid');
    let attributes =['title', 'color','radius','tolerance','view'].reduce(function (c,key){
            var value= $('#markup_'+key).val();
            if (!! value) {return c+'data-'+key+'="'+value+'" '}
            else {return c}
        },'');
    if ($('#markup_hetero').prop('checked')) {
        attributes += 'data-hetero=true ';
    }
    let mode = $('[name="markup_zoom"]:checked').attr('id');
    let sel_el = $('#markup_selection');
    if ((!! sel_el.val()) && (NGL.getStage().getComponentByType('structure').structure.getView(new NGL.Selection(sel_el.val())).atomCount !== 0)) {
        attributes += 'data-selection="'+sel_el.val()+'"';
        $('.is-invalid').removeClass('is-invalid');
    }
    else {sel_el.addClass('is-invalid');
          // load star if not residue...
          if (mode === 'residue' || mode === 'clash') {attributes += 'data-selection="hetero"'} else {attributes += 'data-selection="*"'}
          let msele = $('[id^="sele_"]:focus');
          if (msele) {msele.addClass('is-invalid')}
          }
    let code;
    if (mode === 'default') {
        code = 'data-view="reset"';
    }
    else if (mode === 'auto') {
        code = 'data-view="auto"';
    }
    else if (mode == 'orientation') {
        let view_el = $('#markup_view');
        if (! view_el.val()) {view_el.addClass('is-invalid'); setInterval(() => view_el.removeClass('is-invalid'),1000); return 0;}
        else {code = 'data-view="'+view_el.val()+'"';
        }

    }
    let model = $('#markup_model').children(':selected').val();
    if (model !== 'none') {attributes+= ` data-load="${"${model}"}"`}
    else {code = 'data-focus="'+mode+'"'}
    let id = 'viewport';
    let spanCode ='<span class="prolink" data-target="'+id+'" data-toggle="protein" '+code+' '+attributes+'>Try me as a span-element</span>';
    $('#results code').text(spanCode);
    //$('#results span').detach();
    //$('#results p').append(spanCode);
    if (! noRun) {NGL.specialOps.prolink(spanCode);}
    $('#differing_view').hide(); // Unfortunate side-effect is that the orientation is reset.
};

// call manually not in modal mode.
window.interactive_builder = () => {
    //buttons.
    $('#markup_color').colorpicker();
    // make it more clear what is clicked!
    $('#markup_view_toggle label').click(function (){
        $('#markup_view_toggle label').each(function () {$(this).removeClass('btn-success').addClass('btn-secondary');});
        $(this).removeClass('btn-secondary').addClass('btn-success');
    });
    //make stuff toggle
    ///const hide_input = (element) => $(element).parent().parent().hide();
    const hide_input = (sele) => $(sele).each(function () {$(this).val(''); $(this).parent().parent().hide();});
    //const show_input = (element) => $(element).parent().parent().show();
    const show_input = (sele) => $(sele).each(function () {$(this).parent().parent().show()});

    $('[name="markup_zoom"]').change(function () {
        //show everything
        show_input('#markup_selection,#markup_color,#markup_radius,#markup_tolerance,#markup_view,#markup_title');
        //hide and clear unwanted
        switch($(this).attr('id')) {
          case 'domain':
            hide_input('#markup_radius,#markup_tolerance');
            break;
          case 'residue':
            hide_input('#markup_tolerance');
            break;
          case 'orientation':
            hide_input('#markup_selection,#markup_color,#markup_radius,#markup_tolerance');
            if (['', 'auto','default'].some(v => $('#markup_view').val() === v)) {$('#markup_view').val('['+NGL.getStage('viewport').viewerControls.getOrientation().elements.map((v) => Math.round(v*10)/10)+']');}
            $('#markup_freeze').prop("checked", false);
            break;
          case 'auto':
            hide_input('#markup_selection,#markup_color,#markup_radius,#markup_tolerance');
            $('#markup_view').val('auto');
            $('#markup_freeze').prop("checked", true);
            break;
          case 'default':
            hide_input('#markup_selection,#markup_color,#markup_radius,#markup_tolerance');
            $('#markup_view').val('default');
            $('#markup_freeze').prop("checked", true);
            break;
          case 'bfactor':
            hide_input('#markup_radius,#markup_tolerance');
            break;
          case 'surface':
            hide_input('#markup_radius,#markup_tolerance');
            break;
          default:
            // code block
        }});

    //////////////// Get current view //////////////////////////////
    // this is not independent why? The element does not gets created on show. It's a modal not a tooltip.
    $('#markup_current').click(function () {
        $('#differing_view').hide();
        $('#markup_view').val('['+NGL.getStage('viewport').viewerControls.getOrientation().elements.map((v) => Math.round(v*10)/10)+']');
        interactive_changer();
    });

    let modelSelector = $('#markup_model');
    myData.proteins.forEach(  ({value, type}) => modelSelector.append(`<option value="${"${value}"}">${"${value}"}</option>`) );
    //////////////// Ready ///////////////////////////
    //$('#markup_calculate').click(
    //load domain.
    $('#markup_view_toggle label').first().trigger('click');
    $('#markup_selection').parent().parent().show();
    $('#markup_color').parent().parent().show();
    // change on change.
    $('#markup_form [id^="markup_"]').on('keyup change input', interactive_changer);
    //alert view change.
    $('#markup_freeze').prop("checked", false);
    $('#differing_view').hide();
    window.alertDifference = () => {
        if ($('#markup_freeze').prop("checked") == true) {$('#differing_view').show()}
        else {$('#markup_view').val('['+NGL.getStage('viewport').viewerControls.getOrientation().elements.map((v) => Math.round(v*10)/10)+']');
                interactive_changer(undefined,true); //this will update the code but not run it.
        }
    };
    const sigs = NGL.getStage().mouseObserver.signals;
    sigs.scrolled.add(alertDifference);
    //sigs.moved.add(alertDifference);
    sigs.dragged.add(alertDifference);
};

 $('#selection_modal').on('shown.bs.modal', () => {
        $('#sele_chain,#sele_chain2').html('<option value=" ">from all chains</option>');
        //get names if present...
        let structure = NGL.getStage().getComponentByType('structure').structure;
        // get the chainame:
        let chainNames = structure.chainStore.chainname;
        // chainname is a structure where the first of each three entires is the actual chain letter as a int:
        chainNames = chainNames.filter(v => v>48);
        // chainNames is a uint8 array and needs converting to letter:
        chainNames = Array.from(chainNames).map(v => String.fromCharCode(v));
        let entityList =structure.entityList;
        if (entityList.length > 0) {
            for (let i=0; i< entityList.length; i++) {
                //.map(v => structure.chainname[v])
                for (let j=0; j < entityList[i].chainIndexList.length; j++) {
                    if (entityList[i].entityType === 1) {
                        let I = entityList[i].chainIndexList[j];
                        let v = chainNames[I];  // let's pray to baby Jesus that order matches.
                        let n = entityList[i].description;
                        $('#sele_chain,#sele_chain2').append(`<option value=":${'${v}'}">from chain ${'${v}'} (${'${n}'})</option>`);
                    }
                }
            }
        }
        else {
             // chainNames sometimes has some repeats?! hetero?
            chainNames = chainNames.filter((v, i, a) => a.indexOf(v) === i);
            chainNames.sort().forEach(v => $('#sele_chain,#sele_chain2').append(`<option value=":${'${v}'}">from chain ${'${v}'}</option>`));
        }
        // add elements

        $('#sele_chain option').eq(0).attr('selected', 'selected');
        //option A
        const optA = event => {
            $('#markup_selection').val($('#sele_string').val());
            interactive_changer();
        };
        $('#sele_string').on('keyup change input', optA);
        $('#sele_string_btn').click(event => {optA(event); $('#selection_modal').modal('hide');});
        //option B1
        const optB1 = event => {
            let sele = $('#sele_resi').val() + $('#sele_chain').val();
            $('#markup_selection').val(sele);
            interactive_changer();
        };
        $('#sele_resi,#sele_chain').on('keyup change input', optB1);
        $('#sele_resi_btn').click(event => {optB1(event); $('#selection_modal').modal('hide');});
        //option B2
        const optB2 = event => {
            let sele = $('#sele_from').val() +'-'+$('#sele_to').val()+ $('#sele_chain2').val();
            $('#markup_selection').val(sele);
            interactive_changer();
        };
        $('#sele_from,#sele_to,#sele_chain2').on('keyup change input', optB2);
        $('#sele_range_btn').click(event => {optB2(event); $('#selection_modal').modal('hide');});
    });




