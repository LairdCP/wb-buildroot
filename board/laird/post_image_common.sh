BUILD_TYPE="${1}"

echo "COMMON POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

[ -z "${BR2_LRD_PRODUCT}" ] && \
	BR2_LRD_PRODUCT="$(sed -n 's,^BR2_DEFCONFIG=".*/\(.*\)_defconfig"$,\1,p' ${BR2_CONFIG})"

if grep -qF "BR2_LINUX_KERNEL_IMAGE_TARGET_CUSTOM=y" ${BR2_CONFIG}; then

# Tooling checks
mkimage=${HOST_DIR}/bin/mkimage
fipshmac=${HOST_DIR}/bin/fipshmac

test -x ${mkimage} || \
	die "No mkimage found (host-uboot-tools has not been built?)"

IMAGE_NAME=Image

if grep -q '"Image.gz"' ${BINARIES_DIR}/kernel.its; then
	gzip -9kfn ${BINARIES_DIR}/Image
	IMAGE_NAME+=.gz
elif grep -q '"Image.lzo"' ${BINARIES_DIR}/kernel.its; then
	lzop -9on ${BINARIES_DIR}/Image.lzo ${BINARIES_DIR}/Image
	IMAGE_NAME+=.lzo
elif grep -q '"Image.lzma"' ${BINARIES_DIR}/kernel.its; then
	lzma -9kf ${BINARIES_DIR}/Image
	IMAGE_NAME+=.lzma
fi

hash_check() {
	${fipshmac} ${1}/${2}
	if [ "$(cat ${1}/.${2}.hmac)" == "$(cat ${TARGET_DIR}/usr/lib/fipscheck/${2}.hmac)" ]; then
		rm ${1}/.${2}.hmac
	else
		rm ${1}/.${2}.hmac
		echo "FIPS Hash mismatch to the certified for ${2}"
		exit 1
	fi
}

if grep -qF "BR2_PACKAGE_LAIRD_OPENSSL_FIPS_BINARIES=y" ${BR2_CONFIG}; then
	hash_check ${BINARIES_DIR} ${IMAGE_NAME}
	hash_check ${TARGET_DIR}/usr/bin fipscheck
	hash_check ${TARGET_DIR}/usr/lib libfipscheck.so.1
	hash_check ${TARGET_DIR}/usr/lib libcrypto.so.1.0.0
fi

ln -rsf "${BINARIES_DIR}/kernel.itb" "${BINARIES_DIR}/kernel.bin"

(cd "${BINARIES_DIR}" && ${mkimage} -f kernel.its kernel.itb)

else

ln -rsf "${BINARIES_DIR}/uImage"* "${BINARIES_DIR}/kernel.bin"

fi

ln -rsf board/laird/rootfs-additions-common/usr/sbin/fw_select "${BINARIES_DIR}/fw_select"
ln -rsf board/laird/rootfs-additions-common/usr/sbin/fw_update "${BINARIES_DIR}/fw_update"
ln -rsf "${BINARIES_DIR}/boot.bin" "${BINARIES_DIR}/at91bs.bin"
ln -rsf "${BINARIES_DIR}/rootfs.ubi" "${BINARIES_DIR}/rootfs.bin"

[ -z "${LAIRD_FW_TXT_URL}" ] && \
	LAIRD_FW_TXT_URL="http://$(hostname)/${BR2_LRD_PRODUCT}"

board/laird/mkfwtxt.sh "${LAIRD_FW_TXT_URL}" "${BINARIES_DIR}"
board/laird/mkfwusi.sh

size_check () {
	[ $(stat -Lc "%s" ${BINARIES_DIR}/${1}) -le $((${2}*128*1024)) ] || \
		{ echo "${1} size exceeded ${2} block limit, failed"; exit 1; }
}

case "${BUILD_TYPE}" in
	"wb50n") limit=38 ;;
	"wb45n") limit=18 ;;
	"wb40n") limit=38 ;;
	*)       exit 1   ;;
esac

size_check 'kernel.bin' ${limit}
size_check 'u-boot.bin' 3

[ -n "${VERSION}" ] && RELEASE_SUFFIX="-${VERSION}"

tar -cjhf "${BINARIES_DIR}/${BR2_LRD_PRODUCT}-laird${RELEASE_SUFFIX}.tar.bz2" \
	--owner=root --group=root -C "${BINARIES_DIR}" \
	at91bs.bin u-boot.bin kernel.bin rootfs.bin \
	fw_update fw_select fw_usi fw.txt

echo "COMMON POST IMAGE script: done."
