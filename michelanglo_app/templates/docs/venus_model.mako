<%namespace file="../layout_components/labels.mako" name="info"/>
<%inherit file="../layout_components/layout_w_card.mako"/>

<%block name="buttons">
    <%include file="../layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>

<%block name="title">
    &mdash; VENUS — URLs
</%block>

<%block name="subtitle">
    Variant effect on structure — Model choice
</%block>

<%block name="body">

    <%include file="subparts/docs_nav.mako"/>

        <%include file="subparts/docs_venus_nav.mako" args='topic="model"'/>
         <h3>Decision tree</h3>
    <p>The structure shown is either a PDB crystal structure or failing that a Swissmodel model.</p>
    <p>To qualify the candidate structure/model has to contain the residue of interest.</p>
    <p>Then the structure with the finest resolution is chosen. For more options for a given protein see <a href="/name">the Michelanglo creation by protein name</a></p>
</%block>

<%block name='modals'>
</%block>
<%block name="script">
    <script type="text/javascript">
    </script>
</%block>

