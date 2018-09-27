TARGETDIR=$1

export BR2_LRD_PLATFORM=ig60

echo "IG60 POST BUILD script: starting..."

# source the common post build script
source "board/laird/post_build_common.sh" "$TARGETDIR"

# Remove e/n/i generated from _common
rm -f $TARGETDIR/etc/network/interfaces
rm -f $TARGETDIR/etc/network/interfaces~.gz
rm -f $TARGETDIR/etc/init.d/S95bluetooth.bg

# Correct symlink for the FW we need to load
[ -f $TARGETDIR/lib/firmware/lrdmwl/88W8997_sdio.bin ] \
&& rm -f $TARGETDIR/lib/firmware/lrdmwl/88W8997_sdio.bin \
&& ( cd "$TARGETDIR/lib/firmware/lrdmwl" \
     && ln -s 88W8997_sdio_uart_* 88W8997_sdio.bin )

# fix rootfs-additions-common to come up without any wireless adapter by default
mv $TARGETDIR/etc/init.d/S40wifi $TARGETDIR/etc/init.d/opt/

# Copy the product specific rootfs additions
tar c --exclude=.svn --exclude=.empty -C board/laird/ig60/rootfs-additions/ . | tar x -C $TARGETDIR/

# Fixup and add debugfs to fstab
grep -q "/sys/kernel/debug" $TARGETDIR/etc/fstab ||\
    echo 'nodev /sys/kernel/debug   debugfs   defaults   0  0' >> $TARGETDIR/etc/fstab

# The full / is overlayed with a ubifs store
rm -f $TARGETDIR/etc/init.d/S01bootoverlays

echo "IG60 POST BUILD script: done."
