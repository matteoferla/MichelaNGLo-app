<%inherit file="layout_components/layout_w_card.mako"/>
<%block name="buttons">
            <%include file="layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>
<%block name="title">
            &mdash; Gallery
</%block>
<%block name="subtitle">
            ${sottotitolo}
</%block>

<%block name="main">

    <%def name='card(page)'>
        <div class="card hypercard mb-4" onclick="window.location='/data/${page.identifier}'">
              <img src="/thumb/${page.identifier}" class="card-img-top p-4" alt="thumbnail of ${page.title}">
              <div class="card-body">
                <h5 class="card-title">${page.title}</h5>
                  %if page.privacy == 'public':
                    <p class="card-text text-muted">This page was created by a user.</p>
                  %elif page.privacy == 'published':
                    <p class="card-text text-muted">This user-created page appears in a publication.</p>
                  %elif page.privacy == 'pinned':
                    <p class="card-text text-muted">This page is of importance so is pinned.</p>
                  %elif page.privacy == 'sgc':
                    <p class="card-text text-muted">This page features an Target Enabling Package from the SGC.</p>
                  %endif
              </div>
                <div class="card-footer">
                          <small class="text-muted"><span class="text-muted">ID:</span> ${page.identifier}</small>
                </div>
            </div>
    </%def>

    <%def name="responsifydeck(i)">
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
    </%def>

        <%
            cats = {'published': 'Pages appearing in publications',
                    'pinned': 'Pinned pages',
                    'sgc': 'Target Enabling Packages (SGC)',
                    'public': 'Public Pages',
                    'private': 'Private Pages',
                    'other': 'This should not exist!'}

            sortedpages = {c: [] for c in cats}
            for page in pages:
                if page.privacy in cats.keys():
                    sortedpages[page.privacy].append(page)
                elif page.privacy is False or page.privacy == 'false':
                    sortedpages['private'].append(page) ###this should not happen, but lets play it safe.
                else:
                    sortedpages['other'].append(page)
        %>

        %for k in cats:
            %if len(sortedpages[k]):
                <h4>${cats[k]}</h4>
                <div class="card-deck">
                %for j, page in enumerate(sortedpages[k]):
                    ${card(page)}
                    ${responsifydeck(j)}
                %endfor
                %for s in range(j+1,j+7):
                    <div class="card" style="visibility: hidden;"></div>
                    ${responsifydeck(s)}
                %endfor
                </div>
                <hr/>
            %endif
        %endfor
</%block>
