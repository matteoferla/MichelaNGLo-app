
######################### Routes ##################################
def includeme(config):
    config.add_static_view('static', 'static', cache_max_age=3600)
    config.add_static_view('images', '../images', cache_max_age=3600)
    #config.add_static_view('favicon.ico','static/favicon.ico', cache_max_age=3600)
    config.add_route('favicon','/favicon.ico')
    config.add_route('home', '/')   ##the home page
    config.add_route('home_text', '/verbose') ### the old home page
    config.add_route('home_gimmicky', '/gimmicky') ### the newer home page
    config.add_route('custom', '/custom') ### mesh converter
    config.add_route('pdb', '/pdb')   ### pdb converter
    config.add_route('pymol', '/pymol')  ### pymol converter
    config.add_route('name', '/name')  ### gene name.
    config.add_route('gallery', '/gallery')  ###
    config.add_route('personal', '/personal')
    config.add_route('docs', '/docs/{id}')
    config.add_route('main_docs', '/docs')
    config.add_route('convert_pse', '/convert_pse')
    config.add_route('convert_pdb', '/convert_pdb')
    config.add_route('convert_pdb_w_sdf', '/convert_pdb_w_sdf')
    config.add_route('convert_mesh', '/convert_mesh')
    config.add_route('renumber', '/renumber')
    config.add_route('choose_pdb', '/choose_pdb')
    config.add_route('task_check','/task_check')
    config.add_route('save_pdb', '/save_pdb')
    config.add_route('save_zip', '/save_zip')
    config.add_route('edit_user-page', '/edit_user-page')
    config.add_route('combine_user-page', '/combine_user-page')
    config.add_route('delete_user-page', '/delete_user-page')
    config.add_route('rename_user-page', '/rename_user-page')
    config.add_route('copy_user-page', '/copy_user-page')
    config.add_route('login', '/login')
    config.add_route('status', '/status')
    config.add_route('get', '/get')
    config.add_route('set', '/set')
    config.add_route('mutate', '/mutate')
    config.add_route('remove_chains', '/remove_chains')
    config.add_route('premutate', '/premutate')  #as in mutate a structure before page creation.
    config.add_route('msg', '/msg')
    config.add_route('get_pages', '/get_pages')
    config.add_route('admin', '/admin')
    config.add_route('venus', '/venus')
    config.add_route('venus_random', '/venus_random')
    config.add_route('venus_analyse', '/venus_analyse')
    config.add_route('extended', '/michelanglo.js')
    config.add_route('extended_menu', '/michelanglo_menu.js')
    config.add_route('userdata', '/data/{id}')
    config.add_route('redirect', '/r/{id}')
    config.add_route('userthumb', '/thumb/{id}')
    config.add_route('monitor', '/monitor/{id}')

    #previously existent routes... deadlink possible:
    #config.add_route('sandbox', '/sandbox')
    #config.add_route('clash', '/clash')
    #config.add_route('imagetoggle', '/imagetoggle')
    #config.add_route('markup', '/markup')
