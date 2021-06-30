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
    <%include file="docs/subparts/docs_nav.mako"/>
    <%def name="list_entry(url, icon, title, description, ico_type='far')">\
        <li><span class="fa-li"><i class="${ico_type} fa-${icon}"></i></span><a href="/docs/${url}">${title}</a> &mdash; ${description}</li>
    </%def>
    <h3>Index</h3>
    <p>Choose one of the following topics to continue:</p>
<ul class="fa-ul">
    ${list_entry('github', 'chart-network', 'Inner workings', 'Links to documentation about the inner workings of this site')}
    ${list_entry('implementations', 'code', 'Implementing a view', 'Generic instructions on embedding an interactive view on your own pages.')}
    ${list_entry('markup', 'link', 'Prolinks', 'Details and demo on protein view controlling links ("prolinks").')}
    ${list_entry('cite', 'feather-alt', 'Citation, typography and pronunciation', 'Papers to cite, how to write it and how to say it.')}
    ${list_entry('api', 'robot', 'API', 'Programmatically edit pages.')}
    ${list_entry('clash', 'car-crash', 'Clash', 'Details about how clashes are represented.')}
    ${list_entry('users', 'user', 'Users & pages', 'Information and policy about users and personal pages.')}
    ${list_entry('gene', 'dna', 'Making the perfect structure', 'Advice on creating a protein model that suits your needs.')}
    ${list_entry('venus', 'biohazard', 'VENUS', 'Predict the possible effects of a missense mutation on a given protein.')}
    ## ${list_entry('video', 'camera-movie', 'Videos', 'Tutorials ranging from protein basics to advanced editing')}
</ul>
</%block>