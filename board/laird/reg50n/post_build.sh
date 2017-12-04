
export BR2_LRD_PRODUCT=reg50n
export BR2_LRD_PLATFORM=msd50n

echo "REG50n POST BUILD script: starting..."

# enable tracing and exit on errors
set -x -e

# generate manifest file
echo "/usr/bin/dbgParser" > "$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"
echo "/usr/bin/athtestcmd" >> "$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"
echo "/usr/bin/wmiconfig" >> "$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"
echo "/etc/ar6kl-tools/dbgParser/include/dbglog.h" >> "$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"
echo "/etc/ar6kl-tools/dbgParser/include/dbglog_id.h" >> "$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"
echo "/usr/sbin/smu_cli" >> "$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"

# remove unneeded bins
rm -f $TARGET_DIR/usr/bin/sdc_cli
rm -f $TARGET_DIR/usr/bin/dhcp_injector

# make sure board script is not in target directory and copy it from rootfs-additions
rm -f $TARGET_DIR/reg_tools.sh
cp board/laird/reg50n/rootfs-additions/reg_tools.sh $TARGET_DIR

echo "REG50n POST BUILD script: done."
