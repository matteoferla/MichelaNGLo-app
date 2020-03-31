<h4>User pages</h4>
<p>Once a conversion is done either from a PDB or a PSE, a page is generated.</p>
<p>This page contains several buttons on the right hand side. Most notably "implementation code", which guides the user on how to use the page on their website.</p>
<p>Additionally, the page itself can be downloaded as a self standing page.</p>

<h5>Limits</h5>
There is a hard limit to 50 MB for an upload.
The reason is that:

* you are mostly likely not a nice person and are trying to DoS attack: if you try to upload a large file too many times your IP will be blacklisted.
* if legitimate, such as large file will result in
    * a visitor having to download a similar sized file each time they visit the page
    * the browser on a non-gamer computer being sluggish/unresponsive.

Few structures are affected. A large structure such as a ribosome complex will run smoothly on a computer.
However, a virus with over than 62 chains cannot be converted, while one with less is likely to crash your browser.
In that case, we suggest uploading a single unit and having a picture to show what the whole thing looks like.

If this is not satisfactory please contact the admin
by clicking <i class="far fa-comments"></i> on on the top right or clicking <a href="#" data-toggle="modal" data-target="#chat_modal">here</a>,
and we will circumvent the rules. However, as a huge structure will make a computer sluggish
and may force a visitor to restart their computer. Therefore, these structures will be blacklisted from being set to public.
Furthermore, 30% of visitors visit Michelaɴɢʟo on mobile devices, hence why this option is not a preferred option.

<h5>Editable</h5>
<p>Before downloading the page it may be handy to edit it first.
    By editing the page, prolinks (protein guiding links) can be made.
    (<a href="/markup">see markup documentation for full details</a>)</p>

<p>These user generated pages are accessible by anyone with the URL, but the pages are not listed or can they be cached by search engines.
    This can be altered in security by ticking encrypt, which will apply AES encryption to it and only who has the encryption key can access it,
    or conversely, by ticking public it will be listed in <a href="/gallery">Gallery</a>.</p>

<p><b>NB.</b> The data will not be kept permanently: unvisited longer than a year, unclaimed pages created by guest after 24 hours.</p>

<p>As a wee present for your reading this documentation, adding <code>?bootstrap=materials</code> to the url of the pages will switch the framework look to Google Materials. To use this on the download file right click and copy the link and add <code>&bootstrap=materials</code> to it.</p>

<ul>
    <li>Snapshot: save png</li>
    <li>Download PDB</li>
</ul>

If the user is registered, this page can be edited.
Do note that a few URL query options are possible:
# remote (boolean) boostrap no_user no_buttoons no_analytics
