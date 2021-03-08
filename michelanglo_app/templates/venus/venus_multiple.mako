## route name: /venus
## this view is for Venus
<%namespace file="../layout_components/labels.mako" name="info"/>
<%inherit file="../layout_components/layout_w_card.mako"/>
<%block name="buttons">
            <%include file="../layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>
<%block name="title">
            &mdash; VENUS (Multiple)
</%block>
<%block name="subtitle">
    Assessing the effect of amino acid variants have on structure together
</%block>

<%block name="alert">
    ### nothing.
</%block>

<%block name="main">
        <p>Gateway to the analysis of multiple variants via <a href="/venus">VENUS</a> or to find the best model to show variants.</p>
    <%include file="venus_input.mako"/>
</%block>

<%block name='after_main'>
    <%include file="venus_result_section.mako"/>
</%block>

<%block name='modals'>
    ### This adds #modalStructureless
    <%include file="venus_no_structure.mako"/>
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
        <%include file="venus_multiple.js"/>
        <%include file="../pdb_staging_insert.js"/>
    });
    ####include file="../markup/markup_builder_modal.js"/>
    window.interactive_builder = () => undefined; //burn the call.
</script>
    <link rel="stylesheet" href="/static/feature.css" async>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.17/d3.js"></script>
    ###<script src="https://cdn.rawgit.com/calipho-sib/feature-viewer/v1.0.0/dist/feature-viewer.min.js"></script>
    <script src="/static/ThirdParty/feature-viewer.js" async></script>
</%block>