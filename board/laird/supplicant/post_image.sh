IMAGESDIR="$1"

BR2_LRD_PLATFORM="$2"

echo "$BR2_LRD_PLATFORM POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

[ -z "$BR2_LRD_PRODUCT" ] && export BR2_LRD_PRODUCT="$BR2_LRD_PLATFORM"
[ -z "$LAIRD_RELEASE_STRING" ] && LAIRD_RELEASE_STRING="$(date +%Y%m%d)"

[[ $BR2_LRD_PLATFORM == summit* ]] && PKGNAME=sdcsupp || PKGNAME=wpa_supplicant

sed -n "s/^$PKGNAME,//p" "${BUILD_DIR}/packages-file-list.txt" |\
     tar -cjf "$IMAGESDIR/$BR2_LRD_PRODUCT.tar.bz2" -C "$TARGET_DIR" -T -

echo "$BR2_LRD_PLATFORM POST IMAGE script: done."
