<h3>Step 2 <small class="text-muted">Configure initial view</small></h3>
        <div class="row">
        <div class="col-6"><div id="viewport" style="width: 100%; height: 0; padding-bottom: 100%;"></div>
        </div>
        <div class="col-6">
            <p>Choose how the starting view of the protein should look like.</p>


            <div class="input-group mb-3">
              <div class="input-group-prepend">
                <span class="input-group-text" id="viewcode-label">Viewport code</span>
              </div>
              <textarea rows=5 type="text" class="form-control" aria-label="Viewport code" aria-describedby="viewcode-label" id="viewcode">
                  </textarea>
                  <div class="input-group-append d-flex flex-column" role="group">
                <button type="button" class="btn btn-info rounded-right mb-2" data-toggle="modal" data-target="#markup_modal" style="height: 3.9rem;"><i class="far fa-hammer"></i> Build link code</button>
                <button type="button" class="btn btn-primary rounded-right" id="create" style="height: 3.9rem;"><i class="far fa-pencil-ruler"></i> Make page</button>
                  </div>
            </div>
        </div>
        </div>