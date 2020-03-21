set -x -e

BR2_LRD_PRODUCT="$(sed -n 's,^BR2_DEFCONFIG=".*/\(.*\)_defconfig"$,\1,p' ${BR2_CONFIG})"
BOARD_DIR="$(realpath $(dirname $0))"

echo "${BR2_LRD_PRODUCT^^} POST BUILD script: starting..."

# source the common post build script
source "board/laird/post_build_common.sh" "${TARGET_DIR}"

# fix rootfs-additions-common to come up without any wireless adapter by default
mv ${TARGET_DIR}/etc/init.d/S40wifi ${TARGET_DIR}/etc/init.d/opt/

# Copy the product specific rootfs additions
rsync -rlptDWK --exclude=.empty "${BOARD_DIR}/rootfs-additions/" "${TARGET_DIR}"

# Fixup and add debugfs to fstab
grep -q "/sys/kernel/debug" ${TARGET_DIR}/etc/fstab ||\
	echo 'nodev /sys/kernel/debug   debugfs   defaults   0  0' >> ${TARGET_DIR}/etc/fstab

echo "${BR2_LRD_PRODUCT^^} POST BUILD script: done."
