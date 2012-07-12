#
# aks - AWS Key Switcher
#
# ATonns Fri Jun  1 15:47:00 EDT 2012
#
#   Copyright 2012 Corsis
#   http://www.corsis.com/
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

if [ -z "$AWS_DIR" ]
then
	export AWS_DIR="$HOME/aws"
fi
AWS_ACCOUNT="(none)"

# script that sets up paths to AWS CLI tools
if [ -f $AWS_DIR/global.sh ]
then
	source $AWS_DIR/global.sh
fi

# function to create all key files for authenticating with AWS
unset -f _aks_create_auth_info
_aks_create_auth_info()
{
	_aks_process_auth_info create $*
}

# function to import all key files for authenticating with AWS
unset -f _aks_import_auth_info
_aks_import_auth_info()
{
	_aks_process_auth_info import $*
}

# internal function to process all key info for authenticating with AWS
unset -f _aks_process_auth_info
_aks_process_auth_info()
{
	# args
	local AKS_OPER AWS_DIR AWS_ACCT_DIR AWS_ACCOUNT EC2_ID EC2_ACCESS EC2_SECRET
	local EC2_PRIVATE_KEY EC2_CERT OLD_EC2_PRIVATE_KEY OLD_EC2_CERT
	AKS_OPER=$1 && shift
	AWS_DIR=$1 && shift
	AWS_ACCOUNT=$1 && shift
	AWS_ACCT_DIR="$AWS_DIR/auth/$AWS_ACCOUNT"
	EC2_ID=$1 && shift
	EC2_ACCESS=$1 && shift
	EC2_SECRET=$1 && shift
	if [ "$AKS_OPER" = "import" ]
	then
		OLD_EC2_PRIVATE_KEY=$1 && shift
		OLD_EC2_CERT=$1 && shift
	fi
	EC2_PRIVATE_KEY="pk-$AWS_ACCOUNT.pem"
	EC2_CERT="cert-$AWS_ACCOUNT.pem"
	# per-account directory 
	mkdir --mode=0700 $AWS_ACCT_DIR
	pushd $AWS_ACCT_DIR > /dev/null
	# signing cert
	if [ "$AKS_OPER" = "create" ]
	then
		# signing certificate
		SUBJ="/C=''/ST=''/L=''/O=''/OU=''/CN='$AWS_ACCOUNT'"
		# create a 2048 bit key
		openssl genrsa -out pk-$AWS_ACCOUNT-rsa.pem 2048 2> /dev/null
		# convert to pkcs8 format for amazon
		openssl pkcs8 -topk8 -in pk-$AWS_ACCOUNT-rsa.pem -nocrypt > $EC2_PRIVATE_KEY
		# ~10 year expiration
		openssl req -new -subj $SUBJ -x509 -key pk-$AWS_ACCOUNT-rsa.pem -out $EC2_CERT -days 3650
		# remove old rsa key
		rm -f pk-$AWS_ACCOUNT-rsa.pem
	elif [ "$AKS_OPER" = "import" ]
	then
		cp -p $OLD_EC2_PRIVATE_KEY $EC2_PRIVATE_KEY
		cp -p $OLD_EC2_CERT $EC2_CERT
	fi
	chmod 400 $EC2_PRIVATE_KEY
	chmod 400 $EC2_CERT
	# cred file
	(
		echo "AWSAccessKeyId=$EC2_ACCESS"
		echo "AWSSecretKey=$EC2_SECRET"
	) > $AWS_ACCOUNT.cred
	chmod 400 $AWS_ACCOUNT.cred
	# s3cfg file
	(
		echo "access_key = $EC2_ACCESS"
		echo "secret_key = $EC2_SECRET"
	) > $AWS_ACCOUNT.s3cfg
	chmod 600 $AWS_ACCOUNT.s3cfg
	# awssecrets file
	(
		echo "$EC2_ACCESS"
		echo "$EC2_SECRET"
	) > $AWS_ACCOUNT.awssecrets
	chmod 600 $AWS_ACCOUNT.awssecrets
	# env file
	(
		echo "export EC2_ID=$EC2_ID";
		echo "export EC2_ACCESS=$EC2_ACCESS";
		echo "export EC2_SECRET=$EC2_SECRET";
		echo "export EC2_PRIVATE_KEY="$AWS_ACCT_DIR/pk-$AWS_ACCOUNT.pem;
		echo "export EC2_CERT="$AWS_ACCT_DIR/cert-$AWS_ACCOUNT.pem;
		echo "export AWS_CREDENTIAL_FILE=$AWS_ACCT_DIR/$AWS_ACCOUNT.cred"
		echo "alias s3cmd='s3cmd --config=$AWS_ACCT_DIR/$AWS_ACCOUNT.s3cfg'"
		echo "alias aws='aws --secrets-file=$AWS_ACCT_DIR/$AWS_ACCOUNT.awssecrets'"
	) > $AWS_ACCOUNT-env.sh
	chmod 500 $AWS_ACCOUNT-env.sh
	popd > /dev/null
}

