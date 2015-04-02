IMAGESDIR="$1"

export BR2_LRD_PLATFORM=msd45n

echo "MSD45n POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

test -z "$BR2_LRD_PRODUCT" && export BR2_LRD_PRODUCT=msd45n
TARFILE="$IMAGESDIR/$BR2_LRD_PRODUCT.tar"

tar cf "$TARFILE" -C "$IMAGESDIR" rootfs.tar
tar f "$TARFILE" -C "$STAGING_DIR/usr" -u include/sdc_sdk.h
tar f "$TARFILE" -C "$STAGING_DIR/usr" -u include/sdc_events.h
tar f "$TARFILE" -C "$STAGING_DIR/usr" -u include/lrd_bt_sdk.h
tar f "$TARFILE" -C "$STAGING_DIR/usr" -u include/lrd_bt_errors.h
tar f "$TARFILE" -C "board/laird/wb45n" -u patches/
tar f "$TARFILE" -C "../archive" -u eventmon-1.1.2.tar.gz
bzip2 -f "$TARFILE"

echo "MSD45n POST IMAGE script: done."
