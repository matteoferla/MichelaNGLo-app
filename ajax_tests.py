import requests


class SiteTests:

    def __init__(self):
        self.url = 'http://brc10.well.ox.ac.uk:8088/'
        self.headers = {'user-agent': 'my-app/0.0.1'}

    def test(self, address, data=None, headers=None, verbose=False):
        if not headers:
            headers = self.headers
        if data:
            r = requests.post(self.url + address, data=data, headers=headers)
        else:
            r = requests.post(self.url + address)
        if 'Set-Cookie' in r.headers:
            self.headers['Cookie'] = r.headers['Set-Cookie']
        if verbose:
            print(r.status_code)
            print(r.headers)
            print(r.content)
        return r

#register a user.
site = SiteTests()
data = {'username': 'testdummy',
        'password': 'crash',
        'email': 'testdummy@example.com',
        'action': 'register'} #login, logout, register (req. `email`), whoami (debug only), promote (req. `role`), kill, reset
print(site.test('login', data=data).content)
#reply "status" and occasionally username

data['action'] = 'whoami'
print(site.test('login', data=data).content)


############### create a page!
data = {'mode': 'file', #file|mode
       'demo_file': 'A.pse', #alt. `file`
       'stick': 'hyperball',
       'viewport_id': 'viewport',
       'uniform_non_carbon': False,
       'image': False,
       'pdb_string': True
      }

r =site.test('ajax_convert',data=data)

print(r.content)
