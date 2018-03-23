IMAGESDIR="$1"
TOPDIR="`pwd`"

export BR2_LRD_PLATFORM=som60
export BR2_LRD_PRODUCT=dvk_som60

echo "SOM60 POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

BOARD_DIR="$(dirname $0)"

# Tooling checks
mkimage=$HOST_DIR/bin/mkimage
ubinize=$HOST_DIR/sbin/ubinize
mkfs_ubifs=$HOST_DIR/usr/sbin/mkfs.ubifs

die() { echo "$@" >&2; exit 1; }
test -x $mkimage || \
	die "No mkimage found (host-uboot-tools has not been built?)"
test -x $ubinize || \
	die "no ubinize found (host-mtd has not been built?)"
test -x $mkfs_ubifs || \
	die "no mkfs_ubifs found (mkfs has not been built?)"

# Generate kernel FIT
# kernel.its references zImage and at91-dvk_som60.dtb, and all three
# files must be in current directory for mkimage.
cp $BOARD_DIR/configs/kernel.its $BINARIES_DIR/kernel.its || exit 1
echo "# entering $BINARIES_DIR for the next command"
(cd $BINARIES_DIR && $mkimage -f kernel.its kernel.itb) || exit 1
rm -f $BINARIES_DIR/kernel.its

#Create the user filesystem
$mkfs_ubifs -d $TARGET_DIR/mnt -e 0x1f000 -c 955 -m 0x800 -x lzo  -o $BINARIES_DIR/user.ubifs

#Ubinize the user and squash filesystems, requires .cfg to be present
cp $BOARD_DIR/user-ubinize.cfg $BINARIES_DIR/user-ubinize.cfg
echo "# entering $BINARIES_DIR for the next command"
(cd $BINARIES_DIR && $ubinize -o user.ubi -m 0x800 -p 0x20000 user-ubinize.cfg) || exit 1
cp $BINARIES_DIR/user.ubi $BINARIES_DIR/userfs.bin

echo "# entering $BINARIES_DIR for the next command"
cp $BOARD_DIR/squashfs-ubinize.cfg $BINARIES_DIR/squashfs-ubinize.cfg
(cd $BINARIES_DIR && $ubinize -o sqroot.ubi -m 0x800 -p 0x20000 squashfs-ubinize.cfg) || exit 1
cp $BINARIES_DIR/sqroot.ubi $BINARIES_DIR/sqroot.bin

# generate SWUpdate .swu image
cp $BOARD_DIR/configs/sw-description "$IMAGESDIR/"
if cd "$IMAGESDIR"; then
	$TOPDIR/board/laird/sw_image_generator.sh "$IMAGESDIR"
fi

echo "SOM60 POST IMAGE script: done."
