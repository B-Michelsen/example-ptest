#!/bin/bash
BRANCH_NAME="$(git rev-parse --abbrev-ref HEAD)"
SRCREV="$(git ls-remote origin | head -1 | cut -f 1)"
COMPONENT_NAME=$1
TARGET="root@192.168.7.2"
LAYER_NAME="meta-poc"
IMAGE="core-image-full-cmdline"
YOCTO_PATH="/home/bjarne/repos/yocto"
PROJECT_PATH="/home/bjarne/repos/example-ptest"

# Ensure devtool is available?
# boot up a qemu if not already running
setup() {
	pushd ${YOCTO_PATH} > /dev/null
	if ! [ -x "$(command -v devtool)" ]; then
		source poky/oe-init-build-env 2>&1 > /dev/null
		#echo 'Error: cound not find `devtool`. did you forgot to source?' >&2
	fi
	if ! [ -x "$(pgrep -x "qemu")" ]; then
		echo "Starting qemu"
		# TODO: boot qemu in background
		# take a look at testimage.bbclass
		#runqemu ${IMAGE} qemuparams='--nographic' &
	fi
	echo "Updating recipe to build from local branch ${BRANCH_NAME}"
	# TODO: what if the sources are already in workspace?
	# 1. call devtool reset --remove-work
	# 2. don't force anything, just fail with message.
	devtool modify ${COMPONENT_NAME} --no-extract ${PROJECT_PATH} 2>&1 > /dev/null
	popd > /dev/null
}

build() {
	# TODO: ensure build was successful, otherwise fail.
	echo "Building ${COMPONENT_NAME}"
	devtool build ${COMPONENT_NAME} 
}

run_test() {
        # TODO: add host as no host key checking in ~/.ssh/config
	# Host 192.168.7.2
        #   StrictHostKeyChecking no
	# Otherwise deploy-target will fail
	echo "Deploying to qemu"
	devtool deploy-target ${COMPONENT_NAME} ${TARGET} 2>&1 > /dev/null
	echo "Running tests"
	ssh ${TARGET} ptest-runner ${COMPONENT_NAME}
}

update_recipe() {
	devtool reset ${COMPONENT_NAME} --remove-work
	devtool upgrade ${COMPONENT_NAME} --srcrev ${SRCREV} master
	devtool finish ${COMPONENT_NAME} ${LAYER_NAME} --remove-work
}

setup
build
run_test
# Update recipe could be optional. Not necessary for testing.
#update_recipe
