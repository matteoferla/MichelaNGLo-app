<%block name="options_html">
    <button type="button" class="btn btn-success w-100 my-1" id="save"><i class="far fa-camera"></i> Take snapshot</button><div class="dropdown">
    <button class="btn btn-secondary dropdown-toggle w-100" type="button" id="residueButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
    <i class="far fa-search"></i> Zoom to a view
    </button>
    <div class="dropdown-menu" aria-labelledby="residueMenuButton" id="residue">
    </div>
    </div>
    <button type="button" class="btn btn-outline-primary w-100 my-1" id="store_view_btn" data-target="#store_view_modal" data-toggle="modal"><i class="far fa-save"></i> Store view</button>
    <button type="button" class="btn btn-primary w-100 my-1" data-toggle="modal" data-target="#basics"><i class="far fa-cubes"></i> Protein basics</button>
    <button type="button" class="btn btn-primary w-100 my-1" data-toggle="modal" data-target="#about"><i class="far fa-code"></i> Credits</button>
    <div id="fv"></div>
</%block>

<%block name="options_js">
    ...
</%block>
