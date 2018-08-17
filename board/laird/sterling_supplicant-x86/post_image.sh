IMAGESDIR="$1"

export BR2_LRD_PLATFORM=sterling_supplicant-x86

echo "$BR2_LRD_PLATFORM POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

test -z "$BR2_LRD_PRODUCT" && export BR2_LRD_PRODUCT=$BR2_LRD_PLATFORM
TARFILE="$IMAGESDIR/$BR2_LRD_PRODUCT.tar"

if [ -z "$LAIRD_RELEASE_STRING" ]; then
  LAIRD_RELEASE_STRING=$(date +%Y%m%d)
fi

(cd "$IMAGESDIR"; \
 mkdir -p tmp_$BR2_LRD_PRODUCT; \
 tar -tf rootfs.tar | egrep 'bin[/]wpa_' > tokeep.txt; \
 tar -xf rootfs.tar -C tmp_$BR2_LRD_PRODUCT $(cat tokeep.txt); \
 tar --transform "s,tmp_$BR2_LRD_PRODUCT,$BR2_LRD_PRODUCT-$LAIRD_RELEASE_STRING," -cf "$TARFILE" tmp_$BR2_LRD_PRODUCT; \
 rm -fr tokeep.txt tmp_$BR2_LRD_PRODUCT; \
)

bzip2 -f "$TARFILE"

echo "$BR2_LRD_PLATFORM POST IMAGE script: done."
