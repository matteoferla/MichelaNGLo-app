<%namespace file="../layout_components/common_methods.mako" import="copy_btn"/>
<%namespace file="../layout_components/labels.mako" name="info"/>
<%inherit file="../layout_components/layout_w_card.mako"/>
<%block name="buttons">
            <%include file="../layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>
<%block name="title">
            &mdash; Documentation
</%block>
<%block name="subtitle">
            Video documentation
</%block>

<%block name="main">

<%include file="docs_nav.mako"/>

    <ul class="list-group list-group-flush">
  <li class="list-group-item">
      <h4>Introduction</h4>
        <div class="embed-responsive embed-responsive-16by9">
          <iframe class="embed-responsive-item" src="https://www.youtube.com/embed/v3B3Ok2X5ck" allowfullscreen></iframe>
        </div>
  </li>
  <li class="list-group-item">
      <h4>Basic editing</h4>
<div class="embed-responsive embed-responsive-16by9">
  <iframe class="embed-responsive-item" src="https://www.youtube.com/embed/uQs3LsjgB68" allowfullscreen></iframe>
</div>
  </li>
  <li class="list-group-item">
      <h4>Proteins 101</h4>
      <p>Coming soon!</p>
  </li>
  <li class="list-group-item">
      <h4>Advanced editing</h4>
      <p>Coming soon!</p>
  </li>
  <li class="list-group-item">
      <h4>API</h4>
      <p>Coming soon!</p>
  </li>
</ul>

</%block>