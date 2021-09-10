<div class="float-right">
    <div class="pointlessly-required-div">
        #### filled by JS in layout.mako
    <div id="user" class="my-1 mr-3 text-right"></div>
        #### two icon row closed
        <div class="d-flex flex-row float-right">
        <button class="btn btn-outline-secondary m-1" type="button" style="width: 42px;" id="accessibility_btn"
                data-toggle="tooltip" title="Increase visibility of prolinks (protein-controlling links)">
        <i class="far fa-eye-slash"></i>
    </button>
        <button class="btn btn-outline-secondary m-1" type="button" style="width: 42px;" data-toggle="modal" data-target="#chat_modal" id="chat_modal_btn">
        <i class="far fa-comments"
                data-toggle="tooltip" title="Send message to admin (registered users only)"
        ></i>
    </button>
    ### Twice because mobile.
     <button class="btn btn-outline-secondary m-1 d-none d-lg-block" type="button" style="width: 42px;"
            title="Menu"
            id="menu"
            data-container="body"
            data-toggle="popover"
            data-placement="left"
            data-trigger="focus"
            data-html="true"
            data-content='<div class="list-group list-group-flush">
                            <%
                            menu_opts = (('Home','/michelanglo','far fa-home'),
                               ('Your pages','/personal','far fa-unlock'),
                               ('Convert PyMol file','/pymol','far fa-hammer'),
                               ('Convert PDB file','/pdb','far fa-wrench'),
                               ('Name to PDB', '/name', 'far fa-id-badge'),
                               ('VENUS', '/venus', 'far fa-radar'),
                               ('Convert custom mesh','/custom','far fa-mortar-pestle'),
                               ('Documentation','/docs','far fa-books'),
                               ('Gallery','/gallery','far fa-palette'),
                               ('Github repository','https://github.com/matteoferla/PyMOL-to-NGL-transpiler','fab fa-github')
                               )
                            %>
                            %for txt, link, ico in menu_opts:
                                %if (link and current_page and current_page in link) or (current_page == 'home' and link == '/'):
                                        <a role="button" class="list-group-item list-group-item-dark"><i class="${ico}"></i> ${txt}</a>
                                %else:
                                        <a role="button" class="list-group-item list-group-item-action" href="${link}"><i class="${ico}"></i> ${txt}</a>
                                %endif
                            %endfor
                            </div>
                         '>
        <i class="far fa-bars"></i></button>
     <button class="btn btn-outline-secondary m-1 d-lg-none d-block" type="button" style="width: 42px;" data-toggle="modal" data-target="#menu_modal">
        <i class="far fa-bars"></i></button>
    </div>
        #### two icon row closed
    </div>
    ### inner closed
</div>
### icon block closed

<div class="modal" tabindex="-1" role="dialog" id="menu_modal">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Menu</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        <div class="list-group list-group-flush">
                <%
                menu_opts = (('Home','/','far fa-home'),
                   ('Convert PyMol file','/pymol','far fa-hammer'),
                   ('Convert PDB file','/pdb','far fa-wrench'),
                   ('Name to PDB', '/name', 'far fa-id-badge'),
                   ('Convert custom mesh','/custom','far fa-mortar-pestle'),
                   ('Documentation','/docs','far fa-books'),
                   ('Gallery','/gallery','far fa-palette'),
                   ('Github repository','https://github.com/matteoferla/PyMOL-to-NGL-transpiler','fab fa-github')
                   )
                %>
                %for txt, link, ico in menu_opts:
                    %if (link and current_page and current_page in link) or (current_page == 'home' and link == '/'):
                            <a role="button" class="list-group-item list-group-item-dark"><i class="${ico}"></i> ${txt}</a>
                    %else:
                            <a role="button" class="list-group-item list-group-item-action" href="${link}"><i class="${ico}"></i> ${txt}</a>
                    %endif
                %endfor
                </div>
      </div>
    </div>
  </div>
</div>