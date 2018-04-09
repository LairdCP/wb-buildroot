TARGETDIR=$1

export BR2_LRD_PLATFORM=som60

echo "SOM60 POST BUILD script: starting..."

# source the common post build script
source "board/laird/post_build_common.sh" "$TARGETDIR"

# Copy the product specific rootfs additions
tar c --exclude=.empty -C board/laird/som60/rootfs-additions/ . | tar x -C $TARGETDIR/

# Remove e/n/i generated from _common
rm -f $TARGETDIR/etc/network/interfaces
rm -f $TARGETDIR/etc/network/interfaces~.gz

# Services to enable or disable by default
chmod a+x $TARGETDIR/etc/init.d/S??lighttpd

# Correct symlink for the FW we need to load
[ -f $TARGETDIR/lib/firmware/lrdmwl/88W8997_sdio.bin ] \
&& rm -f $TARGETDIR/lib/firmware/lrdmwl/88W8997_sdio.bin \
&& ( cd "$TARGETDIR/lib/firmware/lrdmwl" \
     && ln -s 88W8997_sdio_uart_* 88W8997_sdio.bin )

# Fixup and add debugfs to fstab
echo 'nodev /sys/kernel/debug   debugfs   defaults   0  0' >> $TARGETDIR/etc/fstab

# The full / is overlayed with a ubifs store
rm -f $TARGETDIR/etc/init.d/S01bootoverlays

echo "SOM60 POST BUILD script: done."
