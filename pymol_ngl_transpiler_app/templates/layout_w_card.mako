<%inherit file="layout.mako"/>
<%page args="card_title='PyMOL&rarr;NGL converter and generator', card_subtitle='ERROR', tour=False"/>

<%block name="alert"/>

<div class="card">
    <div class="card-header">
        <h1 class="card-title">${card_title}
            <%include file="menu_buttons.mako" args='tour=tour'/>
        </h1>
        <h3 class="card-subtitle mb-2 text-muted">${card_subtitle}</h3>
    </div>
    <div class="card-body">
        ${ next.body() }
    </div>
</div>

<%block name="modals"/>