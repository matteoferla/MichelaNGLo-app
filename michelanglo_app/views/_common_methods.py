import os, requests, logging, re, unicodedata
log = logging.getLogger(__name__)

## convert booleans and settings
def is_js_true(value):  # booleans get converted into strings in json.
    if not value or value in ('false', 'False', False, 'No','no', 'F','null', 'off'):
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

def notify_admin(msg):
    """
    Send message to a slack webhook
    :param msg:
    :return:
    """
    # sanitise.
    msg = unicodedata.normalize('NFKD',msg).encode('ascii','ignore').decode('ascii')
    msg = re.sub('[^\w\s\-.,;?!@#()\[\]]','', msg)
    r = requests.post(url=os.environ['SLACK_WEBHOOK'],
                      headers={'Content-type': 'application/json'},
                      data=f"{{'text': '{msg}'}}")
    if r.status_code == 200 and r.content == b'ok':
        return True
    else:
        log.error(f'{msg} failed to send (code: {r.status_code}, {r.content}).')
        return False


def is_malformed(request, *args):
    missing = [k for k in args if k not in request.params]
    if missing:
        request.response.status = 422
        log.warn(f'{get_username(request)} malformed request due to missing {missing}')
        return f'Missing field ({missing})'
    else:
        return None