
export BR2_LRD_PRODUCT=reg45n
export BR2_LRD_PLATFORM=msd45n

echo "REG45n POST BUILD script: starting..."

# enable tracing and exit on errors
set -x -e

# generate manifest file
echo "/usr/bin/dbgParser" > "$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"
echo "/usr/bin/athtestcmd" >> "$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"
echo "/usr/bin/wmiconfig" >> "$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"
echo "/etc/ar6kl-tools/dbgParser/include/dbglog.h" >> "$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"
echo "/etc/ar6kl-tools/dbgParser/include/dbglog_id.h" >> "$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"

# make sure board script is not in target directory and copy it from rootfs-additions
rm -f $TARGET_DIR/reg_tools.sh
cp board/laird/reg45n/rootfs-additions/reg_tools.sh $TARGET_DIR

echo "REG45n POST BUILD script: done."
