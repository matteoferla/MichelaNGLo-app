<%namespace file="../layout_components/labels.mako" name="info"/>
<%inherit file="../layout_components/layout_w_card.mako"/>

<%block name="buttons">
    <%include file="../layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>

<%block name="title">
    &mdash; VENUS — URLs
</%block>

<%block name="subtitle">
    Variant effect on structure — Free energy
</%block>

<%block name="body">

    <%include file="subparts/docs_nav.mako"/>

        <%include file="subparts/docs_venus_nav.mako" args='topic="url"'/>
         <h3>API and redirects</h3>
    <p>There are a few API routes available.
        Firstly the route<code>/venus_analyse</code>, with parameters <code>uniprot</code>, <code>species</code> and <code>mutation</code>
        will return the same content as the VENUS page but as a JSON object.
        for example <a href="https://michelanglo.sgc.ox.ac.uk/venus_analyse?uniprot=P01112&species=9606&mutation=Y40W" target="_blank">
            michelanglo.sgc.ox.ac.uk/venus_analyse?uniprot=P01112&species=9606&mutation=Y40W</a>. </p><p>
        The JSON response contains the following keys:</p>
    <ul><li>status: 'success' | 'error' (msg if error)</li>
        <li>protein: all data for the protein (fills the feature viewer)</li>
        <li>mutation: mutation data from a structure indepenedent point of view (inc. nearby features)</li>
        <li>structural: cartesian neighbourhood of the mutation, best structure (offset fixed) and surface/buried, and helix/sheet/loop</li>
        <li>ddG: energetic assessment of the mutation ddG and scores[] in kcal/mol. contains also the energy minimised neighbourhood of the wt and mutant</li>
    </ul>


        <h4>Redirected</h4>
        <p>
        The parameters <code>uniprot</code>, <code>species</code> and <code>mutation</code> also work the route <code>/venus</code> (the main VENUS page)
        to preload a mutation (e.g. for sharing it).
        Lastly there is the URL <code>/venus_transcript?enst=ENSTXXXXXXX&mutation=XNNX&redirect</code>, which redirects to VENUS a human transcript
        and mutation to VENUS converting the transcript to canonical according to Uniprot.
It accepts ENST and mutations and redirects to the normal VENUS page but with the Uniprot id and the mutation shifted accordingly.
It runs on human genes only, so it is an unofficial route.
    </p>
</%block>

<%block name='modals'>
</%block>
<%block name="script">
    <script type="text/javascript">
    </script>
</%block>

