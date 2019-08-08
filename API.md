# API
Sometimes it is handy to submit edits in the confort of a Jupyter notebook.

The following is just a small demo. For a longer description see: [https://michelanglo.sgc.ox.ac.uk/docs/api](https://michelanglo.sgc.ox.ac.uk/docs/api)

## Login
Only registered users can edit pages, therefore if one wants to edit you need to log in. See `ajax_test.py` for an example.

The json requests to the address `/login` with an field called `action` control logged-in-ness.

The action can be `login` (req. `username` and `password`), `logout`, `register` (req. `username`, `password` and `email`), `whoami` (debug only), `change_password` (req. `username`, `password` and `newpassword`), `promote` (admin only, req. `role`), `kill` (admin only), `reset` (admin only).
The can be `get` or `post`, but in `get` the password will be visible in the apache logs.
As expected, reply will contain `Set-Cookie` in its header, which obviously means that the `Cookie` field in the header should be set.

Description of users is in [github.com/matteoferla/MichelaNGLo/data.md](https://github.com/matteoferla/MichelaNGLo/blob/master/data.md).

For a privacy centered description see also [https://ngl.matteoferla.com/docs#Users](users section in docs).

## Edit
Conversion are done to the address `convert_pse`.

    data = {'mode': 'file', #file|mode
           'demo_file': 'A.pse', #alt. `file`
           'stick': 'hyperball',
           'viewport_id': 'viewport',
           'uniform_non_carbon': False,
           'image': False,
           'pdb_string': True
          }

Edits are done to the address `edit_user-page`.

    data = {'page': '6d788656-9319-4421-9683-24a4159de73b',
            'confidential': 'true',
            'public': 'false',
            'encryption': 'false',
            'columns_viewport': 6,
            'columns_text': 6,
            'title': 'Zany title',
            'description': 'HTML escription',
            'loadfun': 'A JS function'}

Note that regular users cannot upload JS (as they could steal credentials of people they share links to ([example](data/7c76d65a-4a98-4768-8166-ad7bd38f148e)). Therefore, only specially approved users can.