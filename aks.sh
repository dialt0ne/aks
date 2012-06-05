#
# aks - AWS Key Switcher
#
# ATonns Fri Jun  1 15:47:00 EDT 2012
#
#

AWS_DIR="$HOME/aws"
AWS_ACCOUNT="(none)"

# script that sets up paths to AWS CLI tools
if [ -f $AWS_DIR/global.sh ]
then
	source $AWS_DIR/global.sh
fi

# function to create all key files for authenticating with AWS
unset -f create_auth_info
create_auth_info()
{
	# args
	local AWS_DIR AWS_ACCT_DIR AWS_ACCOUNT EC2_ID EC2_ACCESS EC2_SECRET
	AWS_DIR=$1 && shift
	AWS_ACCOUNT=$1 && shift
	EC2_ID=$1 && shift
	EC2_ACCESS=$1 && shift
	EC2_SECRET=$1 && shift
	# per-account directory 
	AWS_ACCT_DIR=$AWS_DIR/auth/$AWS_ACCOUNT
	mkdir --mode=0700 $AWS_ACCT_DIR
	pushd $AWS_ACCT_DIR > /dev/null
	# signing certificate
	SUBJ="/C=''/ST=''/L=''/O=''/OU=''/CN='$AWS_ACCOUNT'"
	# create a 2048 bit key
	openssl genrsa -out pk-$AWS_ACCOUNT-rsa.pem 2048 2> /dev/null
	# ~10 year expiration
	openssl req -new -subj $SUBJ -x509 -key pk-$AWS_ACCOUNT-rsa.pem -out cert-$AWS_ACCOUNT.pem -days 3650
	# convert to pkcs8 format for amazon
	openssl pkcs8 -topk8 -in pk-$AWS_ACCOUNT-rsa.pem -nocrypt > pk-$AWS_ACCOUNT.pem
	# remove old rsa key
	rm -f pk-$AWS_ACCOUNT-rsa.pem
	chmod 400 cert-$AWS_ACCOUNT.pem
	chmod 400 pk-$AWS_ACCOUNT.pem
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
			AWS_ACCOUNT=$2
			if [ "$AWS_ACCOUNT" = "" ]
			then
				echo "error, must provide account name to create"
				return 1
			fi
			if [ -d "$AWS_DIR/auth/$AWS_ACCOUNT" ]
			then
				echo "error, account '$AWS_ACCOUNT' already exists"
				return 1
			fi
			echo "new account will be '$AWS_ACCOUNT'"
			echo "enter EC2 account id [5th field of IAM User ARN]:"
			read EC2_ID
			echo "enter EC2 access key:"
			read EC2_ACCESS
			echo "enter EC2 secret key:"
			read EC2_SECRET
			create_auth_info $AWS_DIR $AWS_ACCOUNT $EC2_ID $EC2_ACCESS $EC2_SECRET
			echo "your singing certificate:"
			cat $AWS_DIR/auth/$AWS_ACCOUNT/cert-$AWS_ACCOUNT.pem
			aks use $AWS_ACCOUNT
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
		list)
			echo "current available accounts are:"
			ls --format=single-column --color=never $AWS_DIR/auth
			return 0
			;;
		use)
			AWS_ACCOUNT=$2
			if [ "$AWS_ACCOUNT" = "" ]
			then
				echo "error, must provide account name to use"
				return 1
			fi
			if [ -f "$AWS_DIR/auth/$AWS_ACCOUNT/$AWS_ACCOUNT-env.sh" ]
			then
				source $AWS_DIR/auth/$AWS_ACCOUNT/$AWS_ACCOUNT-env.sh
				echo switched to account "$AWS_ACCOUNT"
				return 0
			else
				echo "error, can't find '$AWS_DIR/auth/$AWS_ACCOUNT/$AWS_ACCOUNT-env.sh'"
				return 1
			fi
			;;
		*)
			echo "unknown arg: '$1'"
			echo "usage:"
			echo "   aks create [newaccountname]"
			echo "   aks id"
			echo "   aks list"
			echo "   aks use [accountname]"
			return 1
			;;
	esac
}

unset -f _aks
_aks() 
{
	local cur prev opts
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"
	opts="create id list use"
 
	local accounts=$(ls --format=single-column --color=never $AWS_DIR/auth)
	case "${prev}" in
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
			COMPREPLY=( $(compgen -W "${accounts}" -- ${cur}) )
			return 0
			;;
		*)
		;;
	esac

	#
	COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
	return 0
}

complete -F _aks aks

