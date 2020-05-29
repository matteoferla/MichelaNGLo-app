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
            API
</%block>

<%block name="main">

    <%include file="subparts/docs_nav.mako"/>

<h4>Python API</h4>
    <p>A clientside python 3 API is provided at <a href="https://github.com/matteoferla/MichelaNGLo-api" target="_blank">MichelaNGLo-api <i class="fab fa-github"></i></a>.</p>
    <p>The code below describes the basics of how to interact with the site without it.</p>



<h4>Step one: get cookie</h4>
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

<h4>Get uuid of your pages</h4>
<code>get_pages</code> returns a dictionary of arrays of uuid of your pages, with keys 'owned', 'visited' and 'public'. Note that if not logged in, you get the following error: <code>{"owned": "not logged in", "visited": "not logged in", "error": "not logged in", "public": []}</code>

<h4>Get protein page as json</h4>
<p>Adding <code>mode: json</code> to the request for a protein page will return a json, either as a post or get request (you can try the latter in your browser by adding <code>?mode=json</code>).
If you are using an encrypted page you can <b>only</b> get the data back by providing <code>key: password</code>.
The data is encrypted with the hash of the password and this is all handled serverside, so the password is the human readable password, not the token.</p>

<h4>Edit page</h4>
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
<p>To prevent XSS threats (<a href="data/7c76d65a-4a98-4768-8166-ad7bd38f148e">example</a>), <code>loadfun</code> and <code>script</code> tags in the description (or title) are forbidden for regular users &mdash;email the site admin to discuss alternatives.</p>

<h4>Example</h4>
<p>Let's copy the content of one page into another (note this can be done in the main page)</p>
    <pre>${copy_btn('example_code')}<code id="example_code">#python3
import requests, json
donor_url = '00000000-0000-1000-a000-000000000000'
recipient_url = '00000000-0000-1000-a000-000000000001'
mike = requests.Session()
base_url = 'https://michelanglo.sgc.ox.ac.uk'
data =  {'username': 'yournamehere',
    'password': 'yourpasswordhere',
    'action': 'login'}
r = mike.post(base_url+'/login', data=data)
donor = json.loads(mike.post(base_url+'/data/'+donor_url, data={'mode':'json'}).content.decode('utf-8'))
donor['page'] = mash_url
print(mike.post(base_url+'/edit_user-page', data=donor).content)
donor = json.loads(mike.post(base_url+'/data/'+donor_url, data={'mode':'json'}).content.decode('utf-8'))
mash = json.loads(mike.post(base_url+'/data/'+mash_url, data={'mode':'json'}).content.decode('utf-8'))
for key in donor:
    if donor[key] != mash[key]:
        if isinstance(donor[key],bool):
            print(f'Difference with {key} {type(donor[key]).__name__}:{donor[key]} vs. {type(mash[key]).__name__}{mash[key]}')
        else:
            print(f'Difference with {key} {type(donor[key]).__name__}:{len(donor[key])} vs. {type(mash[key]).__name__}:{len(mash[key])}')</code></pre>
</%block>