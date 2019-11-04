IMAGESDIR="${1}"

# enable tracing and exit on errors
set -x -e

if [ "${BR2_LRD_DEVEL_BUILD}" == "y" ]; then
	[ -z "${BR2_DL_DIR}" ] && \
		BR2_DL_DIR="$(sed -n 's,^BR2_DL_DIR="\(.*\)"$,\1,p' ${BR2_CONFIG})"

	if [ -n "${BR2_DL_DIR}" ]; then
		mkdir -p ${BR2_DL_DIR}/linux-backports
		cp ${IMAGESDIR}/*.bz2 ${BR2_DL_DIR}/linux-backports
		cp ${IMAGESDIR}/*.bz2 ${BR2_DL_DIR}/backports-test
	fi
fi
