
export BR2_LRD_PRODUCT=reglwb5

echo "REGLWB5 POST BUILD script: starting..."

# enable tracing and exit on errors
set -x -e

# generate manifest file
echo "/usr/bin/wl" >"$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"
# make sure board script is not in target directory and copy it from rootfs-additions
rm -f $TARGET_DIR/reg_tools.sh
cp board/laird/reglwb/rootfs-additions/reg_tools.sh $TARGET_DIR

echo "REGLWB5 POST BUILD script: done."
