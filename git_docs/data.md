## Users
Need for users: By registering the views generated can be retrieved at a latter date.

The sharable links can be viewed by anyone with the link, 
however, only the registered creator of the page can edit it or promote a registered user who visited the page to edit it.

> app_users=# \d+ users

    Column     |       Type        | Collation | Nullable |              Default              | Storage  | Stats target | Description 
---------------|-------------------|-----------|----------|-----------------------------------|----------|--------------|-------------
 id            | integer           |           | not null | nextval('users_id_seq'::regclass) | plain    |              | 
 name          | character varying |           | not null |                                   | extended |              | 
 role          | character varying |           | not null |                                   | extended |              | 
 password_hash | character varying |           |          |                                   | extended |              | 
 email         | character varying |           |          |                                   | extended |              | 
 owned_pages   | character varying |           |          |                                   | extended |              | 
 visited_pages | character varying |           |          |                                   | extended |              | 

    Indexes:
    "users_pkey" PRIMARY KEY, btree (id)
    "users_name_key" UNIQUE CONSTRAINT, btree (name)


### Class
The model handling the DB is `User` in `mchelanglo_app/models/users.py`.

### Username
The display name. Visible to users owning pages that get visited.

### Role
The users roles are `basic`, `admin` and a few extra cases.
* `basic` can edit
    * pages they created and
    * pages they visited that then have been edited by anther user (with editor rights) to make this user an editor.
* `friend` can edit pages by adding js code (`loadfun`) and adding `&lt;script&gt;` tags to `description`.*
* `trashcan` is a fake-user who is editor of pages created by not logged in users (`guest` is not a user and is a forbidden username). Say, you created a page as guest (unregistered user) and somehow lost the PDB or PSE file and want to be able to edit it as a registered user, the site admin can give you edit rights by checking pages owned by trashcan.
* `public` is a fake-user who is a visitor of all pages made public.
* `admin` can edit users etc and all pages &mdash;except encrypted ones they don't know the key to.

&lowast;) A registered user cannot insert script tags when editing for security reasons.

### Password
Passwords are hashed, so if forgotten they cannot be retrieved. The site admin can however reset your password.

### Email
email is required only for account problems. No ads or sale of info.

### Pages_owned
Pages that can be edited.

### Pages_visited
Pages that were visited.

## Pages
Pages are not stored in the database, but as pickled files in user-data as the uuid.                                   
The class is `Pages` in in `mchelanglo_app/`.

The encryption is done with an AES cipher using a SHA256 hash of the key as the AES key.
As the encryption is done in CBC mode, the randomly chosen IV (kind of like salt) is stored at the front of the encrypted data as commonly done.

The table at present looks like:


    >app_users=# \d+ pages
    
   Column   |            Type             | Collation | Nullable |               Default                | Storage  | Stats target | Description 
------------|-----------------------------|-----------|----------|--------------------------------------|----------|--------------|-------------
 id         | integer                     |           | not null | nextval('pages_index_seq'::regclass) | plain    |              | 
 identifier | text                        |           | not null |                                      | extended |              | 
 title      | text                        |           |          |                                      | extended |              | 
 exists     | boolean                     |           |          | true                                 | plain    |              | 
 edited     | boolean                     |           |          | false                                | plain    |              | 
 encrypted  | boolean                     |           |          | false                                | plain    |              | 
 timestamp  | timestamp without time zone |           | not null |                                      | plain    |              | 
 protected  | boolean                     |           |          |                                      | plain    |              | 
    
    Indexes:
    "pages_pkey" PRIMARY KEY, btree (id)
    "pages_uuid_key" UNIQUE CONSTRAINT, btree (identifier)


## Redirects

This small table contains the names of the redirects `r/nicename` > `data/12345678901234567890`.

>app_users-# \d+ redirects


 Column |  Type   | Collation | Nullable |                Default                | Storage  | Stats target | Description 
--------|---------|-----------|----------|---------------------------------------|----------|--------------|-------------
 id     | integer |           | not null | nextval('redirects_id_seq'::regclass) | plain    |              | 
 short  | text    |           | not null |                                       | extended |              | 
 long   | text    |           | not null |                                       | extended |              | 

    Indexes:
    "redirects_pkey" PRIMARY KEY, btree (id)
    "redirects_long_key" UNIQUE CONSTRAINT, btree (long)
    "redirects_short_key" UNIQUE CONSTRAINT, btree (short)
