#!/bin/bash -e
# https://github.com/tradichel/2sl-job-awsorginit
# init.sh
# author: @teriradichel @2ndsightlab
# Description: Script executed in new AWS Account to
# deploy an organization and initial resources.
##############################################################

if [ -d 2sl-jobexecframework ]; then
 rm -rf 2sl-jobexecframework
fi
if [ -d 2sl-jobexecframework ]; then
	rm -rf 2sl-jobexecframework
fi

#clone the repositories to CloudShell
git clone https://github.com/tradichel/2sl-jobexecframework.git
git clone https://github.com/tradichel/2sl-job-awsorginit.git

cd 2sl-jobexecframework/aws
./scripts/build.sh awsorginit


