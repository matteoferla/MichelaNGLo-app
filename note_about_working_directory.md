## Working directory

This may change at some point, but there are a few instances where 'michealanglo_app' folder is in paths,
not module is used, e.g. open for static files.
This means that michelanglo_app only works if it's enclosing folder is the working directory.
Annoyingly, some calls with the templates assume that michelanglo_app is installed.

This needs to be changed to something like:

    import pkg_resources
    pkg_resources.resource_filename('michelanglo_app:static', '....')

Not fixed as there are several and I dont really have a need to fix it atm.

