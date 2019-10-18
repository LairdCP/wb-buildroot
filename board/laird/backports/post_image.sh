IMAGESDIR="${1}"

if [ "${BR2_LRD_DEVEL_BUILD}" == "y" ] && [ -n "${BR2_DL_DIR}" ]; then
	mkdir -p ${BR2_DL_DIR}/linux-backports
	cp ${IMAGESDIR}/*.bz2 ${BR2_DL_DIR}/linux-backports
	cp ${IMAGESDIR}/*.bz2 ${BR2_DL_DIR}/backports-test
fi
