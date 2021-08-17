BOARD_DIR="${1}"
BUILD_TYPE="${2}"
ENCRYPTED_TOOLKIT_DIR="$(realpath ${3})"
fipshmac=${HOST_DIR}/bin/fipshmac

# enable tracing and exit on errors
set -x -e

[ -z "${BR2_LRD_PRODUCT}" ] && \
	BR2_LRD_PRODUCT="$(sed -n 's,^BR2_DEFCONFIG=".*/\(.*\)_defconfig"$,\1,p' ${BR2_CONFIG})"

echo "${BR2_LRD_PRODUCT^^} POST BUILD script: starting..."

[[ "${BUILD_TYPE}" == *sd ]] && SD=1 || SD=0

# Determine if encrypted image being built
grep -qF "BR2_PACKAGE_LRD_ENCRYPTED_STORAGE_TOOLKIT=y" ${BR2_CONFIG} \
	&& ENCRYPTED_TOOLKIT=1 || ENCRYPTED_TOOLKIT=0

# Create default firmware description file.
# This may be overwritten by a proper release file.
LOCRELSTR="${LAIRD_RELEASE_STRING}"
if [ -z "${LOCRELSTR}" ] || [ "${LOCRELSTR}" == "0.0.0.0" ]; then
	LOCRELSTR="Summit Linux development build 0.${BR2_LRD_BRANCH}.0.0 $(date +%Y%m%d)"
fi
echo "${LOCRELSTR}" > "${TARGET_DIR}/etc/issue"

[ -z "${VERSION}" ] && LOCVER="0.${BR2_LRD_BRANCH}.0.0" || LOCVER="${VERSION}"

echo -ne \
"NAME=\"Summit Linux\"\n"\
"VERSION=\"${LOCRELSTR}\"\n"\
"ID=${BR2_LRD_PRODUCT}\n"\
"VERSION_ID=${LOCVER}\n"\
"BUILD_ID=${LOCRELSTR##* }\n"\
"PRETTY_NAME=\"${LOCRELSTR}\"\n"\
>  "${TARGET_DIR}/usr/lib/os-release"

# Copy the product specific rootfs additions, strip host user access control
rsync -rlptDWK --no-perms --exclude=.empty "${BOARD_DIR}/rootfs-additions/" "${TARGET_DIR}"

# Do not update access time in flash/card
sed -i 's/auto rw/auto,noatime rw/g' ${TARGET_DIR}/etc/fstab

# Do not run fsck for read-only file systems
awk '{if ($6 == 1 && $4 == "ro") $6=0}; 1' ${TARGET_DIR}/etc/fstab > ${TARGET_DIR}/etc/fstab.tmp
mv -f ${TARGET_DIR}/etc/fstab.tmp ${TARGET_DIR}/etc/fstab

if [ ${SD} -ne 0 ]; then
	grep -q "/dev/mmcblk0p2" ${TARGET_DIR}/etc/fstab ||\
		echo '/dev/mmcblk0p2 swap swap defaults,noatime 0 0' >> ${TARGET_DIR}/etc/fstab

	grep -q "/dev/mmcblk0p1" ${TARGET_DIR}/etc/fstab ||\
		echo '/dev/mmcblk0p1 /boot vfat defaults,noatime 0 0' >> ${TARGET_DIR}/etc/fstab

	sed -i 's,^/dev/mtd,# /dev/mtd,' ${TARGET_DIR}/etc/fw_env.config
else
	sed -i 's,^/boot/,# /boot/,' ${TARGET_DIR}/etc/fw_env.config
fi

if [ ${ENCRYPTED_TOOLKIT} -ne 0 ] || [ "${BUILD_TYPE}" == ig60 ]; then
	# Securely mount /var on tmpfs
	grep -q "^tmpfs" ${TARGET_DIR}/etc/fstab &&
		sed -ie '/^tmpfs/ s/mode=1777 /mode=1777,noexec,nosuid,nodev,noatime /' ${TARGET_DIR}/etc/fstab ||
		echo "tmpfs /var tmpfs mode=1777,noexec,nosuid,nodev,noatime 0 0" >> ${TARGET_DIR}/etc/fstab
