IMAGESDIR="$1"

export BR2_LRD_PLATFORM=msd45n-x86

echo "MSD45n-x86 POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

test -z "$BR2_LRD_PRODUCT" && export BR2_LRD_PRODUCT=msd45n-x86
TARFILE="$IMAGESDIR/$BR2_LRD_PRODUCT.tar"

tar cf "$TARFILE" -C "$IMAGESDIR" rootfs.tar
tar f "$TARFILE" -C "$STAGING_DIR/usr" -u include/sdc_sdk.h
tar f "$TARFILE" -C "$STAGING_DIR/usr" -u include/sdc_events.h
tar f "$TARFILE" -C "$STAGING_DIR/usr" -u include/lrd_sdk_pil.h
bzip2 -f "$TARFILE"

echo "MSD45n-x86 POST IMAGE script: done."
