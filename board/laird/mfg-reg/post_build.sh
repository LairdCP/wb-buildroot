# enable tracing and exit on errors
set -x -e

BR2_LRD_PRODUCT="$(sed -n 's,^BR2_DEFCONFIG=".*/\(.*\)_defconfig"$,\1,p' ${BR2_CONFIG})"

echo "${BR2_LRD_PRODUCT^^} POST BUILD script: starting..."

if [[ "${BR2_LRD_PRODUCT}" == mfg60* ]]; then

#lrt and other vendor mfg tools are mutually exclusive
[ -f ${TARGET_DIR}/usr/bin/lrt ] &&  exit 0

LIBEDIT=$(readlink $TARGET_DIR/usr/lib/libedit.so)
LIBEDITLRD=${LIBEDIT/libedit./libedit.lrd.}

echo "/usr/bin/lmu
/usr/bin/lru
/usr/bin/btlru
/usr/lib/${LIBEDITLRD}" \
> "${TARGET_DIR}/${BR2_LRD_PRODUCT}.manifest"

ls "${TARGET_DIR}/lib/firmware/lrdmwl/88W8997_mfg_"* | sed "s,^${TARGET_DIR},," \
	>> "${TARGET_DIR}/${BR2_LRD_PRODUCT}.manifest"

cp "${TARGET_DIR}/usr/lib/${LIBEDIT}" "${TARGET_DIR}/usr/lib/${LIBEDITLRD}"

elif [[ "${BR2_LRD_PRODUCT}" == reg50* ]]; then

echo "/usr/bin/lru
/usr/sbin/smu_cli
/usr/bin/tcmd.sh" \
> "${TARGET_DIR}/${BR2_LRD_PRODUCT}.manifest"

ls "${TARGET_DIR}/lib/firmware/ath6k/AR6004/hw3.0/utf"* | sed "s,^${TARGET_DIR},," \
	>> "${TARGET_DIR}/${BR2_LRD_PRODUCT}.manifest"

# move tcmd.sh into package and add to manifest
cp board/laird/mfg-reg/rootfs-additions/tcmd.sh ${TARGET_DIR}/usr/bin

elif [[ "${BR2_LRD_PRODUCT}" == regCypress* ]]; then

echo "/usr/bin/wl
/lib/firmware/brcm/brcmfmac4339-sdio-mfg.bin
/lib/firmware/brcm/brcmfmac4339-sdio.bin
/lib/firmware/brcm//brcmfmac43430-sdio-mfg.bin
/lib/firmware/brcm//brcmfmac43430-sdio.bin" \
> "${TARGET_DIR}/${BR2_LRD_PRODUCT}.manifest"

ln -srf ${TARGET_DIR}/lib/firmware/brcm/brcmfmac4339-sdio-mfg.bin \
	${TARGET_DIR}/lib/firmware/brcm/brcmfmac4339-sdio.bin
ln -srf ${TARGET_DIR}/lib/firmware/brcm/brcmfmac43430-sdio-mfg.bin \
	${TARGET_DIR}/lib/firmware/brcm/brcmfmac43430-sdio.bin

else
exit 1
fi

# make sure board script is not in target directory and copy it from rootfs-additions
cp board/laird/mfg-reg/rootfs-additions/reg_tools.sh ${TARGET_DIR}

echo "${BR2_LRD_PRODUCT^^} POST BUILD script: done."
