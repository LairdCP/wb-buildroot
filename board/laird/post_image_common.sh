IMAGESDIR="$1"
TOPDIR="`pwd`"

echo "COMMON POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

cp "$IMAGESDIR/uImage"                "$IMAGESDIR/kernel.bin"
cp "$IMAGESDIR/rootfs.ubi"            "$IMAGESDIR/rootfs.bin"
cp "$IMAGESDIR/at91bootstrap.bin"    "$IMAGESDIR/at91bs.bin"

cp board/laird/rootfs-additions-common/usr/sbin/fw_select "$IMAGESDIR/"
cp board/laird/rootfs-additions-common/usr/sbin/fw_update "$IMAGESDIR/"

if [ -z "$LAIRD_FW_TXT_URL" ]; then
  LAIRD_FW_TXT_URL="http://`hostname`/$BR2_LRD_PRODUCT"
fi

if cd "$IMAGESDIR"; then
  $TOPDIR/board/laird/mkfwtxt.sh "$LAIRD_FW_TXT_URL"
  $TOPDIR/board/laird/mkfwusi.sh
  cd - >/dev/null
fi
echo "COMMON POST IMAGE script: done."
