IMAGESDIR="$1"
export BR2_LRD_PRODUCT=msd50n

# enable tracing and exit on errors
set -x -e

echo "MSD50n POST IMAGE script: starting..."
source "board/laird/msd50n/post_image.sh" "$IMAGESDIR"
echo "MSD50n POST BUILD script: done."
