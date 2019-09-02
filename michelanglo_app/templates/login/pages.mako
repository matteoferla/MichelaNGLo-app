<div id="pages-content">

    %if user:
        ################ admin
        %if user.role == 'admin':
            <h6>Admin console</h6>
            <p><a href="/admin">Click here to go to admin console.</a></p>
        %endif

        <%
            owned = user.owned.select(request)
            visited = user.visited.select(request)
            from datetime import datetime, timedelta
            unedited_time = datetime.now() - timedelta(days=20)
            untouched_time = datetime.now() - timedelta(days=300)
        %>

        <%def name="page_row(page, delete=True)">
            <li class="list-group-item" data-page="${page.identifier}">
                        %if page.edited:
                            <i class="far fa-pencil" data-toggle="tooltip" title="This page has been edited."></i>
                        %endif
                        %if page.encrypted:
                            <i class="far fa-key" data-toggle="tooltip" title="This page has been encrypted."></i>
                        %endif
                        %if page.protected:
                            <i class="far fa-eye" data-toggle="tooltip" title="This page is being monitored for changes."></i>
                        %endif
                        %if not page.edited and page.timestamp < unedited_time:
                            <i class="far fa-alarm-clock" data-toggle="tooltip" title="This page is going to be deleted in ${(page.timestamp - datetime.now()) + timedelta(days=30)} unless edited."></i>
                        %endif
                        %if page.edited and page.timestamp < untouched_time:
                            <i class="far fa-alarm-clock" data-toggle="tooltip" title="This page is going to be deleted in ${(page.timestamp - datetime.now()) + timedelta(days=365)} unless opened."></i>
                        %endif
                        <a href="/data/${page.identifier}">${page.title}</a>
                        %if delete:
                        <button class="btn btn-danger btn-sm float-right py-0" onclick="deletePage('${page.identifier}')"><i class="far fa-trash-alt"></i></button>
                        %endif
                    </li>
        </%def>

        ################# owned
        %if owned:
            <h6>Edited pages</h6>
            %if len(owned) < 20:
                <ul class="list-group">
                %for page in owned: ##these are Page instances.
                    ${page_row(page)}
                %endfor
            </ul>
            %else:
                <div class="row">
                    %for owned in [owned[:int(len(owned)/2)], owned[int(len(owned)/2):]]:
                        <div class="col-lg-6 px-0">
                            <ul  class="list-group">
                            %for page in owned:
                                ${page_row(page)}
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
                    ${page_row(page, delete=False)}
                %endfor
            </ul>
        %endif
        ######end of visited
    %endif
</div>
