#!/bin/bash
COMPONENT=$1
TARGET="root@192.168.7.2"
IMAGE="core-image-full-cmdline"
YOCTO_PATH="/home/bjarne/repos/yocto"
PROJECT_PATH="/home/bjarne/repos/example-ptest"

# Ensure devtool is available?
# boot up a qemu if not already running
setup() {
	local COMPONENT=$1
	local PROJECT_PATH=$2
	local YOCTO_PATH=$3
	pushd ${YOCTO_PATH} > /dev/null
	if ! [ -x "$(command -v devtool)" ]; then
		source poky/oe-init-build-env ${YOCTO_PATH}/build 2>&1 > /dev/null
	fi
	if ! [ -x "$(pgrep -x "qemu")" ]; then
		echo "Starting qemu"
		# TODO: boot qemu in background
		# take a look at testimage.bbclass
		#runqemu ${IMAGE} qemuparams='--nographic' &
	fi
	echo "Updating recipe ${COMPONENT} to build from repository ${PROJECT_PATH}"
	devtool modify ${COMPONENT} --no-extract ${PROJECT_PATH} 2>&1 > /dev/null
	popd > /dev/null
}

build() {
	local COMPONENT=$1
	# TODO: ensure build was successful, otherwise fail.
	echo "Building ${COMPONENT}"
	devtool build ${COMPONENT} 
	return $?
}

run_test() {
	local AUT=$1
	local TEST_TARGET=$2
	echo "Deploying to qemu"
	devtool deploy-target -cs ${AUT} ${TEST_TARGET} 2>&1 > /dev/null
	if [ $? -eq 0 ]; then
		echo "Running tests"
		ssh ${TEST_TARGET} ptest-runner ${AUT}
	else
		echo "Failed to deploy, please check if qemu is running"
	fi
}

setup ${COMPONENT} ${PROJECT_PATH} ${YOCTO_PATH}
build ${COMPONENT}
if [ $? -eq 0 ]; then
	run_test ${COMPONENT} ${TARGET}
else
	echo "Failed to build target"
fi
