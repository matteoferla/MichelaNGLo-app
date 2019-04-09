<%inherit file="layout_w_card.mako"/>
<%block name="buttons">
            <%include file="menu_buttons.mako" args='tour=False'/>
</%block>
<%block name="title">
            &mdash; Gallery
</%block>
<%block name="subtitle">
            Here are links to created pages flagged as public
</%block>

<%block name="main">
    <%
        from michelanglo_app.trashcan import get_public
        public = get_public(request)
    %>
        <div class="list-group">
    % for page in public.get_visited_loaded_pages():
        <a href="/data/${page.identifier}" class="list-group-item list-group-item-action">${page.settings['title']}</a>
    % endfor
        </div>
</%block>
