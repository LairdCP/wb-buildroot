BR2_LRD_PRODUCT="$(sed -n 's,^BR2_DEFCONFIG=".*/\(.*\)_defconfig"$,\1,p' ${BR2_CONFIG})"

echo "${BR2_LRD_PRODUCT^^} POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

PKGNAME=adaptive_ww

mkdir -p ${BINARIES_DIR}

[ -n "${VERSION}" ] && RELEASE_SUFFIX="-${VERSION}"

sed -n "s|^${PKGNAME},\./||p" "${BUILD_DIR}/packages-file-list.txt" |\
	tar -cjf "${BINARIES_DIR}/${BR2_LRD_PRODUCT}${RELEASE_SUFFIX}.tar.bz2" \
		--owner=0 --group=0 --numeric-owner \
		-C "${TARGET_DIR}" -T -

echo "${BR2_LRD_PRODUCT^^} POST IMAGE script: done."
