#
# post_image_secure.sh
#
# Generate all secure NAND and SWU artifacts
#
# Inputs - must be located in BINARIES_DIR:
#
#	keys/dev.key			Kernel & SWU signing private key
#	keys/dev.crt			Kernel 7 SWU signing public key
#	keys/key.bin			U-Boot symmetric encryption key
#	boot.scr			Kernel boot script template
#	u-boot-spl.dtb			U-Boot SPL FDT
#	u-boot.its			U-Boot FIT image script
#	u-boot.dtb			U-Boot FDT
#	kernel.its			Kernel FIT image descriptor
#	zImage				Kernel
#	at91-??.dtb			Kernel FDT
#	rootfs.squashfs			RootFS
#	sw-description (optional)	Partial SWU generation script
#	sw-description-full (optional)	Full SWU generation script
#
# Secured artifacts generated in BINARIES_DIR:
#
#	boot.bin			U-Boot SPL
#	u-boot.itb			U-Boot FIT (encrypted)
#	kernel.itb			Kernel FIT (signed)
#	${BR2_LRD_PRODUCT}.swu		Partial SWU (signed)
#	${BR2_LRD_PRODUCT}-full.swu	Full SWU (signed)
#

echo "${BR2_LRD_PRODUCT^^} POST IMAGE SECURE script: starting..."

BOARD_DIR="${1}"
ADD_SWU_FILES="${2}"

# enable tracing and exit on errors
set -x -e

# Secure tooling checks
atmel_pmecc_params=${BUILD_DIR}/uboot-custom/tools/atmel_pmecc_params
openssl=${HOST_DIR}/usr/bin/openssl
veritysetup=${HOST_DIR}/sbin/veritysetup

die() { echo "$@" >&2; exit 1; }

test -x ${atmel_pmecc_params} || \
		die "no atmel_pmecc_params found (uboot has not been built?)"
test -x ${openssl} || \
		die "no openssl found (host-openssl has not been built?)"
test -x ${veritysetup} || \
		die "No veritysetup found (host-cryptsetup has not been built?)"

# Create keys if not present
if [ ! -d ${BINARIES_DIR}/keys || ! -f ${BINARIES_DIR}/keys/dev.key ]; then
	${openssl} genrsa -out ${BINARIES_DIR}/keys/dev.key 2048
	${openssl} req -batch -new -x509 -key ${BINARIES_DIR}/keys/dev.key -out ${BINARIES_DIR}/keys/dev.crt
	dd if=/dev/random of=${BINARIES_DIR}/keys/key.bin bs=64 count=1
fi

# Create unsecured_images dir and copy off unsigned images
if [ ! -d ${BINARIES_DIR}/unsecured_images ]; then
	mkdir -p ${BINARIES_DIR}/unsecured_images
fi

UNSECURED_COMPONENT=(u-boot.dtb u-boot-spl.dtb u-boot-spl-nodtb.bin u-boot-nodtb.bin)
for i in ${UNSECURED_COMPONENT[@]}
do
	cp -f ${BINARIES_DIR}/$i ${BINARIES_DIR}/unsecured_images
done

# Generate the hash table for squashfs
rm -f ${BINARIES_DIR}/rootfs.verity
${veritysetup} format ${BINARIES_DIR}/rootfs.squashfs ${BINARIES_DIR}/rootfs.verity > ${BINARIES_DIR}/rootfs.verity.header
# Get the root hash
HASH="$(awk '/Root hash:/ {print $3}' ${BINARIES_DIR}/rootfs.verity.header)"
SALT="$(awk '/Salt:/ {print $2}' ${BINARIES_DIR}/rootfs.verity.header)"
BLOCKS="$(awk '/Data blocks:/ {print $3}' ${BINARIES_DIR}/rootfs.verity.header)"
SIZE=$((${BLOCKS} * 8))
OFFSET=$((${BLOCKS} + 1))

# Generate a combined rootfs
cat ${BINARIES_DIR}/rootfs.squashfs ${BINARIES_DIR}/rootfs.verity > ${BINARIES_DIR}/rootfs.bin

# Generate the kernel boot script
sed -i -e "s/SALT/${SALT}/g" -e "s/HASH/${HASH}/g" -e "s/BLOCKS/${BLOCKS}/g" -e "s/SIZE/${SIZE}/g" -e "s/OFFSET/${OFFSET}/g" ${BINARIES_DIR}/boot.scr

echo "# entering ${BINARIES_DIR} for the next command"
(cd ${BINARIES_DIR} && ${mkimage} -f kernel.its kernel.itb) || exit 1
cp -f ${BINARIES_DIR}/kernel.itb ${BINARIES_DIR}/kernel-nosig.itb
(cd ${BINARIES_DIR} && ${mkimage} -F -K u-boot.dtb -k keys -r kernel.itb) || exit 1
rm -f ${BINARIES_DIR}/kernel.its

