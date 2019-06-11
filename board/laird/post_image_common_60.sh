BOARD_DIR="${1}"
SD=${2}

# enable tracing and exit on errors
set -x -e

[ -z "${BR2_LRD_PRODUCT}" ] && \
	BR2_LRD_PRODUCT="$(sed -n 's,^BR2_DEFCONFIG=".*/\(.*\)_defconfig"$,\1,p' ${BR2_CONFIG})"

GENIMAGE_CFG="${BOARD_DIR}/configs/genimage.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

# Copy mksdcard.sh and mksdimg.sh to images
cp ${BOARD_DIR}/../scripts-common/mksdcard.sh ${BINARIES_DIR}/
cp ${BOARD_DIR}/../scripts-common/mksdimg.sh ${BINARIES_DIR}/
cp ${BOARD_DIR}/configs/uboot-env.txt ${BINARIES_DIR}/

# Tooling checks
mkimage=${HOST_DIR}/bin/mkimage
atmel_pmecc_params=${BUILD_DIR}/uboot-custom/tools/atmel_pmecc_params
openssl=${HOST_DIR}/usr/bin/openssl
genimage=${HOST_DIR}/bin/genimage
veritysetup=${HOST_DIR}/sbin/veritysetup
mkenvimage=${HOST_DIR}/bin/mkenvimage

die() { echo "$@" >&2; exit 1; }
test -x ${mkimage} || \
	die "No mkimage found (host-uboot-tools has not been built?)"
test -x ${atmel_pmecc_params} || \
	die "no atmel_pmecc_params found (uboot has not been built?)"
test -x ${openssl} || \
	die "no openssl found (host-openssl has not been built?)"
test -x ${veritysetup} || \
	die "No veritysetup found (host-cryptsetup has not been built?)"
test -x ${genimage} || \
	die "No genimage found (host-genimage has not been built?)"
test -x ${mkenvimage} || \
	die "No mkenvimage found (host-uboot-tools has not been built?)"

${mkenvimage} -s 0x20000 -o ${BINARIES_DIR}/uboot-env.bin ${BINARIES_DIR}/uboot-env.txt -r

# Generate dev keys if needed
if [ ! -f ${BINARIES_DIR}/keys/dev.key ]; then
	mkdir -p ${BINARIES_DIR}/keys
	if [ -f $BOARD_DIR/keys/dev.key ]; then
		cp ${BOARD_DIR}/keys/dev.key ${BINARIES_DIR}/keys
		cp ${BOARD_DIR}/keys/dev.crt ${BINARIES_DIR}/keys
		cp ${BOARD_DIR}/keys/key.bin ${BINARIES_DIR}/keys
	else
		${openssl} genrsa -out ${BINARIES_DIR}/keys/dev.key 2048
		${openssl} req -batch -new -x509 -key ${BINARIES_DIR}/keys/dev.key -out ${BINARIES_DIR}/keys/dev.crt
	fi
fi

# Copy the boot.scr and u-boot.its for uboot
rm -f ${BINARIES_DIR}/u-boot.itb
if ! grep -qF "BR2_PACKAGE_LRD_ENCRYPTED_STORAGE_TOOLKIT=y" ${BR2_CONFIG}; then
	cp -f ${BOARD_DIR}/configs/boot.scr ${BINARIES_DIR}/boot.scr
	cp -f ${BOARD_DIR}/configs/u-boot.its ${BINARIES_DIR}/u-boot.its || exit 1
fi
cp "${BINARIES_DIR}/u-boot-spl.dtb" "${BINARIES_DIR}/u-boot-spl-key.dtb"

if (( ${SD} )) ; then
	# Generate the hash table for squashfs
	rm -f ${BINARIES_DIR}/rootfs.verity
	${veritysetup} format ${BINARIES_DIR}/rootfs.squashfs ${BINARIES_DIR}/rootfs.verity > ${BINARIES_DIR}/rootfs.verity.header
	# Get the hash
	HASH="$(awk '/Root hash:/ {print $3}' ${BINARIES_DIR}/rootfs.verity.header)"
	SALT="$(awk '/Salt:/ {print $2}' ${BINARIES_DIR}/rootfs.verity.header)"
	BLOCKS="$(awk '/Data blocks:/ {print $3}' ${BINARIES_DIR}/rootfs.verity.header)"
	SIZE=$((${BLOCKS} * 8))
	OFFSET=$((${BLOCKS} + 1))

	# Generate a combined rootfs
	cat ${BINARIES_DIR}/rootfs.squashfs ${BINARIES_DIR}/rootfs.verity > ${BINARIES_DIR}/rootfs.bin

	# Generate the boot.scr for uboot
	sed -i -e "s/SALT/${SALT}/g" -e "s/HASH/${HASH}/g" -e "s/BLOCKS/${BLOCKS}/g" -e "s/SIZE/${SIZE}/g" -e "s/OFFSET/${OFFSET}/g" ${BINARIES_DIR}/boot.scr