fi

# No need to detect SmartMedia cards, thus remove errors and speedup boot
rm -f ${TARGET_DIR}/usr/lib/udev/rules.d/75-probe_mtd.rules

# Fixup systemd default to avoid errors
sed -i 's/^net\.core\.default_qdisc/# net\.core\.default_qdisc/' ${TARGET_DIR}/usr/lib/sysctl.d/50-default.conf
sed -i 's/^kernel\.sysrq/# kernel\.sysrq/' ${TARGET_DIR}/usr/lib/sysctl.d/50-default.conf

mkdir -p ${TARGET_DIR}/etc/NetworkManager/system-connections

# Make sure connection files have proper attributes
for f in ${TARGET_DIR}/etc/NetworkManager/system-connections/* ; do
	if [ -f "${f}" ] ; then
		chmod 600 "${f}"
	fi
done

# Make sure dispatcher files have proper attributes
[ -d ${TARGET_DIR}/etc/NetworkManager/dispatcher.d ] && \
	find ${TARGET_DIR}/etc/NetworkManager/dispatcher.d -type f -exec chmod 700 {} \;

# Remove bluetooth support when BlueZ 5 not present
if [ ! -x ${TARGET_DIR}/usr/bin/btattach ]; then
	rm -rf ${TARGET_DIR}/etc/bluetooth
	rm -f ${TARGET_DIR}/etc/udev/rules.d/80-btattach.rules
	rm -f ${TARGET_DIR}/usr/lib/systemd/system/btattach.service
	rm -f ${TARGET_DIR}/usr/bin/bt-service.sh
fi

# Remove autoloading cryptodev module when not present
[ -n "$(find "${TARGET_DIR}/lib/modules/" -name cryptodev.ko)" ] || \
	rm -f "${TARGET_DIR}/etc/modules-load.d/cryptodev.conf"

# Clean up Python, Node cruft we don't need
rm -f "${TARGET_DIR}/usr/lib/python2.7/ensurepip/_bundled/*.whl"
rm -f "${TARGET_DIR}/usr/lib/python3.7/ensurepip/_bundled/*.whl"
rm -f "${TARGET_DIR}/usr/lib/python2.7/distutils/command/*.exe"
rm -f "${TARGET_DIR}/usr/lib/python3.7/distutils/command/*.exe"
rm -f "${TARGET_DIR}/usr/lib/python3.7/site-packages/setuptools/*.exe"
[ -d "${TARGET_DIR}/usr/lib/node_modules" ] && \
	find "${TARGET_DIR}/usr/lib/node_modules" -name '*.md' -exec rm -f {} \;
rm -rf "${TARGET_DIR}/var/www/swupdate"
rm -rf "${TARGET_DIR}/usr/share/gobject-introspection-1.0/"

if [ "${BUILD_TYPE}" != ig60 ]; then

# Path to common image files
CCONF_DIR="$(realpath board/laird/configs-common/image)"
CSCRIPT_DIR="$(realpath board/laird/scripts-common)"

# Configure keys, boot script, and SWU tools when using encrypted toolkit
if [ ${ENCRYPTED_TOOLKIT} -ne 0 ]; then
	# Copy keys if present
	if [ -f ${ENCRYPTED_TOOLKIT_DIR}/dev.key ]; then
		mkdir -p ${BINARIES_DIR}/keys
		ln -rsf ${ENCRYPTED_TOOLKIT_DIR}/dev.key ${BINARIES_DIR}/keys/dev.key
		ln -rsf ${ENCRYPTED_TOOLKIT_DIR}/dev.crt ${BINARIES_DIR}/keys/dev.crt
		ln -rsf ${ENCRYPTED_TOOLKIT_DIR}/key.bin ${BINARIES_DIR}/keys/key.bin
	fi
	# Copy the u-boot.its
	ln -rsf ${CCONF_DIR}/u-boot-enc.its ${BINARIES_DIR}/u-boot.its
	# Use verity boot script
	ln -rsf ${CCONF_DIR}/boot_verity.scr ${BINARIES_DIR}/boot.scr
else
	# Copy the u-boot.its
	ln -rsf ${CCONF_DIR}/u-boot.its ${BINARIES_DIR}/u-boot.its
	# Use standard boot script
	ln -rsf ${CCONF_DIR}/boot.scr ${BINARIES_DIR}/boot.scr
fi

if [ ${SD} -ne 0 ] ; then
	ln -rsf ${CCONF_DIR}/boot_mmc.scr ${BINARIES_DIR}/boot.scr
	ln -rsf ${CCONF_DIR}/u-boot_mmc.scr ${BINARIES_DIR}/u-boot.scr

	# Copy mksdcard.sh and mksdimg.sh to images
	ln -rsf ${CSCRIPT_DIR}/mksdcard.sh ${BINARIES_DIR}/mksdcard.sh
	ln -rsf ${CSCRIPT_DIR}/mksdimg.sh ${BINARIES_DIR}/mksdimg.sh
else
	# Copy scripts for SWU generation
	if [[ "${BUILD_TYPE}" == som60x2* ]]; then
		ln -rsf ${BOARD_DIR}/configs/sw-description-som60x2 ${BINARIES_DIR}/sw-description
	else
		ln -rsf ${BOARD_DIR}/configs/sw-description ${BINARIES_DIR}/sw-description
	fi

	ln -rsf ${CSCRIPT_DIR}/erase_data.sh ${BINARIES_DIR}/erase_data.sh
	ln -rsf ${CCONF_DIR}/u-boot-env.tgz ${BINARIES_DIR}/u-boot-env.tgz
	ln -rsf ${CCONF_DIR}/u-boot.scr ${BINARIES_DIR}/u-boot.scr
fi

ln -rsf ${CCONF_DIR}/u-boot.scr.its ${BINARIES_DIR}/u-boot.scr.its

# Generate kernel FIT image script
# kernel.its references zImage and at91-dvk_som60.dtb, and all three
# files must be in current directory for mkimage.
DTB="$(sed -n 's/^BR2_LINUX_KERNEL_INTREE_DTS_NAME="\(.*\)"$/\1/p' ${BR2_CONFIG})"
# Look for DTB in custom path
[ -n "${DTB}" ] || \
	DTB="$(sed 's,BR2_LINUX_KERNEL_CUSTOM_DTS_PATH="\(.*\)",\1,; s,\s,\n,g' ${BR2_CONFIG} | sed -n 's,.*/\(.*\).dts$,\1,p')"

sed "s/at91-dvk_som60/${DTB}/g" ${CCONF_DIR}/kernel.its > ${BINARIES_DIR}/kernel.its

fi

if grep -q 'BR2_DEFCONFIG=.*_fips_dev_.*' ${BR2_CONFIG}; then
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

	${fipshmac} -d ${TARGET_DIR}/usr/lib/fipscheck/ ${BINARIES_DIR}/${IMAGE_NAME}
	${fipshmac} -d ${TARGET_DIR}/usr/lib/fipscheck/ ${TARGET_DIR}/usr/bin/fipscheck
	${fipshmac} -d ${TARGET_DIR}/usr/lib/fipscheck/ ${TARGET_DIR}/usr/lib/libfipscheck.so.1
	${fipshmac} -d ${TARGET_DIR}/usr/lib/fipscheck/ ${TARGET_DIR}/usr/lib/libcrypto.so.1.0.0
fi

echo "${BR2_LRD_PRODUCT^^} POST BUILD script: done."
