<%namespace file="layout_components/labels.mako" name="info"/>
<%inherit file="layout_components/layout_w_card.mako"/>
<%block name="buttons">
            <%include file="layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>
<%block name="title">
            &mdash; Documentation
</%block>
<%block name="subtitle">
            Details instructions
</%block>

<%block name="main">

<ul class="list-group">
    <a class="list-group-item list-group-item-action" href="/docs/markup">HTML markup documentation ("prolinks")</a>
    <a class="list-group-item list-group-item-action" href="/docs/clash">Clash documentation</a>
    <a class="list-group-item list-group-item-action" href="/docs/image">Imagetoggle documentation</a>
    <a class="list-group-item list-group-item-action" href="/docs/implementations">Generic instructions on implementing a view</a>
    <a class="list-group-item list-group-item-action" href="/docs/api">API documentation</a>
</ul>

</%block>