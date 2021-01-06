BUILD_TYPE="${2}"
DEVEL_KEYS="${3}"

BR2_LRD_PRODUCT="$(sed -n 's,^BR2_DEFCONFIG=".*/\(.*\)_defconfig"$,\1,p' ${BR2_CONFIG})"

echo "${BR2_LRD_PRODUCT^^} POST BUILD script: starting..."

SOM60X2_RDVK_DIR="$(realpath $(dirname $0))"
SOM60_DIR="$(realpath ${SOM60X2_RDVK_DIR}/../som60)"

. "${SOM60X2_RDVK_DIR}/../post_build_common_60.sh" "${SOM60_DIR}" "${BUILD_TYPE}" "${DEVEL_KEYS}"

rsync -rlptDWK --exclude=.empty "${SOM60X2_RDVK_DIR}/rootfs-extra/" "${TARGET_DIR}"

rm -f ${TARGET_DIR}/etc/ts.conf ${TARGET_DIR}/etc/pointercal
rm -f ${TARGET_DIR}/etc/profile.d/ts-setup.sh

echo "${BR2_LRD_PRODUCT^^} POST BUILD script: done."
