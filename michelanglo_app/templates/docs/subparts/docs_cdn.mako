<%namespace file="../../layout_components/common_methods.mako" import="copy_btn"/>
<h4>CDN</h4>
<p>In order to make the JavaScript magic happen, the libraries need to be loaded.</p>
<p>Add to the bottom of the page, but before the closing of the <code>body</code> element, the following lines.</p>
<p>First, Michelanglo.js uses JQuery, so make sure it is present. Namely, if nothing works and in the console there is an error saying $ is undefined or if you add <code>
&lt;script>alert('JQuery absent') ? $ === undefined : alert('JQuery present')&lt;/script></code> into the document you get a negative.</p>
<pre>${copy_btn('jq_code')}<code  id="jq_code">&lt;script src="https://code.jquery.com/jquery-3.4.1.min.js"
			  integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo="
			  crossorigin="anonymous" type="text/javascript">&lt;/script></code></pre>
Then you can add the michelanglo.js code:
<pre>${copy_btn('cdn_code')}<code id="cdn_code">&lt;script src="https://unpkg.com/ngl@2.0.0-dev.34/dist/ngl.js" type="text/javascript"&gt;&lt;/script&gt;
   &lt;script src="https://michelanglo.sgc.ox.ac.uk/michelanglo.js" type="text/javascript"&gt;&lt;/script&gt;</code>
</pre>
<p>Alternatively, host these two files in your server and link to them.</p>
<pre>${copy_btn('local_code')}<code id="local_code">&lt;script src="/ngl.js" type="text/javascript"&gt;&lt;/script&gt;
   &lt;script src="/michelanglo.js" type="text/javascript"&gt;&lt;/script&gt;</code></pre>
<p>These scripts load NGL and allow it to be controlled via data-* attributes of HTML elements (see <a href="/markup">markup for more</a>)</p>



<p>Also, if you are using Bootstrap 4 (buggy on 3) the button that shows options can be added with the following code placed after the other parts.</p>
<pre>${copy_btn('menu_code')}<code  id="menu_code">&lt;script src="https://michelanglo.sgc.ox.ac.uk/michelanglo_menu.js" type="text/javascript">&lt;/script></code></pre>
