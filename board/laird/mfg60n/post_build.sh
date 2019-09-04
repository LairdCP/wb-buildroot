BR2_LRD_PRODUCT="$2";

# enable tracing and exit on errors
set -x -e

#lrt and other vendor mfg tools are mutually exclusive
if [ -f $TARGET_DIR/usr/bin/lrt ]; then
	#LRT exists, no need to do further processing
	exit 0
fi

LIBEDIT=$(readlink $TARGET_DIR/usr/lib/libedit.so)
LIBEDITLRD=${LIBEDIT/libedit./libedit.lrd.}

# generate manifest file
echo "/usr/bin/lmu"   >  "$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"
echo "/usr/bin/lru"   >> "$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"
echo "/usr/bin/btlru" >> "$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"
echo "/usr/lib/$LIBEDITLRD"  >> "$TARGET_DIR/$BR2_LRD_PRODUCT.manifest"

for f in $TARGET_DIR/lib/firmware/lrdmwl/88W8997_mfg_*; do
	echo "/lib/firmware/lrdmwl/"$(basename $f) >> $TARGET_DIR/$BR2_LRD_PRODUCT.manifest
done

# make sure board script is not in target directory and copy it from rootfs-additions
rm -f $TARGET_DIR/reg_tools.sh
cp board/laird/scripts-common/reg_tools.sh $TARGET_DIR
cp "$TARGET_DIR/usr/lib/$LIBEDIT" "$TARGET_DIR/usr/lib/$LIBEDITLRD"
