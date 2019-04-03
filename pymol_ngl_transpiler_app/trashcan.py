## This is where guest make pages

from .models import User

def get_trashcan(request):
    trashcan = request.dbsession.query(User).filter_by(name='trashcan').one()
    if trashcan:
        return trashcan
    else:
        #someone deleted the trashcan!
        trashcan = User(name='trashcan', role='trashcan', password_hash='$2b$12$i9eQXLVCw0NskKfcTxpo0eatU2FwXXFgDGVcGJpOKqt6EAANZ7DY6')
        request.dbsession.add(trashcan)
        return trashcan
