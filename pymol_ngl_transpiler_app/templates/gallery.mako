<%inherit file="layout_w_card.mako"/>
<%block name="buttons">
            <%include file="menu_buttons.mako" args='tour=False'/>
</%block>
<%block name="title">
            &mdash; Gallery
</%block>
<%block name="subtitle">
            Here are links to several created pages
</%block>

<%block name="main">
    <%
        import os
        for file in os.listdir(os.path.join('pymol'))
    %>
    None made public.
</%block>
