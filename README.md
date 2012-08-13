## aks - AWS Key Switcher

* Do you have too many IAM accounts?
* Are you bouncing between several AWS accounts, multiple times everyday?
* Searching for a way to manage all your access and secret keys?
* Is it a pain to generate signing certificates for all your IAM accounts?

aks is here to help.

### How aks works

aks modifies the running bash environment variables that are needed by the
AWS CLI tools. It does this by creating a subdirectory in $HOME/aws/auth
for each IAM account (using a name you specify) storing all the key information
there and then sourcing the environment from the created files. When creating a
new account, aks will generate a signing ceritificate for you. aks also has the
option to import the environment for locating the AWS CLI tools (e.g. EC2_HOME,
EC2_AMITOOL_HOME, AWS_IAM_HOME, etc. etc.) from a global script.

### Features

* Uses bash tab-completion for arguments, account names
* Sets proper permissions on files/directories so only you can see your keys
* Can imports keys/certificates based on existing environment variables

### How to install

	git clone git://github.com/dialt0ne/aks.git
	cd aks
	mkdir $HOME/aws
	cp aks.sh global.sh $HOME/aws

### Configuration

	cd $HOME/aws
	mkdir auth
	vi aks.sh global.sh
	# customize variables as needed

### Usage

	source $HOME/aws/aks.sh
	
	usage:
	   aks create [newaccountname]
	   aks id
	   aks import [newaccountname]
	   aks list
	   aks use [accountname]

When creating an account, you will need from the AWS IAM Console, "Security Credentials" tab:

* your EC2 account id (the 5th field of IAM User ARN)
* your EC2 access key
* your EC2 secret key

Then you will be provided with your signing certificate, which you can copy and paste into the AWS IAM Console.

When importing your IAM credentials from the existing environment, the follow variable need to be set:

* `EC2_ID`
* `EC2_ACCESS`
* `EC2_SECRET`
* `EC2_PRIVATE_KEY`
* `EC2_CERT`

Note: to remove an account, just remove the subdirectory of $AWS_DIR/auth with the account name

### ToDo

* await feedback from users
* add more error checking to inputs on create/import

### License

Copyright 2012 Corsis
http://www.corsis.com/

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

