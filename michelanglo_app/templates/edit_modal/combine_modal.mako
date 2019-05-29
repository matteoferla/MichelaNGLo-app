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
                </p>
                %if user:
                    <%
                        owned = user.get_owned_loaded_pages()
                        visited = user.get_visited_loaded_pages()
                    %>
                        <ul class="list-group">
                        %for page in owned:
                            <li class="list-group-item">
                                <a href="/data/${page.identifier}">${page.settings['title']}</a>
                                <button class="btn btn-danger btn-sm float-right py-0" onclick="combinePage('${page.identifier}')"><i class="far fa-paperclip"></i> Add protein and representation</button>
                                <button class="btn btn-danger btn-sm float-right py-0" onclick="copyJSPage('${page.identifier}')"><i class="far fa-clipboard"></i> Add representation only</button>
                                <button class="btn btn-danger btn-sm float-right py-0" onclick="deletePage('${page.identifier}')"><i class="far fa-trash-alt"></i> Delete this page</button>
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
