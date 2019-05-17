<%page args="tour=False"/>
<div class="float-right d-flex flex-row">
    #### filled by JS in layout.mako
    <span id="user" class="my-2 mr-3"></span>
<div class="d-flex flex-column" style="width: 42px;">
    <button class="btn btn-outline-secondary my-1" type="button"
            title="Menu"
            id="menu"
            data-container="body"
            data-toggle="popover"
            data-placement="left"
            data-trigger="focus"
            data-html="true"
            data-content='<div class="list-group list-group-flush">
                            <%
                            menu_opts = (('Home','/','far fa-home'),
                               ('Convert PyMol file','/pymol','far fa-hammer'),
                               ('Convert PDB file','/pdb','far fa-wrench'),
                               ('Convert custom mesh','/custom','far fa-mortar-pestle'),
                               ('Primary documentation','/docs','far fa-books'),
                               ('Markup documentation','/markup','far fa-map-marked-alt'),
                               ('Clash documentation','/clash','far fa-car-crash'),
                               ('Image documentation','/imagetoggle','far fa-images'),
                               ('Gallery','/gallery','far fa-palette'),
                               ('Github repo','https://github.com/matteoferla/PyMOL-to-NGL-transpiler','fab fa-github')
                               )
                            %>
                            %for txt, link, ico in menu_opts:
                                %if current_page in link or (current_page == 'home' and link == '/'):
                                        <a role="button" class="list-group-item list-group-item-dark"><i class="${ico}"></i> ${txt}</a>
                                %else:
                                        <a role="button" class="list-group-item list-group-item-action" href="${link}"><i class="${ico}"></i> ${txt}</a>
                                %endif
                            %endfor
                            </div>
                         '>
        <i class="far fa-bars"></i></button>
    % if tour:
        <button type="button" class="btn btn-outline-secondary my-1" title="Guided tour of the site" data-toggle="tooltip" id="tour"><i class="far fa-question"></i></button>
    % endif
</div>
</div>
#### title toggling is in layout.mako
