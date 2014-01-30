IMAGESDIR="$1"
export BR2_LRD_PRODUCT=msd45n_fips

# enable tracing and exit on errors
set -x -e

echo "MSD45n-fips POST IMAGE script: starting..."
source "board/laird/msd45n/post_image.sh" "$IMAGESDIR"
echo "MSD45n-fips POST BUILD script: done."