rm -f ${BINARIES_DIR}/u-boot.itb
cp "${BINARIES_DIR}/u-boot-spl.dtb" "${BINARIES_DIR}/u-boot-spl-key.dtb"

# Update uboot dtb with keys & sign kernel
# Then build uboot FIT
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

# Create final SPL FIT with appended keyed DTB
cat "${BINARIES_DIR}/u-boot-spl-nodtb.bin" "${BINARIES_DIR}/u-boot-spl-key.dtb" > "${BINARIES_DIR}/u-boot-spl.bin"
rm -f "${BINARIES_DIR}/u-boot-spl-key.dtb"

# Generate Atmel PMECC boot.bin from SPL
${mkimage} -T atmelimage -n $(${atmel_pmecc_params}) -d ${BINARIES_DIR}/u-boot-spl.bin ${BINARIES_DIR}/boot.bin

# Save off the raw PMECC header
dd if=${BINARIES_DIR}/boot.bin of=${BINARIES_DIR}/pmecc.bin bs=208 count=1

# Restore unsecured components
for i in ${UNSECURED_COMPONENT[@]}
do
	rm ${BINARIES_DIR}/$i
	cp -f  ${BINARIES_DIR}/unsecured_images/$i ${BINARIES_DIR}/
done
rm -rf ${BINARIES_DIR}/unsecured_images/

SWU_COMPONENT=(boot.bin u-boot.itb kernel.itb rootfs.bin)

# Embed component hashes in SWU scripts
for i in ${SWU_COMPONENT[@]}
do
	sha_value=$(sha256sum ${BINARIES_DIR}/$i | awk '{print $1}')
	component_sha="@$i.sha256"
	echo "$i          $sha_value"
	if [ -f ${BINARIES_DIR}/sw-description ]; then
		sed -i -e "s/${component_sha}/${sha_value}/g" ${BINARIES_DIR}/sw-description
	fi
	if [ -f ${BINARIES_DIR}/sw-description-full ]; then
		sed -i -e "s/${component_sha}/${sha_value}/g" ${BINARIES_DIR}/sw-description-full
	fi
	if [[ $i = "rootfs.bin" || $i = "kernel.itb" ]]; then
		md5_value=$(md5sum ${BINARIES_DIR}/$i | awk '{print $1}')
		component_md5sum="@$i.md5sum"
		echo "$i          $md5_value"
		if [ -f ${BINARIES_DIR}/sw-description ]; then
			sed -i -e "s/${component_md5sum}/${md5_value}/g" ${BINARIES_DIR}/sw-description
		fi
		if [ -f ${BINARIES_DIR}/sw-description-full ]; then
			sed -i -e "s/${component_md5sum}/${md5_value}/g" ${BINARIES_DIR}/sw-description-full
		fi
	fi
done

# Generate partial SWU (no bootloaders)
if [ -f ${BINARIES_DIR}/sw-description ]; then
	${openssl} cms -sign -in ${BINARIES_DIR}/sw-description -out ${BINARIES_DIR}/sw-description.sig \
		-signer ${BINARIES_DIR}/keys/dev.crt -inkey ${BINARIES_DIR}/keys/dev.key -outform DER -nosmimecap -binary
	( cd ${BINARIES_DIR} && \
		echo -e "sw-description\nsw-description.sig\nboot.bin\nu-boot.itb\nkernel.itb\nrootfs.bin"${ADD_SWU_FILES} |\
		cpio -ov -H crc > ${BINARIES_DIR}/${BR2_LRD_PRODUCT}.swu)
fi

# Generate full SWU (with bootloaders)
if [ -f ${BINARIES_DIR}/sw-description-full ]; then
	rm -f ${BINARIES_DIR}/sw-description ${BINARIES_DIR}/sw-description.sig
	mv ${BINARIES_DIR}/sw-description-full ${BINARIES_DIR}/sw-description
	${openssl} cms -sign -in ${BINARIES_DIR}/sw-description -out ${BINARIES_DIR}/sw-description.sig \
		-signer ${BINARIES_DIR}/keys/dev.crt -inkey ${BINARIES_DIR}/keys/dev.key -outform DER -nosmimecap -binary
	( cd ${BINARIES_DIR} && \
		echo -e "sw-description\nsw-description.sig\nboot.bin\nu-boot.itb\nkernel.itb\nrootfs.bin"${ADD_SWU_FILES} |\
		cpio -ov -H crc > ${BINARIES_DIR}/${BR2_LRD_PRODUCT}-full.swu)
fi
