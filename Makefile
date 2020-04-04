SHELL:=/bin/bash
USER:=$(shell id -un)

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
NIAORG_GID:=$(shell id -gn ${USER})
NIAORG_VOLUME_SRC:=/tmp/NiaPy-Docker

NIAORG_NETWORK_NAME:=mynet123
NIAORG_NETWORK_GW:=93.103.177.1
NIAORG_NETWORK_SUBNET:=93.103.177.0/16
NIAORG_NETWORK_IP:=93.103.177.239

NIAORG_NIAPY_GIT:="https://github.com/NiaOrg/NiaPy.git"
NIAORG_NIAPY_GIT_BRANCH:="development"
NIAORG_NIAPY_EXAMPLES_GIT:="https://github.com/NiaOrg/NiaPy-examples.git"
NIAORG_NIAPY_EXAMPLES_GIT_BRANCH:="development"

EXEC_USER:=${NIAORG_USER}
EXEC_SHELL:=/bin/sh

all:
	-make build
	-make run

## Volume ############################################################################################
volume:
	mkdir -p ${DOCKER_VOLUME_SRC}
	chown -R ${NIAORG_UID}:${NIAORG_GID} ${NIAORG_VOLUME_SRC}

clean_volume: ${DOCKER_VOLUME_SRC}
	rm -rf ${DOCKER_VOLUME_SRC}

## SSL keys ##########################################################################################

sslkey:
	openssl genrsa -des3 -out ${SSL_KEY}_lock.key 2048
	openssl rsa -in ${SSL_KEY}_lock.key -out ${SSL_KEY}.key
	openssl req -x509 -new -nodes -key ${SSL_KEY}.key -sha256 -days 1024 -out ${SSL_PEM}.pem

clean_sslkey:
	
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
	docker build -t niaorg:${NIAORG_TAG} NiaOrgImage \
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

run_net: volume
	-make build
	-make makenet
	docker run --name=niaorg-server \
		--network=${NIAORG_NETWORK_NAME} \
		--ip=${NIAORG_NETWORK_IP} \
		-p ${NIAORG_SORCE_PORT}:9999 \
		-v ${NIAORG_VOLUME_SRC}:/mnt/NiaOrg \
		-d niaorg:${NIAORG_TAG}

run: volume
	-make build
	docker run --name niaorg-server \
		--hostname niapy.org \
		-p ${NIAORG_SORCE_PORT}:9999 \
		-v ${NIAORG_VOLUME_SRC}:/mnt/NiaOrg \
		-d niaorg:${NIAORG_TAG}

run_bash: volume
	-make build
	docker run --rm -it \
		--hostname niapy.org \
		-p ${NIAORG_SORCE_PORT}:9999 \
		-v ${NIAORG_VOLUME_SRC}:/mnt/NiaOrg \
		niaorg:${NIAORG_TAG} \
		/bin/bash

start:
	docker start niaorg-server

exec:
	docker exec -it -u ${EXEC_USER} niaorg-server ${EXEC_SHELL}

stop:
	docker container stop niaorg-server

remove:
	-make stop
	docker container rm niaorg-server

clean:
	-make remove
	docker image rm niaorg:${NIAORG_TAG}

