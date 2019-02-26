<%page args="tour=False"/>

<div class="float-right d-flex flex-column" style="width: 42px;">
    <button class="btn btn-outline-secondary my-1" type="button" title="Menu"
            data-container="body"
            data-toggle="popover"
            data-placement="left"
            data-trigger="focus"
            data-html="true"
            data-content='<a role="button" class="btn btn-outline-secondary mx-1" href="/" title="home">                                                                <i class="far fa-home"></i></a>
                          <a role="button" class="btn btn-outline-secondary mx-1"  href="https://github.com/matteoferla/PyMOL-to-NGL-transpiler" title="Github repo">   <i class="fab fa-github"></i></a>
                          <a role="button" class="btn btn-outline-secondary mx-1"  href="/clash" title="clash documentation">                                           <i class="far fa-car-crash"></i></a>
                          <a role="button" class="btn btn-outline-secondary mx-1"  href="/markup" title="markup documentation">                                         <i class="far fa-map-marked-alt"></i></a>
                          <a role="button" class="btn btn-outline-secondary mx-1"  href="/custom" title="custom mesh converter">                                        <i class="far fa-mortar-pestle"></i></a>
                          <a role="button" class="btn btn-outline-secondary mx-1"  href="/docs" title="help">                                                           <i class="far fa-books"></i></a>
                         '>
        <i class="far fa-bars"></i></button>
    % if tour:
        <button type="button" class="btn btn-outline-secondary my-1" title="Guided tour of the site"><i class="far fa-question"></i></button>
    % endif

</div>
