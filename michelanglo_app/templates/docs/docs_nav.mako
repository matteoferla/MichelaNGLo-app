<ul class="nav nav-tabs">
    %for url, name in [('implementations', 'Implementing a view'), ('markup','Prolinks'), ('cite','Citation'), ('api','API'), ('clash','Clash'), ('users','Users & pages'), ('gene','Starting with a gene name'), ('video', 'Video tutorials')]:
        %if request.matchdict and "id" in request.matchdict and request.matchdict['id'] == url:
            <li class="nav-item"><a class="nav-link active" href="/docs/${url}">${name}</a></li>
        %else:
            <li class="nav-item"><a class="nav-link" href="/docs/${url}">${name}</a></li>
        %endif
    %endfor
</ul>
<br/>