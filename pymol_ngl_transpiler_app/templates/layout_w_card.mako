<%inherit file="layout.mako"/>


<%block name="alert"/>

<div class="card">
    <div class="card-header">
        <h1 class="card-title">
            <%block name="title"/>
            <%block name="buttons"/>
        </h1>
        <h3 class="card-subtitle mb-2 text-muted"><%block name="subtitle"/></h3>
    </div>
    <div class="card-body">
        ${ next.body() }
    </div>
</div>

<%block name="modals"/>
