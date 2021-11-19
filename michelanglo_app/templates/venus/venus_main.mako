## route name: /venus
## this view is for Venus
<%namespace file="../layout_components/labels.mako" name="info"/>
<%inherit file="../layout_components/layout_w_card.mako"/>
<%block name="buttons">
            <%include file="../layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>
<%block name="title">
            &mdash; VENUS
</%block>
<%block name="subtitle">
    Assessing the effect of amino acid variants have on structure
</%block>

<%block name="alert">
    ### nothing.
</%block>

<%block name="main">
        <p>A tool to help in the discovery of why a given mutation is pathogenic (see <a href="/docs/venus">documentation</a>).
            To view multiple mutations at the same time see <a href="/venus_multiple">multiple mutant page</a>.
            For a random protein and mutation <a href="/venus?random">click here</a>.
            For an ENSEMBL id <a href="#" data-toggle="modal" data-target="#transcriptModal">click here</a>.</p>

    <%include file="venus_input.mako"/>
            #################### ALERTS
    %if False:
        <div class="alert alert-warning alert-dismissible fade show my-3" id="construction" role="alert">
  This page is currently under going some changes, therefore some features may break. Do feel free to contact me (Matteo) for any queries: I always welcome feedback be it on purpose or not. (<i class="far fa-comments"></i> button on the top right).
        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
    </div>
    %endif
    <div class="alert alert-info  alert-dismissible fade show mt-5" role="alert">
        This is for academic use only and not intended to be used commercially. Conclusions drawn are suggestions and not diagnostic.
        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
    </div>



</%block>

<%block name='after_main'>
    <%include file="venus_result_section.mako"/>
</%block>

<%block name='modals'>
    ### This adds #modalStructureless
    <%include file="venus_no_structure.mako"/>
    <%include file="extra_info.mako"/>
    <%include file="venus_transcript.mako"/>
</%block>

<%block name='script'>
<script type="text/javascript">
    $(document).ready(function () {
        ### this controls the input validation. It was originally written for /name route
        <%include file="../name.js"/>
        ### this controls the uniprot field. It was originally written for /name route
        <%include file="../results/uniprot_modal.js"/>
        ### this controls venus specific stuff.
        <%include file="venus_class.js"/>
        <%include file="venus.js"/>
    });
    ####include file="../markup/markup_builder_modal.js"/>
    window.interactive_builder = () => undefined; //burn the call.
</script>
    <link rel="stylesheet" href="/static/feature.css" async>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.17/d3.js"></script>
    ###<script src="https://cdn.rawgit.com/calipho-sib/feature-viewer/v1.0.0/dist/feature-viewer.min.js"></script>
    <script src="/static/ThirdParty/feature-viewer.js" async></script>
    <script src="https://cdn.jsdelivr.net/gh/calipho-sib/sequence-viewer@0.2.35/dist/sequence-viewer.min.js" async></script>
    <script src="/static/ThirdParty/msa.min.gz.js" async></script>
</%block>