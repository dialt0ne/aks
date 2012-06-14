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

* uses bash tab-completion for arguments, account names
* Sets proper permissions on files/directories so only you can see your keys

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
	   aks list
	   aks use [accountname]

### ToDo

* create an import function to copy existing IAM keys/certs to aks directory structure
