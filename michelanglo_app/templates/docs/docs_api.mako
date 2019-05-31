<%namespace file="../layout_components/common_methods.mako" import="copy_btn"/>
<h4>API</h4>
<h5>Step one: get cookie</h5>
<p>A post request to <code>/login</code> with the parameters <code>{'username': 'xxxx', 'password': 'xxxx', 'action': 'login'}</code>, will reply with a response with <code>Set-Cookie</code>, which you will add to your request headers as <code>Cookie</code> as normal.</p>

<p>If you use python <code>requests.Session()</code>, this is handled automatically.</p>
<pre>${copy_btn('requests_code')}<code id="requests_code">##python3
from warnings import warn
import requests

mike = requests.Session()
base_url = 'https://michelanglo.sgc.ox.ac.uk'
data =  {'username': 'yournamehere',
    'password': 'yourpasswordhere',
    'action': 'login'}
r = mike.post(base_url+'/login', data=data)
##r.content => b'{"status": "logged in", "name": "yournamehere", "rank": "user"}'
</code>
</pre>
<p>If you are somehow struggling with cookies or what to check if you are logged in the payload <code>{'action': 'whoami'}</code> to <code>/login</code>, will reply with your username.</p>

<h5>Get uuid of your pages</h5>
<code>get_pages</code> returns a dictionary of arrays of uuid of your pages, with keys 'owned', 'visited' and 'public'. Note that if not logged in, you get the following error: <code>{"owned": "not logged in", "visited": "not logged in", "error": "not logged in", "public": []}</code>

<h5>Get protein page as json</h5>
<p>Adding <code>mode: json</code> to the request for a protein page will return a json, either as a post or get request (you can try the latter in your browser by adding <code>?mode=json</code>).
If you are using an encrypted page you can <b>only</b> get the data back by providing <code>key: password</code>.
The data is encrypted with the hash of the password and this is all handled serverside, so the password is the human readable password, not the token.</p>

<h5>Edit page</h5>
<pre>${copy_btn('edit_code')}<code id="edit_code">
data = {'page': 'the-long-uuid-for-the-page',
        'confidential': 'true',
        'public': 'false',
        'encryption': 'false',
        'columns_viewport': 6,
        'columns_text': 6,
        'title': 'New title',
        'description': 'New markdown text',
        'loadfun': loadfun
       }

r = mike.post(base_url+'/edit_user-page', data=data)
print(r.content)
</code></pre>
<p>To prevent XSS threats, <code>loadfun</code> and <code>script</code> tags in the description (or title) are forbidden for regular users &mdash;email the site admin to discuss alternatives.</p>