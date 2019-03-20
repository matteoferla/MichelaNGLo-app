<%inherit file="layout.mako"/>


<%block name="alert"/>

<div class="row py-4">
        <div class="col-lg-10 offset-lg-1">
            <div class="card my-5 shadow">
                <div class="card-header">
                    <img src="static/ox_logo-01.svg" style="height: 6em; position: absolute;">
                    <div style="margin-left: 6em;">
                        <h1 class="card-title">
                            <span onclick="location.href='/';" style="cursor: pointer;">Michela<span style="font-variant: small-caps;">ngl</span>o</span> <%block name="title"/>
                        <%block name="buttons"/>
                    </h1>
                        <h3 class="card-subtitle mb-2 text-muted"><%block name="subtitle"/></h3>
                    </div>
                </div>
                <div class="card-body">
                    ${ next.body() }
                </div>
            </div>
        </div>
    </div>



<%block name="modals"/>
