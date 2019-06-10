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

<%def name="card(place, title, text)">
    <div class="card shadow" style="height: 250px;">
              <div class="card-header">
                <h5 class="card-title">${title|n}</h5>
              </div>
              <div class="card-body">
                  <div class="arrow-${place}"></div>

                <p class="card-text">${text|n}</p>
              </div>
            </div>
</%def>

<%def name="flipcard(place, first_card, second_card)">
    <div class="flip-card">
      <div class="flip-card-inner">
        <div class="flip-card-front">
          ${card(place, *first_card)|n}
        </div>
        <div class="flip-card-back">
          ${card(place, *second_card)|n}
        </div>
      </div>
    </div>
</%def>

<%block name="body">
    <div class="row">
        <div class="col-12 col-md-2 col-xl-3">
            ${flipcard("right",('title','text'),('title','text'))}

        </div>
        <div class='col-12 col-md-8 col-xl-6' id="viewarium">
            <!-- ############################################ -->
            <div id="viewport"></div>
            <div class="d-flex justify-content-center">
            <button type="button" class="btn btn-outline-secondary border-0" id="pause"><i class="far fa-pause"></i></button>
            <button type="button" class="btn btn-outline-secondary border-0" id="resume" style="display: none;"><i class="far fa-play"></i></button>
                %for i in range(4):
                    <button type="button" class="btn btn-outline-secondary border-0" id="frame${i}"><i class="far fa-circle"></i></button>

                %endfor
            </div>
            <!-- ############################################ -->
        </div>
        <div class="col-12 col-md-2 col-xl-3">
            ${flipcard("left",('title','text'),('title','text'))}
        </div>
    </div>
</%block>


<%block name="script">
    <script type="text/javascript">





    $(document).ready(function () {

        class Descriptor {
          constructor({title_left, text_left,title_right, text_right, id, view}) {
            this.title_left = title_left;
            this.text_left = text_left;
            this.title_right = title_right;
            this.text_right = text_right;
            this.id = id;
            this.view = view;
            this.loadCards = (tick) => {
                let cards_title =  tick ? $('.flip-card-back .card-title') : $('.flip-card-front .card-title');
                let cards_text =  tick ? $('.flip-card-back .card-text') : $('.flip-card-front .card-text');
                cards_title.first().html(this.title_left);
                cards_title.last().html(this.title_right);
                cards_text.first().html(this.text_left);
                cards_text.last().html(this.text_right);
                return this;
            };
            this.flipCards = (tick) => {
                let rota = ['rotateX(0deg)', 'rotateX(180deg)'];
                this.view();
                this.loadCards(tick);
                let inner = $('.flip-card-inner');
                inner.css('transition','transform 1s').css('transform','rotateX(90deg)');
                setTimeout(()=>{$('.flip-card-inner > div').toggle(); inner.css('transform',rota[tick % 2])}, 1000);
                $('.fa-dot-circle').removeClass('fa-dot-circle').addClass('fa-circle');
                $(this.id).removeClass('fa-circle').addClass('fa-dot-circle');
                return this;
            };
          }
        }

        // the data
        let mustard = '#ffcc66';
        window.descriptions = [
        {
            title_left: '<i class="far fa-rocket"></i> No JavaScript coding required',
            text_left: 'Create interactive protein views from a PyMOL PSE file or a PDB code/file',
            title_right: "No JavaScript coding required",
            text_right: "Create links to control the protein views",
            id: '#frame0 i',
            view: () => NGL.specialOps.showDomain('viewport', '*', mustard, [41.29294830639554, 22.248845321357074, -38.15151059779185, 0, 25.32782096795833, 30.857828961827977, 45.40872532497881, 0, 36.18080104201877, -46.99403932937292, 11.754418842671718, 0, -10.200858175132803, -24.766561885907656, -2.229398340052575, 1])
        },
        {
            title_left: 'Implement',
            text_left: 'Either follow the easy instructions to implement the view on your website',
            title_right: "Share",
            text_right: "or edit and share the pages you create.",
            id: '#frame1 i',
            view: ()=>NGL.specialOps.showDomain('viewport','*','teal',[ 41.29294830639554, 22.248845321357074, -38.15151059779185, 0, 25.32782096795833, 30.857828961827977, 45.40872532497881, 0, 36.18080104201877, -46.99403932937292, 11.754418842671718, 0, -10.200858175132803, -24.766561885907656, -2.229398340052575, 1 ])
        },
        {
            title_left: '3',
            text_left: '3',
            title_right: "3",
            text_right: "3",
            id: '#frame2 i',
            view: ()=>NGL.specialOps.showDomain('viewport','*','lightcoral', [-18.368176150507537, 74.81398271773811, 53.85689065075363, 0, 2.24223533030926, 55.26199556901072, -76.00112369042608, 0, -92.15567840009014, -13.567107701862422, -12.583763466412949, 0, -12.895500659942627, -26.876500129699707, -2.82450008392334, 1])
        },
        {
            title_left: '4',
            text_left: '4',
            title_right: "4",
            text_right: "4",
            id: '#frame3 i',
            view: ()=>NGL.specialOps.showDomain('viewport','*','lime', [-18.368176150507537, 74.81398271773811, 53.85689065075363, 0, 2.24223533030926, 55.26199556901072, -76.00112369042608, 0, -92.15567840009014, -13.567107701862422, -12.583763466412949, 0, -12.895500659942627, -26.876500129699707, -2.82450008392334, 1])
        }
        ].map((e) => new Descriptor(e));


        //standard width/height are not great with popovers.
        let vp=$('#viewport');
        let h = Math.min( vp.width(), window.innerHeight - vp.offset().top - 48*2 - 8 - 5 - $('footer').height() );
        vp.height(h);
        window.addEventListener( "resize", function( event ) {
            let vp=$('#viewport');
            let h = Math.min( vp.width(), window.innerHeight - vp.offset().top - 48*2 - 8 - 5 - $('footer').height() );
            vp.height(h);
        });



            if (window.innerWidth < 576) { //mobile.
                //$('#viewarium [data-toggle="popover"]').attr("data-placement","bottom");
            }

            // start
            $('.flip-card-back').hide();


            window.tick = true; //front or back?
            window.tock = 1; //description. the first tock was onLoad.
            window.time_fn = () => {
                descriptions[tock].flipCards(tick);
                tick = ! tick; //basically an 'is_back?'
                tock = (tock + 1) % descriptions.length;
            };

            window.timer = setInterval(time_fn,5000);
            //buttons
            [0,1,2,3,4].forEach((i)=> $('#frame'+i).click((e) => {
                $('#pause').trigger('click');
                tick = ! tick; //is back
                tock = i;
                descriptions[tock].flipCards(tick);
                time_fn();
            }));

            function pretty_hisA(protein) {
                let frame = descriptions[0];
                frame.view();
                frame.loadCards(false);
                NGL.specialOps.showTitle('viewport','Please interact with me');
                $('#frame0 i').removeClass('fa-circle').addClass('fa-dot-circle');
            }

            NGL.specialOps.showTitle('viewport','<i class="far fa-dna fa-spin"></i> Loading...');
            NGL.specialOps.multiLoader('viewport', [{type: 'file', value: 'static/Sal_HisA.pdb', loadFx: pretty_hisA}], 'white');


    $('#pause').click((e) => {clearInterval(window.timer); $('#resume').show(); $('#pause').hide();});
    $('#resume').click((e) => {window.timer = setInterval(time_fn,5000); $('#resume').hide(); $('#pause').show();});



        }); //ready


    </script>
</%block>
