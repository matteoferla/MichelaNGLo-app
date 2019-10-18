##### This template is used by both the markup_builder_model and pdb_staging_insert.

<div class="row" id="markup_form">
    <div class="col-12 mb-2"
         title="Choose the focusing mode to use. If unsure consult 'prolinks' page in the documetation. <br/>But briefly, <code>domain</code> is best to show a region or domain. <code>residue</code> is to show residues in selection and their environs. <code>clash</code> shows a clash."
         data-trigger="hover" data-toggle="tooltip"
         data-html=true
         data-placement="left">
        <div class="input-group">
            <div class="input-group-prepend">
                <span class="input-group-text" id="inputGroup-sizing-sm">Zoom to </span>
            </div>
        <div class="btn-group btn-group-toggle" data-toggle="buttons" id="markup_view_toggle">
          % for n in ('domain','residue','clash','surface','bfactor','auto','default','orientation'):
              <label class="btn btn-secondary">
                <input type="radio" name="markup_zoom" id="${n}" autocomplete="off">${n}
              </label>
          % endfor
        </div>
    </div>
    </div>

    <div class="col-12 col-md-6 mb-2" data-trigger="hover" data-toggle="tooltip" data-placement="bottom" title="NGL selection of residues to focus on. <code>1:A</code> will select residue 1 of chain A, <code>1-20:B</code> the residues 1 to 20 of chain B, <code>*</code> for everything. You can only select residues that exist in the structure, if not it will either show all or erroneously pan off camera." data-html=true >
        <div class="input-group">
          <div class="input-group-prepend">
            <span class="input-group-text" id="markup_selection_addon">Selection</span>
          </div>
            <input type="text" class="form-control" placeholder="for example 1-10:A" id="markup_selection" aria-describedby="markup_selection_addon">
            <div class="input-group-append">
                <button class="btn btn-outline-info" type="button" onclick="$('#markup_view').val(''); interactive_changer();"; title="Zoom to residue, discarding current orientation." data-trigger="hover" data-toggle="tooltip" data-placement="top"><i class="fas fa-crosshairs"></i></button>
                <button class="btn btn-outline-info" type="button" id="markup_selection_btn" data-toggle="modal" data-target="#selection_modal"><span data-trigger="hover" data-toggle="tooltip" data-placement="top" title="Show simpler selection builder"><i class="far fa-question"></i></span></button>
            </div>
        </div>
    </div>


    <%
    ##  id type placeholder title
    buttons = (
                ('color','text','yellow', 'The color to show. It is highly recommended to go for light colors as opposed to dark colors and preferable muted or pastel as opposed to primary. Say <span style="color: darkred">DarkRed</span> is hard to seem, <span style="color: red">Red</span> is too sharp, <span style="color: darkred">coral<Coral</span> or <span style="color: magenta">magenta</span> are better.'),
                ('title','text','bla bla', 'The text to show below the structure (optional)'),
                ('radius','number',4, 'How many &aring;ngstr&ouml;m to expand around the residue focused upon. 1.5 &Aring; will show residues that hydrogen bond (if hydrogens are shown), salt bridge or &pi; stack, 3&Aring; will show residues that hydrogen bond (within explicit hydrogens)'),
                ('tolerance','number',1, 'How high to set the threshhold of marking a clash: leave at 1 if unsure &mdash;see "prolink" documentation for more.')
               )
    %>


    %for n,t,d,h in buttons:
        <div class="col-12 col-md-6 mb-2" data-trigger="hover" data-toggle="tooltip" title="${h}" data-html=true data-placement="top" >
        <div class="input-group">
          <div class="input-group-prepend">
            <span class="input-group-text" id="markup_${n}_addon">${n.title()}</span>
          </div>
            <input type="${t}" class="form-control" placeholder="${d}" id="markup_${n}" aria-describedby="markup_${n}_addon">
        </div>
    </div>
    %endfor
    <div class="col-12 col-md-6 mb-2" data-trigger="hover" data-toggle="tooltip" title="By ligand is intended anything with a HETATM entry, so nucleic acids do not count, while modified residues in older structures are often HETATMs." data-html=true data-placement="top">
        <div class="border rounded bg-light p-2">
            <div     class="custom-control custom-switch">
              <input class="custom-control-input"  id="markup_hetero" type="checkbox" >
              <label class="custom-control-label" for="markup_hetero">Show ligands </label>
            </div>
        </div>
    </div>

    <div class="col-12 col-md-6 mb-2" data-trigger="hover" data-toggle="tooltip" title="There are multiple structures in this page. This allows you toggle between them. <code>No model specified</code> will use the currently shown model. If there is only one model and you will not add more ignore this." data-html=true data-placement="top">
        <select class="custom-select" id="markup_model">
          <option selected value="none" name="markup_model">No model specified</option>
        </select>
    </div>

    <div class="input-group mx-3">
      <div class="input-group-prepend">
        <span class="input-group-text" >Orientation</span>
      </div>
      <textarea class="form-control" aria-label="With textarea" rows="1" placeholder="4x4 matrix or 16x1 array" id="markup_view" style="font-size: 80%;"></textarea>
        <div class="input-group-append">
          <div class="input-group-text px-2">
                <div class="custom-control custom-switch">
              <input type="checkbox" class="custom-control-input user-editable-state" id="markup_freeze">
              <label class="custom-control-label" for="markup_freeze">Freeze</label>
            </div>
          </div></button>
      </div>
    </div>
    <div id="differing_view" class="alert alert-warning mx-3 w-100"><i class="far fa-exclamation-triangle"></i> The orientation of the protein differs from the stored one above.</div>

    <div class="col-12 mt-2" id="results">
        <pre><code>&lt;span class="prolink" data-toggle="viewport"&gt;Change a setting!&lt;/span&gt;</code></pre>
    </div>
</div>