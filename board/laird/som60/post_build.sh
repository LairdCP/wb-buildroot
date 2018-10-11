TARGETDIR="$1"

export BR2_LRD_PLATFORM=som60

echo "SOM60 POST BUILD script: starting..."

# source the common post build script
source "board/laird/post_build_common_60.sh" "$TARGETDIR"

# Copy the product specific rootfs additions, strip host user access control
rsync -rlptDW --exclude=.empty "board/laird/som60/rootfs-additions/" "$TARGETDIR"

# Make sure connection files have proper attributes
for f in "$TARGETDIR/etc/NetworkManager/system-connections/*" ; do
    chmod 600 $f
done

# Correct symlink for the FW we need to load
for f in "$TARGETDIR/lib/firmware/lrdmwl/88W8997_sdio_uart_*" ; do
    ln -rsf  $f "$TARGETDIR/lib/firmware/lrdmwl/88W8997_sdio.bin"
    break
done

echo "SOM60 POST BUILD script: done."
