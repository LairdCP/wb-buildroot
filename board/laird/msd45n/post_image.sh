IMAGESDIR="$1"

export BR2_LRD_PLATFORM=msd45n

echo "MSD45n POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

test -z "$BR2_LRD_PRODUCT" && export BR2_LRD_PRODUCT=msd45n
TARFILE="$IMAGESDIR/$BR2_LRD_PRODUCT.tar"

if [ -z "$LAIRD_RELEASE_STRING" ]; then
  LAIRD_RELEASE_STRING=$(date +%Y%m%d)
fi

tar --transform "s,^,$BR2_LRD_PRODUCT-$LAIRD_RELEASE_STRING/," -cf "$TARFILE" -C "$IMAGESDIR" rootfs.tar
tar --transform "s,^,$BR2_LRD_PRODUCT-$LAIRD_RELEASE_STRING/," -f "$TARFILE" -C "$STAGING_DIR/usr" -u include/sdc_sdk.h
tar --transform "s,^,$BR2_LRD_PRODUCT-$LAIRD_RELEASE_STRING/," -f "$TARFILE" -C "$STAGING_DIR/usr" -u include/sdc_events.h
tar --transform "s,^,$BR2_LRD_PRODUCT-$LAIRD_RELEASE_STRING/," -f "$TARFILE" -C "$STAGING_DIR/usr" -u include/lrd_sdk_pil.h
tar --transform "s,^,$BR2_LRD_PRODUCT-$LAIRD_RELEASE_STRING/," -f "$TARFILE" -C "$STAGING_DIR/usr" -u include/lrd_sdk_eni.h
bzip2 -f "$TARFILE"

echo "MSD45n POST IMAGE script: done."
