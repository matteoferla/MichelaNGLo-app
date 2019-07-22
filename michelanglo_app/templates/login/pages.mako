<div id="pages-content">
    %if user:
        ################ admin
        %if user.role == 'admin':
            <h6>Admin console</h6>
            <p><a href="/admin">Click here to go to admin console.</a></p>
        %endif

        <%
            owned = user.get_owned_loaded_pages()
            visited = user.get_visited_loaded_pages()
        %>

        ################# owned
        %if owned:
            <h6>Edited pages</h6>
            %if len(owned) < 20:
                <ul class="list-group">
                %for page in owned:
                    <li class="list-group-item" data-page="${page.identifier}">
                        <a href="/data/${page.identifier}">${page.settings['title']}</a>
                        <button class="btn btn-danger btn-sm float-right py-0" onclick="deletePage('${page.identifier}')"><i class="far fa-trash-alt"></i></button>
                    </li>
                %endfor
            </ul>
            %else:
                <div class="row">
                    %for owned in [owned[:int(len(owned)/2)], owned[int(len(owned)/2):]]:
                        <div class="col-lg-6 px-0">
                            <ul  class="list-group">
                            %for page in owned:
                                <li class="list-group-item" data-page="${page.identifier}">
                                    <a href="/data/${page.identifier}">${page.settings['title']}</a>
                                    <button class="btn btn-danger btn-sm float-right py-0" onclick="deletePage('${page.identifier}')"><i class="far fa-trash-alt"></i></button>
                                </li>
                            %endfor
                            </ul>
                        </div>
                    %endfor
                </div>
            %endif
        %endif
        ######end of owned

        #### visited
        %if visited:
            <h6>Visited pages</h6>
            <ul class="list-group">
                %for page in visited:
                    <li class="list-group-item" data-page="${page.identifier}">
                        <a href="/data/${page.identifier}">${page.settings['title']}</a>
                    </li>
                %endfor
            </ul>
        %endif
        ######end of visited

    %endif
</div>
