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
<%
youtube_videos = {'Introduction': 'v3B3Ok2X5ck',
                  'Basic editing': 'uQs3LsjgB68',
                  'Proteins 101': 'TgjtPUikjfE',
                  'Advanced editing': 'PjPmXs_wE9Y',
                  'Page monitoring': 'ospuYm60j58',
                  'Venus': 'OVBeE0DmQes',
                  'Venus — note on custom models': 'bFTryyZvegE'}
%>

<%include file="subparts/docs_nav.mako"/>

    <ul class="list-group list-group-flush">
    %for video_title, youtube in youtube_videos.items():
        <li class="list-group-item">
          <h4>${video_title}</h4>
            <div class="embed-responsive embed-responsive-16by9">
              <iframe class="embed-responsive-item" src="https://www.youtube.com/embed/${youtube}" allowfullscreen></iframe>
            </div>
        </li>
    %endfor
    </ul>

</%block>