BR2_LRD_PRODUCT="$(sed -n 's,^BR2_DEFCONFIG=".*/\(.*\)_defconfig"$,\1,p' ${BR2_CONFIG})"
TOPDIR="${PWD}"

echo "${BR2_LRD_PRODUCT^^} POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

ln -rsf board/laird/rootfs-additions-common/usr/sbin/fw_select "${BINARIES_DIR}/fw_select"
ln -rsf board/laird/rootfs-additions-common/usr/sbin/fw_update "${BINARIES_DIR}/fw_update"

cd "${BINARIES_DIR}"

ln -rsf "${BINARIES_DIR}/uImage"* "${BINARIES_DIR}/kernel.bin"
ln -rsf "${BINARIES_DIR}/boot.bin" "${BINARIES_DIR}/at91bs.bin"
ln -rsf "${BINARIES_DIR}/rootfs.ubi" "${BINARIES_DIR}/rootfs.bin"

[ -z "${LAIRD_FW_TXT_URL}" ] && \
	LAIRD_FW_TXT_URL="http://$(hostname)/${BR2_LRD_PRODUCT}"

[ -n "${VERSION}" ] && RELEASE_SUFFIX="-${VERSION}"

${TOPDIR}/board/laird/mkfwtxt.sh "${LAIRD_FW_TXT_URL}"
${TOPDIR}/board/laird/mkfwusi.sh

size_check () {
	[ $(stat -Lc "%s" ${BINARIES_DIR}/${1}) -le $((${2}*128*1024)) ] || \
		{ echo "${1} size exceeded ${2} block limit, failed"; exit 1; }
}

size_check 'kernel.bin' 38
size_check 'u-boot.bin' 3

tar -cjhf "${BR2_LRD_PRODUCT}-laird${RELEASE_SUFFIX}.tar.bz2" \
	--owner=root --group=root \
	at91bs.bin u-boot.bin kernel.bin rootfs.bin \
	fw_update fw_select fw_usi fw.txt \
	$(ls userfs.bin prep_nand_for_update 2>/dev/null)

echo "${BR2_LRD_PRODUCT^^} POST IMAGE script: done."
