## convert booleans and settings
def is_js_true(value):  # booleans get converted into strings in json.
    if not value or value == 'false':
        return False
    else:
        return True
