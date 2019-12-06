IMAGESDIR="$1"
TOPDIR="`pwd`"

echo "COMMON POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

if [ -e "$IMAGESDIR/uImage.at91-$BR2_LRD_PRODUCT"  ]
then
	cp "$IMAGESDIR/uImage.at91-$BR2_LRD_PRODUCT"  "$IMAGESDIR/kernel.bin"
else
	cp "$IMAGESDIR/uImage.at91-$BR2_LRD_PLATFORM" "$IMAGESDIR/kernel.bin"
fi
cp "$IMAGESDIR/rootfs.ubi"                       "$IMAGESDIR/rootfs.bin"


if [ -e "$IMAGESDIR/at91bootstrap.bin"  ]
then
cp "$IMAGESDIR/at91bootstrap.bin"                "$IMAGESDIR/at91bs.bin"

# fw_update only needed for legacy boards which also build at91bs
cp board/laird/rootfs-additions-common/usr/sbin/fw_select "$IMAGESDIR/"
cp board/laird/rootfs-additions-common/usr/sbin/fw_update "$IMAGESDIR/"
fi

if [ -z "$LAIRD_FW_TXT_URL" ]; then
  LAIRD_FW_TXT_URL="http://`hostname`/$BR2_LRD_PRODUCT"
fi

if cd "$IMAGESDIR"; then
  $TOPDIR/board/laird/mkfwtxt.sh "$LAIRD_FW_TXT_URL"
  $TOPDIR/board/laird/mkfwusi.sh
  cd - >/dev/null
fi

( cd "$IMAGESDIR" && tar -cjf "$IMAGESDIR/$BR2_LRD_PRODUCT-laird.tar.bz2" \
	$(ls \
		at91bs.bin u-boot.bin kernel.bin rootfs.bin \
		userfs.bin sqroot.bin fw_update fw_select fw_usi fw.txt \
		prep_nand_for_update \
	2>/dev/null))

echo "COMMON POST IMAGE script: done."
