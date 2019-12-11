# enable tracing and exit on errors
set -x -e

if [ "${BR2_LRD_DEVEL_BUILD}" == "y" ]; then
	[ -z "${BR2_DL_DIR}" ] && \
		BR2_DL_DIR="$(sed -n 's,^BR2_DL_DIR="\(.*\)"$,\1,p' ${BR2_CONFIG})"

	if [ -n "${BR2_DL_DIR}" ]; then
		mkdir -p ${BR2_DL_DIR}/linux-backports
		mkdir -p ${BR2_DL_DIR}/backports-test
		cp ${BINARIES_DIR}/*.bz2 ${BR2_DL_DIR}/linux-backports
		cp ${BINARIES_DIR}/*.bz2 ${BR2_DL_DIR}/backports-test
	fi
fi
