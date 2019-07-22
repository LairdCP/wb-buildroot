BOARD_DIR="${1}"
SD=${2}

echo "COMMON POST BUILD script: starting..."

# enable tracing and exit on errors
set -x -e

# remove the resolv.conf.  Network Manager will create the appropriate file and
# link on startup.
rm -f "${TARGET_DIR}/etc/resolv.conf"

# Create default firmware description file.
# This may be overwritten by a proper release file.
LOCRELSTR="${LAIRD_RELEASE_STRING}"
if [ -z "${LOCRELSTR}" ] || [ "${LOCRELSTR}" == "0.0.0.0" ]; then
	LOCRELSTR="Laird Linux development build $(date +%Y%m%d)"
fi
echo "${LOCRELSTR}" > "${TARGET_DIR}/etc/laird-release"
echo "${LOCRELSTR}" > "${TARGET_DIR}/etc/issue"

echo -ne \
"NAME=Laird Linux\n"\
"VERSION=$LOCRELSTR\n"\
"ID=buildroot\n"\
"VERSION_ID=${LOCRELSTR##* }\n"\
"PRETTY_NAME=\"$LOCRELSTR\""\
>  "${TARGET_DIR}/usr/lib/os-release"

# Copy the product specific rootfs additions, strip host user access control
rsync -rlptDWK --exclude=.empty "${BOARD_DIR}/rootfs-additions/" "${TARGET_DIR}"

# Do not update access time in flash/card
sed -i 's/auto rw/auto,noatime rw/g' ${TARGET_DIR}/etc/fstab

# Do not run fsck for read-only file systems
awk -i inplace '{if ($6 == 1 && $4 == "ro") $6=0}; 1' ${TARGET_DIR}/etc/fstab

if [ ${SD} -eq 0 ]; then
	grep -q "/dev/mmcblk0p2" ${TARGET_DIR}/etc/fstab ||\
		echo '/dev/mmcblk0p2 swap swap defaults,noatime 0 0' >> ${TARGET_DIR}/etc/fstab

	grep -q "/dev/mmcblk0p1" ${TARGET_DIR}/etc/fstab ||\
		echo '/dev/mmcblk0p1 /boot vfat defaults,noatime 0 0' >> ${TARGET_DIR}/etc/fstab
fi

if grep -qF "BR2_PACKAGE_LRD_ENCRYPTED_STORAGE_TOOLKIT=y" ${BR2_CONFIG}; then
	# Securely mount /var on tmpfs
	grep -q "^tmpfs" ${TARGET_DIR}/etc/fstab &&
		sed -ie '/^tmpfs/ s/mode=1777 /mode=1777,noexec,nosuid,nodev,noatime /' $TARGET_DIR/etc/fstab ||
		echo "tmpfs /var tmpfs mode=1777,noexec,nosuid,nodev,noatime 0 0" >> ${TARGET_DIR}/etc/fstab
fi

mkdir -p $TARGET_DIR/etc/NetworkManager/system-connections

# Make sure connection files have proper attributes
for f in ${TARGET_DIR}/etc/NetworkManager/system-connections/* ; do
	if [ -f "${f}" ] ; then
		chmod 600 "${f}"
	fi
done

# Make sure dispatcher files have proper attributes
for f in ${TARGET_DIR}/etc/NetworkManager/dispatcher.d/* ; do
	if [ -f "${f}" ] ; then
		chmod 700 "${f}"
	fi
done
