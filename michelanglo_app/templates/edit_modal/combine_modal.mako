<div class="modal fade" tabindex="-1" role="dialog" id="combine_modal">
    <div class="modal-dialog modal-xl" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="far fa-code"></i> Add structure from another pages</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p>A single page can support multiple models, which can be toggled via <code>data-load</code> in the prolink (a link that control the protein view).</p>
                <p>To show a structure, two pieces of information are needed:
                <ol>
                    <li>
                        one is the structure, namely the information of each atom (<i>e.g.</i> element, residue, coordinates). The PDB file basically.
                    </li>
                    <li>
                        the other is the representation, namely the combination of the orientation, residues shown, colors and field of view etc. In the case of PyMOL generated views,
                        these are functions that can be called via the attribute <code>data-view="name_of_function"</code>.
                    </li>
                </ol>

                    </p>
                <p>To combine two PyMOL representation of the same structure use the <code>add representation only</code> button: there is no need to slow things down by loading the same coordinates, else add both.</p>
                <p>This applies also to cases where the structure is taken remotely (e.g. PDB database).</p>
                <p>
                    Note that editing the JS in blocked for regular users (due to security concerns), please speak to the site admin if you would like to alter your permissions.
                    Also note that this page will refresh in order for the changes to be made.
                </p>
                %if user:
                    <%
                        owned = user.owned.select(request.dbsession)
                        visited = user.visited.select(request.dbsession)
                    %>
                        <ul class="list-group">
                            <li class="list-group-item list-group-item-dark">
                                <div class="row">
                                    <div class="col-12 col-md-5">
                                        Page Title
                                    </div>
                                    <div class="col-4 col-md-2 offset-md-1">
                                        Add structure and representation
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
                                        <a href="/data/${page.identifier}">${page.title}</a>
                                    </div>
                                    <div class="col-4 col-md-2 offset-md-1" data-toggle="tooltip" title="Add both the structure and the representation from this page to the current one.">
                                        <button class="btn btn-primary w-100" onclick="combinePage('${page.identifier}')"><i class="far fa-paperclip"></i></button>
                                </div>
                                    <div class="col-4 col-md-2"  data-toggle="tooltip" title="Add only the representation from this page to the current one and not the structure as it is the same.">
                                        <button class="btn btn-primary w-100" onclick="copyJSPage('${page.identifier}')"><i class="far fa-clipboard"></i></button>
                                    </div>
                                    %if page in owned:
                                        <div class="col-4 col-md-2"  data-toggle="tooltip" title="Delete this page.">
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
