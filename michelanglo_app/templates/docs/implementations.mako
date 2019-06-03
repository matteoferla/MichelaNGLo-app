<%namespace file="../layout_components/labels.mako" name="info"/>
<%inherit file="../layout_components/layout_w_card.mako"/>
<%block name="buttons">
            <%include file="../layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>
<%block name="title">
            &mdash; Documentation
</%block>
<%block name="subtitle">
            General implementation
</%block>

<%block name="main">

    <%include file="docs_nav.mako"/>


<p>This is a generalised instructions for implementing a view from Michelanglo on your site. For the code specific to your generated view see your pages and click the button "implement" on the side.</p>

############################################################ Raw
<%include file="docs_raw.mako"/>

############################################################# CDN
<%include file="docs_cdn.mako"/>

############################################################# Viewport
<%include file="docs_viewport.mako"/>

</%block>