fi

# Generate kernel FIT
# kernel.its references zImage and at91-dvk_som60.dtb, and all three
# files must be in current directory for mkimage.
DTB="$(sed -n 's/^BR2_LINUX_KERNEL_INTREE_DTS_NAME="\(.*\)"$/\1/p' ${BR2_CONFIG})"
# Look for DTB in custom path
[ -z ${DTB} ] && DTB="$(sed -n 's,BR2_LINUX_KERNEL_CUSTOM_DTS_PATH=".*/\(.*\).dts"$,\1,p' ${BR2_CONFIG})"

sed "s/at91-dvk_som60/${DTB}/g" ${BOARD_DIR}/configs/kernel.its > ${BINARIES_DIR}/kernel.its || exit 1

if grep -q '"Image.gz"' ${BINARIES_DIR}/kernel.its; then
	gzip -9kf ${BINARIES_DIR}/Image
elif grep -q '"Image.lzo"' ${BINARIES_DIR}/kernel.its; then
	lzop -9o ${BINARIES_DIR}/Image.lzo ${BINARIES_DIR}/Image
elif grep -q '"Image.lzma"' ${BINARIES_DIR}/kernel.its; then
	lzma -9kf ${BINARIES_DIR}/Image
fi

echo "# entering ${BINARIES_DIR} for the next command"
(cd ${BINARIES_DIR} && ${mkimage} -f kernel.its kernel.itb) || exit 1
(cd ${BINARIES_DIR} && ${mkimage} -F -K u-boot.dtb -k keys -r kernel.itb) || exit 1
rm -f ${BINARIES_DIR}/kernel.its

# First check for local keys, generate own if not
# Then update uboot dtb with keys & sign kernel
# Then build uboot FIT
if ! grep -qF "BR2_PACKAGE_LRD_ENCRYPTED_STORAGE_TOOLKIT=y" ${BR2_CONFIG}; then
	echo "# entering ${BINARIES_DIR} for the next command"
	(cd "${BINARIES_DIR}" && "${mkimage}" -f u-boot.its -K u-boot-spl-key.dtb -k keys -r u-boot.itb) || exit 1
else
	# Create AES key and IV from binary keyfile
	AES_KEY=`xxd -p -l 16 ${BINARIES_DIR}/keys/key.bin`
	AES_IV=`xxd -p -s 16 -l 16 ${BINARIES_DIR}/keys/key.bin`

	# Encrypt U-Boot and U-Boot DTB
	${openssl} aes-128-cbc -e -K ${AES_KEY} -iv ${AES_IV} -in ${BINARIES_DIR}/u-boot.dtb -out ${BINARIES_DIR}/u-boot.dtb.enc -v
	${openssl} aes-128-cbc -e -K ${AES_KEY} -iv ${AES_IV} -in ${BINARIES_DIR}/u-boot-nodtb.bin -out ${BINARIES_DIR}/u-boot-nodtb.bin.enc -v

	# Create U-Boot FIT image (encrypted), and store key and IV in SPL
	echo "# entering ${BINARIES_DIR} for the next command"
	(cd "${BINARIES_DIR}" && "${mkimage}" -f u-boot.its u-boot.itb) || exit 1
	(cd "${BINARIES_DIR}" && "${mkimage}" -F -K u-boot-spl-key.dtb -k keys -r -Z ${AES_KEY} -z ${AES_IV} u-boot.itb) || exit 1
fi

# Then update SPL with appended keyed DTB
cat "${BINARIES_DIR}/u-boot-spl-nodtb.bin" "${BINARIES_DIR}/u-boot-spl-key.dtb" > "${BINARIES_DIR}/u-boot-spl.bin"

rm -f "${BINARIES_DIR}/u-boot-spl-key.dtb"

if (( ${SD} )) ; then
	# Regenerate Atmel PMECC boot.bin
	${mkimage} -T atmelimage -n $(${atmel_pmecc_params}) -d ${BINARIES_DIR}/u-boot-spl.bin ${BINARIES_DIR}/boot.bin

	# Build the UBI
	rm -rf "${GENIMAGE_TMP}"
	${genimage}                          \
		--rootpath "${TARGET_DIR}"     \
		--tmppath "${GENIMAGE_TMP}"    \
		--inputpath "${BINARIES_DIR}"  \
		--outputpath "${BINARIES_DIR}" \
		--config "${GENIMAGE_CFG}"

	# generate SWUpdate .swu image
	cp ${BOARD_DIR}/configs/sw-description ${BINARIES_DIR}/
	( cd ${BINARIES_DIR} && \
		echo -e "sw-description\nboot.bin\nu-boot.itb\nkernel.itb\nrootfs.bin\nuboot-env.bin" |\
		cpio -ov -H crc > ${BINARIES_DIR}/${BR2_LRD_PRODUCT}.swu)
fi
