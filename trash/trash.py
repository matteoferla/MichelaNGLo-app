minor_error = ''  # does nothing now.
# The problem is that there is not a standard mode toggle?
## assertions
if not 'pdb_string' in request.params and ('pdb' in request.params and not request.params['pdb']):
    response = {'error': 'danger', 'error_title': 'No PDB code',
                'error_msg': 'A PDB code is required to make the NGL viewer show a protein.', 'snippet': '',
                'validation': ''}
    log.warn(response)
    request.session['status'] = make_msg(response['error_title'], response['error_msg'], 'error', 'bg-danger')
    return response
elif request.params['mode'] == 'out' and not request.params['pymol_output']:
    response = {'error': 'danger', 'error_title': 'No PyMOL code',
                'error_msg': 'PyMOL code is required to make the NGL viewer show a protein.', 'snippet': '',
                'validation': ''}
    log.warn(response)
    request.session['status'] = make_msg(response['error_title'], response['error_msg'], 'error', 'bg-danger')
    return response
elif request.params['mode'] == 'file' and not (('demo_file' in request.params and request.params['demo_file']) or (
        'file' in request.params and request.params['file'].filename)):
    response = {'error': 'danger', 'error_title': 'No PSE file',
                'error_msg': 'A PyMOL file to make the NGL viewer show a protein.', 'snippet': '', 'validation': ''}
    log.warn(response)
    request.session['status'] = make_msg(response['error_title'], response['error_msg'], 'error', 'bg-danger')
    return response

view = ''
reps = ''
data = request.params['pymol_output'].split('PyMOL>')
for block in data:
    if 'get_view' in block:
        view = block
    elif 'iterate' in block:  # strickly lowercase as it ends in _I_terate
        reps = block
    elif not block:
        pass  # empty line.
    else:
        minor_error = 'Unknown block: ' + block
trans = PyMolTranspiler(view=view, representation=reps, pdb=request.params['pdb'], job=User.get_username(request), **settings)




def store_data(page, settings):
    if 'description' not in settings:
        settings['description'] = 'Editable text. press pen to edit.'
    if 'title' not in settings:
        settings['title'] = 'User submitted structure'
    for key in ['viewport', 'image', 'uniform_non_carbon', 'verbose', 'validation', 'stick', 'save', 'backgroundcolor', 'author', 'loadfun', 'proteinJSON', 'pdb', 'description', 'title',
                'data_other']:
        if key not in settings:
            settings[key] = ''
    with open(os.path.join('michelanglo_app', 'user-data', page + '.p'), 'wb') as fh:
        pickle.dump(settings, fh)


def read_data(page):
    file = full_path_data(page)
    if os.path.exists(file):
        with open(file, 'rb') as fh:
            settings = pickle.load(fh)
        return settings
    else:
        return {}


def delete_data(page):
    file = full_path_data(page)
    if os.path.exists(file):
        os.remove(file)


def full_path_data(page):
    page = sanitise_URL(page)
    return os.path.join('michelanglo_app', 'user-data', page + '.p')





def old_edit(request):
    if request.POST['type'] == 'edit':
        if (os.path.isfile(os.path.join('michelanglo_app', 'user', request.POST['page'] + '.js'))):
            make_static_html(js='external', **request.POST) ##this could be dangerous but I think it is safe.
    elif request.POST['type'] == 'delete':
        os.remove(os.path.join('michelanglo_app','user',sanitise_URL(request.POST['page'])+'.html'))
        js = sanitise_URL(request.POST['page']) + '.js'
        if os.path.isfile(js):
            os.remove(os.path.join('michelanglo_app', 'user', js))
    return {'success': 1}


<div id="control_table" >

</div>





def make_static_page(page, **settings): #proteinJSON, backgroundcolor, pdb and loadfun + title, page/uuid and description
    settings['js'] = 'external'
    settings['data_other'] =''
    make_static_js(page,**settings)
    make_static_html(page,**settings)




def make_static_html(page, description='Editable text. press pen to edit.',title='User submitted structure', **settings):
    open(os.path.join('michelanglo_app', 'user', page + '.html'), 'w', newline='\n').write(
        mako.template.Template(filename=os.path.join('michelanglo_app', 'templates', 'user_protein.mako'),
                               format_exceptions=True,
                               lookup=mako.lookup.TemplateLookup(directories=[os.getcwd()])
                               ).render_unicode(description=sanitise_HTML(description),
                                                title=sanitise_HTML(title),
                                                uuid=sanitise_URL(page),
                                                **settings))

def make_static_js(page, **settings):
    js = os.path.join('michelanglo_app', 'user', page + '.js')
    if (not os.path.isfile(js)):
        tags='<script type="text/javascript" id="code">{0}</script>'
        if 'pdb' in settings and settings['pdb']:
            open(js,'w').write(tags.format ('var pdb = `REMARK 666 Note that the indent is important as is the secondary structure def\n{pdb}`;\n{loadfun}'.format(**settings)))
        else:
            open(js, 'w').write(tags.format(settings['loadfun']))

