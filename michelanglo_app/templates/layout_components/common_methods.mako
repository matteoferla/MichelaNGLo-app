<%def name="copy_btn(target)">
    <div class="float-right">
        <button type="button" class="btn btn-outline-primary btn-sm m-1 clipboard" data-clipboard-target="#${target}"><i class="far fa-clipboard"></i> Copy</button>
    </div>
</%def>

<%def name="ext_item(link, name, icon)">
    ## use like:
    ## <%elements:card title="from SMILES" description="${description}" card_id="${card_id}">...</%elements:card>

    <li>
        ## class is in ul as in fa-ul
        <span class="fa-li"><i class="far ${icon}"></i></span>
        <a href="${link}" target="_blank">${name} <i class="far fa-external-link"></i></a> &mdash;
        ${caller.body()}
    </li>
</%def>

<%def name="wiki(page, text=None)">
    <a href="https://en.wikipedia.org/wiki/${page}" target="_blank">${text if text else page}
        <i class="fab fa-wikipedia-w"></i></a>
</%def>

<%def name="external(url, text)">
    <a href="${url}" target="_blank">${text}
        <i class="far fa-external-link"></i></a>
</%def>

<%def name="docs(name)">
    <a href="/docs/${name}">${name} documentation</a>
</%def>