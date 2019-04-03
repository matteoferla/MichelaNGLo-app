import os, re, pickle
##################### Page
# The reason this is not a DB is because
# * the PDB files can get massive
# * the
# * they are easy to query anyway as they have a uuid

class Page:
    def __init__(self, identifier):
        self.identifier = identifier.replace('\\','/').replace('*','').split('/')[-1]
        self.path = os.path.join('pymol_ngl_transpiler_app', 'user-data', self.identifier + '.p')
        self.settings = {}

    def exists(self):
        if os.path.exists(self.path):
            return True
        else:
            return False

    def load(self):
        if self.exists():
            with open(self.path, 'rb') as fh:
                self.settings  = pickle.load(fh)
        return self.settings

    def save(self, settings=None):
        if not settings:
            settings = self.settings
        if 'description' not in settings:
            settings['description'] = 'Editable text. press pen to edit.'
        if 'title' not in settings:
            settings['title'] = 'User submitted structure'
        for fun, keys in ((list, ('editors', 'visitors', 'authors')),
                      (bool, ('image', 'uniform_non_carbon', 'verbose', 'validation', 'save')),
                      (str, ('viewport', 'stick', 'backgroundcolor', 'loadfun', 'proteinJSON', 'pdb', 'description', 'title', 'data_other'))):
            for key in keys:
                if key not in settings:
                    settings[key] = fun()
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
