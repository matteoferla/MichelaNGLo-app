## TL;DR
This is for the ultra-impatient and assumes:

* have conda already, if not read Step 1 and 2.
* have a licence to FontAwesome-Pro, if not read Step 3
* dont care about VENUS or gene name route, if not read Step 4
* you want to use sqlite, not postgres. if not read Step 5
* dont care about static downloads, if not read step 6


Install modules in a folder called michelanglo:

    mkdir michelanglo
    cd michelanglo/
    git clone --recursive https://github.com/matteoferla/MichelaNGLo.git app
    git clone https://github.com/matteoferla/MichelaNGLo-protein-module.git protein-module
    git clone https://github.com/matteoferla/MichelaNGLo-transpiler transpiler
    cd protein-module
    python3 setup.py install
    #python3 create.py & #do this to get protein data. else:
    mkdir ../protein-data
    mkdir ../protein-data/reference
    touch ../protein-data/reference/pdb_chain_uniprot.tsv
    # end of hacky way round.
    cd ../transpiler
    python3 setup.py install
    cd ../app
    python3 setup.py install
    npm install # installs puppeteer, but you will have to decide about the chromium sandboxing
    # do not want sqlite? change the env variable accordingly and read below
    cp demo.db mike.db
    PROTEIN_DATA='../protein-data' SECRETCODE='needed-for-remote-reset' SQL_URL='sqlite:///mike.db' SLACK_WEBHOOK='https://hooks.slack.com/services/xxx/xxx/xxx' python3 app.py > ../mike.log 2>&1

The last command runs it (to run in dev mode add `--d`).
The admin user in the `demo.db` file is `admin` with password `admin`.
Additional adding the env var `SENTRY_DNS_MICHELANGLO='https://xxxx@sentry.io/xxx'` will send errors.
The Slack webhook isn't optional, but giving a dummy value will just make errors, but not crash it.

## Preface
This is why there are many commands to copy.

** Do not jump the gun and git clone recursively** this repository without altering FontAwesome Pro requirement if needed (see below).

### Diagram

Michelanglo has lots of moving parts...
![diagram](./images/mike%20layout-03.png)

