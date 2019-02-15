BOARD_DIR=$1

echo "COMMON POST BUILD script: starting..."

# enable tracing and exit on errors
set -x -e

# remove the resolv.conf.  Network Manager will create the appropriate file and
# link on startup.
rm -f $TARGET_DIR/etc/resolv.conf

# Create default firmware description file.
# This may be overwritten by a proper release file.
LOCRELSTR="$LAIRD_RELEASE_STRING"
if [ -z "$LOCRELSTR" ] || [ "$LOCRELSTR" == "0.0.0.0" ]; then
	LOCRELSTR="Laird Linux development build $(date +%Y%m%d)"
fi
echo "$LOCRELSTR" > $TARGET_DIR/etc/laird-release
echo "$LOCRELSTR" > $TARGET_DIR/etc/issue

echo -ne \
"NAME=Laird Linux\n"\
"VERSION=$LOCRELSTR\n"\
"ID=buildroot\n"\
"VERSION_ID=${LOCRELSTR##* }\n"\
"PRETTY_NAME=\"$LOCRELSTR\""\
>  $TARGET_DIR/usr/lib/os-release

# Copy the product specific rootfs additions, strip host user access control
rsync -rlptDWK --exclude=.empty "$BOARD_DIR/rootfs-additions/" "$TARGET_DIR"

# Remove MMC automount when booting from SD card
[[ $BR2_LRD_PLATFORM == *"sd" ]] || [[ $BR2_LRD_PLATFORM == *"sd_"* ]] && \
    rm -f "$TARGET_DIR/etc/udev/rules.d/91-mmcmount.rules"

mkdir -p $TARGET_DIR/etc/NetworkManager/system-connections

# Make sure connection files have proper attributes
for f in "$TARGET_DIR/etc/NetworkManager/system-connections/*" ; do
    chmod 600 $f
done
