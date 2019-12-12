IMAGESDIR="$1"

BR2_LRD_PLATFORM=wb50n_rdvk

echo "WB50n_RDVK POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

# source the common post image script
source "board/laird/post_image_common.sh" "$IMAGESDIR"

echo "WB50n_RDVK POST IMAGE script: done."
