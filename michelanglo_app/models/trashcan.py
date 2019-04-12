## Trashcan and Public aren't real users.
## Trashcan is the owner of pages made by non guest make pages.
## Public is a visitor to pages made public.
## Anonymous and Guest are two other forbidden usernames.

from .user import User

def get_trashcan(request):
    trashcan = request.dbsession.query(User).filter_by(name='trashcan').first()
    if trashcan:
        return trashcan
    else:
        #someone deleted the trashcan!
        trashcan = User(name='trashcan', role='trashcan', password_hash='$2b$12$EaadzvGZ3hd60a3dfqTrkOAstBQtzjTXVdG0OFm0O.pTibjK3OIn6')
        request.dbsession.add(trashcan)
        return trashcan

def get_public(request):
    trashcan = request.dbsession.query(User).filter_by(name='trashcan').first()
    if trashcan:
        return trashcan
    else:
        #someone deleted the public!
        public = User(name='public', role='public', password_hash='$2b$12$EaadzvGZ3hd60a3dfqTrkOAstBQtzjTXVdG0OFm0O.pTibjK3OIn6')
        request.dbsession.add(public)
        return public
