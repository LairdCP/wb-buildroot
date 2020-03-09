BOARD_DIR="${1}"
SD=${2}
DEVEL_KEYS="${3}"

# enable tracing and exit on errors
set -x -e

[ -z "${BR2_LRD_PRODUCT}" ] && \
	BR2_LRD_PRODUCT="$(sed -n 's,^BR2_DEFCONFIG=".*/\(.*\)_defconfig"$,\1,p' ${BR2_CONFIG})"

GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"


# Tooling checks
mkimage=${HOST_DIR}/bin/mkimage
atmel_pmecc_params=${BUILD_DIR}/uboot-custom/tools/atmel_pmecc_params
genimage=${HOST_DIR}/bin/genimage
mkenvimage=${HOST_DIR}/bin/mkenvimage
fipshmac=${HOST_DIR}/bin/fipshmac

die() { echo "$@" >&2; exit 1; }

test -x ${mkimage} || \
	die "No mkimage found (host-uboot-tools has not been built?)"
test -x ${atmel_pmecc_params} || \
	die "no atmel_pmecc_params found (uboot has not been built?)"
test -x ${genimage} || \
	die "No genimage found (host-genimage has not been built?)"
test -x ${mkenvimage} || \
	die "No mkenvimage found (host-uboot-tools has not been built?)"

# Copy the u-boot.its
cp -f ${BOARD_DIR}/configs/u-boot.its ${BINARIES_DIR}/u-boot.its

# Configure keys, boot script, and SWU tools when using encrypted toolkit
if grep -qF "BR2_PACKAGE_LRD_ENCRYPTED_STORAGE_TOOLKIT=y" ${BR2_CONFIG}; then
	# Copy dev keys if present
	if [ -f ${DEVEL_KEYS}/dev.key ]; then
		mkdir -p ${BINARIES_DIR}/keys
		cp ${DEVEL_KEYS}/* ${BINARIES_DIR}/keys/ -fr
	fi
	# Use verity boot script
	cp -f ${BOARD_DIR}/configs/boot_verity.scr ${BINARIES_DIR}/boot.scr
	# Copy scripts for SWU generation
	if [[ "${BR2_LRD_PRODUCT}" =~ ^(som60x2|ig60ll)$ ]]; then
		cp ${BOARD_DIR}/configs/sw-description-som60x2 ${BINARIES_DIR}/sw-description -fr
	else
		cp ${BOARD_DIR}/configs/sw-description ${BINARIES_DIR}/ -fr
	fi
	cp ${BOARD_DIR}/../scripts-common/erase_data.sh ${BINARIES_DIR}/ -fr
	cp ${BOARD_DIR}/configs/u-boot-env.tgz ${BINARIES_DIR}/ -fr
	# Build rootfs UBI with verity
	GENIMAGE_CFG="${BOARD_DIR}/configs/genimage_verity.cfg"
else
	# Use standard boot script
	cp -f ${BOARD_DIR}/configs/boot.scr ${BINARIES_DIR}/boot.scr
	# Build rootfs UBI without verity
	GENIMAGE_CFG="${BOARD_DIR}/configs/genimage.cfg"
fi

if (( ! ${SD} )) ; then
	cp -f ${BINARIES_DIR}/boot.scr ${BINARIES_DIR}/uboot.scr

	# Copy mksdcard.sh and mksdimg.sh to images
	cp ${BOARD_DIR}/../scripts-common/mksdcard.sh ${BINARIES_DIR}/
	cp ${BOARD_DIR}/../scripts-common/mksdimg.sh ${BINARIES_DIR}/
fi

# Generate kernel FIT image script
# kernel.its references zImage and at91-dvk_som60.dtb, and all three
# files must be in current directory for mkimage.
DTB="$(sed -n 's/^BR2_LINUX_KERNEL_INTREE_DTS_NAME="\(.*\)"$/\1/p' ${BR2_CONFIG})"
# Look for DTB in custom path
[ -z ${DTB} ] && \
	DTB="$(sed 's,BR2_LINUX_KERNEL_CUSTOM_DTS_PATH="\(.*\)",\1,; s,\s,\n,g' ${BR2_CONFIG} | sed -n 's,.*/\(.*\).dts$,\1,p')"

