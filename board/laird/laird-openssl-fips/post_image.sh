BR2_LRD_PRODUCT="$(sed -n 's,^BR2_DEFCONFIG=".*/\(.*\)_defconfig"$,\1,p' ${BR2_CONFIG})"

echo "${BR2_LRD_PRODUCT^^} POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

mkdir -p ${BINARIES_DIR}

PKGNAME=libopenssl_1_0_2

[ -n "${VERSION}" ] && RELEASE_SUFFIX="-${VERSION}"
RELEASE_FILE="${BINARIES_DIR}/${BR2_LRD_PRODUCT}${RELEASE_SUFFIX}.tar"

sed -n "s|^${PKGNAME},\(.*\.so\..*\)|\1|p" "${BUILD_DIR}/packages-file-list.txt" |\
     tar --transform 's|^./|target/|' -cf "${RELEASE_FILE}" -C "${TARGET_DIR}" -T -

sed -n "s|^${PKGNAME},\(.*bin/openssl\)|\1|p" "${BUILD_DIR}/packages-file-list.txt" |\
     tar --transform 's|^./|target/|' -rf "${RELEASE_FILE}" -C "${TARGET_DIR}" -T -

sed -n "s|^${PKGNAME},\(.*[/]etc[/]ssl[/].*\)|\1|p" "${BUILD_DIR}/packages-file-list.txt" |\
     tar --transform 's|^./|target/|' -rf "${RELEASE_FILE}" -C "${TARGET_DIR}" -T -

sed -n "s|^${PKGNAME},\(./usr/include\)|\1|p" "${BUILD_DIR}/packages-file-list-staging.txt" |\
     tar --transform 's|^./|staging/|' -rf "${RELEASE_FILE}" -C "${STAGING_DIR}" -T -

sed -n "s|^${PKGNAME},\(./usr/lib\)|\1|p" "${BUILD_DIR}/packages-file-list-staging.txt" |\
     tar --transform 's|^./|staging/|' -rf "${RELEASE_FILE}" -C "${STAGING_DIR}" -T -

sed -n "s|^openssl-fips,\(./usr/local/ssl/fips-2.0/include/openssl/fips.*\)|\1|p" "${BUILD_DIR}/packages-file-list-staging.txt" |\
     tar --transform 's|^./usr/local/ssl/fips-2.0/include|staging/usr/include|' \
        -rf "${RELEASE_FILE}" -C "${STAGING_DIR}" -T -

bzip2 -f "${RELEASE_FILE}"

if [ "${BR2_LRD_DEVEL_BUILD}" == "y" ]; then
	[ -z "${BR2_DL_DIR}" ] && \
		BR2_DL_DIR="$(sed -n 's,^BR2_DL_DIR="\(.*\)"$,\1,p' ${BR2_CONFIG})"

	if [ -n "${BR2_DL_DIR}" ]; then
		mkdir -p ${BR2_DL_DIR}/laird_openssl_fips-binaries
		cp ${RELEASE_FILE}.bz2 \
			${BR2_DL_DIR}/laird_openssl_fips-binaries/${BR2_LRD_PRODUCT}-0.${BR2_LRD_BRANCH}.0.0.tar.bz2
	fi
fi

echo "${BR2_LRD_PRODUCT^^} POST IMAGE script: done."
