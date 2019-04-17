<%namespace file="layout_components/labels.mako" name="info"/>
<%inherit file="layout_components/layout_w_card.mako"/>
<%block name="buttons">
            <%include file="layout_components/horizontal_menu_buttons.mako" args='tour=False'/>
</%block>
<%block name="subtitle">
            An interactive protein on your website with a few clicks
</%block>

<%def name="descriptive(link, fa, title, text)">
    <a href="${link}"  class="btn btn-outline-primary btn-block my-0 border-0 text-left">
        <div class="row">
            <div class="col-3">
                <i class="far ${fa}"></i>
                <b>${title}</b>
            </div>
            <div class="col-9 border-left">
                <span>${text|n}</span>
            </div>
        </div>
                </a>

</%def>

<%block name="body">
    <div class="row">
        <div class='col-12 col-md-8 col-xl-9'>
            ### Mission
            <div class="row">
                <div class="col-4 text-right d-sm-none d-md-block"  style="margin: auto;">
                    <h4><i class="far fa-rocket"></i>&nbsp;Mission</h4>
                </div>
                <div class="col-12 col-md-8">
                    <div class="mb-2 p-3 border border-dark rounded-lg border-top-0 border-bottom-0 text-muted">
                <p>Our aim is to help create NGL views for academic websites, blog posts and supplementary materials for papers with extra functionality such as <span class="prolink" data-toggle="protein" data-title="tada!" data-target="viewport" data-view="[-18.368176150507537, 74.81398271773811, 53.85689065075363, 0, 2.24223533030926, 55.26199556901072, -76.00112369042608, 0, -92.15567840009014, -13.567107701862422, -12.583763466412949, 0, -12.895500659942627, -26.876500129699707, -2.82450008392334, 1]">guiding the viewers' attention</span>.</p>
            </div>
                </div>
            </div>

            ### NGL
            <div class="row">
                <div class="col-12 col-md-8">
                    <div class="mb-2 p-3 border border-dark rounded-lg border-top-0 border-bottom-0 text-muted">
                <p>NGL (<a href="http://nglviewer.org/ngl/api/" target="_blank">nglviewer.org <i class="far fa-external-link"></i></a>) is a powerful javascript library that allows the visualisation of protein on websites that was developed by Alex Rose at the PDB. With the tools presented here, it becomes even easier to create great protein represetations on the web.</p>
            </div>
                </div>
                <div class="col-4 text-left d-sm-none d-md-block"  style="margin: auto;">
                    <h4><i class="far fa-cubes"></i> NGL Extended</h4>
                </div>
            </div>


        </div>

        <div class='col-12 col-sm-4 col-xl-3'>
            <div id="viewport" style="width:100%; height: 0; padding-bottom: 100%;"></div>
        </div>


        <div class="col-12 my-3">

            ### Simplicity
            <div class="row">
                <div class="col-2 text-right d-sm-none d-md-block"  style="margin: auto;">
                    <h4><i class="far fa-wand-magic"></i> Simplicity</h4>
                </div>
                <div class="col-12 col-md-10">
                    <div class="mb-2 p-3 border border-dark rounded-lg border-top-0 border-bottom-0 text-muted">
                <p>This app allows the creation fo NGL views without any JS coding with the following features:</p>
                ${descriptive('/markup', 'fa-map-marked-alt', 'JS-free markup', 'By adding to NGL the power to create and control the protein view with simple to implement HTML tags without any JavaScript')}
                ${descriptive('/pymol', 'fa-hammer', 'PyMOL file conversion', 'Convert a PyMol PSE file to a NGL view that can be shared or its code copy-pasted.')}
                ${descriptive('/clash', 'fa-car-crash', 'Show clashes', 'Expanding upon NGL by adding the ability to show clashes.')}
                ${descriptive('/imagetoggle', 'fa-images', 'Image to NGL toggling', 'Adding the fuctionality of toggling from an annotated static image to an NGL view.')}
                ${descriptive('/custom', 'fa-mortar-pestle', 'custom mesh conversion', 'Converting a 3D file to a mesh in NGL allowing you to have anything from a giant question mark or pair of scissors to a T-Rex in your protein')}

                <p class="pt-2">For more details in general, see the <a href="/docs">documentation</a>.</p>

                    </div>
                </div>
            </div>

            <h4></h4>


            ### Github
            <div class="row">
                <div class="col-12 col-md-10">
                    <div class="mb-2 p-3 border border-dark rounded-lg border-top-0 border-bottom-0 text-muted">
                <p>The source code for this server is available at <a href="https://github.com/matteoferla/MichelaNGLo" target="_blank">github.com/matteoferla/MichelaNGLo <i class="far fa-external-link"></i></a>. The JS file to extend NGL can be found <a href="https://raw.githubusercontent.com/matteoferla/MichelaNGLo/master/michelanglo_app/static/ngl.extended.js" target="_blank">here <i class="far fa-external-link"></i></a>.</p>
            </div>
                </div>

                <div class="col-2 text-left d-sm-none d-md-block"  style="margin: auto;">
                    <h4><i class="fab fa-github"></i> Github</h4>
                </div>

                <div class="col-2 text-right d-sm-none d-md-block"  style="margin: auto;">
                    <h4><i class="far fa-books"></i> Citation</h4>
                </div>
            <div class="col-12 col-md-10">
                    <div class="mb-2 p-3 border border-dark rounded-lg border-top-0 border-bottom-0 text-muted">
                <p>Please cite:
                    <ul>
                        <li>Manuscript not remotely in preparation.</li>
                        <li>
                            <a href="https://dx.doi.org/10.1093/bioinformatics/bty419" target="_blank">AS Rose, AR Bradley, Y Valasatava, JM Duarte, A Prlić and PW Rose. NGL viewer: web-based molecular graphics for large complexes. Bioinformatics: bty419, 2018.</a>
                    </li>
                    </ul>
                        </p>
            </div>
                </div>
            </div>

        </div>
    </div>

</%block>


<%block name="script">
    <script type="text/javascript">
        $(document).ready(function () {
            function pretty_hisA(protein) {
                var schemeId = NGL.ColormakerRegistry.addSelectionScheme([["lightcoral", "*"]]);
	            protein.addRepresentation( "cartoon", {color: schemeId });
                var view=[64.19461657851211, 34.58837775693359, -59.31089193592322, 0, 39.37499797163815, 47.972028636740525, 70.59306324960345, 0, 56.24719826644338, -73.0576154030002, 18.27359008394372, 0, -12.895500659942627, -26.876500129699707, -2.82450008392334, 1];
                protein.stage.animationControls.orient(view, 2000);
                NGL.specialOps.showTitle('viewport','Please interact with me')
            }
            NGL.specialOps.showTitle('viewport','<i class="far fa-dna fa-spin"></i> Loading...');
            NGL.specialOps.multiLoader('viewport', [{type: 'file', value: 'static/Sal_HisA.pdb', loadFx: pretty_hisA}], 'white');

        }); //ready
    </script>
</%block>
