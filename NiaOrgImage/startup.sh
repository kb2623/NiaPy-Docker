#!/bin/bash

NIA_GIT=$1
NIA_GIT_BRANCH=$2
NIA_GIT_EXAMPLES=$3
NIA_GIT_BRANCH_EXAMPLES=$4

curr=$(pwd)

if [ ! -d NiaPy ]; then
	git clone $NIA_GIT -b $NIA_GIT_BRANCH NiaPy \
		&& cd NiaPy \
		&& make build
	cd ${curr}
fi

if [ ! -d NiaPy-examples ]; then
	git clone $NIA_GIT_EXAMPLES -b $NIA_GIT_BRANCH_EXAMPLES NiaPy-examples
	cd ${curr}
fi

cd NiaOrg-examples && lab
