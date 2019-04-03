Users have a `name`, which is unique.

They have a `role`, which can be:                     
* "basic" (generic logged in user),
* "admin" (can delete other users and pages, edit any page and can alter other user roles),
* "friend" (an approved user who is trusted to not do XSS attacks so can add scripts to page),
* "guest" (technically not a DB user, but the default unlogged in state) and
* "trashcan" (a user in name only that collects pages made by guest users).

They a `password_hash` and methods to interact with it.

They have two strings `visited_pages` and `owned_pages`. These are space-separated Page uuids.
The methods to interact with these is `get_visited_pages`/`get_owned_pages` and `add_visited_page`/`add_owned_page`.

