<%inherit file="layout_components/layout_w_card.mako"/>
<%block name="buttons">
            <%include file="layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>
<%block name="title">
            &mdash; Gallery
</%block>
<%block name="subtitle">
            Here are links to created pages flagged as public
</%block>

<%block name="main">
        <div class="list-group">
    % for page in public_pages:
        <a href="/data/${page.identifier}" class="list-group-item list-group-item-action">${page.title}</a>
    % endfor
        </div>
</%block>
