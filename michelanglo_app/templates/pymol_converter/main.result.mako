<%page args="snippet=False, error='', error_msg='', error_title='', validation='', viewport='viewport', image=False, save='', backgroundcolor='white', loadfun='ERROR (parent)', proteinJSON='ERROR (Parent)', pdb=''"/>
<%namespace file="../layout_components/labels.mako" name="info"/>

<li class="list-group-item" id="results">
    #### <div class="float-right"><button type="button" class="btn btn-outline-secondary" id="tour_result"><i class="far fa-question"></i></button></div>
    <h3>Results</h3>

    % if error:
        <div class="alert alert-${error}" role="alert">
            <h4 class="alert-heading">${error_title}</h4>
            <p>${error_msg}</p>
            <hr>
            <p class="mb-0">If you believe this is incorrect please let Matteo know!</p>
        </div>
    % endif

    % if snippet:
       #### tab control
    <nav>
      <div class="nav nav-tabs" id="nav-tab" role="tablist">
        <a class="nav-item nav-link active" id="nav-protein-tab" data-toggle="tab" href="#nav-protein" role="tab" aria-controls="nav-protein" aria-selected="true">Live</a>
        <a class="nav-item nav-link" id="nav-downloads-tab" data-toggle="tab" href="#nav-downloads" role="tab" aria-controls="nav-downloads" aria-selected="false">Shareables</a>
        <a class="nav-item nav-link" id="nav-implement-tab" data-toggle="tab" href="#nav-implement" role="tab" aria-controls="nav-implement" aria-selected="false">Instructions</a>
        ##<a class="nav-item nav-link" id="nav-validate-tab" data-toggle="tab" href="#nav-validate" role="tab" aria-controls="nav-validate" aria-selected="false">Validation</a>
        </div>
    </nav>
        <br/>
           #### tabs
    <div class="tab-content" id="nav-tabContent">

           #### first tab: live
      <div class="tab-pane fade show active" id="nav-protein" role="tabpanel" aria-labelledby="nav-protein-tab">
           <%include file="../results/live.mako" args="viewport=viewport, backgroundcolor=backgroundcolor, image=image, loadfun=loadfun, proteinJSON=proteinJSON, pdb=pdb"/>
      </div>

            #### second tab: download
        <div class="tab-pane fade" id="nav-downloads" role="tabpanel" aria-labelledby="nav-downloads-tab">
            <div class="list-group border border-rounded">
                % if page:
                  <a href="data/${page}" class="list-group-item list-group-item-action">
                    <i class="far fa-handshake"></i> Sharable and editable version
                  </a>
                % endif
              <a href="/data/${page}?no_user=1&remote=1&no_buttons=1" class="list-group-item list-group-item-action" download="page.html"><i class="far fa-download"></i> Download file</a>
              <a href="/save_pdb?uuid=${page}" class="list-group-item list-group-item-action" download="model.pdb"><i class="far fa-map"></i> Download PDB</a>
            </div>
      </div>

        #### third tab: implement
      <div class="tab-pane fade" id="nav-implement" role="tabpanel" aria-labelledby="nav-implement-tab">
          <%include file="../results/implement.mako" args="viewport=viewport, backgroundcolor=backgroundcolor, image=image, loadfun=loadfun, proteinJSON=proteinJSON, pdb=pdb"/>
      </div>

       ### fourth tab: code removed.

   % if validation and 1==0:
       ### fith tab: validation
           <div class="tab-pane fade" id="nav-validate" role="tabpanel" aria-labelledby="nav-validate-tab">
           <p>This code can be used to validate the orientation in PyMOL (i.e. go full circle)</p>
        <pre class="p-2"><div class="float-right"><a href="#validation_code" data-clipboard-target="#validation_code" id="copy_validation">Copy</a></div>
                <code id="validation_code">${validation}</code></pre>
       </div>
    % endif


    </div>
    % endif
</li>


<script type="text/javascript">
        new ClipboardJS('.clipboard');




        #####<%include file="results/tour.js"/>


    </script>
<%include file="../userpage_components/about.mako"/>
<%include file="../userpage_components/basics.mako"/>
