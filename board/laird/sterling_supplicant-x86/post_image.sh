IMAGESDIR="$1"

export BR2_LRD_PLATFORM=sterling_supplicant-x86

echo "sterling_supplicant-x86 POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

test -z "$BR2_LRD_PRODUCT" && export BR2_LRD_PRODUCT=sterling_supplicant-x86
TARFILE="$IMAGESDIR/$BR2_LRD_PRODUCT.tar"

if [ -z "$LAIRD_RELEASE_STRING" ]; then
  LAIRD_RELEASE_STRING=$(date +%Y%m%d)
fi

# create copy of rootfs.tar with just supplicant components
# first step deletes all directories except /usr/lib and /usr/sbin
# second step deletes all remaining non-supplicant components
(cd "$IMAGESDIR"; \
 mkdir -p $BR2_LRD_PRODUCT; \
 cp rootfs.tar $BR2_LRD_PRODUCT; \
 cd $BR2_LRD_PRODUCT; \
 tar -tf rootfs.tar | \
	 egrep '/$' | \
	 egrep -v '[.]/$|[.]/usr/$|[.]/usr/lib/$|[.]/usr/sbin/$' | \
	 sort -r >todel1.txt;
 tar --file=rootfs.tar --delete `cat todel1.txt`;
 tar -tf rootfs.tar | \
	 egrep -v '/$|wpa_|libcrypto|libssl|libdbus-[1-9]' | \
	 sort -r >todel2.txt; \
 tar --file=rootfs.tar --delete `cat todel2.txt`;
 rm todel1.txt todel2.txt)

tar --transform "s,$BR2_LRD_PRODUCT,$BR2_LRD_PRODUCT-$LAIRD_RELEASE_STRING," -cf "$TARFILE" -C "$IMAGESDIR" $BR2_LRD_PRODUCT/rootfs.tar
bzip2 -f "$TARFILE"

echo "sterling_supplicant-x86 POST IMAGE script: done."