### Backend
* Python 3.7
    * Pyramid
    * Waitress (Apache: reverse proxy)
    * PyMOL (see note)
    * Biopython
    * APScheduler
    * Postgres
    * external purpose written modules:
        * [github.com/matteoferla/MichelaNGLo-protein-module](https://github.com/matteoferla/MichelaNGLo-protein-module)
        * [github.com/matteoferla/MichelaNGLo-transpiler](https://github.com/matteoferla/MichelaNGLo-transpiler)
* NodeJS
    * Puppeeter
   

**Python 3.7**: This repo uses f-strings and the author is unwilling to make it backwards compatible.
**DB**: Postgres is more robust and secure than SQLite. But if you are just running this for yourself, be lazy & go SQLite.

### Frontend
* Mako-templated HTML
* NGL
* JQuery
* Boostrap 4.3
* FontAwesome Pro
* Bootstrap Tour (mod)

**FontAwesome**: I have a pro licence, but a free version is available. So a wee change is required to `.gitmodules` (see below).

## Step 1. Prerequisites

Linux packages

    sudo apt install nodejs
    sudo apt install npm

And either...

    sudo apt install sqlite

or...

    sudo apt install postgres

Mac packages

    brew install nodejs
    brew install npm
    brew install wget

either...

    brew install sqlite
or...

    brew install postgres
    
Installing postgres on a networked windows machine is a satanic endevour.
Consider a Docker container with Alpine, a VM with Ubuntu, Rasperry pi with Raspian (use Berryconda) or an old smartphone with AfterMarketOS.
All the documentation here works on Ubuntu, CentOS and MacOS and everything in Windows it is a bit trickier. But the excecutables will have `.exe` suffixes and are in `Scripts` folder `C:\Users\yournamehere\AppData\Local\Continuum\anaconda3\Scripts\pip3.exe` say for your regular install, your virtual env will be wherever you put it.


## Step 2. Python
This app requires Python3 compiled PyMOL. The best option is using Conda. Otherwise it needs to be compiled ([instructions](https://blog.matteoferla.com/2019/04/pymol-on-linux-without-conda.html)).
So the best bet is to install anaconda3:

    wget https://repo.anaconda.com/archive/Anaconda3-2019.10-MacOSX-x86_64.sh
    bash Anaconda3-2019.10-MacOSX-x86_64.sh -b
    conda init
    conda config --set auto_activate_base true
    conda update conda
    
If you want to make env —your call

    conda create -n env python=3.7 anaconda
    conda activate env
    
Install what you need:

    conda install -c schrodinger pymol
    conda install -c conda-forge -y biopython
    #conda install -c conda-forge -y rdkit

## Step 3. Clone the required repos 

### Step 3.1 MichelaNGLo specific 

For fetching proteins, michelanglo_app requires [https://github.com/matteoferla/MichelaNGLo-protein-module](https://github.com/matteoferla/MichelaNGLo-protein-module).

Both the protein module and Michelanglo require a PyMOL manipulation script, whcih is separate as the protein parsing module works without Michelanglo.
[https://github.com/matteoferla/MichelaNGLo-transpiler](https://github.com/matteoferla/MichelaNGLo-transpiler) for more.


    mkdir michelanglo
    cd michelanglo/
    git clone https://github.com/matteoferla/MichelaNGLo-protein-module.git protein-module
    cd protein-module
    python3 setup.py install
    git clone https://github.com/matteoferla/MichelaNGLo-transpiler transpiler
    cd ../transpiler
    python3 setup.py install

### Step 3.2 FontAwesome

Do you have FontAwesome Pro?
    
    git clone --recursive https://github.com/matteoferla/MichelaNGLo.git app
    cd ../app
    python3 setup.py install
    
Installing it isn't needed for normal operations, just esthetics.

Else:

    git clone https://github.com/matteoferla/MichelaNGLo.git app
    https://github.com/FortAwesome/Font-Awesome
    sed -i 's/Font-Awesome-Pro\.git/Font-Awesome\.git/g' .gitmodules
    git submodule update --init --recursive
    python3 setup.py install
    
Note that you'll also need to change all instances of the class `far` with `fas` in the templates
by adding `<script>$('.far').addClass('fas').removeClass('far')</script>` near the bottom of `templates/layout_components/layout.mako` 
(There is a common giving more info within there).
If this is too much faff just drop matteo dot ferla at gmail an email.

## Step 4. Generate the data
It also uses a protein module to allow gene name querying.

This module uses a lot of data. That unfortunately I cannot keep as a repo for you to download.
However. This step is optional: if not done, gene retrieval will not work.

This module has lots of cool stuff. I might be worth your while checking it out.

see [https://github.com/matteoferla/MichelaNGLo-protein-module](https://github.com/matteoferla/MichelaNGLo-protein-module)

Also, if you plan to mod Michelanglo do not clone the protein module in Michelanglo or your IDE will go _extremely_ slow.

To get everything...

    cd ../protein-module
    python3 create.py
    
This will save all the data it will download and parse to this folder.
This will take a whole day.
For licencing issues, Phosphosite plus data needs to be downloaded manually.

However, if there is a species you are interested in, email me and I can save you the bother.

## Step 5. Create the database

The database needs starting, for SQLite make a copy of `demo.db` or do the following:

    touch mike.db
    SQL_URL=sqlite:///mike.db alembic -c development.ini revision --autogenerate -m "init"
    SQL_URL=sqlite:///mike.db alembic -c development.ini upgrade head
    
If using postgres the environment variable needs to be `SQL_URL=postgresql://name_of_owner_user_you_made_for_the_db_that_is_not_postgres:its_password@localhost:5432/name_of_db`

Obviously, nothing ever goes smoothly. If you get an error with the second line (the upgrade) edit the file `michelanglo_app/alembic/versions/xxxx.py` if you get:

* an error about explicit contraint names: change all `sa.Boolean()` to `sa.Boolean(create_constraint=False)`. SQLite does not know about Booleans.
* ... ?

For a more robust system, use postgres (as used in our version).

## Step 6. NPM

In order to get thumbnails of the protein in the galleries, or for when you share your protein on Twitter or Facebook, nodejs with puppeteer is required.
![Facebook](./images/fb_thumb.jpg)

    npm i puppeteer
    
Also, some of the submodules in `michelanglo_app/static/ThirdParty` need building. But this is only required for static offline downloads.

## Step 7. Run

### Environment variables

Having an config file with sensitive data on GitHub is a no-no, so there are lots of env variables used here.
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

    SQL_URL=xxx;SECRETCODE=xxx;SLACK_WEBHOOK=xxx;PROTEIN_DATA=xxx python3 app.py --d

## Ghosts in the machine
Run the script and make a user called `admin`.
The users `trashcan` gets generated automatically when a guest makes a view and is blacklisted along with `guest` and `Anonymous`.

## Did you turn it off and on again?
Set up a system daemon, or a cron job to make sure it comes back upon system failure.
Also, the app.py serves on port 8088.

# Future
## Rosetta

For Venus, upcoming, pyrosetta will be optionally required.

    curl -o a.tar.gz  -u Academic_User:**** https://www.rosettacommons.org/downloads/academic/3.11/rosetta_bin_linux_3.11_bundle.tgz