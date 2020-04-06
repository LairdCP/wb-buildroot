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
#	$SWU_FILES			Files to store in .swu
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
SWU_FILES="${2}"

# enable tracing and exit on errors
set -x -e

# Secure tooling checks
mkimage=${HOST_DIR}/bin/mkimage
atmel_pmecc_params=${BUILD_DIR}/uboot-custom/tools/atmel_pmecc_params
openssl=${HOST_DIR}/usr/bin/openssl
veritysetup=${HOST_DIR}/sbin/veritysetup

die() { echo "$@" >&2; exit 1; }

test -x ${mkimage} || \
	die "No mkimage found (host-uboot-tools has not been built?)"
test -x ${atmel_pmecc_params} || \
		die "no atmel_pmecc_params found (uboot has not been built?)"
test -x ${openssl} || \
		die "no openssl found (host-openssl has not been built?)"
test -x ${veritysetup} || \
		die "No veritysetup found (host-cryptsetup has not been built?)"

echo "# entering ${BINARIES_DIR} for this script"
cd ${BINARIES_DIR}

# Create keys if not present
if [ ! -f keys/dev.key ]; then
	${openssl} genrsa -out keys/dev.key 2048
	${openssl} req -batch -new -x509 -key keys/dev.key -out keys/dev.crt
	dd if=/dev/random of=keys/key.bin bs=64 count=1
fi

# Create unsecured_images dir and copy off unsigned images
mkdir -p unsecured_images
cp -ft unsecured_images \
	u-boot.dtb u-boot-spl.dtb u-boot-spl-nodtb.bin u-boot-nodtb.bin

# Generate the hash table for squashfs
rm -f $rootfs.verity
${veritysetup} format rootfs.squashfs rootfs.verity > rootfs.verity.header
# Get the root hash
HASH="$(awk '/Root hash:/ {print $3}' rootfs.verity.header)"
SALT="$(awk '/Salt:/ {print $2}' rootfs.verity.header)"
BLOCKS="$(awk '/Data blocks:/ {print $3}' rootfs.verity.header)"
SIZE=$((${BLOCKS} * 8))
OFFSET=$((${BLOCKS} + 1))

# Generate a combined rootfs
cat rootfs.squashfs rootfs.verity > rootfs.bin

# Generate the kernel boot script
sed -i -e "s/SALT/${SALT}/g" -e "s/HASH/${HASH}/g" -e "s/BLOCKS/${BLOCKS}/g" -e "s/SIZE/${SIZE}/g" -e "s/OFFSET/${OFFSET}/g" boot.scr

${mkimage} -f kernel.its kernel.itb
cp -f kernel.itb kernel-nosig.itb
${mkimage} -F -K u-boot.dtb -k keys -r kernel.itb
rm -f kernel.its

rm -f u-boot.itb
cp u-boot-spl.dtb u-boot-spl-key.dtb

# Update uboot dtb with keys & sign kernel
# Then build uboot FIT
# Create AES key and IV from binary keyfile
AES_KEY=$(xxd -p -l 16 keys/key.bin)
AES_IV=$(xxd -p -s 16 -l 16 keys/key.bin)

# Encrypt U-Boot and U-Boot DTB
${openssl} aes-128-cbc -e -K ${AES_KEY} -iv ${AES_IV} -in u-boot.dtb -out u-boot.dtb.enc -v
${openssl} aes-128-cbc -e -K ${AES_KEY} -iv ${AES_IV} -in u-boot-nodtb.bin -out u-boot-nodtb.bin.enc -v

[ ! -f u-boot.scr.itb ] || \
${openssl} aes-128-cbc -e -K ${AES_KEY} -iv ${AES_IV} -in u-boot.scr.itb -out u-boot.scr.itb.enc -v

# Create U-Boot FIT image (encrypted), and store key and IV in SPL
${mkimage} -f u-boot.its u-boot.itb
${mkimage} -F -K u-boot-spl-key.dtb -k keys -r -Z ${AES_KEY} -z ${AES_IV} u-boot.itb

# Create final SPL FIT with appended keyed DTB
cat u-boot-spl-nodtb.bin u-boot-spl-key.dtb > u-boot-spl.bin
rm -f u-boot-spl-key.dtb

# Generate Atmel PMECC boot.bin from SPL
${mkimage} -T atmelimage -n $(${atmel_pmecc_params}) -d u-boot-spl.bin boot.bin

# Save off the raw PMECC header
dd if=boot.bin of=pmecc.bin bs=208 count=1

# Restore unsecured components
mv -ft ./ unsecured_images/*
rm -rf unsecured_images/

[ -f sw-description ] && have_swdesc=1 || have_swdesc=0
[ -f sw-description-full ] && have_swdescf=1 || have_swdescf=0

# Embed component hashes in SWU scripts
for i in ${SWU_FILES/sw-description /}
do
	sha_value=$(sha256sum $i | awk '{print $1}')
	component_sha="@${i}.sha256"
	echo "${i}          ${sha_value}"

	[ ${have_swdesc} -eq 0 ] || \
		sed -i -e "s/${component_sha}/${sha_value}/g" sw-description

	[ ${have_swdescf} -eq 0 ] || \
		sed -i -e "s/${component_sha}/${sha_value}/g" sw-description-full

	if [ ${i} == rootfs.bin ] || [ ${i} == kernel.itb ]; then
		md5_value=$(md5sum $i | awk '{print $1}')
		component_md5sum="@${i}.md5sum"
		echo "${i}          ${md5_value}"

		[ ${have_swdesc} -eq 0 ] || \
			sed -i -e "s/${component_md5sum}/${md5_value}/g" sw-description

		[ ${have_swdescf} -eq 0 ] || \
			sed -i -e "s/${component_md5sum}/${md5_value}/g" sw-description-full
	fi
done

ALL_SWU_FILES="${SWU_FILES/sw-description/sw-description sw-description.sig}"
SWU_FILE_STR="${ALL_SWU_FILES// /\\n}"

# Generate partial SWU (no bootloaders)
if [ ${have_swdesc} -ne 0 ]; then
	${openssl} cms -sign -in sw-description -out sw-description.sig \
		-signer keys/dev.crt -inkey keys/dev.key -outform DER -nosmimecap -binary
	echo -e "${SWU_FILE_STR}" | cpio -ovL -H crc > ${BR2_LRD_PRODUCT}.swu
	rm -f sw-description.sig
fi

# Generate full SWU (with bootloaders)
if [ ${have_swdescf} -ne 0 ]; then
	[ ${have_swdesc} -eq 0 ] || cp -f sw-description sw-description.backup
	ln -rsf sw-description-full sw-description

	${openssl} cms -sign -in sw-description -out sw-description.sig \
		-signer keys/dev.crt -inkey keys/dev.key -outform DER -nosmimecap -binary
	echo -e "${SWU_FILE_STR}" | cpio -ovL -H crc > ${BR2_LRD_PRODUCT}-full.swu
	rm -f sw-description.sig

	[ ${have_swdesc} -eq 0 ] || mv -f sw-description.backup sw-description
fi

cd -

echo "${BR2_LRD_PRODUCT^^} POST IMAGE SECURE script: done."
