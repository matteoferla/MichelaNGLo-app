<%namespace file="layout_components/labels.mako" name="info"/>
<%inherit file="layout_components/layout_w_card.mako"/>
<%block name="buttons">
            <%include file="layout_components/vertical_menu_buttons.mako" args='tour=True'/>
</%block>
<%block name="title">
            &mdash; PyMol
</%block>
<%block name="subtitle">
            Convert a PyMol file to an interactive NGL viewport
</%block>
<%def name="checkbox(title, label, id, append=None, is_checked=False, justify_right=False)">
    <div
        %if justify_right:
            class="input-group justify-content-end"
        %else:
            class="input-group"
        %endif
        data-toggle="tooltip" title="${title|n}" data-html="true" >
      <div class="input-group-prepend">
        <div class="input-group-text
        % if not append:
                rounded-right
        % endif
        ">
          <div class="custom-control custom-switch">
              <input type="checkbox" id="${id}" class="custom-control-input"
                     %if is_checked:
                         checked
                     %endif
                    >
                <label class="custom-control-label" for="${id}">${label}</label>

              </div>
            </div>
        </div>
        %if append:
            <div class="input-group-append">
                ${append|n}
            </div>
        %endif
      </div>
</%def>

<%block name="body">
<ul class="list-group list-group-flush">
            <li class="list-group-item">
                <form>
                    <div class="row">
                        <div class="col-xl-5 col-lg-6 mb-3">
                            <div class="input-group" data-toggle="tooltip" title="Upload your PyMOL PSE file">
                              <div class="input-group-prepend">
                                <span class="input-group-text" id="upload_addon">Upload PSE file</span>
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
                        <div class="col-xl-3 col-lg-4 col-md-6 mb-3">
                            ${checkbox(info.attr.pdb_string, "Include PDB data", "pdb_string", '<div class="btn btn-info" data-toggle="modal" data-target="#CDN_modal" >?</div>', justify_right=True)}

                        </div>
                        <div class="col-xl-3 col-lg-3 col-md-6 mb-3">
                                <div class="input-group mb-3" data-toggle="tooltip" data-html="true"
                                     title="${info.attr.pdb|n}">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text">PDB code</span>
                                    </div>
                                    <input type="text" class="form-control rounded-right" id="pdb" value="1UBQ" required>
                                    <div class="invalid-feedback" id="error_pdb">No PDB code</div>
                                </div>
                            </div>
                        <div class="col-xl-2 col-lg-3 col-md-6 mb-4">
                            ${checkbox(info.attr.uniform_non_carbon, "Uniform non carbons", "uniform_non_carbon", append=None, is_checked=True)}
                        </div>
                        <div class="col-xl-6 col-lg-6 col-md-8 mb-4">
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

                    </div>


                <!--footnote-->
                <p class="card-text">Please see <a href="https://github.com/matteoferla/PyMOL-to-NGL-transpiler/blob/master/README.md">the Github readme <i class="fas fa-external-link"></i></a> for documentation about how the conversions are done.</p>

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
</%block>

######## other blocks
<%block name='modals'>

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

</%block>

<%block name="script">
    <script type="text/javascript">
        $(document).ready(function () {

        <%include file="pymol_converter/main.mako.js"/>
            <%include file="pymol_converter/tour.mako.js"/>
        }); //ready
    </script>
</%block>
