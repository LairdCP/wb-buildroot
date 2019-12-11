BR2_LRD_PRODUCT="${2}"

echo "${BR2_LRD_PRODUCT^^} POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

PKGNAME=adaptive_ww

mkdir -p ${BINARIES_DIR}

sed -n "s/^${PKGNAME},//p" "${BUILD_DIR}/packages-file-list.txt" |\
     tar -cjf "${BINARIES_DIR}/${BR2_LRD_PRODUCT}.tar.bz2" -C "${TARGET_DIR}" -T -

echo "${BR2_LRD_PRODUCT^^} POST IMAGE script: done."
