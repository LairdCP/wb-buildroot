BR2_LRD_PLATFORM=wb45n

echo "${BR2_LRD_PLATFORM^^} POST BUILD script: starting..."

# source the common post build script
source "board/laird/post_build_common_legacy.sh" "${TARGET_DIR}"

# Copy the product specific rootfs additions
tar c --exclude=.svn --exclude=.empty -C board/laird/wb45n/rootfs-additions/ . | tar x -C ${TARGET_DIR}/

# create a compressed backup copy of the /e/n/i file
gzip -c ${TARGET_DIR}/etc/network/interfaces >${TARGET_DIR}/etc/network/interfaces~.gz

# Services to enable or disable by default
#chmod a+x ${TARGET_DIR}/etc/init.d/S??lighttpd

# Remove the custom bluetooth init-script if bluez utility is not included
[ -x ${TARGET_DIR}/usr/sbin/hciconfig ] || rm -f /etc/init.d/opt/S??bluetooth

# Fixup and add debugfs to fstab
grep -q "/sys/kernel/debug" ${TARGET_DIR}/etc/fstab ||\
	echo 'nodev /sys/kernel/debug   debugfs   defaults   0  0' >> ${TARGET_DIR}/etc/fstab

echo "${BR2_LRD_PLATFORM^^} POST BUILD script: done."
