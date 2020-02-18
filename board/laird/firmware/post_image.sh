BR2_LRD_PRODUCT=firmware

echo "${BR2_LRD_PRODUCT^^} POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

mkdir -p ${BINARIES_DIR}

FW_DIR="${TARGET_DIR}/lib/firmware"

[ -n "${VERSION}" ] && RELEASE_SUFFIX="-${VERSION}"

create_bcm4343w_firmware_archive()
{
	local DOMAIN=${1}

	local BRCM_DIR=${FW_DIR}/brcm

	ln -rsf ${FW_DIR}/regulatory_${DOMAIN}.db ${FW_DIR}/regulatory.db
	ln -rsf ${BRCM_DIR}/brcmfmac43430-sdio-${DOMAIN}.txt ${BRCM_DIR}/brcmfmac43430-sdio.txt

	(
	cd ${TARGET_DIR}
	tar -cjf "${BINARIES_DIR}/laird-lwb-${DOMAIN}-firmware${RELEASE_SUFFIX}.tar.bz2" \
		lib/firmware/brcm/BCM43430A1.hcd \
		lib/firmware/brcm/brcmfmac43430-sdio.bin \
		lib/firmware/brcm/brcmfmac43430-sdio.clm_blob \
		lib/firmware/brcm/brcmfmac43430-sdio-${DOMAIN}.txt \
		lib/firmware/brcm/brcmfmac43430-sdio-prod.bin \
		lib/firmware/brcm/brcmfmac43430-sdio.txt \
		lib/firmware/regulatory_${DOMAIN}.db lib/firmware/regulatory.db
	)
}

create_bcm4339_firmware_archive()
{
	local DOMAIN=${1}

	local BRCM_DIR=${FW_DIR}/brcm

	ln -rsf ${FW_DIR}/regulatory_${DOMAIN}.db ${FW_DIR}/regulatory.db
	ln -rsf ${BRCM_DIR}/brcmfmac4339-sdio-${DOMAIN}.txt ${BRCM_DIR}/brcmfmac4339-sdio.txt

	(
	cd ${TARGET_DIR}
	tar -cjf "${BINARIES_DIR}/laird-lwb5-${DOMAIN}-firmware${RELEASE_SUFFIX}.tar.bz2" \
		lib/firmware/brcm/BCM4335C0.hcd \
		lib/firmware/brcm/brcmfmac4339-sdio.bin \
		lib/firmware/brcm/brcmfmac4339-sdio-${DOMAIN}.txt \
		lib/firmware/brcm/brcmfmac4339-sdio-prod.bin \
		lib/firmware/brcm/brcmfmac4339-sdio.txt \
		lib/firmware/regulatory_${DOMAIN}.db lib/firmware/regulatory.db
	)
}

create_60_firmware_archive()
{
	grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_${1^^}60_${2^^}_${3^^}=y" ${BR2_CONFIG} || return

	local FW_FILE=$(basename ${FW_DIR}/lrdmwl/88W8997_${1}_${2}_${3}_*.bin)
	[ "${1}" == "SU" ] && FW_PROD=summit60 || FW_PROD=sterling60

	ln -rsf ${FW_DIR}/lrdmwl/${FW_FILE} ${FW_DIR}/lrdmwl/88W8997_${2}.bin
	ln -rsf ${FW_DIR}/regulatory_${FW_PROD}.db ${FW_DIR}/regulatory.db

	tar -cjf "${BINARIES_DIR}/laird-${FW_PROD}-firmware-${2}-${3}${RELEASE_SUFFIX}.tar.bz2" \
		-C ${TARGET_DIR} \
		--owner=0 --group=0 --numeric-owner \
		lib/firmware/lrdmwl/88W8997_${2}.bin \
		lib/firmware/lrdmwl/${FW_FILE} \
		lib/firmware/regulatory_${FW_PROD}.db lib/firmware/regulatory.db
}

create_60_firmware_archive ST sdio uart
create_60_firmware_archive ST sdio sdio
create_60_firmware_archive ST pcie uart
create_60_firmware_archive ST pcie usb
create_60_firmware_archive ST usb uart
create_60_firmware_archive ST usb usb

create_60_firmware_archive SU sdio uart
create_60_firmware_archive SU sdio sdio
create_60_firmware_archive SU pcie uart
create_60_firmware_archive SU pcie usb
create_60_firmware_archive SU usb uart
create_60_firmware_archive SU usb usb

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SOM60=y" ${BR2_CONFIG}; then
	FW_FILE=$(basename ${FW_DIR}/lrdmwl/88W8997_SOM_sdio_uart_*.bin)

	ln -rsf ${FW_DIR}/lrdmwl/${FW_FILE} ${FW_DIR}/lrdmwl/88W8997_sdio.bin
	ln -rsf ${FW_DIR}/regulatory_summit60.db ${FW_DIR}/regulatory.db

	tar -cjf "${BINARIES_DIR}/laird-som60-radio-firmware${RELEASE_SUFFIX}.tar.bz2" \
		-C ${TARGET_DIR} \
		--owner=0 --group=0 --numeric-owner \
		lib/firmware/lrdmwl/88W8997_sdio.bin \
		lib/firmware/lrdmwl/${FW_FILE} \
		lib/firmware/regulatory_summit60.db lib/firmware/regulatory.db
fi

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_BCM4343=y" ${BR2_CONFIG}; then
create_bcm4343w_firmware_archive fcc
create_bcm4343w_firmware_archive etsi
create_bcm4343w_firmware_archive jp
fi

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_BCM4339=y" ${BR2_CONFIG}; then
create_bcm4339_firmware_archive fcc
create_bcm4339_firmware_archive etsi
create_bcm4339_firmware_archive ic
create_bcm4339_firmware_archive jp
fi

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_AR6003=y" ${BR2_CONFIG}; then
ln -rsf ${FW_DIR}/regulatory_default.db ${FW_DIR}/regulatory.db
tar -cjf "${BINARIES_DIR}/laird-ath6k-6003-firmware${RELEASE_SUFFIX}.tar.bz2" \
	-C ${TARGET_DIR} \
	--owner=0 --group=0 --numeric-owner \
	lib/firmware/ath6k/AR6003 \
	lib/firmware/regulatory_default.db \
	lib/firmware/regulatory.db lib/firmware/regulatory.db.p7s
fi

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_AR6004=y" ${BR2_CONFIG}; then
ln -rsf ${FW_DIR}/regulatory_default.db ${FW_DIR}/regulatory.db
tar -cjf "${BINARIES_DIR}/laird-ath6k-6004-firmware${RELEASE_SUFFIX}.tar.bz2" \
	-C ${TARGET_DIR} \
	--owner=0 --group=0 --numeric-owner \
	lib/firmware/ath6k/AR6004 \
	lib/firmware/bluetopia \
	lib/firmware/regulatory_default.db \
	lib/firmware/regulatory.db lib/firmware/regulatory.db.p7s
fi

echo "${BR2_LRD_PRODUCT^^} POST IMAGE script: done."
