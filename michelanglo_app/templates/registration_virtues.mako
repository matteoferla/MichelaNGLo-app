<%inherit file="layout_components/layout_w_card.mako"/>
<%block name="buttons">
            <%include file="layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>
<%block name="title">
            &mdash; Gallery
</%block>
<%block name="subtitle">
            This is were your personal gallery of files would be were you to register
</%block>

<%block name="main">
    <p>You are not logged in. To register or log in press <a href="#user" onclick="setInterval(()=> $('#user').toggleClass('font-weight-bold'), 500);">the user icon (<i class="far fa-user-secret"></i>) in the top right</a>. Once logged in, this same button can be used to see a concise list of protein, to log-out and other user-specific features.</p>
    <p>Once you are logged in and protein page you create will appear here in your <i>private</i> gallery. Namely, sharing this page will be unique for each user (<i>i.e.</i> if someone's link brought you here they were unfortunately misinformed). If you are want to see examples see <a href="/gallery">the gallery</a>.</p>
    <p>Registration is free and this site is academic and not for commercial or espionage purposes and complies with GDPR (see <a href="/docs/users">data policy</a>).</p>
</%block>
