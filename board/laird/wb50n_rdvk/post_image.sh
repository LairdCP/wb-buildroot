BUILD_TYPE="${2}"

BR2_LRD_PRODUCT="$(sed -n 's,^BR2_DEFCONFIG=".*/\(.*\)_defconfig"$,\1,p' ${BR2_CONFIG})"

echo "${BR2_LRD_PRODUCT^^} POST IMAGE script: starting..."

# source the common post image script
. board/laird/post_image_common.sh "${BUILD_TYPE}"

sed '/^# transfer-list.*/a\  /etc/NetworkManager/system-connections' -i ${BINARIES_DIR}/fw.txt

echo "${BR2_LRD_PRODUCT^^} POST IMAGE script: done."
