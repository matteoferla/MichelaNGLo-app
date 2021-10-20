import os
from michelanglo_transpiler import PyMolTranspiler, GlobalPyMOL
from michelanglo_protein import Structure, global_settings

def setup_folders(user_data_folder:str, protein_data_folder:str):
    """
    Makes the folders based on michelanglo.user_data_folder from the config unless overridden by

    """
    ## make folders if not existant
    if not os.path.isdir(user_data_folder):
        os.mkdir(user_data_folder)
    for folder in ('pages', 'thumb', 'monitor', 'temp'):
        folder_path = os.path.join(user_data_folder, folder)
        if not os.path.isdir(folder_path):
            os.mkdir(folder_path)
    # Pages.data_folder is set in `.models.includeme`
    ## clean up temp
    temporary_folder = os.path.join(user_data_folder, 'temp')
    if os.path.isdir(temporary_folder):
        for file in os.listdir(temporary_folder):
            os.remove(os.path.join(temporary_folder, file))
    ## set defaults
    PyMolTranspiler.temporary_folder = temporary_folder
    GlobalPyMOL.pymol.cmd.set('fetch_path', temporary_folder)
    Structure.temporary_folder = temporary_folder
    global_settings.startup(protein_data_folder)
    # transpiler templates are here.
    PyMolTranspiler.template_folder = os.path.join(os.getcwd(), 'michelanglo_app', 'transpiler_templates')

def setup_comms(slack_webhook:str, server_email:str, admin_email: str):
    from .views.common_methods import Comms
    if slack_webhook:
        Comms.slack_webhook = slack_webhook.strip()
    if server_email and '@' in server_email:
        Comms.server_email = server_email.strip()
    if admin_email and '@' in admin_email:
        Comms.admin_email = admin_email.strip()
