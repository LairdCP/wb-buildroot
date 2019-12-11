BR2_LRD_PRODUCT="${2}"

echo "${BR2_LRD_PRODUCT^^} POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

mkdir -p ${BINARIES_DIR}

PKGNAME=libopenssl_1_0_2

sed -n "s|^${PKGNAME},\(.*\.so\..*\)|\1|p" "${BUILD_DIR}/packages-file-list.txt" |\
     tar --transform 's|^./|target/|' -cf "${BINARIES_DIR}/${BR2_LRD_PRODUCT}.tar" -C "${TARGET_DIR}" -T -

sed -n "s|^${PKGNAME},\(.*bin/openssl\)|\1|p" "${BUILD_DIR}/packages-file-list.txt" |\
     tar --transform 's|^./|target/|' -rf "${BINARIES_DIR}/${BR2_LRD_PRODUCT}.tar" -C "${TARGET_DIR}" -T -

sed -n "s|^${PKGNAME},\(./usr/include\)|\1|p" "${BUILD_DIR}/packages-file-list-staging.txt" |\
     tar --transform 's|^./|staging/|' -rf "${BINARIES_DIR}/${BR2_LRD_PRODUCT}.tar" -C "${STAGING_DIR}" -T -

sed -n "s|^${PKGNAME},\(./usr/lib\)|\1|p" "${BUILD_DIR}/packages-file-list-staging.txt" |\
     tar --transform 's|^./|staging/|' -rf "${BINARIES_DIR}/${BR2_LRD_PRODUCT}.tar" -C "${STAGING_DIR}" -T -

sed -n "s|^openssl-fips,\(./usr/local/ssl/fips-2.0/include/openssl/fips.*\)|\1|p" "${BUILD_DIR}/packages-file-list-staging.txt" |\
     tar --transform 's|^./usr/local/ssl/fips-2.0/include|staging/usr/include|' \
        -rf "${BINARIES_DIR}/${BR2_LRD_PRODUCT}.tar" -C "${STAGING_DIR}" -T -

bzip2 -f "${BINARIES_DIR}/${BR2_LRD_PRODUCT}.tar"

if [ "${BR2_LRD_DEVEL_BUILD}" == "y" ]; then
	[ -z "${BR2_DL_DIR}" ] && \
		BR2_DL_DIR="$(sed -n 's,^BR2_DL_DIR="\(.*\)"$,\1,p' ${BR2_CONFIG})"

	if [ -n "${BR2_DL_DIR}" ]; then
		mkdir -p ${BR2_DL_DIR}/laird_openssl_fips-binaries
		cp ${BINARIES_DIR}/${BR2_LRD_PRODUCT}.tar.bz2 \
			${BR2_DL_DIR}/laird_openssl_fips-binaries/${BR2_LRD_PRODUCT}-0.${BR2_LRD_BRANCH}.0.0.tar.bz2
	fi
fi

echo "${BR2_LRD_PRODUCT^^} POST IMAGE script: done."
