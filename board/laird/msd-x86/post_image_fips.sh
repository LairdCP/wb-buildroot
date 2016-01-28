IMAGESDIR="$1"
export BR2_LRD_PRODUCT=msd-x86_fips

# enable tracing and exit on errors
set -x -e

echo "MSD-x86-fips POST IMAGE script: starting..."
source "board/laird/msd-x86/post_image.sh" "$IMAGESDIR"
echo "MSD-x86-fips POST BUILD script: done."
