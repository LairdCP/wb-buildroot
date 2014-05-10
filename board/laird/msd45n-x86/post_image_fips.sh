IMAGESDIR="$1"
export BR2_LRD_PRODUCT=msd45n-x86_fips

# enable tracing and exit on errors
set -x -e

echo "MSD45n-x86-fips POST IMAGE script: starting..."
source "board/laird/msd45n-x86/post_image.sh" "$IMAGESDIR"
echo "MSD45n-x86-fips POST BUILD script: done."
