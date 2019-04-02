import os, re, pickle
##################### Page
# The reason this is not a DB is because the files can get massive and they are easy to query anyway.
class Page:
    def __init__(self, identifier):
        self.identifier = identifier.replace('\\','/').replace('*','').split('/')[-1]
        self.path = os.path.join('pymol_ngl_transpiler_app', 'user-data', self.identifier + '.p')

    def exists(self):
        if os.path.exists(self.path):
            return True
        else:
            return False

    def load(self):
        if self.exists():
            with open(self.path, 'rb') as fh:
                settings = pickle.load(fh)
            return settings
        else:
            return {}

    def save(self, settings):
        if 'description' not in settings:
            settings['description'] = 'Editable text. press pen to edit.'
        if 'title' not in settings:
            settings['title'] = 'User submitted structure'
        for key in ['viewport', 'image', 'uniform_non_carbon', 'verbose', 'validation', 'stick', 'save', 'backgroundcolor', 'author', 'loadfun', 'proteinJSON', 'pdb', 'description', 'title',
                    'data_other', 'editors']:
            if key not in settings:
                settings[key] = ''
        with open(self.path, 'wb') as fh:
            pickle.dump(settings, fh)

    def delete(self):
        if self.exists():
            os.remove(self.path)

    @staticmethod
    def sanitise_URL(page):
        return page.replace('\\', '/').replace('*', '').split('/')[-1]

    @staticmethod
    def sanitise_HTML(code):
        return re.sub('<\s?\/?script', '&lt;script', code, re.IGNORECASE)
