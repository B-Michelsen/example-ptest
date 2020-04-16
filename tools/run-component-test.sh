#!/bin/sh
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
	pushd ${YOCTO_PATH}
	if ! [ -x "$(command -v devtool)" ]; then
		source poky/oe-init-build-env
		echo 'Error: cound not find `devtool`. did you forgot to source?' >&2
	fi
	if ! [ -x "$(pgrep -x "qemu")" ]; then
		echo "Starting qemu"
		# TODO: boot qemu in background
		# take a look at testimage.bbclass
		runqemu ${IMAGE} qemuparams='--nographic'
	fi
	echo "Updating recipe to build from local branch ${BRANCH_NAME}"
	# TODO: what if the sources are already in workspace?
	# 1. call devtool reset --remove-work
	# 2. don't force anything, just fail with message.
	devtool modify ${COMPONENT_NAME} --no-extract ${PROJECT_PATH} 2>&1 > /dev/null
	popd
}

build() {
	devtool build ${COMPONENT_NAME} 2>&1 > /dev/null
}

run_test() {
        # TODO: add host as no host key checking in ~/.ssh/config
	# Host 192.168.7.2
        #   StrictHostKeyChecking no
	# Otherwise deploy-target will fail
	devtool deploy-target ${COMPONENT_NAME} ${TARGET}
	ssh ${TARGET} ptest-runner ${COMPONENT_NAME}
}

update_recipe() {
	devtool reset ${COMPONENT_NAME} --remove-work
	devtool upgrade ${COMPONENT_NAME} --srcrev ${SRCREV} master
	devtool finish ${COMPONENT_NAME} ${LAYER_NAME} --remove-work
}

setup
build
[ $? -eq 0 ] || exit 1
run_test
update_recipe
