IMAGESDIR="$1"

export BR2_LRD_PRODUCT=regCypress

[ ! -d "${IMAGESDIR}" ] && mkdir -p "${IMAGESDIR}"

# enable tracing and exit on errors
set -x -e

if [ -z "${LAIRD_RELEASE_STRING}" ]; then
  LAIRD_RELEASE_STRING=$(date +%Y%m%d)
fi

# insert version number
sed -i "2i#${LAIRD_RELEASE_STRING}" ${TARGET_DIR}/reg_tools.sh
sed -i "1i#${LAIRD_RELEASE_STRING}" ${TARGET_DIR}/${BR2_LRD_PRODUCT}.manifest

TARFILE="${BR2_LRD_PRODUCT}.tar.bz2"

# generate tar.bz2 to be inserted in script
tar -cjf "${IMAGESDIR}/${TARFILE}" -C ${TARGET_DIR} \
	${BR2_LRD_PRODUCT}.manifest \
	usr/bin/wl \
	lib/firmware/brcm/bcm4339/brcmfmac4339-sdio-mfg.bin \
	lib/firmware/brcm/bcm4339/brcmfmac4339-sdio.bin \
	lib/firmware/brcm/bcm4343w/brcmfmac43430-sdio-mfg.bin \
	lib/firmware/brcm/bcm4343w/brcmfmac43430-sdio.bin

# generate sha to validate package
sha256sum ${IMAGESDIR}/${TARFILE} > ${IMAGESDIR}/${BR2_LRD_PRODUCT}.sha

# generate self-extracting script and repackage tar.bz2 to contain script and sum file
cat ${TARGET_DIR}/reg_tools.sh ${IMAGESDIR}/${TARFILE} > ${IMAGESDIR}/${BR2_LRD_PRODUCT}.sh
chmod +x ${IMAGESDIR}/${BR2_LRD_PRODUCT}.sh

# remove old tarfile and recreate new one containing self-extracting script and sha file
rm ${IMAGESDIR}/${TARFILE}
tar -cjf "${IMAGESDIR}/${TARFILE}" -C ${IMAGESDIR} \
	${BR2_LRD_PRODUCT}.sh \
	${BR2_LRD_PRODUCT}.sha

echo "REGCYPRESS POST BUILD script: done."
