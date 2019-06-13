#!/bin/bash
####################################################################################################
# AUTH: Matthew Baum
# DATE: 2018-01-31
# DESC: This script automates the execution of a jmeter test and the production of test results
# ARGS:
#   - $1: jmeter_script: the script to run
#   - $2: output_directory: the directory where a date-stamped results directory will be created
#   - $others: All other arguments are forwarded directly to jmeter
#
# NOTE: assumes the following programs exist: tee, tar
# NOTE: This script assumes jmeter is included in the command path
# NOTE: This script passes default sizing args to the jvm, if the JVM_ARGS env var is undefined
####################################################################################################
if [ $# -lt 2 ]; then
	printf "**** ERROR: Must pass at least 2 args to this script: 1=jmeter_script, 2=output_directory\n\tFound $# args: #@\n\texiting...\n"
	exit 1
fi

# set jvm args for jmeter, if undefined
if [ -z $JVM_ARGS ]; then
	export JVM_ARGS="-Xms512m -Xmx2g"
	echo "**** LOG: Setting JVM heap size to: $JVM_ARGS"
fi

# create output directory
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
RES_DIR="$2/$TIMESTAMP"
echo "**** LOG: Results will appear under: $RES_DIR"
mkdir -p $RES_DIR

# run test, pass args and save logs
echo "**** LOG: Starting jmeter test: $1"
echo "**** LOG: Additional arguments: ${@:3}"
jmeter -n -t $1 -l $RES_DIR/res.csv -e -o $RES_DIR/dashboard -j $RES_DIR/jmeter.log -JRES_DIR=$RES_DIR ${@:3} | tee $RES_DIR/console.log

# compress results
echo "**** LOG: Writing compressed result files to: ${RES_DIR}.tar.gz"
tar -czvf $RES_DIR.tar.gz -C $RES_DIR .

exit 0
