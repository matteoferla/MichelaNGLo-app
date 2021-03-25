## route name: /venus
## this view is for Venus
<%namespace file="../layout_components/labels.mako" name="info"/>
<%inherit file="../layout_components/layout_w_card.mako"/>
<%block name="buttons">
            <%include file="../layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>
<%block name="title">
            &mdash; VENUS debug
</%block>
<%block name="subtitle">
    Assessing the effect of amino acid variants have on structure
</%block>

<%block name="alert">
    ### nothing.
</%block>

<%block name="main">
    <h1>Modals</h1>
    <p>This page simply shows what the modals say and is not meant for users.
        Most modal links are added by <code>Venus.prototype.concludeMutational</code> to
        the <code>#effect</code> entry. The methods called by this have a non-standard case with underscore for clarity.</p>
        <div class="list-group">
            <%
                modals = {'#modalStructureless':'raised when no structure',
                          '#': 'No link added by Venus.prototype.concludeMutational_nonsense',
                          '#modalPhosphorylation': 'Link added by Venus.prototype.concludeMutational_phospho',
                          '#modalBuriedPhosphorylation': 'Link added by Venus.prototype.concludeMutational_phospho',
                          '#modalDistortedPhosphorylation': 'Link added by Venus.prototype.concludeMutational_phospho',
                          '#modalChargedPhosphorylation': 'Link added by Venus.prototype.concludeMutational_phospho',
                          '#modalDisulfide': 'Link added by Venus.prototype.concludeMutational_disulfo',
                          '#modalUbiquitination': 'Link added by Venus.prototype.concludeMutational_ubi',
                          '#modalDestabilisation': 'Link added by Venus.prototype.concludeMutational_destabilising',
                         }
            %>
            % for identifier, text in modals.items():
                <button type="button"
                        class="list-group-item list-group-item-action"
                        data-toggle="modal" data-target="${identifier}"
                >
                    ${text} (<code>${identifier}</code>)
                </button>
            % endfor
        </div>
    <h1>MCS</h1>
    <div class="row">
        %for first, first_aa in enumerate('I V L F C M A G T S W Y P H N D E Q K R'.split()):
            %for second, second_aa in enumerate('I V L F C M A G T S W Y P H N D E Q K R'.split()):
                % if first < second:
                <div class="col-3 border rounded">
                    <p>${first_aa} to ${second_aa}</p>
                    <img src="/static/aa/${first_aa}${second_aa}.svg" width="100%;">
                    <img src="/static/aa/${second_aa}${first_aa}.svg" width="100%;">
                </div>
                % endif
            %endfor
        %endfor
    </div>
</%block>

<%block name='after_main'>
</%block>

<%block name='modals'>
    ### This adds #modalStructureless
    <%include file="venus_no_structure.mako"/>
    <%include file="extra_info.mako"/>
</%block>

<%block name='script'>
<script type="text/javascript">
    $(document).ready(function () {
        ### this controls the input validation. It was originally written for /name route
        ## %include file="../name.js"/>
        ### this controls the uniprot field. It was originally written for /name route
        ## include file="../results/uniprot_modal.js"/>
        ### this controls venus specific stuff.
        <%include file="venus_class.js"/>
        ## include file="venus.js"/>
    });
    ####include file="../markup/markup_builder_modal.js"/>
    window.interactive_builder = () => undefined; //burn the call.
</script>
    <link rel="stylesheet" href="/static/feature.css" async>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.17/d3.js"></script>
    ###<script src="https://cdn.rawgit.com/calipho-sib/feature-viewer/v1.0.0/dist/feature-viewer.min.js"></script>
    <script src="/static/ThirdParty/feature-viewer.js" async></script>
</%block>