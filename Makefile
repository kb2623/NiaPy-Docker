HOST_INTERFACE=enp0

SSL_KEY:=jupyter_server
SSL_PEM:=jupyter_cert

PIPENV_TAG:=latest

NIAORG_TAG:=latest
NIAORG_ARG:=BASE_CONTAINER=pipenv:${PIPENV_TAG}
NIAORG_IP:=192.168.1.37
NIAORG_SORCE_PORT:=9999
NIAORG_DESTINATION_PORT:=9999
NIAORG_PASSWORD:=test1234
NIAORG_USER:=jovyan
NIAORG_UID:=1001
NIAORG_GROUP:=jovyan
NIAORG_GID:=1001

NIAORG_NETWORK_NAME:=mynet123
NIAORG_NETWORK_GW:=192.168.1.1
NIAORG_NETWORK_SUBNET:=192.168.1.0/24
NIAORG_NETWORK_IP:=192.168.1.23

sslkey:
	openssl genrsa -des3 -out NiaOrgImage/${SSL_KEY}_lock.key 2048
	openssl rsa -in NiaOrgImage/${SSL_KEY}_lock.key -out NiaOrgImage/${SSL_KEY}.key
	openssl req -x509 -new -nodes -key NiaOrgImage/${SSL_KEY}.key -sha256 -days 1024 -out NiaOrgImage/${SSL_PEM}.pem

sslclean:
	-rm NiaOrgImage/${SSL_KEY}_lock.key
	-rm NiaOrgImage/${SSL_KEY}.key
	-rm NiaOrgImage/${SSL_PEM}.pem

buildPipenv: PipenvImage/Dockerfile PipenvImage/fix-permissions PipenvImage/.tmux.conf PipenvImage/.basic.tmuxtheme
	docker build -t pipenv:${PIPENV_TAG} PipenvImage

buildNiaorg: NiaOrgImage/Dockerfile NiaOrgImage/${SSL_KEY}.key NiaOrgImage/${SSL_PEM}.pem NiaOrgImage/createuser.sh NiaOrgImage/jupyter_notebook_config.py
	-make buildPipenv 
	docker build -t niapyorg:${NIAORG_TAG} --build-arg ${NIAORG_ARG} --build-arg NB_PORT=${NIAORG_DESTINATION_PORT} --build-arg NB_KEY=${SSL_KEY} --build-arg NB_PEM=${SSL_PEM} --build-arg NB_PASSWORD=${NIAORG_PASSWORD} --build-arg NB_USER=${NIAORG_USER} --build-arg NB_UID=${NIAORG_UID} --build-arg NB_GROUP=${NIAORG_GROUP} --build-arg NB_GID=${NIAORG_GID} NiaOrgImage

build:
	-make buildNiaorg

createnet:
	docker network create \
		-d macvlan \
		--subnet=${NIAORG_NETWORK_SUBNET} \
		--gateway ${NIAORG_NETWORK_GW} \
		-o parent=${HOST_INTERFACE} \
		${NIAORG_NETWORK_NAME}

runPipenv:
	-make buildPipenv
	docker run -it \
		--name pipenv-server \
		pipenv:${PIPENV_TAG} \
		/bin/bash

runnet:
	-make build
	-make makenet
	docker run --name=niapyorg-server \
		--network=${NIAORG_NETWORK_NAME} \
		--ip=${NIAORG_NETWORK_IP} \
		-p ${NIAORG_SORCE_PORT}:${NIAORG_DESTINATION_PORT} \
		-d niapyorg:${NIAORG_TAG}

run:
	-make build
	docker run --name niapyorg-server \
		-p ${NIAORG_IP}:${NIAORG_SORCE_PORT}:${NIAORG_DESTINATION_PORT} \
		-d niapyorg:${NIAORG_TAG}

startPipenv:
	docker start pipenv-server

start:
	docker start niapyorg-server

stopPipenv:
	docker container stop pipenv-server

stop:
	docker container stop niapyorg-server

removePipenv:
	-make stopPipenv
	docker container rm pipenv-server

remove:
	-make stop
	docker container rm niapyorg-server

cleanPipenv:
	-make removePipenv
	docker image rm pipenv:${PIPENV_TAG}

clean:
	docker image rm niapyorg:${NIAORG_TAG}

cleanall: 
	-make remove
	-make clean
	-make cleanPipenv
