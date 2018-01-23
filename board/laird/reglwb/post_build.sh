
export BR2_LRD_PRODUCT=reglwb

echo "REGLWB POST BUILD script: starting..."

# enable tracing and exit on errors
set -x -e

# generate manifest file
echo "/usr/bin/wl" >"$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"
echo "/lib/firmware/brcm/bcm4343w/brcmfmac43430-sdio-mfg.bin" >>"$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"
echo "/lib/firmware/brcm/bcm4343w/brcmfmac43430-sdio.bin" >>"$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"
# make sure board script is not in target directory and copy it from rootfs-additions
rm -f $TARGET_DIR/reg_tools.sh
cp board/laird/reglwb/rootfs-additions/reg_tools.sh $TARGET_DIR

echo "REGLWB POST BUILD script: done."
