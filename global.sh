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
	export AWS_DIR=$HOME/aws
fi
pathmunge () {
  if ! echo $PATH | egrep -q "(^|:)$1($|:)" ; then
    if [ "$2" = "after" ] ; then
      PATH=$PATH:$1
    else
      PATH=$1:$PATH
    fi
  fi
}
if [ -z "$JAVA_HOME" ]
then
        #export JAVA_HOME=/usr/lib/jvm/java-1.6.0-sun-1.6.0.11/jre
        export JAVA_HOME=/usr/java/latest
fi
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
