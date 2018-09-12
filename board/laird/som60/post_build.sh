TARGETDIR=$1

export BR2_LRD_PLATFORM=som60

echo "SOM60 POST BUILD script: starting..."

# source the common post build script
source "board/laird/post_build_common_60.sh" "$TARGETDIR"

# Copy the product specific rootfs additions
tar c --exclude=.empty -C board/laird/som60/rootfs-additions/ . | tar x -C $TARGETDIR/

# Correct symlink for the FW we need to load
[ -f $TARGETDIR/lib/firmware/lrdmwl/88W8997_sdio.bin ] \
&& rm -f $TARGETDIR/lib/firmware/lrdmwl/88W8997_sdio.bin \
&& ( cd "$TARGETDIR/lib/firmware/lrdmwl" \
     && ln -s 88W8997_sdio_uart_* 88W8997_sdio.bin )

echo "SOM60 POST BUILD script: done."
