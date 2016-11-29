IMAGESDIR="$1"

export BR2_LRD_PRODUCT=reg45n
export BR2_LRD_PLATFORM=msd45n

# enable tracing and exit on errors
set -x -e

if [ -z "$LAIRD_RELEASE_STRING" ]; then
  LAIRD_RELEASE_STRING=$(date +%Y%m%d)
fi

# insert version number
sed -i "2i#$LAIRD_RELEASE_STRING" $TARGET_DIR/reg_tools.sh
mv "$TARGET_DIR/$BR2_LRD_PRODUCT.manifest" "$TARGET_DIR/$BR2_LRD_PRODUCT-$LAIRD_RELEASE_STRING.manifest"
sed -i "1i#$LAIRD_RELEASE_STRING" "$TARGET_DIR/$BR2_LRD_PRODUCT-$LAIRD_RELEASE_STRING.manifest"

TARFILE="$BR2_LRD_PRODUCT-$LAIRD_RELEASE_STRING.tar"

# generate tar.bz2 to be inserted in script
tar -cvf $IMAGESDIR/$TARFILE --directory="$TARGET_DIR/usr/bin" .
tar --append --file="$IMAGESDIR/$TARFILE" -C "$TARGET_DIR/etc/ar6kl-tools/dbgParser/include/" .
tar --append --file="$IMAGESDIR/$TARFILE" -C "$TARGET_DIR/" "$BR2_LRD_PRODUCT-$LAIRD_RELEASE_STRING.manifest"
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

echo "REG45n POST BUILD script: done."
