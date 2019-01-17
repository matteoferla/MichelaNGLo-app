<%page args="snippet='', snippet_run='', error='', error_msg='', error_title='', validation='', viewport='viewport'"/>

<li class="list-group-item" id="results">
    <h3>Results</h3>
    % if error:
        <div class="alert alert-${error}" role="alert">
            <h4 class="alert-heading">${error_title}</h4>
            <p>${error_msg}</p>
            <hr>
            <p class="mb-0">If you believe this is incorrect please let Matteo know!</p>
        </div>
    % endif

    % if snippet:
        <p>Add wherever needed to the page add <code> &lt;div id="${viewport}" style="width:100%; height: 0; padding-bottom: 100%;"&gt;&lt;/div&gt;</code> or something similar.</p>
        <p>If you are adding an image, you might need to add it manually as many WYSIWYG editors with insert image buttons (<i>e.g.</i> Blogger) make images that when clicked result in a pop-up with the image fullsize, which is obviously incompatible.
        Therefore add or edit the image thusly: <code>&lt;div id="viewport"&gt; &lt;img src="my_protein.jpg" alt="my protein" width='100%'&gt;&lt;/div&gt;</code>.</p>
        <p>The CSS style can be different, but the important thing is that there is a <code>width</code> or a <code>min-width</code> and a <code>height</code> or a <code>min-height</code> &mdash;in
            this example the 0 height is a special case and results in the height being equal to the width.</p>
        <p>Copy-paste this at the bottom of the HTML document (with the editor in HTML mode).</p>
        <h4>Code</h4>
        <pre class="p-2"><div class="float-right"><a href="#snippet" data-clipboard-target="#snippet" id="copy_snippet">Copy</a></div>
            <code id="snippet">${snippet}</code></pre>
    % if validation:
        <p>For code that can be used to validate the orientation in PyMOL (i.e. gone full circle) <a href="#validation" data-toggle="collapse">press here.</a></p>
        <div class="collapse" id="validation">
            <pre class="p-2"><div class="float-right"><a href="#validation_code" data-clipboard-target="#validation_code" id="copy_validation">Copy</a></div>
                <code id="validation_code">${validation}</code></pre>
        </div>
    % endif
    % if snippet:
        <hr>
        <h4>Live</h4>
        <div id="viewport" style="width:100%; height: 0; padding-bottom: 100%;"></div>
    % endif
    % endif
</li>
% if snippet:
    <script type="text/javascript">
        new ClipboardJS('#copy_snippet,#copy_validation');
        $(document).ready(function () {${snippet_run|n}});
    </script>
% endif
