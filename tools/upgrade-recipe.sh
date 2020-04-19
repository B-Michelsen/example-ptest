COMPONENT_NAME=$1
SRCREV="$(git ls-remote origin | head -1 | cut -f 1)"
LAYER_NAME="meta-example-test"

update_recipe() {
	devtool reset ${COMPONENT_NAME}
	devtool upgrade ${COMPONENT_NAME} --srcrev ${SRCREV} master
	devtool finish ${COMPONENT_NAME} ${LAYER_NAME}
}

update_recipe 
