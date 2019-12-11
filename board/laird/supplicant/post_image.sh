BR2_LRD_PRODUCT="${2}"

echo "${BR2_LRD_PRODUCT^^} POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

mkdir -p ${BINARIES_DIR}

if [[ ${BR2_LRD_PRODUCT} == *legacy* ]]; then
	PKGNAME="(sdcsupp|sdccli|sdcsdk)"
elif [[ ${BR2_LRD_PRODUCT} == summit* ]]; then
	PKGNAME=sdcsupp
else
	PKGNAME=wpa_supplicant
fi

sed -nE "s/^${PKGNAME},\.\///p" "${BUILD_DIR}/packages-file-list.txt" |\
	tar -cf "${BINARIES_DIR}/${BR2_LRD_PRODUCT}.tar" -C "${TARGET_DIR}" -T -

if [[ ${BR2_LRD_PRODUCT} == *legacy* ]]; then
	tar -uf "${BINARIES_DIR}/${BR2_LRD_PRODUCT}.tar" -C "${STAGING_DIR}" \
		usr/include/sdc_sdk.h \
		usr/include/sdc_events.h \
		usr/include/lrd_sdk_pil.h \
		usr/include/lrd_sdk_eni.h \
		usr/lib/libsdc_sdk.so
fi

bzip2 -f "${BINARIES_DIR}/${BR2_LRD_PRODUCT}.tar"

echo "${BR2_LRD_PRODUCT^^} POST IMAGE script: done."
