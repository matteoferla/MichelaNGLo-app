<%inherit file="../layout_components/layout_w_card.mako"/>

<%block name="buttons">
            <%include file="../layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>

<%block name="title">
            &mdash; Guiding links ("Prolinks")
</%block>

<%block name="subtitle">
            Construction of HTML anchor tags to guide the users to a residue or region
</%block>

<%block name="body">

    <%include file="subparts/docs_nav.mako"/>


    <div class='row'>
        <div class='col-12'>
            <h3>Open source</h3>
            <p>This site is open source and can be found on GitHub under an MIT licence.
                However, some components, namely Pyrosetta for VENUS or the Phosphosite Plus data present in the protein data,
                require academic licences from the relevant sites.
            </p>
            <h3>Mechanics</h3>
            <p>Documentation about the workings of the site can be found in the relevant GitHub repos.</p>
            <p>These are:</p>
            <ul>
                <li><a href="https://github.com/matteoferla/MichelaNGLo-app">App</a></li>
                <li><a href="https://github.com/matteoferla/MichelaNGLo-protein-module">Protein module</a></li>
                <li><a href="https://github.com/matteoferla/MichelaNGLo-transpiler">Transpiler</a></li>
            </ul>
            <img src="/images/mike%20layout-03.png" style="width: 100%;"/>

            <p>Of note is the page <a href="https://github.com/matteoferla/MichelaNGLo-app/blob/master/git_docs/deploy.md">deploy.md</a>
            which details how to deploy a local copy of Michelaɴɢʟo.
            </p>
            <h3>Stand alone components</h3>
            <ul>
                <li>The <a href="https://github.com/matteoferla/MichelaNGLo-protein-module">protein module</a> can be used independently of the web app as a Python module.</li>
                <li>The protein data is very large. However, a compressed version of the files for human protein can be found in <a href="https://github.com/matteoferla/MichelaNGLo-human-protein-data">this repo</a>.</li>
                <li>The JSON files for matching names to Uniprot IDs can be found in <a href="https://github.com/matteoferla/Name-synomyms-to-Uniprot">a separate repo</a></li>
            </ul>
        </div>
    </div>
</%block>