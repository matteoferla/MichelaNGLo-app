<%page args="tour=False"/>

<div class="float-right d-flex flex-column" style="width: 42px;">
    <button class="btn btn-outline-secondary my-1" type="button"
            title="Menu"
            id="menu"
            data-container="body"
            data-toggle="popover"
            data-placement="left"
            data-trigger="focus"
            data-html="true"
            data-content='<a role="button" class="btn btn-outline-secondary mx-1" href="/" title="Home">                                                                <i class="far fa-home"></i></a>
                          <a role="button" class="btn btn-outline-secondary mx-1"  href="/pymol" title="Convert PyMol file">                                            <i class="far fa-hammer"></i></a>
                          <a role="button" class="btn btn-outline-secondary mx-1"  href="/pdb" title="Prep PDB">                                                        <i class="far fa-wrench"></i></a>
                          <a role="button" class="btn btn-outline-secondary mx-1"  href="/clash" title="Clash documentation">                                           <i class="far fa-car-crash"></i></a>
                          <a role="button" class="btn btn-outline-secondary mx-1"  href="/markup" title="Markup documentation">                                         <i class="far fa-map-marked-alt"></i></a>
                          <a role="button" class="btn btn-outline-secondary mx-1"  href="/imagetoggle" title="Image documentation">                                     <i class="far fa-images"></i>
                          <a role="button" class="btn btn-outline-secondary mx-1"  href="/custom" title="Custom mesh converter">                                        <i class="far fa-mortar-pestle"></i></a>
                          <a role="button" class="btn btn-outline-secondary mx-1"  href="/docs" title="Help">                                                           <i class="far fa-books"></i></a>
                          <a role="button" class="btn btn-outline-secondary mx-1"  href="https://github.com/matteoferla/PyMOL-to-NGL-transpiler" title="Github repo">   <i class="fab fa-github"></i></a>
                         '>
        <i class="far fa-bars"></i></button>
    % if tour:
        <button type="button" class="btn btn-outline-secondary my-1" title="Guided tour of the site" data-toggle="tooltip" id="tour"><i class="far fa-question"></i></button>
    % endif
</div>

#### title toggling is in layout.mako
