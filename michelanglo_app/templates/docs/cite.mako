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

<%include file="subparts/docs_nav.mako"/>

<h4>Relevant citation</h4>
    <ul>
        <li><a href="https://doi.org/10.1016/j.jmb.2022.167567" target="_blank">Ferla MP, Pagnamenta AT, Koukouflis L, Taylor JC, Marsden BD. Venus: Elucidating the Impact of Amino Acid Variants on Protein Function Beyond Structure Destabilisation. J Mol Biol. 434(11):167567. 2022 Jun 15. <i class="far fa-external-link"></i></a></li>
        <li><a href="https://doi.org/10.1093/bioinformatics/btaa104" target="_blank">Ferla MP, Pagnamenta AT, Damerell D, Taylor JC, Marsden BD. Michelanglo:  sculpting protein views on web pages without coding. Bioinformatics. 36(10):3268-3270. 2020 Feb 15. <i class="far fa-external-link"></i></a></li>
    </ul>
<p>Additionally, Michelaɴɢʟo and Venus depend on various other works. Most notably NGL:</p>
<ul>
<li><a href="https://dx.doi.org/10.1093/bioinformatics/bty419" target="_blank">AS Rose, AR Bradley, Y Valasatava, JM Duarte, A Prlić and PW Rose. NGL viewer: web-based molecular graphics for large complexes. Bioinformatics: bty419, 2018. <i class="far fa-external-link"></i></a></li>
</ul>
<p>Venus relies several datasets which are listed (with relevant publications) in the bottom of an analysis in the Venus page.</p>

<h4>Typography and phonetics</h4>
<p>Michelaɴɢʟo is a blend of Michelangelo &mdash;as in <a href="https://en.wikipedia.org/wiki/Michelangelo" target="_blank">the sculptor <i class="fab fa-wikipedia-w"></i></a> not the ninja turtle&mdash; and NGL (the library that it uses) and as a consequence it can either be rendered in CamelCase MichelaNGLo or, preferably, with the NGL in <a href="https://en.wikipedia.org/wiki/Small_caps" target="_blank">small caps <i class="fab fa-wikipedia-w"></i></a>, thusly: Michelaɴɢʟo.</p>
<p>In terms of pronunciation, it is pronounced like the sculptor and it's your call if to pronounce with a terse first syllable /ˌmɪkəlˈændʒəloʊ/ (closer to Italian, albeit technically /mikeˈlandʒelo/) or a lax one /ˌmaɪkəlˈændʒəloʊ/ (as the ninja turtle calls himself) &mdash;the author of this site, despite speaking Italian, goes for the latter as it sounds less pretentious.</p>

