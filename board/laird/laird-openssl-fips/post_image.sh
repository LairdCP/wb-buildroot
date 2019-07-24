IMAGESDIR="$1"

BR2_LRD_PLATFORM="$2"

[ ! -d "$IMAGESDIR" ] && mkdir -p "$IMAGESDIR"

echo "$BR2_LRD_PLATFORM POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e


[ -z "$BR2_LRD_PRODUCT" ] && export BR2_LRD_PRODUCT="$BR2_LRD_PLATFORM"
[ -z "$LAIRD_RELEASE_STRING" ] && LAIRD_RELEASE_STRING="$(date +%Y%m%d)"

PKGNAME=libopenssl_1_0_2

sed -n "s/^$PKGNAME,\(.*[.]so.*\)/\1/p" "${BUILD_DIR}/packages-file-list.txt" |\
     tar --transform 's|^./|./target/|' -cf "$IMAGESDIR/$BR2_LRD_PRODUCT.tar" -C "$TARGET_DIR" -T -

sed -n "s/^$PKGNAME,\(.*bin[/]openssl\)/\1/p" "${BUILD_DIR}/packages-file-list.txt" |\
     tar --transform 's|^./|./target/|' -rf "$IMAGESDIR/$BR2_LRD_PRODUCT.tar" -C "$TARGET_DIR" -T -

sed -n "s/^$PKGNAME,//p" "${BUILD_DIR}/packages-file-list-staging.txt" |\
     tar --transform 's|^./|./staging/|' -rf "$IMAGESDIR/$BR2_LRD_PRODUCT.tar" -C "$STAGING_DIR" -T -

bzip2 -f "$IMAGESDIR/$BR2_LRD_PRODUCT.tar"

echo "$BR2_LRD_PLATFORM POST IMAGE script: done."
