## Diagram

Michelanglo has lots of moving parts.
![diagram](./images/mike%20layout-01.png)

### Backend
* Python 3.7
    * Pyramid
    * Waitress (Apache: reverse proxy)
    * PyMOL (see note)
    * Biopython
    * APScheduler
    * Postgres
    * external purpose written module: [github.com/matteoferla/MichelaNGLo-protein-module](https://github.com/matteoferla/MichelaNGLo-protein-module)
* NodeJS
    * Puppeeter
   
### Frontend
* Mako-templated HTML
* NGL
* JQuery
* Boostrap 4.3
* FontAwesome Pro
* Bootstrap Tour (mod)

## Python 3.7
This repo uses f-strings.

### Python3 compiled Pymol in Ubuntu
This app requires Python3 compiled Pymol. The best option is using Conda. Otherwise it needs to be compiled ([instructions](https://blog.matteoferla.com/2019/04/pymol-on-linux-without-conda.html)).
So the best bet is to install anaconda3. See the web.
Then make a venv etc.

    conda install -c schrodinger pymol

## clone michelanglo   
Note that this module uses submodule so clone it recursively.

    git clone --recursive https://github.com/matteoferla/MichelaNGLo.git
    python3 setup.py install #or pip install -e .

## Protein module
It also uses a protein module to allow gene name querying. This module has lots of cool stuff. I might be worth your while checking it out.

see [https://github.com/matteoferla/MichelaNGLo-protein-module](https://github.com/matteoferla/MichelaNGLo-protein-module)

    git clone https://github.com/matteoferla/MichelaNGLo-protein-module.git
    cd MichelaNGLo-protein-module
    python3 setup.py install

This module uses a lot of data. That unfortunately I cannot keep as a repo for you to download.
Also, if you plan to mod Michelanglo do not clone the protein module in Michelanglo or your IDE will go _extremely_ slow.

    Python3
    >>>from protein.generate import ProteomeGatherer
    >settings = ProteomeGatherer.settings
    >>>settings.verbose = False #or True
    >>>settings.init(data_folder='../protein-data') #or wherever

This will save all the data it will download and parse to this folder.
It will download the Uniprot and few other large datasets with the following:

    >>>settings.retrieve_references(ask=False, refresh=False)

These will be parse with:

    >>>ProteomeGatherer(skip=True, remake_pickles=True)

This will take overnight.

## Create the database
The config file needs altering for alembic to work: make a copy and hard code the environment variables.
Alternatively, I might have altered the initialise_db script to run off enviroment variables.

    alembic -c production.ini revision --autogenerate -m "lets get this party started"
    alembic -c production.ini upgrade head

All the documentation here works on Ubuntu, CentOS and MacOS.
In Windows it is a bit trickier. But the excecutables will have `.exe` suffixes and are in `Scripts` folder `C:\Users\yournamehere\AppData\Local\Continuum\anaconda3\Scripts\pip3.exe` say for your regular install, your virtual env will be wherever you put it.

## Environment variables

Where did you put the protein?

    PROTEIN_DATA='/home/apps/protein-data'
    
code is used to give the command to reset mike:

    SECRETCODE='1234567890'
    
DB URL

    SQL_URL='postgresql://username:password@localhost:5432/app_users'
    
(opt) Sentry

    SENTRY_DNS_MICHELANGLO='https://xxxxx'

Slack webhook to keep you in the loop. Note that to get a slack webhook you don't go in your normal page, but in [api.slack.com](https://api.slack.com/)

    SLACK_WEBHOOK='xxxxxxxxxxx'
    
So a bash variable is declared without spaces `a="hello world"` and then you can call it `echo $a`. These will not be available outside of the current session, unless you `export $a`.
Alternative you can run the application you want to feed the env variable without leaving a trace(ish) by `a="hello world" python myscript`

## Ghosts in the machine
Also change the secret in `production.ini` and run the script and make a user called `admin`.
The users `trashcan` gets generated automatically when a guest makes a view and is blacklisted along with `guest` and `Anonymous`.

## Did you turn it off and on again?
Set up a system daemon, or a cron job to make sure it comes back upon system failure.
Also, the app.py serves on port 8088.

# nodejs

In order to get thumbnails of the protein in the galleries, or for when you share your protein on Twitter or Facebook, nodejs with puppeteer is required.
![Facebook](./images/fb_thumb.jpg)


    sudo apt install nodejs
    sudo apt install npm
    npm i puppeteer
    
Also, some of the submodules in `michelanglo_app/static/ThirdParty` need building. But this is only required for static offline downloads.

# Rosetta

For Venus, upcoming, Rosetta will be optionally required

curl -o a.tar.gz  -u Academic_User:**** https://www.rosettacommons.org/downloads/academic/3.11/rosetta_bin_linux_3.11_bundle.tgz