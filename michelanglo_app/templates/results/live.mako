<%page args="viewport='error', proteinJSON='ERROR', backgroundcolor='red', image=False, loadfun='ERROR (child)', pdb=''" />
<div class="row">
    <div class="col-12 col-md-12">
        <div id="viewport" role="NGL" data-proteins='${proteinJSON}' data-backgroundcolor="${backgroundcolor}">
            % if image:
        <img src="images/clickmap.jpg" alt="clickmap" width='100%' style='cursor: pointer' alt="clickmap">
            % endif
        </div></div>
    <div class="col-12 col-md-2">
        <button type="button" class="btn btn-success w-100 my-1" id="save"><i class="far fa-camera"></i> Take snapshot</button>
        <button type="button" class="btn btn-primary w-100 my-1" data-toggle="modal" data-target="#basics"><i class="far fa-cubes"></i> Protein basics</button>
        <button type="button" class="btn btn-primary w-100 my-1" data-toggle="modal" data-target="#about"><i class="far fa-code"></i> About</button>
    </div>
</div>



<script type="text/javascript">
    % if pdb:
        var pdb = `REMARK 666 Note that the indent is important as is the secondary structure def.
${pdb}`;
    % endif

    ${loadfun|n}

    window.myData=undefined;
    $('[role="NGL"]').viewport();
</script>
