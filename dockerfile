##### UNFINISHED #######
# mod of a previous dockerfile of mine

#$ docker build -t xxxx:latest .
$ docker run -d -p 8088:8088 xxxxxx



FROM centos:latest
RUN apt-get update && yes|apt-get upgrade
RUN apt-get install -y wget bzip2 sudo git
RUN adduser apps sudo
WORKDIR /home/apps/
RUN chmod a+rwx /home/apps/  ????

# Anaconda3
#https://repo.continuum.io/archive/
RUN wget https://repo.continuum.io/archive/Anaconda3-2019.07-Linux-x86_64.sh
RUN bash Anaconda3-2019.07-Linux-x86_64.sh -b
RUN rm Anaconda3-2019.07-Linux-x86_64.sh
ENV PATH /home/apps/anaconda3/bin:$PATH   ?? or source???
RUN conda update conda
RUN conda update anaconda
RUN conda update --all


##olde
WORKDIR /opt/app-root/src
COPY . /opt/app-root/src/
ENTRYPOINT ["container-entrypoint"]


EXPOSE  8088
USER 1001   ??? What was this again?

RUN pip install --upgrade pip
RUN pip install -r requirements.txt

Alembic the DB
submodules

CMD ["python", "app.py", "-p 8080"]