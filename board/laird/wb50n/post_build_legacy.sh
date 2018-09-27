TARGETDIR=$1

export BR2_LRD_PLATFORM=wb50n

echo "WB50n POST BUILD legacy script: starting..."

# source the common post build legacy script
source "board/laird/post_build_common_legacy.sh" "$TARGETDIR"

# Copy the product specific rootfs additions
tar c --exclude=.svn --exclude=.empty -C board/laird/wb50n/rootfs-additions/ . | tar x -C $TARGETDIR/

# create a compressed backup copy of the /e/n/i file
gzip -c $TARGETDIR/etc/network/interfaces >$TARGETDIR/etc/network/interfaces~.gz

# Services to enable or disable by default
chmod a+x $TARGETDIR/etc/init.d/S??lighttpd

# Fixup and add debugfs to fstab
grep -q "/sys/kernel/debug" $TARGETDIR/etc/fstab ||\
	echo 'nodev /sys/kernel/debug   debugfs   defaults   0  0' >> $TARGETDIR/etc/fstab

echo "WB50n POST BUILD script: done."
