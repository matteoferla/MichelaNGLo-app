<%namespace file="layout_components/labels.mako" name="info"/>
<%inherit file="layout_components/layout_w_card.mako"/>
<%block name="buttons">
            <div>
            <%include file="layout_components/vertical_menu_buttons.mako" args='tour=False'/>
            </div>
</%block>
<%block name="subtitle">
            An interactive protein on your website with a few clicks
</%block>

<%block name="body">
    <div class="row">
        ## viewport

    <div class="col-12 col-md-5">
    <!-- ############################################ -->
        <div id="viewport" class="w-100" style="min-height: 300px !important; min-width: 300px !important;"></div>
        <div class="d-flex justify-content-center">
        <button type="button" class="btn btn-outline-secondary border-0" id="pause"><i class="far fa-pause"></i></button>
        <button type="button" class="btn btn-outline-secondary border-0" id="resume" style="display: none;"><i class="far fa-play"></i></button>
            %for i in range(4):
                <button type="button" class="btn btn-outline-secondary border-0" id="frame${i}"><i class="far fa-circle"></i></button>
            %endfor
        </div>
        <!-- ############################################ -->
    </div>
        ## text
    <div class="col-12 col-md-7 d-md-block" id="topics">
        <%
        topics = [
        {
           "title": '<i class="far fa-rocket"></i> Quick and easy',
            "text": '''Create interactive protein views starting from one of the following
                        <ul class="text-left">
                            <li><a href="/pymol">a PyMOL PSE file</a></li>
                            <li><a href="/pdb">a PDB code/file</a></li>
                            <li><a href="/name">a gene name</a></li>
                            </ul>''',

        },
        {
           "title": '<i class="far fa-globe-europe"></i> Share',
            "text": "Edit and share the pages you create. (<a href='/gallery'>Examples</a>)"
        },
        {
           "title": '<i class="far fa-map-marked-alt"></i> Control',
            "text": 'Guide readers on shared pages by creating <span class="prolink" data-toggle="protein" data-focus="residue" data-selection="210:A" data-hetero=true>&ldquo;prolinks&rdquo;</span> (<a href="/docs/markup">protein view controlling links</a>) to control the protein views, including showing <span class="prolink" data-toggle="protein" data-focus="clash" data-selection="101:A" data-hetero=true>clashes</span> .',

        },
        {
           "title": '<i class="far fa-code"></i> Implement',
            "text": 'Alternatively, follow the instructions on the generated page to implement the view on your website.',

        },
        {
           "title": '<i class="fab fa-github"></i> Open source',
            "text":  'The source code for this server is available at <a href="https://github.com/matteoferla/MichelaNGLo" target="_blank">GitHub <i class="far fa-external-link"></i></a>.'
        },
        {
           "title": '<i class="far fa-books"></i> More',
            "text": 'See <a href="/docs">documentation</a> for more information or view <a href="https://youtu.be/v3B3Ok2X5ck">demo video</a>.'
        }
        ]
        #   "title": '<i class="far fa-bolt"></i> NGL powered', "text": 'NGL (<a href="http://nglviewer.org/ngl/api/" target="_blank">nglviewer.org <i class="far fa-external-link"></i></a>) is a JavaScript library that allows the visualisation of protein on the web.'
         %>
        %for index, entry in enumerate(topics):
            <div class="row" id="topic_${index}">
            <div class="col-4 text-right d-none d-lg-block"  style="margin: auto;">
                <b>${entry['title']|n}</b>
            </div>
            <div class="col-12 col-lg-8">
             <div class="mb-2 p-3 border border-dark rounded-lg border-top-0 border-bottom-0 text-muted">
                <p>${entry['text']|n}</p>
            </div>
            </div>
        </div>
        %endfor
    </div>
    </div>
</%block>


<%block name="script">
    <script type="text/javascript">

    $(document).ready(function () {

        // the data
        const mustard = '#ffcc66';
        window.views = [
            () => NGL.specialOps.showDomain('viewport', '*', mustard, [41.29294830639554, 22.248845321357074, -38.15151059779185, 0, 25.32782096795833, 30.857828961827977, 45.40872532497881, 0, 36.18080104201877, -46.99403932937292, 11.754418842671718, 0, -10.200858175132803, -24.766561885907656, -2.229398340052575, 1]),
            () => NGL.specialOps.showDomain('viewport','97-103 or 197-203 or 166-172 or 124-132','teal',[ 49.337653376809236, 32.898090475626475, 11.796951351474945, 0, 26.819403807907317, -48.72454809722087, 23.712748701316123, 0, 22.409194486192025, -14.11702924275698, -54.35249715239321, 0, -10.200858175132803, -24.766561885907656, -2.229398340052575, 1]),
            () => NGL.specialOps.showDomain('viewport', '*', 'lightcoral', [-18.368176150507537, 74.81398271773811, 53.85689065075363, 0, 2.24223533030926, 55.26199556901072, -76.00112369042608, 0, -92.15567840009014, -13.567107701862422, -12.583763466412949, 0, -12.895500659942627, -26.876500129699707, -2.82450008392334, 1]),
            () => NGL.specialOps.showSurface('viewport')
        ];


        //standard width/height are not great with popovers.
        let vp=$('#viewport');
        let h = Math.min( vp.width(), window.innerHeight - vp.offset().top - 48*2 - 8 - 5 - $('footer').height() );
        vp.height(h);
        window.addEventListener( "resize", function( event ) {
            let vp=$('#viewport');
            let h = Math.min( vp.width(), window.innerHeight - vp.offset().top - 48*2 - 8 - 5 - $('footer').height() );
            vp.height(h);
        });

            window.frequency = 8000;
            window.tick = true; //front or back?
            window.tock = 1; //description. the first tock was onLoad.
            window.time_fn = () => {
                views[tock]();
                $('.fa-dot-circle').removeClass('fa-dot-circle').addClass('fa-circle');
                $(`#frame${"${tock}"} .far`).removeClass('fa-circle').addClass('fa-dot-circle');
                tick = ! tick; //basically an 'is_back?'
                tock = (tock + 1) % views.length;
            };

            window.timer = setInterval(time_fn,window.frequency);
            //buttons
            (new Array(views.length)).fill(0).forEach(
                (v,i)=> $('#frame'+i).click((e) => {
                    $('#pause').trigger('click');
                    tick = ! tick; //is back
                    tock = i;
                    views[tock]();
                    $('.fa-dot-circle').removeClass('fa-dot-circle').addClass('fa-circle');
                    $(`#frame${"${tock}"} .far`).removeClass('fa-circle').addClass('fa-dot-circle');
                    time_fn();
                })
            );

            function pretty_hisA(protein) {
                views[0]();
                //frame.loadCards(false);
                NGL.specialOps.showTitle('viewport','Please interact with me');
                $('#frame0 i').removeClass('fa-circle').addClass('fa-dot-circle');
            }

            NGL.specialOps.showTitle('viewport','<i class="far fa-dna fa-spin"></i> Loading...');
            NGL.specialOps.multiLoader('viewport', [{type: 'file', value: 'static/Sal_HisA.pdb', loadFx: pretty_hisA}], 'white');


    $('#pause').click((e) => {clearInterval(window.timer); $('#resume').show(); $('#pause').hide();});
    $('#resume').click((e) => {window.timer = setInterval(time_fn,window.frequency); $('#resume').hide(); $('#pause').show();});



        }); //ready
    </script>
</%block>