<%inherit file="layout.mako"/>
<%namespace file="labels.mako" name="info"/>
<div class="card">
    <div class="card-header">
        <h1 class="card-title">PyMOL&rarr;NGL transpiler
            <div class="float-right">
                <button type="button" class="btn btn-outline-secondary"><i class="far fa-question"></i></button><br/>
                <button type="button" class="btn btn-outline-secondary"><i class="fab fa-github"></i></button>
            </div>
        </h1>
        <h3 class="card-subtitle mb-2 text-muted">Generate a NGL view from a PyMOL PSE file.</h3>
    </div>
    <div class="card-body">
        <ul class="list-group list-group-flush">
            <li class="list-group-item">
                <p class="card-text">Please see <a href="https://github.com/matteoferla/PyMOL-to-NGL-transpiler/blob/master/README.md">the Github readme</a> for documentation.</p>
                <form>
                <!-- mode selector -->
                <div class="row">
                    <div class="col-lg-8 mb-3">
                        <div class="input-group" data-toggle="tooltip" title="Choose input method">
                          <div class="input-group-prepend">
                            <span class="input-group-text" id="input_mode-addon">Mode </span>
                          </div>
                          <div class="btn-group btn-group-toggle" data-toggle="buttons">
                          <label class="btn btn-secondary active">
                            <input type="radio" name="input_mode" id="input_mode_out" autocomplete="off" value="file" checked> Upload PSE
                          </label>
                          <label class="btn btn-secondary">
                            <input type="radio" name="input_mode" id="input_mode_file" value="out" autocomplete="off"> Input PyMol output
                          </label>
                        </div>
                        </div>
                    </div>
                </div>

                <!-- in via out -->
                <div id="in_via_out" class="collapse">
                    <h3>Input via PyMOL output</h3>
                    <p>To generate the pyMOL ouput use the commands in PyMOL:</p>
                        <pre><code>iterate all, ID,chain,resi, resn,name, elem,reps, color</code></pre><p>and</p><pre><code>get_view</code></pre>
                    <p>Then copy-paste the whole output here.</p>
                        <div class="row">
                            <div class="col-md-12 pb-4">
                                <div class="input-group">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text">PyMOL output</span>
                                    </div>
                                    <textarea class="form-control" aria-label="With textarea" id="pymol_output" rows="6" required></textarea>
                                    <div class="input-group-append">
                                        <button type="button" class="btn btn-info" id="demo">Demo</button>
                                    </div>
                                </div>
                                <div class="invalid-feedback" id="error_pymol_output">Please paste a valid output.</div>
                            </div>
                        </div>
                </div>

                <!-- in via file -->
                <div id="in_via_file" class="collapse show">
                    <h3>Input via PyMol</h3>
                    <div class="row">
                        <div class="col-lg-6 mb-3">
                            <div class="input-group" data-toggle="tooltip" title="Upload your PyMOL PSE file">
                              <div class="input-group-prepend">
                                <span class="input-group-text" id="upload_addon">Upload PSE</span>
                              </div>
                              <div class="custom-file">
                                <input type="file" class="custom-file-input" id="upload" aria-describedby="upload_addon" accept=".pse">
                                <label class="custom-file-label" for="upload">Choose file</label>
                              </div>
                                <div class="input-group-append">
                                <button type="button" class="btn btn-info" id="demo_mod_btn" data-toggle="modal" data-target="#demo_modal">Demo</button>
                                </div>
                            </div>
                            <div class="invalid-feedback" id="error_upload">Please upload a valid pse file.</div>
                        </div>
                        <div class="col-xl-4 col-md-6 mb-4">
                            <div class="input-group" data-toggle="tooltip"
                                 title="Basically, if you are using a PSE based on a RCSB PDB structure, don't tick this, but give the PDB code. Otherwise, tick this. For more info, press the question mark.">
                                <div class="input-group-prepend">
                                    <div class="input-group-text bg-secondary">
                                        <input type="checkbox" id="pdb_string"></div>
                                </div>
                                <div class="input-group-append">
                            <span class="input-group-text">
                                Include PDB data
                            </span>
                                    <div class="btn btn-info" data-toggle="modal" data-target="#CDN_modal" >?</div>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>

                <!-- in common -->
                <div id="in_common">
                    <div class="row">
                        <div class="col-xl-4 col-md-6 pb-4">
                                <div class="input-group mb-3" data-toggle="tooltip"
                                     title="${info.attr.pdb|n}">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text">PDB code/name</span>
                                    </div>
                                    <input type="text" class="form-control" id="pdb" value="1UBQ" required>
                                    <div class="invalid-feedback" id="error_pdb">No PDB code</div>
                                </div>
                            </div>
                        <div class="col-xl-4 col-md-6 mb-4">
                            <div class="input-group" data-toggle="tooltip"
                                 title="${info.attr.uniform_non_carbon|n}">
                                <div class="input-group-prepend">
                                    <div class="input-group-text bg-secondary">
                                        <input type="checkbox" id="uniform_non_carbon"></div>
                                </div>
                                <div class="input-group-append">
                            <span class="input-group-text">
                                Uniform non carbons
                            </span>
                                </div>
                            </div>
                        </div>
                        <div class="col-xl-3 col-md-6 mb-4">
                            <div class="input-group" data-toggle="tooltip"
                                 title="Use a static image that when clicked becomes the NGL interactive protein">
                                <div class="input-group-prepend">
                                    <div class="input-group-text bg-secondary">
                                        <input type="checkbox" id="image"></div>
                                </div>
                                <div class="input-group-append">
                            <span class="input-group-text">
                                Static image
                            </span>
                                </div>
                            </div>
                        </div><!--image-->
                        <div class="col-xl-7 col-md-8 mb-4">
                            <div class="input-group" data-toggle="tooltip" data-html="true"
                                 title="${info.attr.sticks|n}">
                                <div class="input-group-prepend">
                                    <span class="input-group-text" id="input_mode-addon">Sticks as </span>
                                  </div>
                                <div class="btn-group btn-group-toggle" data-toggle="buttons">
                                  <label class="btn btn-secondary">
                                    <input type="radio" name="sticks" id="sticks_licorice" autocomplete="off" value="licorice"> Liquorice
                                  </label>
                                <label class="btn btn-secondary active">
                                    <input type="radio" name="sticks" id="sticks_sym_licorice" autocomplete="off" value="sym_licorice" checked> Liq. w&#773; db bonds
                                  </label>
                                  <label class="btn btn-secondary">
                                    <input type="radio" name="sticks" id="sticks_hyperball" value="hyperball" autocomplete="off"> Hyperball
                                  </label>
                                </div>
                            </div>
                        </div><!--sticks-->



                        <!--<div class="col-xl-4 col-md-6 pb-4">
                            <div class="input-group" data-toggle="tooltip"
                                 title="This is just a stylistic thing...">
                                <div class="input-group-prepend">
                                    <span class="input-group-text">Indent</span>
                                </div>
                                <div class="input-group-append">
                                    <span class="input-group-text bg-white rounded-right"><input type="range" list="tickmarks" id="indent" min="0" max="10" value="0"></span>
                                    <datalist id="tickmarks">
                                        <option value="0" label="0">
                                        <option value="1">
                                        <option value="2">
                                        <option value="3">
                                        <option value="4">
                                        <option value="5" label="5">
                                        <option value="6">
                                        <option value="7">
                                        <option value="8">
                                        <option value="9">
                                        <option value="10" label="10">
                                    </datalist>
                                </div>
                            </div>
                        </div>-->
                    </div>
                    <h3>Technical</h3>
                    <div class="row"  id="technical_div">
                        <div class="col-xl-4 col-md-6 pb-4">
                                <div class="input-group mb-3" data-toggle="tooltip"
                                     title="the id of the div that will contain the viewport">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text">Viewport id</span>
                                    </div>
                                    <input type="text" class="form-control" id="viewport_id" value="viewport" required>
                                    <div class="invalid-feedback" id="error_pdb">No id</div>
                                </div>
                            </div><!--viewport-->
                        <div class="col-xl-5 col-md-6 mb-4">
                            <div class="input-group" data-toggle="tooltip"
                                 title="Add a 'take snapshop' function. To do this a button is required with a given id.">
                                <div class="input-group-prepend">
                                    <div class="input-group-text bg-secondary">
                                        <input type="checkbox" id="snapshot" checked></div>
                                    <span class="input-group-text">
                                Snapshot
                            </span>
                                </div>
                                <div class="input-group-append">
                                    <input type="text" class="form-control" id="snapshot_id" value="saveBtn">
                                </div>
                            </div>
                        </div><!--snap-->
                        <div class="col-xl-12 col-md-12 mb-4">
                            <div class="input-group" data-toggle="tooltip"
                                 title="The output can contain an script element pointing to a ngl.js source. Disable the checkbox to not have one or alter the address.">
                                <div class="input-group-prepend">
                                    <div class="input-group-text">NGL Address</div>

                                </div>
                                <div class="input-group-text bg-secondary rounded-0">
                                    <input type="checkbox" id="cdn_bool" checked>
                                </div>
                                <input type="text" class="form-control" id="cdn" value="https://cdn.rawgit.com/arose/ngl/v0.10.4-1/dist/ngl.js">
                                <div class="input-group-append">
                                    <div class="btn btn-info" data-toggle="modal" data-target="#CDN_modal" >?</div>

                                </div>
                            </div>
                        </div><!--NGL-->
                    </div>
                </div>
                </form>


                <div class="row align-center">
                    <div class="col-md-4 offset-md-4">
                        <div class="btn-group d-flex" role="group" aria-label="Submit">
                            <button type="button" class="btn btn-warning flex-fill" id="clear">Clear</button>
                            <button type="button" class="btn btn-success flex-fill" id="submit">Submit</button>
                        </div>
                    </div>
                </div>
            </li>
        </ul>


    </div>
