IMAGESDIR="${1}"

BR2_LRD_PLATFORM="${2}"

[ ! -d "${IMAGESDIR}" ] && mkdir -p "${IMAGESDIR}"

echo "${BR2_LRD_PLATFORM} POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

[ -z "${BR2_LRD_PRODUCT}" ] && export BR2_LRD_PRODUCT="${BR2_LRD_PLATFORM}"
[ -z "${LAIRD_RELEASE_STRING}" ] && LAIRD_RELEASE_STRING="$(date +%Y%m%d)"

if [[ ${BR2_LRD_PLATFORM} == *legacy* ]]; then
	PKGNAME="(sdcsupp|sdccli|sdcsdk)"
elif [[ ${BR2_LRD_PLATFORM} == summit* ]]; then
	PKGNAME=sdcsupp
else
	PKGNAME=wpa_supplicant
fi

sed -nE "s/^${PKGNAME},\.\///p" "${BUILD_DIR}/packages-file-list.txt" |\
	tar -cf "${IMAGESDIR}/${BR2_LRD_PRODUCT}.tar" -C "${TARGET_DIR}" -T -

if [[ ${BR2_LRD_PLATFORM} == *legacy* ]]; then
	tar -uf "${IMAGESDIR}/${BR2_LRD_PRODUCT}.tar" -C "${STAGING_DIR}" \
		usr/include/sdc_sdk.h \
		usr/include/sdc_events.h \
		usr/include/lrd_sdk_pil.h \
		usr/include/lrd_sdk_eni.h \
		usr/lib/libsdc_sdk.so
fi

bzip2 -f "${IMAGESDIR}/${BR2_LRD_PRODUCT}.tar"

echo "${BR2_LRD_PLATFORM} POST IMAGE script: done."
