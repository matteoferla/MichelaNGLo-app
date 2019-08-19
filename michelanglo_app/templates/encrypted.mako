<%inherit file="layout_components/layout_w_card.mako"/>
<%block name="buttons">
            <%include file="layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>
<%block name="title">
            &mdash; Encrypted page
</%block>
<%block name="subtitle">
            The page is encrypted and needs to be unlocked
</%block>

<%block name="body">
    <p>Note: to prevent dictionary attacks, you <b>will be banned</b> if you fail an inhuman amount of times a minute.</p>
    <form action="/data/${page}" method="post">
        <div class="input-group mb-3">
          <div class="input-group-prepend">
            <span class="input-group-text" id="keylabel">Key</span>
          </div>
            <input type="password" class="form-control" name="key" placeholder="key" aria-label="key" aria-describedby="keylabel">
            <div class="input-group-append">
            <input type="submit" class="btn btn-success" value="Submit">
          </div>
        </div>
    </form>
</%block>

<%block name='modals'>
</%block>

<%block name='script'>
</%block>
