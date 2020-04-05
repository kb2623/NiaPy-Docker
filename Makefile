SHELL:=/bin/bash
USER:=$(shell id -un)
PYTHON_VERSION=3.7

HOST_INTERFACE=enp96s0f0

SSL_KEY:=jupyter_server
SSL_PEM:=jupyter_cert

PIPENV_TAG:=latest

NIAORG_TAG:=latest
NIAORG_IP:=164.8.230.37
NIAORG_SORCE_PORT:=9999
NIAORG_PASSWORD:=test1234
NIAORG_USER:=$(shell id -un ${USER})
NIAORG_UID:=$(shell id -u ${USER})
NIAORG_GROUP:=$(shell id -gn ${USER})
NIAORG_GID:=$(shell id -g ${USER})
NIAORG_VOLUME_SRC:=/tmp/NiaOrg-${NIAORG_TAG}-python-${PYTHON_VERSION}

NIAORG_NETWORK_NAME:=mynet123
NIAORG_NETWORK_GW:=93.103.177.1
NIAORG_NETWORK_SUBNET:=93.103.177.0/16
NIAORG_NETWORK_IP:=93.103.177.239

NIAORG_NIAPY_GIT:="https://github.com/NiaOrg/NiaPy.git"
NIAORG_NIAPY_GIT_BRANCH:=$(shell git rev-parse --abbrev-ref HEAD)
NIAORG_NIAPY_EXAMPLES_GIT:="https://github.com/NiaOrg/NiaPy-examples.git"
NIAORG_NIAPY_EXAMPLES_GIT_BRANCH:=$(shell git rev-parse --abbrev-ref HEAD)

EXEC_USER:=${NIAORG_USER}
EXEC_SHELL:=/bin/sh

all:
	-make build
	-make run

## Volume ############################################################################################

volume:
	mkdir -p ${NIAORG_VOLUME_SRC}
	chown -R ${NIAORG_UID}:${NIAORG_GID} ${NIAORG_VOLUME_SRC}

clean_volume: ${DOCKER_VOLUME_SRC}
	rm -rf ${DOCKER_VOLUME_SRC}

## SSL keys ##########################################################################################

sslkey:
	openssl genrsa -des3 -out ${SSL_KEY}_lock.key 2048
	openssl rsa -in ${SSL_KEY}_lock.key -out ${SSL_KEY}.key
	openssl req -x509 -new -nodes -key ${SSL_KEY}.key -sha256 -days 1024 -out ${SSL_PEM}.pem

clean_sslkey:
	rm -f ${SSL_KEY}.key ${SSL_PEM}.pem
	
## SSL keys ##########################################################################################

net:
	docker network create \
		-d macvlan \
		--subnet=${NIAORG_NETWORK_SUBNET} \
		--gateway ${NIAORG_NETWORK_GW} \
		-o parent=${HOST_INTERFACE} \
		${NIAORG_NETWORK_NAME}

clean_net:
	docker network rm ${NIAORG_NETWORK_NAME}

## NiaOrg ############################################################################################

build: ${SSL_KEY}_lock.key ${SSL_KEY}.key ${SSL_PEM}.pem
	-cp ${SSL_KEY}_lock.key NiaOrgImage/${SSL_KEY}_lock.key
	-cp ${SSL_KEY}.key NiaOrgImage/${SSL_KEY}.key
	-cp ${SSL_PEM}.pem NiaOrgImage/${SSL_PEM}.pem
	docker build -t niaorg:${NIAORG_TAG}-python-${PYTHON_VERSION} NiaOrgImage \
		--build-arg PYTHON_VERSION=${PYTHON_VERSION} \
		--build-arg NB_PORT=${NIAORG_DESTINATION_PORT} \
		--build-arg NB_KEY=${SSL_KEY} \
		--build-arg NB_PEM=${SSL_PEM} \
		--build-arg NB_PASSWORD=${NIAORG_PASSWORD} \
		--build-arg NB_USER=${NIAORG_USER} \
		--build-arg NB_UID=${NIAORG_UID} \
		--build-arg NB_GROUP=${NIAORG_GROUP} \
		--build-arg NB_GID=${NIAORG_GID} \
		--build-arg NIA_GIT=${NIAORG_NIAPY_GIT} \
		--build-arg NIA_GIT_BRANCH=${NIAORG_NIAPY_GIT_BRANCH} \
		--build-arg NIA_GIT_EXAMPLES=${NIAORG_NIAPY_EXAMPLES_GIT} \
		--build-arg NIA_GIT_BRANCH_EXAMPLES=${NIAORG_NIAPY_EXAMPLES_GIT_BRANCH}
	-rm NiaOrgImage/${SSL_KEY}_lock.key NiaOrgImage/${SSL_KEY}.key NiaOrgImage/${SSL_PEM}.pem

build_clean:
	docker image rm niaorg:${NIAORG_TAG}-python-${PYTHON_VERSION}

create_net: volume
	docker create --name=niaorg-server \
		--network=${NIAORG_NETWORK_NAME} \
		--ip=${NIAORG_NETWORK_IP} \
		--hostname niaorg \
		-p ${NIAORG_SORCE_PORT}:9999 \
		-v ${NIAORG_VOLUME_SRC}:/mnt/NiaOrg \
		-d niaorg:${NIAORG_TAG}-python-${PYTHON_VERSION}

create: volume
	docker create --name niaorg-server-python-${PYTHON_VERSION} \
		--hostname niaorg \
		-p ${NIAORG_SORCE_PORT}:9999 \
		-v ${NIAORG_VOLUME_SRC}:/mnt/NiaOrg \
		-d niaorg:${NIAORG_TAG}-python-${PYTHON_VERSION}

run: volume
	docker run --rm -it \
		--hostname niaorg \
		-p ${NIAORG_SORCE_PORT}:9999 \
		-v ${NIAORG_VOLUME_SRC}:/mnt/NiaOrg \
		niaorg:${NIAORG_TAG}
		#${EXEC_SHELL}

run_net: volume
	docker run --rn -it \
		--network=${NIAORG_NETWORK_NAME} \
		--ip=${NIAORG_NETWORK_IP} \
		--hostname niaorg \
		-p ${NIAORG_SORCE_PORT}:9999 \
		-v ${NIAORG_VOLUME_SRC}:/mnt/NiaOrg \
		niaorg:${NIAORG_TAG} \
		${EXEC_SHELL}

start:
	docker start niaorg-server-python-${PYTHON_VERSION}

stop:
	docker stop niaorg-server-python-${PYTHON_VERSION}

exec:
	docker exec -it -u ${EXEC_USER} niaorg-server-python-${PYTHON_VERSION} ${EXEC_SHELL}

remove:
	-make stop
	docker container rm niaorg-server-python-${PYTHON_VERSION}
	-make build_clean

clean:
	-make remove
	docker image rm niaorg:${NIAORG_TAG}-python-${PYTHON_VERSION}

