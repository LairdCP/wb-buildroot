TARGETDIR=$1

export BR2_LRD_PLATFORM=wb45n

echo "WB45n POST BUILD script: starting..."

# source the common post build script
source "board/laird/post_build_common_legacy.sh" "$TARGETDIR"

# Copy the product specific rootfs additions
tar c --exclude=.svn --exclude=.empty -C board/laird/wb45n/rootfs-additions/ . | tar x -C $TARGETDIR/

# create a compressed backup copy of the /e/n/i file
gzip -c $TARGETDIR/etc/network/interfaces >$TARGETDIR/etc/network/interfaces~.gz

# Services to enable or disable by default
chmod a+x $TARGETDIR/etc/init.d/S??lighttpd

# Remove the custom bluetooth init-script if bluez utility is not included
[ -x $TARGETDIR/usr/sbin/hciconfig ] || rm -f /etc/init.d/opt/S??bluetooth

# Fixup and add debugfs to fstab
grep -q "/sys/kernel/debug" $TARGETDIR/etc/fstab ||\
	echo 'nodev /sys/kernel/debug   debugfs   defaults   0  0' >> $TARGETDIR/etc/fstab

echo "WB45n POST BUILD script: done."
