
BOARD_DIR="$(dirname $0)"
GENIMAGE_CFG="${BOARD_DIR}/genimage.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

# Tooling checks
mkimage="${HOST_DIR}/bin/mkimage"
atmel_pmecc_params="${BUILD_DIR}/uboot-custom/tools/atmel_pmecc_params"
openssl="${HOST_DIR}/usr/bin/openssl"
genimage="${HOST_DIR}/bin/genimage"
veritysetup="${HOST_DIR}/sbin/veritysetup"
mkenvimage="${HOST_DIR}/bin/mkenvimage"

set -x -e

rm -rf "${GENIMAGE_TMP}"

genimage                           \
	--rootpath "${TARGET_DIR}"     \
	--tmppath "${GENIMAGE_TMP}"    \
	--inputpath "${BINARIES_DIR}"  \
	--outputpath "${BINARIES_DIR}" \
	--config "${GENIMAGE_CFG}"

[ -z "${BR2_LRD_PRODUCT}" ] && \
	BR2_LRD_PRODUCT="$(sed -n 's,^BR2_DEFCONFIG=".*/\(.*\)_defconfig"$,\1,p' ${BR2_CONFIG})"

if [[ "${BR2_LRD_PRODUCT}" == *"rdvk" ]]
then
	cp "${BOARD_DIR}"/sw-description "${BINARIES_DIR}"/
	(cd  "${BINARIES_DIR}" && gzip -f rootfs.ext2)
	(cd "${BINARIES_DIR}" && echo -e "sw-description\nrootfs.ext2.gz" |\
		cpio -ov -H crc > "${BINARIES_DIR}/${BR2_LRD_PRODUCT}.swu")
fi
