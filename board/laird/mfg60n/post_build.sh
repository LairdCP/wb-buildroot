export BR2_LRD_PRODUCT=mfg60n

# enable tracing and exit on errors
set -x -e

# generate manifest file
echo "/usr/bin/lmu" > "$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"

# make sure board script is not in target directory and copy it from rootfs-additions
rm -f $TARGET_DIR/reg_tools.sh
cp board/laird/mfg60n/rootfs-additions/reg_tools.sh $TARGET_DIR

