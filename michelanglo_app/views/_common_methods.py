## convert booleans and settings
def is_js_true(value):  # booleans get converted into strings in json.
    if not value or value == 'false':
        return False
    else:
        return True

def get_username(request):
    """
    Returns the useraname or the IP address...
    :param request:
    :return:
    """
    if request.user:
        return f'{request.user.name} ({request.user.role})'
    else:
        return '/'.join([request.environ[x] for x in ("REMOTE_ADDR",
                                                      "HTTP_X_FORWARDED_FOR",
                                                      "HTTP_CLIENT_IP") if x in request.environ])
