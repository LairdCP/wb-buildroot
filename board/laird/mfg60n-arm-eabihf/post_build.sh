export BR2_LRD_PRODUCT=mfg60n-arm-eabihf
export BR2_LRD_MFG_VERSION=16.205.153.252.bin

# enable tracing and exit on errors
set -x -e

LIBEDIT=$(readlink $TARGET_DIR/usr/lib/libedit.so)
LIBEDITLRD=${LIBEDIT/libedit./libedit.lrd.}

# generate manifest file
echo "/usr/bin/lmu"   >  "$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"
echo "/usr/bin/lru"   >> "$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"
echo "/usr/bin/btlru" >> "$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"
echo "/usr/lib/$LIBEDITLRD"  >> "$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"
echo "/lib/firmware/lrdmwl/88W8997_mfg_pcie_uart_v""$BR2_LRD_MFG_VERSION" >> "$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"
echo "/lib/firmware/lrdmwl/88W8997_mfg_pcie_usb_v""$BR2_LRD_MFG_VERSION"  >> "$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"
echo "/lib/firmware/lrdmwl/88W8997_mfg_sdio_sdio_v""$BR2_LRD_MFG_VERSION" >> "$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"
echo "/lib/firmware/lrdmwl/88W8997_mfg_sdio_uart_v""$BR2_LRD_MFG_VERSION" >> "$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"

# make sure board script is not in target directory and copy it from rootfs-additions
rm -f $TARGET_DIR/reg_tools.sh
cp board/laird/$BR2_LRD_PRODUCT/rootfs-additions/reg_tools.sh $TARGET_DIR
cp "$TARGET_DIR/usr/lib/$LIBEDIT" "$TARGET_DIR/usr/lib/$LIBEDITLRD"
