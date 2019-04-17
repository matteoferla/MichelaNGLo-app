<%namespace file="layout_components/labels.mako" name="info"/>
<%inherit file="layout_components/layout_w_card.mako"/>
<%block name="buttons">
            <%include file="layout_components/horizontal_menu_buttons.mako" args='tour=False'/>
</%block>
<%block name="title">
            &mdash; Documentation
</%block>
<%block name="subtitle">
            Details instructions
</%block>

<%block name="main">
############################################################ Raw
<%include file="docs/docs_raw.mako"/>

############################################################# CDN
<%include file="docs/docs_cdn.mako"/>

############################################################# Viewport
<%include file="docs/docs_viewport.mako"/>

############################################################# Guiding links
<h4>Prolinks</h4>
<p>Links to guide the visitors ('prolinks') are described <a href="/markup">elsewhere</a>.</p>

############################################################# Users
<%include file="docs/docs_users.mako"/>

######################################################### Pages
    <%include file="docs/docs_pages.mako"/>
</%block>
