<div class="modal fade" tabindex="-1" role="dialog" id="combine_modal">
    <div class="modal-dialog modal-xl" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="far fa-code"></i> Combine</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p>A single page can support multiple models, which can be toggled via <code>data-load</code> in the prolink.
                    Additionally, functions for specific representations can be run via prolinks using the attribute <code>data-view="nameOfFunction"</code>.<br/>
                    In order to implement either of these, generate another page and combine it here.<br/>
                    Note that editing the JS in blocked for regular users (due to security concerns), please speak to the site admin if you would like to alter your permissions.
                    Also note that this page will refresh in order for the changes to be made.
                </p>
                %if user:
                    <%
                        owned = user.get_owned_loaded_pages()
                        visited = user.get_visited_loaded_pages()
                    %>
                        <ul class="list-group">
                            <li class="list-group-item list-group-item-dark">
                                <div class="row">
                                    <div class="col-12 col-md-5">
                                        Page Title
                                    </div>
                                    <div class="col-4 col-md-2 offset-md-1">
                                        Add protein and representation
                                </div>
                                    <div class="col-4 col-md-2">
                                        Add representation only
                                    </div>
                                    <div class="col-4 col-md-2">
                                        Delete this page
                                    </div>
                                </div>
                            </li>
                        %for page in owned+visited:
                            <li class="list-group-item">
                                <div class="row">
                                    <div class="col-12 col-md-5">
                                        <a href="/data/${page.identifier}">${page.settings['title']}</a>
                                    </div>
                                    <div class="col-4 col-md-2 offset-md-1">
                                        <button class="btn btn-primary w-100" onclick="combinePage('${page.identifier}')"><i class="far fa-paperclip"></i></button>
                                </div>
                                    <div class="col-4 col-md-2">
                                        <button class="btn btn-primary w-100" onclick="copyJSPage('${page.identifier}')"><i class="far fa-clipboard"></i></button>
                                    </div>
                                    %if page in owned:
                                        <div class="col-4 col-md-2">
                                         <button class="btn btn-danger w-100" onclick="deletePage('${page.identifier}')"><i class="far fa-trash-alt"></i></button>
                                        </div>
                                    %endif
                                </div>
                            </li>
                        %endfor
                        </ul>
                %endif
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal"><i class="far fa-sign-out"></i> Close</button>
                </div>
            </div>
        </div>
    </div>
</div>
