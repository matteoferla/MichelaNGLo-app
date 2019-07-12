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

    <%include file="docs_nav.mako"/>

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
<p>To prevent XSS threats, <code>loadfun</code> and <code>script</code> tags in the description (or title) are forbidden for regular users &mdash;email the site admin to discuss alternatives.</p>

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

<h4>Python class</h4>
<p>Below is a Python3.6+ simple API interface for <a href="https://michelanglo.sgc.ox.ac.uk">https://michelanglo.sgc.ox.ac.uk</a>.</p>
<pre><code>&gt;&gt;&gt; mike = MikeAPI('username','password')
&gt;&gt;&gt; page_data = mike.get_page('abcdedf-uuid-string-of-page')
&gt;&gt;&gt; page_data['proteinJSON'][2]['value'] = 'altered_variable_name'
&gt;&gt;&gt; page_data['pdb'][2][0] = 'altered_variable_name'
&gt;&gt;&gt; mike.set_page('abcdedf-uuid-string-of-page',page_data)
</code></pre>
<h5>Instance attributes:</h5>
<ul>
<li><code>.url</code> is 'https://michelanglo.sgc.ox.ac.uk/' unless altered (<em>e.g.</em> local version of Michelanglo)</li>
<li><code>.username</code> is the username</li>
<li><code>.password</code> is the raw password</li>
<li><code>.visited_pages</code>, <code>.owned_pages</code> and <code>.public_pages</code> are lists filled by <code>.refresh_pages()</code></li>
<li><code>.request</code> is a requests session object.</li>
</ul>
<h5>Instance methods:</h5>
<ul>
<li><code>.post(route, data=None, headers=None)</code> does the requests for other methods...</li>
<li><code>.post_json(route, data=None, headers=None)</code> as above but decodes the json reply...</li>
<li><code>.login()</code>. called automatically during initialisation.</li>
<li><code>.verify_user()</code>. check whether you are still logged in.</li>
<li><code>.refresh_pages()</code>. gets the lists <code>.visited_pages</code>, <code>.owned_pages</code> and <code>.public_pages</code></li>
<li><code>.get_page(uuid)</code> returns the data (:dict) for a given page.</li>
<li><code>.set_page(uuid, data)</code> sets the data (:dict) for a given page</li>
<li><code>.delete_page(uuid)</code> delete</li>
<li><code>.rename_page(uuid, name)</code> rename (admin only!)</li>
</ul>
<pre>${copy_btn('class_code')}<code id="class_code">import requests, json

class MikeAPI:

    def __init__(self, username: str, password: str, session=None):
        self.url = 'https://michelanglo.sgc.ox.ac.uk/'
        self.username = username
        self.password = password
        self.visited_pages = [] # filled by self.refresh_pages()
        self.owned_pages = [] # filled by self.refresh_pages()
        self.public_pages = [] # filled by self.refresh_pages()
        if session:
            self.request = session
        else:
            self.request = requests.Session()
        self.login()
        self.refresh_pages()

    def post(self,route, data=None, headers=None):
        reply = self.request.post(self.url+route, data, headers)
        if reply.status_code == 200:
            return reply
        else:
            raise Exception('The site {url} returned a status code {code}. Content: {con}'.format(url=self.url, code = r.status_code, con = r.content))

    def post_json(self,route, data=None, headers=None):
        reply = self.post(route, data, headers)
        return json.loads(reply.content.decode('utf-8'))

    def login(self):
        reply = self.post('login', data={'username': self.username,
                                'password':  self.password,
                                'action':   'login'})
        return self

    def verify_user(self):
        return self.post_json('login',{'action': 'whoami'})

    def refresh_pages(self):
        data = self.post_json('get_pages')
        self.visited_pages = data['visited']
        self.owned_pages = data['owned']
        self.public_pages = data['public']
        return self

    def get_page(self,uuid):
        data = self.post_json('data/'+uuid, data={'mode':'json'})
        if isinstance(data['proteinJSON'],str): #will be.
            data['proteinJSON'] = json.loads(data['proteinJSON'])
        if isinstance(data['pdb'],str): #will be.
            data['pdb'] = json.loads(data['pdb'])
        return data


    def set_page(self,uuid,data):
        data['page'] = uuid
        if not isinstance(data['proteinJSON'],str):
            data['proteinJSON'] = json.dumps(data['proteinJSON'])
        if not isinstance(data['pdb'],str):
            data['pdb'] = json.dumps(data['pdb'])
        self.post('edit_user-page', data=data)

    def del_page(self,uuid):
        self.post('delete_user-page', data={'page': uuid})

    def rename_page(self,uuid, new_name): ##admin only
        self.post('rename_user-page', data={'old_page': uuid, 'new_page': new_name})

    @staticmethod
    def print_reply(reply):
        print(f'Status code: {reply.status_code}; Headers: {reply.headers}; Content: {reply.content}')
</code></pre>
</%block>