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
    $('#markup_title').parent().show();
    $('#markup_selection,#markup_color,#markup_radius,#markup_tolerance,#markup_orient').each(function () {$(this).parent().hide()});
    $('#markup_view_toggle label').click(function (){
        $('#markup_view_toggle label').each(function () {$(this).removeClass('btn-success').addClass('btn-secondary');});
        $(this).removeClass('btn-secondary').addClass('btn-success');
    });
    //make stuff toggle
    $('[name="markup_zoom"]').change(function () {
        $('#markup_selection,#markup_color,#markup_radius,#markup_tolerance,#markup_orient').each(function () {
            $(this).parent().hide();
            $(this).val('')});
        if ($(this).attr('id') === 'domain') {$('#markup_selection,#markup_color').each(function () {$(this).parent().show()});}
        else if ($(this).attr('id') === 'residue') {$('#markup_selection,#markup_color,#markup_radius').each(function () {$(this).parent().show()});}
        else if ($(this).attr('id') === 'clash') {$('#markup_selection,#markup_color,#markup_radius,#markup_tolerance').each(function () {$(this).parent().show()});}
        else if ($(this).attr('id') === 'orientation') {$('#markup_orient').each(function () {$(this).parent().show()});}
        else {}
        //
    });
    //////////////// Current //////////////////////////////
    $('#markup_current').click(function () {
        $('#markup_orient').val('['+NGL.getStage('viewport').viewerControls.getOrientation().elements+']');
    });
    //////////////// Calculate! ///////////////////////////
    $('#markup_calculate').click(function () {
    $('.markup_modal .is-invalid').removeClass('is-invalid');
    var attributes =['title','selection','color','radius','tolerance','orientation'].reduce(function (c,key){
            var value= $('#markup_'+key).val();
            if (!! value) {return c+'data-'+key+'="'+value+'"'}
            else {return c}
        },'');
    var mode = $('[name="markup_zoom"]:checked').attr('id');
    if (mode === 'default') {
        code = 'data-view="reset"';
    }
    else if (mode === 'auto') {
        code = 'data-view="auto"';
    }
    else if (mode == 'orientation') {
        var d=$('#markup_orient').val();
        if (! d) {$('#markup_orient').addClass('is-invalid');}
        code = 'data-view="'+d+'"';
    }
    else {code = 'data-focus="'+mode+'"'}
    var id = '#viewport';
    code = '<a href="'+id+'" '+code+' '+attributes+'>Try me</a>';
    console.log(code);

    $('#results code').text(code);
    $('#results a').detach();
    $('#results').append(code);
    $('#results a').protein();
});
});

