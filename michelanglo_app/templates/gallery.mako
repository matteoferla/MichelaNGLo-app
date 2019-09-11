<%inherit file="layout_components/layout_w_card.mako"/>
<%block name="buttons">
            <%include file="layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>
<%block name="title">
            &mdash; Gallery
</%block>
<%block name="subtitle">
            Here are links to created pages flagged as public
</%block>

<%block name="main">

    <div class="card-deck">
                % for i, page in enumerate(sorted(public_pages, key=lambda p: ['published','sgc','public'].index(p.privacy) if p.privacy in ['published','sgc','public'] else 10)):
                    <div class="card hypercard" onclick="window.location='/data/${page.identifier}'">
                          <img src="/thumb/${page.identifier}" class="card-img-top p-4" alt="thumbnail of ${page.title}">
                          <div class="card-body">
                            <h5 class="card-title">${page.title}</h5>
                              %if page.privacy == 'public':
                                <p class="card-text text-muted">This page was created by a user.</p>
                              %elif page.privacy == 'published':
                                <p class="card-text text-muted">This user-created page appears in a publication.</p>
                              %elif page.privacy == 'sgc':
                                <p class="card-text text-muted">This page features an Target Enabling Package from the SGC.</p>
                              %endif
                          </div>
                            <div class="card-footer">
                                      <small class="text-muted"><span class="text-muted">ID:</span> ${page.identifier}</small>
                            </div>
                        </div>
                    %if i % 6 == 5:
                        <div class="w-100 d-none d-xl-block"><!-- wrap every 6 on xl--></div>
                    %endif
                    %if i % 4 == 3:
                        <div class="w-100 d-none d-lg-block d-xl-none pb-3"><!-- wrap every 4 on lg--></div>
                    %endif
                    %if i % 3 == 2:
                        <div class="w-100 d-none d-md-block d-lg-none pb-3"><!-- wrap every 3 on md--></div>
                    %endif
                    %if i % 2 == 1:
                        <div class="w-100 d-none d-sm-block d-md-none pb-3"><!-- wrap every 2 on sm--></div>
                    %endif
                % endfor
            </div>
</%block>
