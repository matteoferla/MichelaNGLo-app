const show_input = (element) => $(element).parent().parent().show();
const hide_input = (element) => $(element).parent().parent().hide();

$('#markup_modal').on('hide.bs.modal', function (e) {
    $('#moved_viewport').before($('#viewport').detach());
    $('#viewport').after('<div id=""></div>');
    $('#moved_viewport').detach();
    NGL.getStage('viewport').handleResize();
});

$('#markup_modal').on('shown.bs.modal', function (e) {
    //move the viewport over...
  $('#viewport').after('<div id="moved_viewport"></div>');
  $('#modal_viewport_box').append($('#viewport').detach());
  NGL.getStage('viewport').handleResize();
    //buttons.
    $('#markup_color').colorpicker();
    $('#markup_title').parent().show();
    $('#markup_selection,#markup_color,#markup_radius,#markup_tolerance').each(function () {hide_input(this)});
    $('#markup_view_toggle label').click(function (){
        $('#markup_view_toggle label').each(function () {$(this).removeClass('btn-success').addClass('btn-secondary');});
        $(this).removeClass('btn-secondary').addClass('btn-success');
    });
    //make stuff toggle
    $('[name="markup_zoom"]').change(function () {
        $('#markup_selection,#markup_color,#markup_radius,#markup_tolerance,#markup_view').each(function () {
            hide_input(this);
            $(this).val('')});
            $('#markup_view').attr('placeholder','optional 16x1 array');
        if ($(this).attr('id') === 'domain') {$('#markup_selection,#markup_color,#markup_view').each(function () {show_input(this)});}
        else if ($(this).attr('id') === 'residue') {$('#markup_selection,#markup_color,#markup_radius,#markup_view').each(function () {show_input(this)});}
        else if ($(this).attr('id') === 'clash') {$('#markup_selection,#markup_color,#markup_radius,#markup_tolerance,#markup_view').each(function () {show_input(this)});}
        else if ($(this).attr('id') === 'orientation') {$('#markup_view').each(function () {show_input(this)});
                                                        $('#markup_view').attr('placeholder','16x1 array or the keywords "auto" or "reset"');}
        else if ($(this).attr('id') === 'auto') {$('#markup_view').each(function () {show_input(this)});
                                                        $('#markup_view').val('auto');}
        else if ($(this).attr('id') === 'default') {$('#markup_view').each(function () {show_input(this)});
                                                        $('#markup_view').val('default');}
        else if ($(this).attr('id') === 'bfactor') {$('#markup_selection,#markup_color,#markup_radius,#markup_view').each(function () {show_input(this)});}
        else if ($(this).attr('id') === 'surface') {$('#markup_view').each(function () {show_input(this)});}

        //
    });
    //////////////// Current //////////////////////////////
    $('#markup_current').click(function () {
        $('#markup_view').val('['+NGL.getStage('viewport').viewerControls.getOrientation().elements.map((v) => Math.round(v*10)/10)+']');
    });
    //////////////// Calculate! ///////////////////////////
    //$('#markup_calculate').click(
    //load domain.
    $('#markup_view_toggle label').first().trigger('click');
    $('#markup_selection').parent().parent().show();
    $('#markup_color').parent().parent().show();

    $('[id^="markup_"]').on('keyup change input', function () {
    $('.is-invalid').removeClass('is-invalid');
    let attributes =['title', 'color','radius','tolerance','view'].reduce(function (c,key){
            var value= $('#markup_'+key).val();
            if (!! value) {return c+'data-'+key+'="'+value+'" '}
            else {return c}
        },'');
    if ($('#markup_hetero').prop('checked')) {
        attributes += 'data-hetero=true ';
    }
    let sel_el = $('#markup_selection');
    if (!! sel_el.val()) {attributes += 'data-selection="'+sel_el.val()+'"'; sel_el.removeClass('is-invalid');}
    else {sel_el.addClass('is-invalid'); attributes += 'data-selection="*"'}
    let mode = $('[name="markup_zoom"]:checked').attr('id');
    let code;
    if (mode === 'default') {
        code = 'data-view="reset"';
    }
    else if (mode === 'auto') {
        code = 'data-view="auto"';
    }
    else if (mode == 'orientation') {
        let view_el = $('#markup_view');
        if (! view_el.val()) {view_el.addClass('is-invalid'); return 0;}
        else {code = 'data-view="'+view_el.val()+'"';
        console.log(typeof view_el)
        }

    }
    else {code = 'data-focus="'+mode+'"'}
    let id = 'viewport';
    let aCode = '<a href="'+id+'" data-toggle="protein" '+code+' '+attributes+'>Try me as an anchor-element</a>';
    let spanCode ='<span class="prolink" data-target="'+id+'" data-toggle="protein" '+code+' '+attributes+'>Try me as a span-element</span>';
    $('#results code').text(aCode+'\n'+spanCode);
    $('#results a').detach();
    $('#results span').detach();
    $('#results p').html(' or ');
    $('#results p').prepend(aCode);
    $('#results p').append(spanCode);
    $('#results a,#results span').protein();
    $('#results a').click();
});

});

