<div class="modal fade" tabindex="-1" role="dialog" id="markup_modal">
  <div class="modal-dialog modal-xl">
    <div class="modal-content">
        <div class="modal-header">
        <h5 class="modal-title">Create custom links</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
        <div class="modal-body">
            <div class="row">
          <div class="col-12 col-md-8">
              <p>This tool allows you to create custom anchor elements that control the protein.</p>
            <div class="row">
                <div class="col-12 mb-2">
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


                %for n,t,d in (('selection','text', '1-10:A'),('color','text','yellow'),('title','text','bla bla'),('radius','number',4),('tolerance','number',1)):
                    <div class="col-12 col-md-6 mb-2">
                    <div class="input-group">
                      <div class="input-group-prepend">
                        <span class="input-group-text" id="markup_${n}_addon">${n.title()}</span>
                      </div>
                        <input type="${t}" class="form-control" placeholder="${d}" id="markup_${n}" aria-describedby="markup_${n}_addon">
                    </div>
                </div>
                %endfor
                <div class="col-12 col-md-6 mb-2">
                    <div class="border rounded bg-light p-2">
                        <div     class="custom-control custom-switch">
                          <input class="custom-control-input"  id="markup_hetero" type="checkbox" >
                          <label class="custom-control-label" for="markup_hetero">Show ligands </label>
                        </div>
                    </div>
                </div>
                <div class="input-group mb-2 mx-3">
                  <div class="input-group-prepend">
                    <span class="input-group-text" >Orientation</span>
                  </div>
                  <textarea class="form-control" aria-label="With textarea" rows="3" placeholder="4x4 matrix or 16x1 array" id="markup_view" style="font-size: 80%;"></textarea>
                    <div class="input-group-append">
                    <button class="btn btn-outline-info" id="markup_current">Get</button>
                  </div>
                </div>
                <div class="col-6 col-md-4 mb-2">
                <button type="button" class="btn btn-outline-success w-100" id="markup_calculate"><i class="far fa-magic"></i> Make</button>
                </div>

                <div class="col-12" id="results">
                    <pre><code></code></pre>
                    <p><a>Press make first!</a></p>
                </div>
                <div class="col-12">
                <h5>Details</h5>
                <p>The difference between the two types of link is that the a-element ("anchor" element) is a regular link,
                    while the span element is just a span of text with custom styling: for example the protein-controlling elements are green in this site because they are span elements with the extra styling conferred by the attribute <code>class="prolink"</code>. The CSS style of this class is declared in the stylesheet as:</p>
                <pre><code>.prolink {
	color: mediumseagreen;
}

.prolink:hover {
	color: seagreen;
	cursor: pointer;
	text-decoration: underline;
}</code></pre>
                </div>
            </div>

          </div>
          <!-- RHS-->
          <div class="col-12 col-md-4" id="modal_viewport_box">
          </div>
      </div>
    </div>
        </div>
  </div>
</div>