</div>

<div class="modal" tabindex="-1" role="dialog" id="throbber" style="top:90%; overflow:hidden;">
  <div class="modal-dialog" role="document">
    <div class="modal-content bg-warning">
        <div class="modal-body"> <i class="fas fa-cog fa-spin"></i> Calculations in progress... <br/>Is this the best way to make a snackbar in BS4??</div>
    </div>
  </div>
</div>


<div class="modal fade" tabindex="-1" role="dialog" id="CDN_modal">
  <div class="modal-dialog modal-lg" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">NGL library and PDB file</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
          <p>For a web page to load a resource (<i>e.g.</i> image, PDB file or JS libary), the latter needs to be available online (<i>i.e.</i>not on one's laptop).</p>
          <h6>NGL</h6>
        <p>In order to use the NGL protein viewer it needs to be loaded by your browser. This is a piece of JavaScript code which is requested to be loaded by the HTML page with a line </p>
          <pre><code>&lt;script scr="address where the script can be downloaded dot js"&gt;&lt;/script&gt;</code></pre>
          <p>This checkbox allows you to ommit this line (unchecked) if you are making other arrangements (<i>i.e.</i> you know what you are doing).</p>
          <p>This library can be local or remote.</p>
          <p>For example, if you have a <code>.html</code> file with the protein code from here appropriately copy-pasted and you want to use it offline, then download the <a href="https://raw.githubusercontent.com/arose/ngl/master/dist/ngl.js" download>js file</a> and save it next to your file (<i>i.e.</i> relative path) and add the line</p>
          <pre><code>&lt;script type="text/javascript" scr="ngl.js"&gt;&lt;/script&gt;</code></pre>
          <p>If you are going to use the code on a page where you are not free to control what files are served, say your departmental webpage, opt for the remotely held file (CDN), which is the default value.</p>
          <pre><code>&lt;script type="text/javascript" scr="https://cdn.rawgit.com/arose/ngl/v0.10.4-1/dist/ngl.js"&gt;&lt;/script&gt;</code></pre>
          <h6>PDB files</h6>
          <p>This also applies for the PDB code. If you add a PDB code, it will use that from the PDB. If it looks like a file name (<i>e.g.</i> <code>file.pdb</code>) then it will assume <b>you</b> will upload it to the correct place (<i>e.g.</i> <code>file.pdb</code> the PDB file is uploaded to the same folder as the HTML page; <code>https://www.myuni.ac.uk/~myusername/file.pdb</code> will <i>try</i> to fetch it from the URL &mdash;do note that some places don't serve 'raw' or 'cross-origin' files. Alternatively you can click <code>Include PDB data</code>, which means you don't have to worry.</p>
          <h6>The big red 403</h6>
          <p>The PDB and JS files cannot be kept on Dropbox or most cloud storage providers. If you get a Dropbox share link, set it 'all with link' and add the URL query <code>?db=1</code> to it, you will get the following error in the JS console (in Chrome, right click, inspect, Console tab):</p>
          <pre><code>stage.loadFile("https://www.dropbox.com/s/23mxwy0okylrvll/dddG.pdb?dl=1")
(index):1 Access to XMLHttpRequest at 'https://www.dropbox.com/s/23mxwy0okylrvll/dddG.pdb?dl=1' from origin 'http://ngl.matteoferla.com' has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present on the requested resource.</code></pre>
          <p>This is because of a server-side security setting, which cannot be circumvented by the user &mdash;and Bitcoin hacker-miners. Likewise, only a specially configured server will serve JS libraries (called a "CDN").</p>
          <p><b>Consequently, it is best to use the default CDN for NGL and tick <code>Include PDB data</code>.</b></p>
      </div>
    </div>
  </div>
</div>


<div class="modal fade" tabindex="-1" role="dialog" id="demo_modal">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Demo PSE</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        <p>Demo PSEs. Protein alphabet taken from Howarth (2015). </p>
          <div class="row">
              <div class="col-6 pr-0">
                  <div class="list-group">
              % for i in range(ord('A'), ord('N')+1):
                  <button type="button" class="list-group-item list-group-item-action demo-pse" data-value="${chr(i)}.pse"> ${chr(i)}.pse </button>
              % endfor
            </div>
              </div>
              <div class="col-6 pl-0"><div class="list-group">
                  % for i in range(ord('N'), ord('Z')+1):
                  <button type="button" class="list-group-item list-group-item-action demo-pse" data-value="${chr(i)}.pse"> ${chr(i)}.pse </button>
              % endfor
                  <button type="button" class="list-group-item list-group-item-action demo-pse" data-value="art.pse"> art.pse </button>
              </div></div>
          </div>

      </div>
    </div>
  </div>
</div>

<%block name="script">
    <script type="text/javascript">
        $(document).ready(function () {

            $('#pdb_string').change(function () {
                if ($('#pdb_string').is(':checked')) {
                    $('#pdb').attr('disabled',true);
                    $('#pdb').val('N/A');
                    $('#pdb').removeClass('is-invalid');
                    $('#error_pdb').hide();
                } else {
                    $('#pdb').removeAttr('disabled');
                    $('#pdb').val('');
                    $('#pdb').addClass('is-invalid');
                    $('#error_pdb').show();
                }
            });


            function valid_value(id){
                if (! $(id).val()) {
                    window.setTimeout(function () {
                        $(id).addClass('is-invalid');
                        $(id)[0].scrollIntoView();
                        $('#error_' + id.replace('#','')).show();
                        $('#throbber').modal('hide');
                        },0);
                    throw 'Incomplete '+id;
                }
                else if (!! $(id)[0].files) {return $(id)[0].files[0]}
                else {return $(id).val();}
            }

            $('[name="input_mode"]').on('change', function() {
              if($(this).val() === "file") {
                $('#in_via_file').collapse('show');
                $('#in_via_out').collapse('hide');
              } else if($(this).val() === "out") {
                $('#in_via_file').collapse('hide');
                $('#in_via_out').collapse('show');
              } else {
                  alert('No idea why I thought I needed a third.')
              }
            });

            $('#upload').change(function () {
                var file=$('#upload').val().split('\\').slice(-1)[0];
                if (!! $('#upload').val()) {
                    if ($('#upload').val().toLowerCase().search('.pse') != -1) {
                    $('#upload').addClass('is-valid');
                    $('#upload').removeClass('is-invalid');
                    $('#error_upload').hide();
                    if (! $('#pdb').val()) {$('#pdb').val(file).replace('.pse','.pdb')}
                }
                else {
                    $('#upload').removeClass('is-valid');
                    $('#upload').addClass('is-invalid');
                    $('#error_upload').show();
                }
                $('#upload+.custom-file-label').html(file);
                } // else? nothing added. user chickened out.
            });


            $('[data-toggle="tooltip"]').tooltip();

            $('#demo').click(function () {
                $("#input_mode_out").prop("checked", false);
                $.get("static/pymol_demo.txt", function (text) {
                    $('#pymol_output').val(text);
                });
            });

            $('#submit').click(function () {
                $('#throbber').modal('show');
                $('#results').remove();
                stage=false;
                $('.is-invalid').removeClass('is-invalid');
                $('.is-valid').removeClass('is-valid');
                $('.invalid-feedback').hide();

                data = new FormData();
                var mode=$("input[name='input_mode']:checked").val();
                if ($('#pdb_string').is(':checked')) {data.append( 'pdb', ''); data.append('pdb_string',1)} else {data.append( 'pdb', valid_value('#pdb'));}
                data.append( 'mode', mode );
                if        (mode == 'out') {
                    data.append('pymol_output', valid_value('#pymol_output'));
                } else if (mode == 'file' && !! demo_pse) {data.append('demo_file',demo_pse);
                } else if (mode == 'file') {    data.append( 'file', valid_value('#upload'));
                } else {throw 'Impossible mode';}
                data.append( 'uniform_non_carbon',$('#uniform_non_carbon').is(':checked'));
                data.append('viewport_id',valid_value('#viewport_id'));
                data.append( 'image',$('#image').is(':checked'));
                data.append('stick',$("input[name='sticks']:checked").val());
                var snapshot = '';
                if ($('#snapshot').is(':checked')) {
                    snapshot = $('#snapshot_id').val();
                }
                data.append('save',snapshot);
                var cdn = '';
                if ($('#cdn_bool').is(':checked')) {
                    cdn = $('#cdn').val();
                }
                data.append( 'cdn',cdn);
                data.append( 'indent',$('#indent').val());
                //{pdb: pdb, uniform_non_carbon: uniform_non_carbon, pymol_output: pymol_output, indent: indent, cdn: cdn}
                $.ajax({
                    type: "POST",
                    url: "ajax_convert",
                    processData: false,
                    enctype: "multipart/form-data",
                    cache: false,
                    contentType: false,
                    data:  data
                })
                        .done(function (msg) {
                            $('#throbber').modal('hide');
                            $('.card-body > ul').append(msg);
                        })
                        .fail(function () {
                            $('#throbber').modal('hide');
                            alert('ERROR');
                        })
            });

            $('#clear').click(function () {
                $('#results').remove();
                $('#pymol_output').val('');
                $('#pdb').val('');
                $('.is-invalid').removeClass('is-invalid');
                $('.is-valid').removeClass('is-valid');
                $('.invalid-feedback').hide();
            });

        var demo_pse='';
        $('.demo-pse').click(function () {
            demo_pse=$(this).data('value');
            $('#upload+.custom-file-label').html('DEMO: '+demo_pse);
            $('#demo_modal').modal('hide');
            $('#pdb_string').prop('checked',true);
            $('#pdb_string').trigger('change');
        });

        window.tour = new Tour({
          backdrop: true,
          steps: [
          {
            element: "h1",
            title: "Aim",
            content: `${info.attr.aim|n}`,
            placement: "bottom"
          },
          {
            element: "h1",
            title: "Where to use",
            content: `${info.attr.usable|n}`,
            placement: "bottom"
          },{
            element: "h1 .fa-github",
            title: "GitHub Repository",
            content: `${info.attr.github|n}`,
            placement: "right"
          },

          {
            element: "#input_mode_file",
            title: "Input mode",
            content: `${info.attr.mode|n}`,
            placement: "bottom"
          },
          {
            element: "#upload",
            title: "Upload your PSE file",
            content: `${info.attr.upload|n}`,
            placement: "bottom"
          },
          {
            element: "#demo_mod_btn",
            title: "Demo PSE",
            content: `${info.attr.demo_pse|n}`,
            placement: "bottom"
          },
          {
            element: "#pdb_string",
            title: "Include PDB text?",
            content: `${info.attr.pdb_string|n}`,
            placement: "top"
          },
          {
            element: "#pdb",
            title: "PDB address",
            content: `${info.attr.pdb|n}`,
            placement: "top"
          },
          {
            element: "#uniform_non_carbon",
            title: "Correct color error for non-carbons",
            content: `${info.attr.uniform_non_carbon|n}`,
            placement: "top"
          },
          {
            element: "#image",
            title: "Static image on load",
            content: `${info.attr.image|n}`,
            placement: "top"
          },
          {
            element: "#sticks_sym_licorice",
            title: "Stick conversion",
            content: `${info.attr.sticks|n}`,
            placement: "top"
          },
          {
            element: "#technical_div",
            title: "Technicalities",
            content: 'These options are best left alone at first.',
            placement: "top"
          },
          {
            element: "#submit",
            title: "Results",
            content: 'This completes the tour of the inputs. For a tour of the results, choose a demo PSE and submit the job and click the question mark.',
            placement: "top"
          }




        ]});

        tour.init();
        $('.card-title .fa-question').click(function () {
            // Initialize the tour

            // Start the tour
            if (tour.ended()) {tour.goTo(0);}
            tour.start(true);
        });

        }); //ready
    </script>
</%block>
