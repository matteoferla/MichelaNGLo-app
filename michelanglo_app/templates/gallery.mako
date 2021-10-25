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
    <%
        from michelanglo_app.models import Publication, Doi, Page

        def publication(page):
            pub = request.dbsession.query(Publication).filter_by(identifier=page.identifier).first()
            if pub:
                return pub.to_html()
            else:
                return '(No publication data set)'

        def publication_year(page):
            pub = request.dbsession.query(Publication).filter_by(identifier=page.identifier).first()
            if pub:
                return pub.year
            else:
                return 1970

        from datetime import datetime, timedelta
        unedited_time = datetime.now() - timedelta(days=20)
        untouched_time = datetime.now() - timedelta(days=300)

        shorts = {d.long: d.short for d in request.dbsession.query(Doi).all()}
    %>

    <%def name='card(page)'>
        <div class="card hypercard mb-4"
              %if page.identifier in shorts:
                  data-uuid="r/${shorts[page.identifier]}"
              %else:
                  data-uuid="data/${page.identifier}"
              %endif
              >
              <img src="/thumb/${page.identifier}" class="card-img-top p-4" alt="thumbnail of ${page.title}">
              <div class="card-body">
                <h5 class="card-title">${page.title}</h5>
                  %if page.privacy == 'public':
                    <p class="card-text text-muted">This page was created by a user.</p>
                  %elif page.privacy == 'published':
                    <p class="card-text text-muted">This user-created page appears in a publication.<br/><small>${publication(page)|n}</small></p>
                  %elif page.privacy == 'pinned':
                    <p class="card-text text-muted">This page is of importance so is pinned.</p>
                  %elif page.privacy == 'sgc':
                    <p class="card-text text-muted">This page features an Target Enabling Package from the SGC.</p>
                  %endif
              </div>
                <div class="card-footer">
                    %if page.identifier in shorts:
                        <small class="text-muted"><span class="text-muted">short ID:</span> ${shorts[page.identifier]}</small>
                    %else:
                        <small class="text-muted"><span class="text-muted">ID:</span> ${page.identifier}</small>
                    %endif
                    %if page.protected:
                        <i class="far fa-lock"  data-toggle="tooltip" title="This page cannot be deleted."></i>
                    %endif
                    %if page.encrypted:
                        <i class="far fa-key" data-toggle="tooltip" title="This page has been encrypted."></i>
                    %endif
                    %if page.privacy != 'private':
                        &nbsp;
                    %elif not page.edited and page.timestamp < unedited_time:
                        <i class="far fa-alarm-clock" data-toggle="tooltip" title="This page is going to be deleted in ${(page.timestamp - datetime.now()) + timedelta(days=30)} unless edited."></i>
                    %elif page.edited and page.timestamp < untouched_time:
                        <i class="far fa-alarm-clock" data-toggle="tooltip" title="This page is going to be deleted in ${(page.timestamp - datetime.now()) + timedelta(days=365)} unless opened."></i>
                    %endif
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
            for page in pages: #type: Page
                if page.privacy in cats.keys():
                    sortedpages[page.privacy].append(page)
                elif page.privacy is False or page.privacy == 'false':
                    sortedpages['private'].append(page) ###this should not happen, but lets play it safe.
                else:
                    sortedpages['other'].append(page)
            for cat in cats: #type: str
                if cat == 'published':
                    sorter = lambda page: publication_year(page)
                else:
                    sorter = lambda page: page.timestamp
                sortedpages[cat] = sorted(sortedpages[cat], key=sorter, reverse=True)
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

<%block name="script">
    <script type="text/javascript">
        $(document).ready(function () {
            $('.hypercard').click(event => {
                if (event.target.tagName !== 'A') {
                    identifier = $(event.target).parents('.hypercard').data('uuid');
                    window.location=identifier;
                }
            });
        });
    </script>
</%block>
