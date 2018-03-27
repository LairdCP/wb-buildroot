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
atmel_pmecc_params=$BUILD_DIR/uboot-custom/tools/atmel_pmecc_params
openssl=$HOST_DIR/usr/bin/openssl

die() { echo "$@" >&2; exit 1; }
test -x $mkimage || \
	die "No mkimage found (host-uboot-tools has not been built?)"
test -x $ubinize || \
	die "no ubinize found (host-mtd has not been built?)"
test -x $mkfs_ubifs || \
	die "no mkfs_ubifs found (mkfs has not been built?)"
test -x $atmel_pmecc_params || \
	die "no atmel_pmecc_params found (uboot has not been built?)"
test -x $openssl || \
	die "no openssl found (host-openssl has not been built?)"

# Generate dev keys if needed
if [ ! -f $BINARIES_DIR/keys/dev.key ]; then
	mkdir -p $BINARIES_DIR/keys
	$openssl genrsa -out $BINARIES_DIR/keys/dev.key 2048
	$openssl req -batch -new -x509 -key $BINARIES_DIR/keys/dev.key -out $BINARIES_DIR/keys/dev.crt
fi

# Generate kernel FIT
# kernel.its references zImage and at91-dvk_som60.dtb, and all three
# files must be in current directory for mkimage.
cp $BOARD_DIR/configs/kernel.its $BINARIES_DIR/kernel.its || exit 1
echo "# entering $BINARIES_DIR for the next command"
(cd $BINARIES_DIR && $mkimage -f kernel.its kernel.itb) || exit 1
(cd $BINARIES_DIR && $mkimage -F -K u-boot.dtb -k keys kernel.itb) || exit 1
rm -f $BINARIES_DIR/kernel.its

# Re-generate u-boot FIT with Keys
rm -f $BINARIES_DIR/u-boot.itb
cp $BOARD_DIR/configs/u-boot.its $BINARIES_DIR/u-boot.its || exit 1
# First check for local keys, generate own if not
# Then update uboot dtb with keys & sign kernel
# Then build uboot FIT
echo "# entering $BINARIES_DIR for the next command"
(cd $BINARIES_DIR && $mkimage -f u-boot.its -K u-boot-spl.dtb -k keys u-boot.itb) || exit 1

# Then update SPL with appended keyed DTB
cat $BINARIES_DIR/u-boot-spl-nodtb.bin $BINARIES_DIR/u-boot-spl.dtb > $BINARIES_DIR/u-boot-spl.bin
# Regenerate Atmel PMECC boot.bin
$mkimage -T atmelimage -n $($atmel_pmecc_params) -d $BINARIES_DIR/u-boot-spl.bin $BINARIES_DIR/boot.bin




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
