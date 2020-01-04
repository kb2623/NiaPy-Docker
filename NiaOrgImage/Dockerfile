FROM alpine:3.10 AS NiaPyOrg_base

LABEL maintainer="Klemen Berkovic <roxor@gmail.com>"
LABEL tags="python, microframework, nature-inspired-algorithms, swarm-intelligence, optimization-algorithms"
LABEL github="https://github.com/NiaOrg"
LABEL github-docker="https://github.com/NiaOrg/NiaPy-Docker"

ARG PYTHON_VERSION=3.8.0
ARG NO_PROC_MAKE=1

ENV NB_HOME=/home/$NB_USER
ENV NIA_GIT=https://github.com/kb2623/NiaPy.git
ENV NIA_EXAMPLES_GIT=https://github.com/kb2623/NiaPy-examples.git
ENV PYTHON_CONFIG_PREFIX=/usr/local

USER root
WORKDIR /root

# Install needed programs
RUN apk add --no-cache git g++ gcc zsh bash make linux-headers build-base dpkg-dev dpkg ncurses-dev openssl-dev pax-utils sqlite-dev tcl-dev tk tk-dev util-linux-dev util-linux-dev xz-dev zlib-dev bzip2-dev coreutils expat-dev gdbm-dev libc-dev libffi-dev libnsl-dev libtirpc-dev readline-dev \
 && rm -rf /var/cache/apk/*

# Build and install python
RUN wget https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tar.xz \
 && tar xf Python-$PYTHON_VERSION.tar.xz
RUN cd Python-$PYTHON_VERSION \
 && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
 && ./configure --prefix=$PYTHON_CONFIG_PREFIX --build="${gnuArch}" --enable-optimizations --enable-shared --enable-loadable-sqlite-extensions --with-system-expat --with-system-ffi --without-ensurepip \
 && make -j $NO_PROC_MAKE EXTRA_CFLAGS="-DTHREAD_STACK_SIZE=0x100000" \
 && make -j $NO_PROC_MAKE install
RUN rm -rf Python-$PYTHON_VERSION \
 && rm Python-$PYTHON_VERSION.tar.xz
RUN cd /usr/local/bin \
	&& ln -s idle3 idle \
	&& ln -s pydoc3 pydoc \
	&& ln -s python3 python \
	&& ln -s python3-config python-config

# Install pip
RUN wget -O get-pip.py https://bootstrap.pypa.io/get-pip.py \
 && python get-pip.py

# For user skeleton dir
RUN mkdir -p /etc/skel
ADD .zshrc /etc/skel
ADD .profile /etc/skel
ADD .bashrc /etc/skel

ARG GIT_BRANCH="development"
FROM NiaPyOrg_base

LABEL maintainer="Klemen Berkovic <roxor@gmail.com>"
LABEL tags="python, microframework, nature-inspired-algorithms, swarm-intelligence, optimization-algorithms"
LABEL github="https://github.com/NiaOrg"
LABEL github-docker="https://github.com/NiaOrg/NiaPy-Docker"

ARG NB_USER="jovyan"
ARG NB_UID=1001
ARG NB_GROUP="jovyan"
ARG NB_GID=1001
ARG NB_PASSWORD="test1234"
ARG NB_KEY=jupyter_server
ARG NB_PEM=jupyter_cert
ARG NIA_GIT="https://github.com/kb2623/NiaPy.git"
ARG NIA_EXAMPLES_GIT="https://github.com/kb2623/NiaPy-examples.git"
ARG GIT_BRANCH="development"

USER root
WORKDIR /root

# Create user
ADD createuser.sh .
RUN chmod a+rx createuser.sh \
 && ./createuser.sh $NB_USER $NB_UID $NB_GROUP $NB_GID $NB_HOME \
 && chmod g+w /etc/passwd

# Install jupyterlab and pipenv
RUN pip install pipenv jupyterlab
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
RUN git clone $NIA_GIT -b $GIT_BRANCH \
 && cd NiaPy \
 && make build

# Get and buld NiaPy-examples and run jupyter lab
RUN git clone $NIA_EXAMPLES_GIT -b $GIT_BRANCH \
 && cd NiaPy-examples \
 && make install

## ENTRYPOINT ####################################################

USER $NB_UID
WORKDIR $NB_HOME/NiaPy-examples

EXPOSE 9999

CMD lab
ENTRYPOINT make

# vim: tabstop=1 expandtab shiftwidth=1 softtabstop=1