unset -f aks
aks()
{
	case "$1" in
		create)
			TARGET_AWS_ACCOUNT="$2"
			if [ "$TARGET_AWS_ACCOUNT" = "" ]
			then
				echo "error, must provide account name to create"
				unset TARGET_AWS_ACCOUNT
				return 1
			fi
			if [ -d "$AWS_DIR/auth/$TARGET_AWS_ACCOUNT" ]
			then
				echo "error, account '$TARGET_AWS_ACCOUNT' already exists"
				unset TARGET_AWS_ACCOUNT
				return 1
			fi
			echo "new account will be '$TARGET_AWS_ACCOUNT'"
			TARGET_EC2_ID=""
			while [ -z $TARGET_EC2_ID ]
			do
				echo "enter EC2 account id [5th field of IAM User ARN]:"
				read TARGET_EC2_ID
				# ToDo - add error checking here
			done
			TARGET_EC2_ACCESS=""
			while [ -z $TARGET_EC2_ACCESS ]
			do
				echo "enter EC2 access key:"
				read TARGET_EC2_ACCESS
				# ToDo - add error checking here
			done
			TARGET_EC2_SECRET=""
			while [ -z $TARGET_EC2_SECRET ]
			do
				echo "enter EC2 secret key:"
				read TARGET_EC2_SECRET
				# ToDo - add error checking here
			done
			EC2_ID="TARGET_EC2_ID"
			EC2_ACCESS="TARGET_EC2_ACCESS"
			EC2_SECRET="TARGET_EC2_SECRET"
			AWS_ACCOUNT="$TARGET_AWS_ACCOUNT"
			_aks_create_auth_info $AWS_DIR $AWS_ACCOUNT $EC2_ID $EC2_ACCESS $EC2_SECRET
			echo "your new singing certificate [copy/paste into IAM Signing Certificates]:"
			cat $AWS_DIR/auth/$AWS_ACCOUNT/cert-$AWS_ACCOUNT.pem
			aks use $AWS_ACCOUNT
			unset TARGET_AWS_ACCOUNT
			return 0
			;;
		id)
			if [ "$AWS_ACCOUNT" != "(none)" ]
			then
				echo "current account is '$AWS_ACCOUNT'"
				return 0
			else
				echo "no current account"
				return 1
			fi
			;;
		import)
			TARGET_AWS_ACCOUNT="$2"
			if [ "$TARGET_AWS_ACCOUNT" = "" ]
			then
				echo "error, must provide account name to import"
				unset TARGET_AWS_ACCOUNT
				return 1
			fi
			if [ -d "$AWS_DIR/auth/$TARGET_AWS_ACCOUNT" ]
			then
				echo "error, account '$TARGET_AWS_ACCOUNT' already exists"
				unset TARGET_AWS_ACCOUNT
				return 1
			fi
			echo "imported account will be '$TARGET_AWS_ACCOUNT'"
			if [ "$EC2_ID" = "" ]
			then
				echo "error, environment varible EC2_ID is missing"
				unset TARGET_AWS_ACCOUNT
				return 1
			fi
			if [ "$EC2_ACCESS" = "" ]
			then
				echo "error, environment varible EC2_ACCESS is missing"
				unset TARGET_AWS_ACCOUNT
				return 1
			fi
			if [ "$EC2_SECRET" = "" ]
			then
				echo "error, environment varible EC2_SECRET is missing"
				unset TARGET_AWS_ACCOUNT
				return 1
			fi
			if [ "$EC2_PRIVATE_KEY" = "" ]
			then
				echo "error, environment varible EC2_PRIVATE_KEY is missing"
				unset TARGET_AWS_ACCOUNT
				return 1
			fi
			if [ "$EC2_CERT" = "" ]
			then
				echo "error, environment varible EC2_CERT is missing"
				unset TARGET_AWS_ACCOUNT
				return 1
			fi
			AWS_ACCOUNT="$TARGET_AWS_ACCOUNT"
			_aks_import_auth_info $AWS_DIR $AWS_ACCOUNT $EC2_ID $EC2_ACCESS $EC2_SECRET $EC2_PRIVATE_KEY $EC2_CERT
			echo "imported info for account '$AWS_ACCOUNT'"
			aks use $AWS_ACCOUNT
			unset TARGET_AWS_ACCOUNT
			return 0
			;;
		list)
			echo "current available accounts are:"
			ls --format=single-column --color=never $AWS_DIR/auth
			return 0
			;;
		use)
			TARGET_AWS_ACCOUNT="$2"
			if [ "$TARGET_AWS_ACCOUNT" = "" ]
			then
				echo "error, must provide account name to use. account not switched"
				unset TARGET_AWS_ACCOUNT
				return 1
			fi
			if [ -f "$AWS_DIR/auth/$TARGET_AWS_ACCOUNT/$TARGET_AWS_ACCOUNT-env.sh" ]
			then
				AWS_ACCOUNT="$TARGET_AWS_ACCOUNT"
				source $AWS_DIR/auth/$AWS_ACCOUNT/$AWS_ACCOUNT-env.sh
				echo "switched to account '$AWS_ACCOUNT'"
				unset TARGET_AWS_ACCOUNT
				return 0
			else
				echo "error, can't find '$AWS_DIR/auth/$TARGET_AWS_ACCOUNT/$TARGET_AWS_ACCOUNT-env.sh'"
				unset TARGET_AWS_ACCOUNT
				return 1
			fi
			;;
		*)
			echo "unknown arg: '$1'"
			echo "usage:"
			echo "   aks create [newaccountname]"
			echo "   aks id"
			echo "   aks import [newaccountname]"
			echo "   aks list"
			echo "   aks use [accountname]"
			return 1
			;;
	esac
}

unset -f _aks_complete
_aks_complete() 
{
	local CURRENT PREVIOUS OPTIONS
	COMPREPLY=()
	CURRENT="${COMP_WORDS[COMP_CWORD]}"
	PREVIOUS="${COMP_WORDS[COMP_CWORD-1]}"
	OPTIONS="create id import list use"
 
	# each subdir is a 'known' account
	local ACCOUNTS=$(ls --format=single-column --color=never $AWS_DIR/auth)
	case "${PREVIOUS}" in
		create)
			# no args
			COMPREPLY=()
			return 0
			;;
		id)
			# no args
			COMPREPLY=()
			return 0
			;;
		list)
			# no args
			COMPREPLY=()
			return 0
			;;
		use)
			COMPREPLY=( $(compgen -W "${ACCOUNTS}" -- ${CURRENT}) )
			return 0
			;;
		*)
		;;
	esac

	# if there's no previous arg, present available options
	COMPREPLY=($(compgen -W "${OPTIONS}" -- ${CURRENT}))
	return 0
}

complete -F _aks_complete aks

