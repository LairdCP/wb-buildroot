IMAGESDIR="$1"

export BR2_LRD_PLATFORM=wb50n
export BR2_LRD_PRODUCT=wb50n

echo "WB50n POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

# source the common post image script
source "board/laird/post_image_common.sh" "$IMAGESDIR"

# generate SWUpdate .swu image
cp $TOPDIR/board/laird/$BR2_LRD_PRODUCT/configs/sw-description "$IMAGESDIR/"
if cd "$IMAGESDIR"; then
	$TOPDIR/board/laird/sw_image_generator.sh "$IMAGESDIR"
fi


echo "WB50n POST IMAGE script: done."
