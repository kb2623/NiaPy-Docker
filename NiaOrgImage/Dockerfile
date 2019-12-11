ARG BASE_CONTAINER=pipenv:latest
FROM $BASE_CONTAINER

LABEL maintainer="Klemen Berkovic <roxor@gmail.com>"

LABEL tags="python, microframework, nature-inspired-algorithms, swarm-intelligence, optimization-algorithms"
LABEL github="https://github.com/NiaOrg"
LABEL github-docker="https://github.com/NiaOrg/NiaPy-Docker"
LABEL description="Nature-inspired algorithms are a very popular tool for solving optimization problems. Numerous variants of nature-inspired algorithms have been developed since the beginning of their era. To prove their versatility, those were tested in various domains on various applications, especially when they are hybridized, modified or adapted. However, implementation of nature-inspired algorithms is sometimes a difficult, complex and tedious task. In order to break this wall, NiaPy is intended for simple and quick use, without spending time for implementing algorithms from scratch."

ARG GIT_BRANCH="development"
ARG NB_USER="jovyan"
ARG NB_UID=1001
ARG NB_GROUP="jovyan"
ARG NB_GID=1001
ARG NB_PASSWORD="test1234"
ARG NB_PORT=9999
ARG NB_KEY=jupyter_server
ARG NB_PEM=jupyter_cert
ENV NB_HOME=/home/$NB_USER
ENV NIA_GIT=https://github.com/kb2623/NiaPy.git
ENV NIA_EXAMPLES_GIT=https://github.com/kb2623/NiaPy-examples.git

USER root
WORKDIR /root

# Create user
COPY createuser.sh .
RUN chmod a+rx createuser.sh
RUN echo "auth requisite pam_deny.so" >> /etc/pam.d/su && \
    ./createuser.sh $NB_USER $NB_UID $NB_GROUP $NB_GID $NB_HOME && \
    chmod g+w /etc/passwd && \
    fix-permissions $NB_HOME

# Install jupyter lab
RUN pip3 install jupyterlab
# Add stings for jupyter
COPY jupyter_notebook_config.py /etc/jupyter/
RUN printf "c.NotebookApp.certfile = u'/etc/jupyter/%s.pem'\n" $NB_PEM >> /etc/jupyter/jupyter_notebook_config.py
RUN printf "c.NotebookApp.keyfile = u'/etc/jupyter/%s.key'\n" $NB_KEY >> /etc/jupyter/jupyter_notebook_config.py
RUN printf "c.NotebookApp.port = %d\n" $NB_PORT >> /etc/jupyter/jupyter_notebook_config.py
RUN printf "c.NotebookApp.password = u'%s'\n" $(python3 -c "from notebook.auth import passwd; print(passwd('${NB_PASSWORD}'))") >> /etc/jupyter/jupyter_notebook_config.py
COPY $NB_KEY.key /etc/jupyter/
COPY $NB_PEM.pem /etc/jupyter/
RUN fix-permissions /etc/jupyter/

USER $NB_UID
WORKDIR $NB_HOME

# Get and buld NiaPy
RUN git clone $NIA_GIT -b $GIT_BRANCH
RUN cd NiaPy && make build && cd ..
# Get and buld NiaPy-examples and run jupyter lab
RUN git clone $NIA_EXAMPLES_GIT -b $GIT_BRANCH
RUN cd NiaPy-examples && make install

USER $NB_UID
WORKDIR $NB_HOME/NiaPy-examples
EXPOSE $NB_PORT
CMD lab
ENTRYPOINT make


# vim: tabstop=4 noexpandtab shiftwidth=3 softtabstop=3