<h4>Licence</h4>
<h5>Michelaɴɢʟo</h5>
<p>This site is open-source (see <a href="https://github.com/matteoferla/MichelaNGLo" target="_blank">github.com/matteoferla/MichelaNGLo <i class="far fa-external-link"></i></a>) and released under the MIT licence.
Any content within the user pages belongs to the creators and editors of those pages (therefore consult them for copyright/privacy <i>etc.</i>).</p>
<h5>VENUS</h5>
<p><a href="/venus">VENUS (Variant Effect on Structure)</a> itself is likewise open source under an MIT licence,
    but utilises several third party data,
    which are under different licences and as a result the page is for academic use only.</p>
    <p>Specifically results concluded by data from a given databases should be acknowledged appropriately:</p>

    <%def name="make_entry(dataset, a_url, a_text, licence, ref)">
        <li>
            <b>${dataset}</b>

            %if a_url:
                is from
                <a href="${a_url}" target="_blank">${a_text} <i class="far fa-external-link"></i></a>
            %endif

            %if licence:
                <br/>${licence}
            %endif

            <br/>${ref}
        </li>
    </%def>

    <ul>

        <li><b>Specific crystal structure</b> depends on the structure used.
            Not all deposited crystal structures have an associated paper.
            See relevant PDB entry for more.</li>

        ${make_entry(  dataset='Domain data',
                       a_url='https://www.uniprot.org/',
                       a_text='Uniprot',
                       licence='??? License',
                       ref='The UniProt Consortium. UniProt: a worldwide hub of protein knowledge. Nucleic Acids Res. 47: D506-515 (2019).'
                    )}

        ${make_entry(  dataset='Crystal structure data',
                       a_url='https://www.rcsb.org/',
                       a_text='Protein Data Bank',
                       licence='? License',
                       ref='H.M. Berman, J. Westbrook, Z. Feng, G. Gilliland, T.N. Bhat, H. Weissig, I.N. Shindyalov, P.E. Bourne. (2000) The Protein Data Bank Nucleic Acids Research, 28: 235-242.'
                    )}

        ${make_entry(  dataset='Phosphorylation data',
                       a_url='https://www.phosphosite.org/homeAction.action',
                       a_text='PhosphoSitePlus (R)',
                       licence='Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License',
                       ref='Hornbeck PV, Zhang B, Murray B, Kornhauser JM, Latham V, Skrzypek E. PhosphoSitePlus, 2014: mutations, PTMs and recalibrations. Nucleic Acids Res. 2015 43:D512-20.'
                    )}

        ${make_entry(  dataset='Kyle-Doolittle hydrophobicity scale',
                       a_url=None,
                       a_text=None,
                       licence=None,
                       ref='Kyte, Jack; Doolittle, Russell F. (May 1982). "A simple method for displaying the hydropathic character of a protein". Journal of Molecular Biology. Elsevier BV. 157 (1): 105–32.'
                    )}

        ${make_entry(  dataset='Human variability data',
                       a_url='https://gnomad.broadinstitute.org/',
                       a_text='gnomAD',
                       licence='? License',
                       ref="Konrad J. Karczewski, Laurent C. Francioli, Grace Tiao, Beryl B. Cummings, Jessica Alföldi, Qingbo Wang, Ryan L. Collins, Kristen M. Laricchia, Andrea Ganna, Daniel P. Birnbaum, Laura D. Gauthier, Harrison Brand, Matthew Solomonson, Nicholas A. Watts, Daniel Rhodes, Moriel Singer-Berk, Eleanor G. Seaby, Jack A. Kosmicki, Raymond K. Walters, Katherine Tashman, Yossi Farjoun, Eric Banks, Timothy Poterba, Arcturus Wang, Cotton Seed, Nicola Whiffin, Jessica X. Chong, Kaitlin E. Samocha, Emma Pierce-Hoffman, Zachary Zappala, Anne H. O’Donnell-Luria, Eric Vallabh Minikel, Ben Weisburd, Monkol Lek, James S. Ware, Christopher Vittal, Irina M. Armean, Louis Bergelson, Kristian Cibulskis, Kristen M. Connolly, Miguel Covarrubias, Stacey Donnelly, Steven Ferriera, Stacey Gabriel, Jeff Gentry, Namrata Gupta, Thibault Jeandet, Diane Kaplan, Christopher Llanwarne, Ruchi Munshi, Sam Novod, Nikelle Petrillo, David Roazen, Valentin Ruano-Rubio, Andrea Saltzman, Molly Schleicher, Jose Soto, Kathleen Tibbetts, Charlotte Tolonen, Gordon Wade, Michael E. Talkowski, The Genome Aggregation Database Consortium, Benjamin M. Neale, Mark J. Daly, Daniel G. MacArthur. Variation across 141,456 human exomes and genomes reveals the spectrum of loss-of-function intolerance across human protein-coding genes. bioRxiv 531210."
                    )}

        ${make_entry(  dataset='Linear Motifs',
                       a_url='http://elm.eu.org/',
                       a_text='ELM database',
                       licence='Academic License',
                       ref='Gouw M, Michael S, Sámano-Sánchez H, Kumar M, Zeke A, Lang B, Bely B, Chemes LB, Davey NE, Deng Z, Diella F, Gürth CM, Huber AK, Kleinsorg S, Schlegel LS, Palopoli N, Roey KV, Altenberg B, Reményi A, Dinkel H, Gibson TJ. The eukaryotic linear motif resource - 2018 update. Nucleic Acids Res. 2018 Jan 4;46(D1):D428-D434.'
                    )}

        ${make_entry(  dataset='Free energy calculations',
                       a_url='http://www.pyrosetta.org/',
                       a_text='PyRosetta',
                       licence='Academic License',
                       ref='S. Chaudhury, S. Lyskov & J. J. Gray, "PyRosetta: a script-based interface for implementing molecular modeling algorithms using Rosetta," Bioinformatics, 26(5), 689-691 (2010).'
                    )}
    </ul>
</%block>