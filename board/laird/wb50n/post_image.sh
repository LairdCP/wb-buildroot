IMAGESDIR="$1"
TOPDIR="`pwd`"

export BR2_LRD_PLATFORM=wb50n
export BR2_LRD_PRODUCT=wb50n

echo "WB50n POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

if cd "$IMAGESDIR"; then
	#Ubinize the squash filesystems

	$TARGET_DIR/../host/usr/sbin/ubinize -o $TARGET_DIR/../images/sqroot.ubi -m 0x800 -p 0x20000 $TARGET_DIR/../../../board/laird/wb50n/squashfs-ubinize.cfg

	cp $BINARIES_DIR/sqroot.ubi $BINARIES_DIR/sqroot.bin
fi

# source the common post image script
if cd "$TOPDIR"; then
	source "board/laird/post_image_common.sh" "$IMAGESDIR"
fi

echo "WB50n POST IMAGE script: done."
