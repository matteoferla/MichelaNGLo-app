<%inherit file="layout.mako"/>

% if self.alert and self.alert() != '':
<div class="row p-4 d-none d-lg-block">
    <div class="col-lg-10 offset-lg-1">
        <%block name="alert"/>
    </div>
</div>
% endif

<div class="row py-4" id="main_card">
        <div class="col-lg-10 offset-lg-1">
            <div class="card my-5 shadow">
                <div class="card-header">
                    <div class="d-flex flex-md-row flex-column justify-content-between">
                        <div class="mr-2 d-none d-md-block">
                            <img src="/static/NGL.png" style="height: 6em;">
                        </div>
                        <div class="float-left">
                        <h1 class="card-title">
                            <span onclick="location.href='/';" style="cursor: pointer;">Michela<span style="font-variant: small-caps; font-weight: bolder;">ngl</span>o</span>
                            <%block name="title"/>
                        </h1>
                        <h3 class="card-subtitle mb-2 text-muted"><%block name="subtitle"/></h3>
                    </div>
                        <div class="float-right">
                            <%block name="buttons"/>
                        </div>
                        </div>
                    </div>
                <div class="card-body">
                    ${ next.body() }
                </div>
            </div>
        </div>
    </div>



<%block name="modals"/>
