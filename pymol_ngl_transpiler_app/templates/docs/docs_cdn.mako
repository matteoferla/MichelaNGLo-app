<h4>CDN</h4>
<p>Add to the bottom of the page, but before the closing of the <code>body</code> element, these two lines:</p>
<pre><div class="float-right"><span data-clipboard-target="#cdn_code" class="clipboard">Copy</span></div><code id="cdn_code">&lt;script src="https://unpkg.com/ngl@2.0.0-dev.34/dist/ngl.js" type="text/javascript"&gt;&lt;/script&gt;
   &lt;script src="https://www.matteoferla.com/ngl.extended.js" type="text/javascript"&gt;&lt;/script&gt;</code>
</pre>
<p>Alternatively, host these two files in your server and link to them.</p>
<pre><div class="float-right"><span data-clipboard-target="#local_code" class="clipboard">Copy</span></div><code id="local_code">&lt;script src="/ngl.js" type="text/javascript"&gt;&lt;/script&gt;
   &lt;script src="/ngl.extended.js" type="text/javascript"&gt;&lt;/script&gt;</code></pre>
<p>These scripts load NGL and allow it to be controlled via data-* attributes of HTML elements (see <a href="/markup">markup for more</a>)</p>
