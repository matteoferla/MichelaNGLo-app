#### THIS PIECE OF CODE IS FOR THE ONE TIME ONLY MIGRATION FROM PAGES AS PICKLE ONLY TO A DB MANAGED PICKLE SYSTEM.
if __name__ == '__main__':
    from ..models import *
    import os, transaction
    from datetime import datetime

    from sqlalchemy import create_engine
    from sqlalchemy.orm import sessionmaker
    engine = create_engine(os.environ['SQL_URL'], echo=False)
    Session = sessionmaker(bind=engine)
    sesh = Session()


    with transaction.manager:
        sesh.rollback()
        for file in os.listdir('../user-data/'):   ## asumed this file is in models...
            (uuid, ext) = os.path.splitext(file)
            p = sesh.query(Page).filter_by(identifier=uuid).first()
            try:
                if p:
                    print(f'Page {uuid} exists!')
                    p.load()
                    p.title = p.settings['title']
                    sesh.update(p)
                elif ext == '.p':
                    p = Page(uuid)
                    p.exists = True
                    print(f'Page {uuid} to be loaded...')
                    p.load()
                    print(f'Page {uuid} to be registered...')
                    # bprint(p.settings.keys())
                    # bprint(f'Page  {uuid} has been authored by {p.settings["authors"]} &mdash; {p.settings["author"]} &mdash; {p.settings["editors"]}')
                    # bprint(f'Page  {uuid} is {p.settings["title"]}: {p.settings["description"]}')
                    p.timestamp = p.settings['date']
                    p.encrypted = False
                    p.edited = True
                    p.title = p.settings['title']
                    # bprint(f'Page {uuid} has a timestamp {p.timestamp}.')
                    sesh.add(p)
                    sesh.commit()
                elif ext == '.ep':
                    p = Page(uuid)
                    p.exists = True
                    print(f'Page {uuid} is encrypted.')
                    print(f'Page {uuid} to be registered...')
                    print(p.settings.keys())
                    # bprint(f'Page  {uuid} has been authored by {p.settings["authors"]} &mdash; {p.settings["author"]} &mdash; {p.settings["editors"]}')
                    # bprint(f'Page  {uuid} is {p.settings["title"]}: {p.settings["description"]}')
                    p.timestamp = datetime.utcnow()
                    p.encrypted = True
                    p.edited = True
                    p.title = p.settings['title']
                    # bprint(f'Page {uuid} has a timestamp {p.timestamp}.')
                    sesh.add(p)
                    sesh.commit()
            except Exception as err:
                print(f'Page {uuid} glitched. {err}')

