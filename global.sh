export AWS_DIR=$HOME/aws
pathmunge () {
  if ! echo $PATH | /bin/egrep -q "(^|:)$1($|:)" ; then
    if [ "$2" = "after" ] ; then
      PATH=$PATH:$1
    else
      PATH=$1:$PATH
    fi
  fi
}
#export JAVA_HOME=/usr/lib/jvm/java-1.6.0-sun-1.6.0.11/jre
export JAVA_HOME=/usr/java/latest
#
export EC2_HOME=$AWS_DIR/tools/api-tools
pathmunge $EC2_HOME/bin after
#
export EC2_AMITOOL_HOME=$AWS_DIR/tools/ami-tools
pathmunge $EC2_AMITOOL_HOME/bin after
#
export AWS_CLOUDFORMATION_HOME=$AWS_DIR/tools/cfn-tools
pathmunge $AWS_CLOUDFORMATION_HOME/bin after
#
export AWS_CLOUDWATCH_HOME=$AWS_DIR/tools/cw-tools
pathmunge $AWS_CLOUDWATCH_HOME/bin after
#
export AWS_ELASTICACHE_HOME=$AWS_DIR/tools/elasticache-tools
pathmunge $AWS_ELASTICACHE_HOME/bin after
#
export AWS_ELB_HOME=$AWS_DIR/tools/elb-tools
pathmunge $AWS_ELB_HOME/bin after
#
export AWS_IAM_HOME=$AWS_DIR/tools/iam-tools
pathmunge $AWS_IAM_HOME/bin after
#
export AWS_AUTO_SCALING_HOME=$AWS_DIR/tools/as-tools
pathmunge $AWS_AUTO_SCALING_HOME/bin after
#
export AWS_RDS_HOME=$AWS_DIR/tools/rds-tools
pathmunge $AWS_RDS_HOME/bin after
#
export AWS_SNS_HOME=$AWS_DIR/tools/sns-tools
pathmunge $AWS_SNS_HOME/bin after
#
