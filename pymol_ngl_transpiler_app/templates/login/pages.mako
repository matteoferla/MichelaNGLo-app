<div id="pages-content">
    %if user:
        <%
            from pymol_ngl_transpiler_app.pages import Page
            if user.owned_pages:
                owned_raw = [Page(pagename) for pagename in user.owned_pages.split()]
                owned = [page for page in owned_raw if page.exists()]
            else:
                owned = []
            if user.visited_pages:
                visited_raw = [Page(pagename) for pagename in user.visited_pages.split()]
                visited = [page for page in visited_raw if page.exists()]
            else:
                visited = []
        %>
        ################# owned
        %if owned:
            <h6>Edited pages</h6>
            <ul>
                %for page in owned:
                    <li class="list-group-item" data-page="${page.identifier}">
                        <a href="/data/${page.identifier}">${page.load()['title']}</a>
                        <button class="btn btn-danger btn-sm float-right py-0" onclick="deletePage('${page.identifier}')"><i class="far fa-trash-alt"></i></button>
                    </li>
                %endfor
            </ul>
        %endif
        ######end of owned

        #### visited
        %if visited:
            <h6>Visited pages</h6>
            <ul>
                %for page in visited:
                    <li class="list-group-item" data-page="${page.identifier}">
                        <a href="/data/${page.identifier}">${page.load()['title']}</a>
                    </li>
                %endfor
            </ul>
        %endif
        ######end of visited

    %endif
</div>
