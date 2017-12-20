IMAGESDIR="$1"
TOPDIR="`pwd`"

echo "COMMON POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

if [ -e "$IMAGESDIR/uImage.$BR2_LRD_PLATFORM"  ]
then
	cp "$IMAGESDIR/uImage.$BR2_LRD_PLATFORM"  "$IMAGESDIR/kernel.bin"
elif [ -e "$IMAGESDIR/uImage.$BR2_LRD_PRODUCT"  ]
then
	cp "$IMAGESDIR/uImage.$BR2_LRD_PRODUCT"  "$IMAGESDIR/kernel.bin"
else
	cp "$IMAGESDIR/uImage"                    "$IMAGESDIR/kernel.bin"
fi
cp "$IMAGESDIR/rootfs.ubi"                       "$IMAGESDIR/rootfs.bin"
cp "$IMAGESDIR/at91bootstrap.bin"                "$IMAGESDIR/at91bs.bin"

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

cp board/laird/$BR2_LRD_PRODUCT/configs/sw-description "$IMAGESDIR/"
if cd "$IMAGESDIR"; then
	$TOPDIR/board/laird/sw_image_generator.sh "$IMAGESDIR"
fi


echo "COMMON POST IMAGE script: done."
