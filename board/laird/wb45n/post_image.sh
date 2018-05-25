IMAGESDIR="$1"

export BR2_LRD_PLATFORM=wb45n
export BR2_LRD_PRODUCT=wb45n

echo "WB45n POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

#Create the user filesystem
$TARGET_DIR/../host/usr/sbin/mkfs.ubifs -d $TARGET_DIR/mnt -e 0x1f000 -c 955 -m 0x800 -x lzo  -o $TARGET_DIR/../images/user.ubifs

#Ubinize the user and squash filesystems
$TARGET_DIR/../host/usr/sbin/ubinize -o $TARGET_DIR/../images/user.ubi -m 0x800 -p 0x20000 $TARGET_DIR/../../../board/laird/wb45n/user-ubinize.cfg

cp $BINARIES_DIR/user.ubi $BINARIES_DIR/userfs.bin

$TARGET_DIR/../host/usr/sbin/ubinize -o $TARGET_DIR/../images/sqroot.ubi -m 0x800 -p 0x20000 $TARGET_DIR/../../../board/laird/wb45n/squashfs-ubinize.cfg

cp $BINARIES_DIR/sqroot.ubi $BINARIES_DIR/sqroot.bin

# source the common post image script
source "board/laird/post_image_common.sh" "$IMAGESDIR"

echo "WB45n POST IMAGE script: done."
