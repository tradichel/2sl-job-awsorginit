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

if [ -d 2sl-job-awsorginit ]; then
	rm -rf 2sl-job-awsorginit
fi

buildxversion=$(docker buildx version | cut -d " " -f2 | cut -d "+" -f1)
echo "Buildx Version: $buildxversion"

if [ "$buildxversion" == "v0.0.0" ]; then
	git clone https://github.com/docker/buildx.git
	cd buildx
	sudo make install
	mkdir -p ~/.docker/cli-plugins #no sudo
	sudo install bin/build/buildx ~/.docker/cli-plugins/docker-buildx
	cd ..
	rm -rf buildx
	buildxversion=$(docker buildx version)
	echo "Buildx updated to version: $buildxversion"
	echo "Restart CloudShell to free up space and run this script again"
fi

#clone the repositories to CloudShell
git clone https://github.com/tradichel/2sl-jobexecframework.git
git clone https://github.com/tradichel/2sl-job-awsorginit.git

cd 2sl-jobexecframework/

###NOTE: Parameter code untested#####
#check to see if the domain parameter exists
exists=$(ssm_parameter_exists "domain")
#if not ask the user for a domain and add it
if [ "$exists" == "false" ]; then
  echo "The domain SSM parameter does not exist."
  echo "Please enter the email domain you would like to use for the email addresses associated with your AWS accounts:"
  read domain
  ssm_put_parameter_value "domain" $domain
fi

#check to see if the org parameter exists
exists=$(ssm_parameter_exists "org")

#if not ask the user for a domain and add it
if [ "$exists" == "false" ]; then
  echo "The org SSM parameter does not exist."
  echo "Please enter the value you would like to use prepent to aws account names and use for the name of the root account your AWS accounts:"
  read domain
  ssm_put_parameter_value "domain" $domain
fi
###NOTE: Parameter code untested#####

./scripts/build.sh awsorginit

sudo yum install jq -y
creds=$(curl -H "Authorization: $AWS_CONTAINER_AUTHORIZATION_TOKEN" $AWS_CONTAINER_CREDENTIALS_FULL_URI 2>/dev/null)
profile='root'
region=$AWS_REGION

accesskeyid="$(echo $creds | jq -r ".AccessKeyId")"
secretaccesskey="$(echo $creds | jq -r ".SecretAccessKey")"
sessiontoken="$(echo $creds | jq -r ".Token")"

echo "********************************************"
echo "Pass credentials to container"
echo "********************************************"
parameters="\
  profile=root,\
  accesskey=$accesskeyid,\
  secretaccesskey=$secretaccesskey,\
  sessiontoken=$sessiontoken,\
  region=$AWS_REGION"

#remove any spaces so the parameter list is treated as a single argument passed to the container
parameters=$(echo $parameters | sed 's/ //g')

echo "********************************************"
echo "Run the container $image and execute the job $job_parameter"
echo "********************************************"
docker run awsorginit $parameters

#clear space in CloudShell
sudo docker system prune -y
sudo yum clean all
history -c
./scripts/delete_all_images_and_containers.sh
cd ..
rm -rf 2sl*
