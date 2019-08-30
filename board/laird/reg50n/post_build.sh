
export BR2_LRD_PRODUCT=reg50n
export BR2_LRD_PLATFORM=msd50n

echo "REG50n POST BUILD script: starting..."

# enable tracing and exit on errors
set -x -e

# generate manifest file
echo "/usr/bin/athtestcmd" > "$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"
echo "/usr/sbin/smu_cli" >> "$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"

for f in $TARGET_DIR/lib/firmware/ath6k/AR6004/hw3.0/utf*; do
	echo "/lib/firmware/ath6k/AR6004/hw3.0/"$(basename $f) >> $TARGET_DIR/$BR2_LRD_PRODUCT.manifest
done


# move tcmd.sh into package and add to manifest
cp board/laird/reg50n/rootfs-additions/tcmd.sh $TARGET_DIR/usr/bin
echo "/usr/bin/tcmd.sh" >> "$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"

# make sure board script is not in target directory and copy it from rootfs-additions
rm -f $TARGET_DIR/reg_tools.sh
cp board/laird/reg50n/rootfs-additions/reg_tools.sh $TARGET_DIR

echo "REG50n POST BUILD script: done."
