BR2_LRD_PRODUCT="$(sed -n 's,^BR2_DEFCONFIG=".*/\(.*\)_defconfig"$,\1,p' ${BR2_CONFIG})"
SOM60X2_RDVK_DIR="$(realpath $(dirname $0))"
SOM60_DIR="$(realpath ${SOM60X2_RDVK_DIR}/../som60)"
BUILD_TYPE="${2}"
DEVEL_KEYS="${3}"

echo "${BR2_LRD_PRODUCT^^} POST BUILD script: starting..."

. "${SOM60X2_RDVK_DIR}/../post_build_common_60.sh" "${SOM60_DIR}" "${BUILD_TYPE}" "${DEVEL_KEYS}"

rsync -rlptDWK --exclude=.empty "${SOM60X2_RDVK_DIR}/rootfs-extra/" "${TARGET_DIR}"

rm ${TARGET_DIR}/usr/lib/systemd/system/btattach.service
rm ${TARGET_DIR}/etc/ts.conf ${TARGET_DIR}/etc/pointercal
rm ${TARGET_DIR}/etc/udev/rules.d/80-btattach.rules
rm ${TARGET_DIR}/etc/profile.d/ts-setup.sh

echo "${BR2_LRD_PRODUCT^^} POST BUILD script: done."
