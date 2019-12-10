ARG BASE_CONTAINER=alpine:3.10
FROM $BASE_CONTAINER

LABEL maintainer="Klemen Berkovic <roxor@gmail.com>"
LABEL github="https://github.com/NiaOrg"
LABEL github-docker="https://github.com/NiaOrg/NiaPy-Docker"
LABEL description="Base image with pipenv and jupyterlab"

USER root
WORKDIR /root

# Update the system
RUN apt update
# Install needed programs
RUN apt install -y git make vim vifm tmux && apt install -y virtualenv && apt install -y pipenv
# Add script
ADD fix-permissions /usr/local/bin/fix-permissions
RUN chmod a+rx /usr/local/bin/fix-permissions
# Enable prompt color in the skeleton .bashrc before creating the default NB_USER
RUN [ -e /etc/skel/.bashrc ] && rm /etc/skel/.bashrc
ADD .bashrc /etc/skel
ADD .tmux.conf /etc/skel
ADD .basic.tmuxtheme /etc/skel
RUN [ -e /etc/skel/.profile ] && rm /etc/skel/.profile
ADD .profile /etc/skel

CMD /bin/bash
