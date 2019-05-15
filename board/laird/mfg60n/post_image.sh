IMAGESDIR="$1"
BR2_LRD_PRODUCT="$2"
BR2_LRD_MFG_FW=lib/firmware/lrdmwl
BR2_LRD_LIBEDIT=usr/lib

[ ! -d "$IMAGESDIR" ] && mkdir -p "$IMAGESDIR"

# enable tracing and exit on errors
set -x -e

if [ -f $TARGET_DIR/usr/bin/lrt ]; then
	#LRT exists, no need to do further processing
	exit 0
fi

if [ -z "$LAIRD_RELEASE_STRING" ]; then
  LAIRD_RELEASE_STRING=$(date +%Y%m%d)
fi

# insert version number
sed -i "2i#$LAIRD_RELEASE_STRING" $TARGET_DIR/reg_tools.sh
mv "$TARGET_DIR/$BR2_LRD_PRODUCT.manifest" "$TARGET_DIR/$BR2_LRD_PRODUCT-$LAIRD_RELEASE_STRING.manifest"
sed -i "1i#$LAIRD_RELEASE_STRING" "$TARGET_DIR/$BR2_LRD_PRODUCT-$LAIRD_RELEASE_STRING.manifest"
LIBEDIT=$(grep -F "libedit.lrd." "$TARGET_DIR/$BR2_LRD_PRODUCT-$LAIRD_RELEASE_STRING.manifest")

TARFILE="$BR2_LRD_PRODUCT-$LAIRD_RELEASE_STRING.tar"

MFG60N_APPS="lru lmu btlru"

# generate tar.bz2 to be inserted in script
tar -cvf $IMAGESDIR/$TARFILE --directory="$TARGET_DIR/usr/bin" $MFG60N_APPS

tar --append --file="$IMAGESDIR/$TARFILE" -C "$TARGET_DIR/" "$BR2_LRD_PRODUCT-$LAIRD_RELEASE_STRING.manifest"
for f in $TARGET_DIR/lib/firmware/lrdmwl/88W8997_mfg_*; do
	tar --append --file="$IMAGESDIR/$TARFILE" -C "$TARGET_DIR/$BR2_LRD_MFG_FW" $(basename $f)
done
tar --append --file="$IMAGESDIR/$TARFILE" -C "$TARGET_DIR/$BR2_LRD_LIBEDIT" "${LIBEDIT/#*\/}"

bzip2 -f "$IMAGESDIR/$TARFILE"

# generate sha to valitage package
CURRENT_PWD=`pwd`
cd $IMAGESDIR
sha256sum "$TARFILE.bz2" > "$BR2_LRD_PRODUCT-$LAIRD_RELEASE_STRING.sha"
cd $CURRENT_PWD

# generate self-extracting script and repackage tar.bz2 to contain script and sum file
cat $TARGET_DIR/reg_tools.sh "$IMAGESDIR/$TARFILE.bz2" > "$IMAGESDIR/$BR2_LRD_PRODUCT-$LAIRD_RELEASE_STRING.sh"
chmod +x "$IMAGESDIR/$BR2_LRD_PRODUCT-$LAIRD_RELEASE_STRING.sh"

# remove old tarfile and recreate new one containing self-extracting script and sha file
rm "$IMAGESDIR/$TARFILE.bz2"
tar -cvf "$IMAGESDIR/$TARFILE" --directory="$IMAGESDIR" "$BR2_LRD_PRODUCT-$LAIRD_RELEASE_STRING.sh"
tar --append --file="$IMAGESDIR/$TARFILE" --directory="$IMAGESDIR" "$BR2_LRD_PRODUCT-$LAIRD_RELEASE_STRING.sha"

bzip2 -f "$IMAGESDIR/$TARFILE"