sed "s/at91-dvk_som60/${DTB}/g" ${BOARD_DIR}/configs/kernel.its > ${BINARIES_DIR}/kernel.its || exit 1

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
		die "FIPS Hash mismatch to the certified for ${2}"
	fi
}

if grep -qF "BR2_PACKAGE_LAIRD_OPENSSL_FIPS_BINARIES=y" ${BR2_CONFIG}; then
	hash_check ${BINARIES_DIR} ${IMAGE_NAME}
	hash_check ${TARGET_DIR}/usr/bin fipscheck
	hash_check ${TARGET_DIR}/usr/lib libfipscheck.so.1
	hash_check ${TARGET_DIR}/usr/lib libcrypto.so.1.0.0
fi

if ! grep -qF "BR2_PACKAGE_LRD_ENCRYPTED_STORAGE_TOOLKIT=y" ${BR2_CONFIG}; then
	# Generate non-secured artifacts
	echo "# entering ${BINARIES_DIR} for the next command"
	(cd ${BINARIES_DIR} && ${mkimage} -f kernel.its kernel.itb) || exit 1
	(cd "${BINARIES_DIR}" && "${mkimage}" -f u-boot.its u-boot.itb) || exit 1
	cat "${BINARIES_DIR}/u-boot-spl-nodtb.bin" "${BINARIES_DIR}/u-boot-spl.dtb" > "${BINARIES_DIR}/u-boot-spl.bin"
	if (( ${SD} )); then
		# Generate Atmel PMECC boot.bin from SPL
		${mkimage} -T atmelimage -n $(${atmel_pmecc_params}) -d ${BINARIES_DIR}/u-boot-spl.bin ${BINARIES_DIR}/boot.bin
		# Copy rootfs
		cp ${BINARIES_DIR}/rootfs.squashfs ${BINARIES_DIR}/rootfs.bin
	fi
else
	# Generate all secured artifacts (NAND, SWU packages)
	. "${BOARD_DIR}/../post_image_secure.sh" "${BOARD_DIR}" "\nu-boot-env.tgz\nerase_data.sh"
fi

size_check () {
	[ $(stat -c "%s" ${BINARIES_DIR}/${1}) -le $((${2}*128*1024)) ] || \
		{ echo "${1} size exceeded ${2} block limit, failed"; exit 1; }
}

size_check 'u-boot.bin' 7

if [ -n "${VERSION}" ]; then
	RELEASE_FILE="${BINARIES_DIR}/${BR2_LRD_PRODUCT}-laird-${VERSION}.tar"
else
	RELEASE_FILE="${BINARIES_DIR}/${BR2_LRD_PRODUCT}-laird.tar"
fi

if (( ${SD} )) ; then
	# Build the UBI
	rm -rf "${GENIMAGE_TMP}"
	${genimage}                          \
		--rootpath "${TARGET_DIR}"     \
		--tmppath "${GENIMAGE_TMP}"    \
		--inputpath "${BINARIES_DIR}"  \
		--outputpath "${BINARIES_DIR}" \
		--config "${GENIMAGE_CFG}"

	tar -C ${BINARIES_DIR} -cf ${RELEASE_FILE} \
		boot.bin u-boot.itb kernel.itb rootfs.bin

	if grep -qF "BR2_PACKAGE_LRD_ENCRYPTED_STORAGE_TOOLKIT=y" ${BR2_CONFIG}; then
		tar -C ${BINARIES_DIR} -rf ${RELEASE_FILE} \
			--owner=0 --group=0 --numeric-owner \
			pmecc.bin u-boot-spl.dtb u-boot-spl-nodtb.bin u-boot.dtb \
			u-boot-nodtb.bin u-boot.its kernel-nosig.itb sw-description \
			 ${BR2_LRD_PRODUCT}.swu

		tar -C ${HOST_DIR}/usr/bin -rf ${RELEASE_FILE} \
			--owner=0 --group=0 --numeric-owner \
			fdtget fdtput mkimage genimage
	fi

	bzip2 -f ${RELEASE_FILE}
else
	tar -C ${BINARIES_DIR} -cjf ${RELEASE_FILE}.bz2 \
		--owner=0 --group=0 --numeric-owner \
		u-boot-spl.bin u-boot.itb kernel.itb rootfs.tar mksdcard.sh mksdimg.sh
fi
