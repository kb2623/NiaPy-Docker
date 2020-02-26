ARG PYTHON_VERSION=3.6
FROM python:$PYTHON_VERSION-slim

LABEL maintainer="Klemen Berkovic <roxor@gmail.com>"
LABEL tags="python, microframework, nature-inspired-algorithms, swarm-intelligence, optimization-algorithms"
LABEL github="https://github.com/NiaOrg"
LABEL github-docker="https://github.com/NiaOrg/NiaPy-Docker"

ARG NO_PROC_MAKE=1
ARG NB_USER="jovyan"
ARG NB_UID=1001
ARG NB_GROUP="jovyan"
ARG NB_GID=1001
ARG NB_PASSWORD="test1234"
ARG NB_KEY=jupyter_server
ARG NB_PEM=jupyter_cert
ARG NIA_GIT="https://github.com/NiaOrg/NiaPy.git"
ARG NIA_GIT_BRANCH="development"
ARG NIA_GIT_EXAMPLES="https://github.com/NiaOrg/NiaPy-examples.git"
ARG NIA_GIT_BRANCH_EXAMPLES="master"

ENV NB_HOME=/home/$NB_USER

USER root
WORKDIR /root

# For user skeleton dir
RUN mkdir -p /etc/skel
ADD .zshrc /etc/skel
ADD .profile /etc/skel
ADD .bashrc /etc/skel

USER root
WORKDIR /root

# Create user
ADD createuser.sh .
RUN chmod a+rx createuser.sh \
 && bash createuser.sh $NB_USER $NB_UID $NB_GROUP $NB_GID $NB_HOME \
 && chmod g+w /etc/passwd

# Install programs
RUN apt update \
 && apt install -y tmux git gcc g++ gdb make bash zsh \
 && pip install --upgrade pip \ 
 && pip install pipenv jupyterlab
# Add stings for jupyter
COPY $NB_KEY.key /etc/jupyter/
COPY $NB_PEM.pem /etc/jupyter/
COPY jupyter_notebook_config.py /etc/jupyter/
RUN printf "c.NotebookApp.certfile = u'/etc/jupyter/%s.pem'\n" $NB_PEM >> /etc/jupyter/jupyter_notebook_config.py \
 && printf "c.NotebookApp.keyfile = u'/etc/jupyter/%s.key'\n" $NB_KEY >> /etc/jupyter/jupyter_notebook_config.py \
 && printf "c.NotebookApp.port = 9999\n" >> /etc/jupyter/jupyter_notebook_config.py \
 && printf "c.NotebookApp.password = u'%s'\n" $(python3 -c "from notebook.auth import passwd; print(passwd('${NB_PASSWORD}'))") >> /etc/jupyter/jupyter_notebook_config.py

USER $NB_UID
WORKDIR $NB_HOME

# Get and buld NiaPy
RUN git clone $NIA_GIT -b $NIA_GIT_BRANCH \
 && cd NiaPy \
 && make build

# Get and buld NiaPy-examples and run jupyter lab
RUN git clone $NIA_GIT_EXAMPLES -b $NIA_GIT_BRANCH_EXAMPLES
#&& cd NiaPy-examples \
#&& make install

## ENTRYPOINT ####################################################

USER $NB_UID
#WORKDIR $NB_HOME/NiaPy-examples
WORKDIR $NB_HOME
#EXPOSE 9999
CMD lab
ENTRYPOINT bash

# vim: tabstop=1 expandtab shiftwidth=1 softtabstop=1
