<%namespace file="../layout_components/common_methods.mako" import="copy_btn"/>
<%namespace file="../layout_components/labels.mako" name="info"/>
<%inherit file="../layout_components/layout_w_card.mako"/>
<%block name="buttons">
            <%include file="../layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>
<%block name="title">
            &mdash; Documentation
</%block>
<%block name="subtitle">
            Citation & licence
</%block>

<%block name="main">

<%include file="docs_nav.mako"/>

<h4>Citation</h4>
    <ul>
        <li><span class="text-danger">Unpublished.</span></li>
        <li><a href="https://dx.doi.org/10.1093/bioinformatics/bty419" target="_blank">AS Rose, AR Bradley, Y Valasatava, JM Duarte, A Prlić and PW Rose. NGL viewer: web-based molecular graphics for large complexes. Bioinformatics: bty419, 2018. <i class="far fa-external-link"></i></a></li>
    </ul>
<h4>Licence</h4>
<p>This site is open-source (see <a href="https://github.com/matteoferla/MichelaNGLo" target="_blank">github.com/matteoferla/MichelaNGLo <i class="far fa-external-link"></i></a>) and released under the MIT licence.
Any content within the user pages belongs to the creators and editors of those pages (therefore consult them for copyright/privacy <i>etc.</i>).</p>
<h4>Typography and phonetics</h4>
<p>Michelaɴɢʟo is a blend of Michelangelo &mdash;as in <a href="https://en.wikipedia.org/wiki/Michelangelo" target="_blank">the sculptor <i class="fab fa-wikipedia-w"></i></a> not the ninja turtle&mdash; and NGL (the library that it uses) and as a consequence it can either be rendered in CamelCase MichelaNGLo or, preferably, with the NGL in <a href="https://en.wikipedia.org/wiki/Small_caps" target="_blank">small caps <i class="fab fa-wikipedia-w"></i></a>, thusly: Michelaɴɢʟo.</p>
<p>In terms of pronunciation, it is pronounced like the sculptor and it's your call if to pronounce with a terse first syllable /ˌmɪkəlˈændʒəloʊ/ (closer to Italian, albeit technically /mikeˈlandʒelo/) or a lax one /ˌmaɪkəlˈændʒəloʊ/ (as the ninja turtle calls himself) &mdash;the author of this site, despite speaking Italian, goes for the latter as it sounds less pretentious.</p>
</%block>