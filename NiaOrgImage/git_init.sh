#!/bin/bash



cd NiaOrg

curr_wd=$(pwd)

if [ ! -d NiaPy ]; then
	git clone $NIA_GIT -b $NIA_GIT_BRANCH NiaPy \
		&& cd NiaPy \
		&& make build
	cd ${curr_wd}
fi

if [ ! -d NiaPy-examples ]; then
	git clone $NIA_GIT_EXAMPLES -b $NIA_GIT_BRANCH_EXAMPLES NiaPy-examples
	cd ${curr_wd}
fi

cd NiaOrg-examples && lab
