#!/bin/bash -e
# https://github.com/tradichel/2sl-job-awsorginit
# execute.sh
# author: @teriradichel @2ndsightlab
# Description: Container execution script to run the job
# for this specific container.
##############################################################
PROFILE="$1"

echo "Executing 2sl-job-awsorginit/execute.sh"

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
template='resources/iam/user/user.yaml'
aws cloudformation deploy --template $template --stack-name root-root-iam-user-root-admin --capabilities CAPABILITY_NAMED_IAM --profile $PROFILE --parameter-overrides NameParam=root-admin ConsoleAccessParam=true

template='resources/iam/managedpolicy/root-permissionsboundary.yaml'
aws cloudformation deploy --template $template  --stack-name root-root-iam-managedpolicy-root-permissionboundary --capabilities CAPABILITY_NAMED_IAM --profile $PROFILE 

template='resources/iam/userpolicy/root-adminuserpolicy.yaml'
aws cloudformation deploy --template $template --stack-name root-root-iam-userpolicy-root-adminuserpolicy --capabilities CAPABILITY_NAMED_IAM --profile $PROFILE 

template='resources/iam/role/root-adminrole.yaml'
aws cloudformation deploy --template $template --stack-name root-root-role-iam-root-adminrole --capabilities CAPABILITY_NAMED_IAM --profile $PROFILE 

template='resources/iam/rolepolicy/root-adminrolepolicy.yaml'
aws cloudformation deploy --template $template --stack-name root-root-iam-rolepolicy-root-adminrolepolicy --capabilities CAPABILITY_NAMED_IAM --profile $PROFILE 

echo "The next step is to run 2sl-job-awsenvinit"

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

