TOPDIR="${PWD}"

echo "COMMON POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

BR2_LRD_PRODUCT="$(sed -n 's,^BR2_DEFCONFIG=".*/\(.*\)_defconfig"$,\1,p' ${BR2_CONFIG})"

if grep -qF "BR2_LINUX_KERNEL_APPENDED_DTB=y" ${BR2_CONFIG}; then
cp "${BINARIES_DIR}/uImage."* "${BINARIES_DIR}/kernel.bin"
else
cp "${BINARIES_DIR}/uImage" "${BINARIES_DIR}/kernel.bin"
fi
cp "${BINARIES_DIR}/rootfs.ubi" "${BINARIES_DIR}/rootfs.bin"
cp "${BINARIES_DIR}/at91bootstrap.bin" "${BINARIES_DIR}/at91bs.bin"

cp board/laird/rootfs-additions-common/usr/sbin/fw_select "${BINARIES_DIR}/"
cp board/laird/rootfs-additions-common/usr/sbin/fw_update "${BINARIES_DIR}/"

[ -z "${LAIRD_FW_TXT_URL}" ] && \
	LAIRD_FW_TXT_URL="http://$(hostname)/${BR2_LRD_PRODUCT}"

[ -n "${VERSION}" ] && RELEASE_SUFFIX="-${VERSION}"

cd "${BINARIES_DIR}"
${TOPDIR}/board/laird/mkfwtxt.sh "${LAIRD_FW_TXT_URL}"
${TOPDIR}/board/laird/mkfwusi.sh

size_check () {
	[ $(stat -c "%s" ${BINARIES_DIR}/${1}) -le $((${2}*128*1024)) ] || \
		{ echo "${1} size exceeded ${2} block limit, failed"; exit 1; }
}

[[ "${BR2_LRD_PRODUCT}" == "wb50n"* ]] && limit=38 || limit=18
size_check 'kernel.bin' ${limit}
size_check 'u-boot.bin' 3

tar -cjf "${BR2_LRD_PRODUCT}-laird${RELEASE_SUFFIX}.tar.bz2" \
	--owner=0 --group=0 --numeric-owner \
	at91bs.bin u-boot.bin kernel.bin rootfs.bin \
	fw_update fw_select fw_usi fw.txt \
	$(ls userfs.bin sqroot.bin prep_nand_for_update 2>/dev/null)

echo "COMMON POST IMAGE script: done."
