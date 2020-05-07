TOPDIR="${PWD}"

echo "COMMON POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

BR2_LRD_PRODUCT="$(sed -n 's,^BR2_DEFCONFIG=".*/\(.*\)_defconfig"$,\1,p' ${BR2_CONFIG})"

if grep -qF "BR2_LINUX_KERNEL_APPENDED_DTB=y" ${BR2_CONFIG}; then
ln -rsf "${BINARIES_DIR}/uImage."* "${BINARIES_DIR}/kernel.bin"
else
ln -rsf "${BINARIES_DIR}/uImage" "${BINARIES_DIR}/kernel.bin"
fi
ln -rsf "${BINARIES_DIR}/rootfs.ubi" "${BINARIES_DIR}/rootfs.bin"
ln -rsf "${BINARIES_DIR}/at91bootstrap.bin" "${BINARIES_DIR}/at91bs.bin"

ln -rsf board/laird/rootfs-additions-common/usr/sbin/fw_select "${BINARIES_DIR}/fw_select"
ln -rsf board/laird/rootfs-additions-common/usr/sbin/fw_update "${BINARIES_DIR}/fw_update"

[ -z "${LAIRD_FW_TXT_URL}" ] && \
	LAIRD_FW_TXT_URL="http://$(hostname)/${BR2_LRD_PRODUCT}"

[ -n "${VERSION}" ] && RELEASE_SUFFIX="-${VERSION}"

cd "${BINARIES_DIR}"
${TOPDIR}/board/laird/mkfwtxt.sh "${LAIRD_FW_TXT_URL}"
${TOPDIR}/board/laird/mkfwusi.sh

size_check () {
	[ $(stat -Lc "%s" ${BINARIES_DIR}/${1}) -le $((${2}*128*1024)) ] || \
		{ echo "${1} size exceeded ${2} block limit, failed"; exit 1; }
}

case "${BR2_LRD_PRODUCT}" in
	"wb50n"*) limit=38 ;;
	"wb40n"*) limit=38 ;;
	*)        limit=18 ;;
esac

size_check 'kernel.bin' ${limit}
size_check 'u-boot.bin' 3

tar -cjhf "${BR2_LRD_PRODUCT}-laird${RELEASE_SUFFIX}.tar.bz2" \
	--owner=root --group=root \
	at91bs.bin u-boot.bin kernel.bin rootfs.bin \
	fw_update fw_select fw_usi fw.txt \
	$(ls userfs.bin sqroot.bin prep_nand_for_update 2>/dev/null)

echo "COMMON POST IMAGE script: done."
