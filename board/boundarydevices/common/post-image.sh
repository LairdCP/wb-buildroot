
BOARD_DIR="$(realpath $(dirname $0))"
GENIMAGE_CFG="${BOARD_DIR}/genimage.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

# Tooling checks
genimage="${HOST_DIR}/bin/genimage"

set -x -e

rm -rf "${GENIMAGE_TMP}"

${genimage}                        \
	--rootpath "${TARGET_DIR}"     \
	--tmppath "${GENIMAGE_TMP}"    \
	--inputpath "${BINARIES_DIR}"  \
	--outputpath "${BINARIES_DIR}" \
	--config "${GENIMAGE_CFG}"

BR2_LRD_PRODUCT="$(sed -n 's,^BR2_DEFCONFIG=".*/\(.*\)_defconfig"$,\1,p' ${BR2_CONFIG})"

RELEASE_FILE="${BINARIES_DIR}/${BR2_LRD_PRODUCT}-laird"
[ -n "${VERSION}" ] && RELEASE_FILE+="-${VERSION}"

if [[ "${BR2_LRD_PRODUCT}" == *"rdvk" ]]; then
	cp "${BOARD_DIR}"/sw-description "${BINARIES_DIR}"/
	gzip -f "${BINARIES_DIR}/rootfs.ext2"
	(cd "${BINARIES_DIR}" && echo -e "sw-description\nrootfs.ext2.gz" |\
		cpio -ov -H crc > "${BINARIES_DIR}/${BR2_LRD_PRODUCT}.swu")
	tar -C -"${BINARIES_DIR}" -cjf "${RELEASE_FILE}.tar.bz2" \
		sdcard.img ${BR2_LRD_PRODUCT}.swu
else
	tar -C -"${BINARIES_DIR}" -cjf "${RELEASE_FILE}.tar.bz2" \
		sdcard.img
fi
