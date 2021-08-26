SOM60X2_RDVK_DIR="$(realpath $(dirname $0))"
SOM60_DIR="$(realpath ${SOM60X2_RDVK_DIR}/../som60)"

BUILD_TYPE="${2}"
DEVEL_KEYS="${3}"

BR2_LRD_PRODUCT="$(sed -n 's,^BR2_DEFCONFIG=".*/\(.*\)_defconfig"$,\1,p' ${BR2_CONFIG})"

echo "${BR2_LRD_PRODUCT^^} POST BUILD script: starting..."

. "${SOM60X2_RDVK_DIR}/../post_build_common_60.sh" "${SOM60_DIR}" "${BUILD_TYPE}" "${DEVEL_KEYS}"

rsync -rlptDWK --no-perms --exclude=.empty "${SOM60X2_RDVK_DIR}/rootfs-additions/" "${TARGET_DIR}"

rm -f ${TARGET_DIR}/usr/lib/systemd/system/btattach.service
rm -f ${TARGET_DIR}/etc/udev/rules.d/80-btattach.rules

echo "${BR2_LRD_PRODUCT^^} POST BUILD script: done."
