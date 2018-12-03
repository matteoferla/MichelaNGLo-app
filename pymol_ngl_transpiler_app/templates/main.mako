<%inherit file="layout.mako"/>

<div class="card">
    <div class="card-header">
        <h1 class="card-title">PyMOL&rarr;NGL transpiler</h1>
        <h3 class="card-subtitle mb-2 text-muted">Generate a NGL view from a PyMOL PSE file.</h3>
    </div>
    <div class="card-body">
        <ul class="list-group list-group-flush">
            <li class="list-group-item">
                <p class="card-text">Please see <a href="https://github.com/matteoferla/PyMOL-to-NGL-transpiler/blob/master/README.md">the Github readme</a> for documentation.</p>
                <h3>Input via PyMOL output</h3>
                <p>For now this is the only way. In future an upload will be present.</p>
                <p>To generate the pyMOL ouput use the commands in PyMOL <code>iterate all, ID,chain,resi, resn,name, elem,reps, color</code> and <code>get_view</code>. Then copy-paste the whole output
                    here.</p>
                <form>
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
                        </div>
                        <div class="col-xl-4 col-md-6 pb-4">
                            <div class="input-group mb-3" data-toggle="tooltip"
                                 title="Two options: the PDB code from PDB or a web address to a file with suffix and all.">
                                <div class="input-group-prepend">
                                    <span class="input-group-text">PDB code</span>
                                </div>
                                <input type="text" class="form-control" id="pdb" value="1UBQ" required>
                                <div class="invalid-feedback">No PDB code</div>
                            </div>
                        </div>
                        <div class="col-xl-4 col-md-6 pb-4">
                            <div class="input-group" data-toggle="tooltip"
                                 title="It is unlikely that one purposefully wants a non-carbon element to be represented with different colors. By checking this, the most common color for that element will be used.">
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

                        <div class="col-xl-12 col-md-12 pb-4">

                            <div class="input-group" data-toggle="tooltip"
                                 title="The output can contain an script element pointing to a ngl.js source. Disable the checkbox to not have one or alter the address.">
                                <div class="input-group-prepend">
                                    <div class="input-group-text">NGL Address</div>

                                </div>
                                <div class="input-group-text bg-secondary rounded-0">
                                    <input type="checkbox" id="cdn_bool" checked>
                                </div>
                                <input type="text" class="form-control" id="cdn" value="https://cdn.rawgit.com/arose/ngl/v0.10.4-1/dist/ngl.js">
                            </div>
                        </div>

                        <div class="col-xl-4 col-md-6 pb-4">
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




<%block name="script">
    <script type="text/javascript">
        $(document).ready(function () {
            $('[data-toggle="tooltip"]').tooltip()
            $('#demo').click(function () {
                $.get("static/pymol_demo.txt", function (text) {
                    $('#pymol_output').val(text);
                });
            });
            $('#submit').click(function () {
                $('#results').remove();
                var pdb = $('#pdb').val();
                var uniform_non_carbon = $('#uniform_non_carbon').is(':checked');
                var cdn = '';
                if ($('#cdn_bool').is(':checked')) {
                    cdn = $('#cdn').val();
                }
                var pymol_output = $('#pymol_output').val();
                var indent = $('#indent').val();
                $.ajax({
                    method: "POST",
                    url: "ajax_convert",
                    data: {pdb: pdb, uniform_non_carbon: uniform_non_carbon, pymol_output: pymol_output, indent: indent, cdn: cdn}
                })
                        .done(function (msg) {
                            $('.card-body > ul').append(msg);
                        })
                        .fail(function () {
                            alert('ERROR');
                        })
            });
            $('#clear').click(function () {
                $('#results').remove();
                $('#pymol_output').val('');
                $('#pdb').val('');
            });
        });
    </script>
</%block>
