set -x -e
TARGETDIR=$1

export BR2_LRD_PLATFORM=wb50n
echo "WB50n_RDVK POST BUILD script: starting..."

# source the common post build script
source "board/laird/post_build_common.sh" "$TARGETDIR"

# fix rootfs-additions-common to come up without any wireless adapter by default
mv $TARGETDIR/etc/init.d/S40wifi $TARGETDIR/etc/init.d/opt/

# Copy the product specific rootfs additions
tar c --exclude=.svn --exclude=.empty -C board/laird/wb50n_rdvk/rootfs-additions/ . | tar x -C $TARGETDIR/

# Fixup and add debugfs to fstab
echo 'nodev /sys/kernel/debug   debugfs   defaults   0  0' >> $TARGETDIR/etc/fstab

echo "WB50n RDVK POST BUILD script: done."
