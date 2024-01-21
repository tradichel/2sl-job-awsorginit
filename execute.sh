#!/bin/bash -e
# https://github.com/tradichel/2sl-job-awsorginit
# execute.sh
# author: @teriradichel @2ndsightlab
# Description: Container execution script to run the job
# for this specific container.
##############################################################
profile="$1"

echo "Executing 2sl-job-awsorginit/execute.sh"

template_dir="2sl-jobexecframework/resources/aws/"

#Naver use the root credentials in the root management account unless 
#absolutely required. And that is almost never. Make sure the 
#root management account has hardware MFA assigned (like a Yubikey)
#and preferrably two hardware MFA devices. Create a strong password
#and lock the credentials away somewhere secure that can be accessed
#in case of emergency. Understand who has access to these 
#credentials and under what circumstances.

#Create a break glass user in case we can't get access to the account
#from any other account or an external identity provider, if used.
#This account has limited permissions so it cannot create other users
#in the root account. As soon as this account is created, add hardware MFA
#like a Yubikey, two if possible, and lock down the credentials in a 
#secure location for future use only if required.
template=$template_dir'iam/user/user.yaml'
aws cloudformation deploy --template-file $template --stack-name root-root-iam-user-root-admin --capabilities CAPABILITY_NAMED_IAM --profile $profile --parameter-overrides NameParam=root-admin ConsoleAccessParam=true

template=$template_dir'iam/managedpolicy/root-accountrolepermissionsboundary.yaml'
aws cloudformation deploy --template-file $template  --stack-name root-root-iam-managedpolicy-root-permissionboundary --capabilities CAPABILITY_NAMED_IAM --profile $profile 

template=$template_dir'iam/userpolicy/root-adminuserpolicy.yaml'
aws cloudformation deploy --template-file $template --stack-name root-root-iam-userpolicy-root-adminuserpolicy --capabilities CAPABILITY_NAMED_IAM --profile $profile 

template=$template_dir'iam/role/root-adminrole.yaml'
aws cloudformation deploy --template-file $template --stack-name root-root-role-iam-root-adminrole --capabilities CAPABILITY_NAMED_IAM --profile $profile 

template=$template_dir'iam/rolepolicy/root-adminrolepolicy.yaml'
aws cloudformation deploy --template-file template --stack-name root-root-iam-rolepolicy-root-adminrolepolicy --capabilities CAPABILITY_NAMED_IAM --profile $profile 

#We want to take actions in the root account as little as possible since 
#Service Control Policies (SCPs) do not apply in the root management account
#of an organization.
#
#orgadmin OU
#orgadmin account
#orgadmin user
#orgadmin role
#orgadmin group

####
# 
# Deploy resources to use the 2sl-jobexecframework
#
# Running jobs using the 2sl-jobexecframework requires the following minimal credentials and roles:
#
# * An EC2 instance job role: Eventually used by an EC2 instance but can be assumed by environment admin
# * A user with virtual MFA device assigned; the device name must match the username
# * AWS access key and secret key in secrets manager for the user running the job
# * A role that the user can assume that is used to run the job
#
# Our initial user is the org-admin user (above).
#
# Our initial role to run jobs is the org-adminrole (above)
#
# We need to deploy the EC2 job role (below).
#
# We need to deploy a secret with a developer secret key and access key (below)
#
# Once we have those minimal resources the org-admin user can run jobs 
# until we have all the resource in place including to securely run jobs 
# in this account which includes an EC2 instance using a secure AMI in a 
# private network with VPC endpoints and a NAT and all future users and
# credentials deployed in our IAM account or possibly leveraging an IdP (TBD).
#
######

# The ec2job role in this account differs from the long term architecture
# because we cannot reference users or credentials from other sources until
# they have been deployed. So our initial configuration of the 2sl-jobexecframework
# deploys everyting in the org-admin account. This account is used to deploy 
# everything else or the users that deploy everything else.
# For this reason, the initial ec2job role references a secret in the same
# account to obtain the credentials to run jobs and the user and MFA device
# used to run the jobs is in the same account.

#template=$template_dir'iam/role/orgec2jobrole.yaml'
#aws cloudformation deploy --template-file $template --stack-name root-root-role-iam-ec2jobrole --capabilities CAPABILITY_NAMED_IAM --profile $profile 

#orgadmin user developer key and access key in secret that only the ec2 job role 
#and the orgadmin user can access.

#################################################################################
# Copyright Notice
# All Rights Reserved.
# All materials (the “Materials”) in this repository are protected by copyright 
# under U.S. Copyright laws and are the property of 2nd Sight Lab. They are provided 
# pursuant to a royalty free, perpetual license the person to whom they were presented 
# by 2nd Sight Lab and are solely for the training and education by 2nd Sight Lab.
#
# The Materials may not be copied, reproduced, distributed, offered for sale, published, 
# displayed, performed, modified, used to create derivative works, transmitted to 
# others, or used or exploited in any way, including, in whole or in part, as training 
# materials by or for any third party.
#
# The above copyright notice and this permission notice shall be included in all 
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
################################################################################ 

