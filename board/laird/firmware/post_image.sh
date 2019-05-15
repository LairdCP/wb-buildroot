IMAGESDIR="$1"

export BR2_LRD_PLATFORM=laird-radio-firmware
export FW_DIR="$TARGET_DIR/lib/firmware"

[ ! -d "$IMAGESDIR" ] && mkdir -p "$IMAGESDIR"

echo "$BR2_LRD_PLATFORM POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

[ -z "$LAIRD_RELEASE_STRING" ] && LAIRD_RELEASE_STRING="$(date +%Y%m%d)"

create_bcm4343w_firmware_zipfile()
{
	DOMAIN=$1
	FIRMWARE=$2

	ln -rsf $FW_DIR/regulatory_$DOMAIN.db $FW_DIR/regulatory.db;
	ln -rsf $FW_DIR/brcm/bcm4343w/brcmfmac43430-sdio-prod.bin $FW_DIR/brcm/bcm4343w/brcmfmac43430-sdio.bin;
	ln -rsf $FW_DIR/brcm/bcm4343w/brcmfmac43430-sdio-$DOMAIN.txt $FW_DIR/brcm/bcm4343w/brcmfmac43430-sdio.txt;
	cd $FW_DIR/brcm/; ln -sf bcm4343w/brcmfmac43430-sdio.bin brcmfmac43430-sdio.bin; cd -;
	ln -rsf $FW_DIR/brcm/bcm4343w/brcmfmac43430-sdio-$DOMAIN.txt $FW_DIR/brcm/brcmfmac43430-sdio.txt;
	ln -rsf $FW_DIR/brcm/bcm4343w/brcmfmac43430-sdio.clm_blob $FW_DIR/brcm/brcmfmac43430-sdio.clm_blob;
	ln -rsf $FW_DIR/brcm/bcm4343w/4343w.hcd $FW_DIR/brcm/4343w.hcd;

	tar -cjf "$IMAGESDIR/$FIRMWARE.tar.bz2" \
	./lib/firmware/brcm/bcm4343w/brcmfmac43430-sdio-prod.bin \
	./lib/firmware/brcm/bcm4343w/brcmfmac43430-sdio.bin \
	./lib/firmware/brcm/bcm4343w/brcmfmac43430-sdio.txt \
	./lib/firmware/brcm/bcm4343w/brcmfmac43430-sdio-$DOMAIN.txt \
	./lib/firmware/brcm/bcm4343w/brcmfmac43430-sdio.clm_blob \
	./lib/firmware/brcm/bcm4343w/4343w.hcd	\
	./lib/firmware/brcm/brcmfmac43430-sdio.bin \
	./lib/firmware/brcm/brcmfmac43430-sdio.txt \
	./lib/firmware/brcm/brcmfmac43430-sdio.clm_blob \
	./lib/firmware/brcm/4343w.hcd	\
	./lib/firmware/regulatory_$DOMAIN.db ./lib/firmware/regulatory.db
	zip -j $IMAGESDIR/$FIRMWARE-$LAIRD_RELEASE_STRING.zip $IMAGESDIR/$FIRMWARE.tar.bz2
	rm $IMAGESDIR/$FIRMWARE.tar.bz2 -fr
}

create_bcm4339_firmware_zipfile()
{
	DOMAIN=$1
	FIRMWARE=$2

	ln -rsf $FW_DIR/regulatory_$DOMAIN.db $FW_DIR/regulatory.db;
	ln -rsf $FW_DIR/brcm/bcm4339/brcmfmac4339-sdio-prod.bin $FW_DIR/brcm/bcm4339/brcmfmac4339-sdio.bin;
	ln -rsf $FW_DIR/brcm/bcm4339/brcmfmac4339-sdio-$DOMAIN.txt $FW_DIR/brcm/bcm4339/brcmfmac4339-sdio.txt;
	cd $FW_DIR/brcm/; ln -sf bcm4339/brcmfmac4339-sdio.bin brcmfmac4339-sdio.bin; cd -;
	ln -rsf $FW_DIR/brcm/bcm4339/brcmfmac4339-sdio-$DOMAIN.txt $FW_DIR/brcm/brcmfmac4339-sdio.txt;
	ln -rsf $FW_DIR/brcm/bcm4339/4339.hcd $FW_DIR/brcm/4339.hcd;

	tar -cjf "$IMAGESDIR/$FIRMWARE.tar.bz2" \
	./lib/firmware/brcm/bcm4339/brcmfmac4339-sdio-prod.bin \
	./lib/firmware/brcm/bcm4339/brcmfmac4339-sdio.bin \
	./lib/firmware/brcm/bcm4339/brcmfmac4339-sdio.txt \
	./lib/firmware/brcm/bcm4339/brcmfmac4339-sdio-$DOMAIN.txt \
	./lib/firmware/brcm/bcm4339/4339.hcd	\
	./lib/firmware/brcm/brcmfmac4339-sdio.bin \
	./lib/firmware/brcm/brcmfmac4339-sdio.txt \
	./lib/firmware/brcm/4339.hcd	\
	./lib/firmware/regulatory_$DOMAIN.db ./lib/firmware/regulatory.db
	zip -j $IMAGESDIR/$FIRMWARE-$LAIRD_RELEASE_STRING.zip $IMAGESDIR/$FIRMWARE.tar.bz2
	rm $IMAGESDIR/$FIRMWARE.tar.bz2 -fr
}

cd $TARGET_DIR

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_ST60_SDIO_UART=y" ${BR2_CONFIG}; then
ln -rsf $FW_DIR/lrdmwl/88W8997_ST_sdio_uart_*.bin $FW_DIR/lrdmwl/88W8997_sdio.bin
ln -rsf $FW_DIR/regulatory_sterling60.db $FW_DIR/regulatory.db
tar -cjf "$IMAGESDIR/laird-sterling60-firmware-sdio-uart-$LAIRD_RELEASE_STRING.tar.bz2" \
	./lib/firmware/lrdmwl/88W8997_sdio.bin \
	./lib/firmware/lrdmwl/88W8997_ST_sdio_uart_*.bin \
	./lib/firmware/regulatory_sterling60.db ./lib/firmware/regulatory.db
fi

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_ST60_SDIO_SDIO=y" ${BR2_CONFIG}; then
ln -rsf $FW_DIR/lrdmwl/88W8997_ST_sdio_sdio_*.bin $FW_DIR/lrdmwl/88W8997_sdio.bin
ln -rsf $FW_DIR/regulatory_sterling60.db $FW_DIR/regulatory.db
tar -cjf "$IMAGESDIR/laird-sterling60-firmware-sdio-sdio-$LAIRD_RELEASE_STRING.tar.bz2" \
	./lib/firmware/lrdmwl/88W8997_sdio.bin \
	./lib/firmware/lrdmwl/88W8997_ST_sdio_sdio_*.bin \
	./lib/firmware/regulatory_sterling60.db ./lib/firmware/regulatory.db
fi

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_ST60_PCIE_UART=y" ${BR2_CONFIG}; then
ln -rsf $FW_DIR/lrdmwl/88W8997_ST_pcie_uart_*.bin $FW_DIR/lrdmwl/88W8997_pcie.bin
ln -rsf $FW_DIR/regulatory_sterling60.db $FW_DIR/regulatory.db
tar -cjf "$IMAGESDIR/laird-sterling60-firmware-pcie-uart-$LAIRD_RELEASE_STRING.tar.bz2" \
	./lib/firmware/lrdmwl/88W8997_pcie.bin \
	./lib/firmware/lrdmwl/88W8997_ST_pcie_uart_*.bin \
	./lib/firmware/regulatory_sterling60.db ./lib/firmware/regulatory.db
fi

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_ST60_PCIE_USB=y" ${BR2_CONFIG}; then
ln -rsf $FW_DIR/lrdmwl/88W8997_ST_pcie_usb_*.bin $FW_DIR/lrdmwl/88W8997_pcie.bin
ln -rsf $FW_DIR/regulatory_sterling60.db $FW_DIR/regulatory.db
tar -cjf "$IMAGESDIR/laird-sterling60-firmware-pcie-usb-$LAIRD_RELEASE_STRING.tar.bz2" \
	./lib/firmware/lrdmwl/88W8997_pcie.bin \
	./lib/firmware/lrdmwl/88W8997_ST_pcie_usb_*.bin \
	./lib/firmware/regulatory_sterling60.db ./lib/firmware/regulatory.db
fi

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_ST60_USB_UART=y" ${BR2_CONFIG}; then
ln -rsf $FW_DIR/lrdmwl/88W8997_ST_usb_uart_*.bin $FW_DIR/lrdmwl/88W8997_usb.bin
ln -rsf $FW_DIR/regulatory_sterling60.db $FW_DIR/regulatory.db
tar -cjf "$IMAGESDIR/laird-sterling60-firmware-usb-uart-$LAIRD_RELEASE_STRING.tar.bz2" \
	./lib/firmware/lrdmwl/88W8997_usb.bin \
	./lib/firmware/lrdmwl/88W8997_ST_usb_uart_*.bin \
	./lib/firmware/regulatory_sterling60.db ./lib/firmware/regulatory.db
fi

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SU60_SDIO_UART=y" ${BR2_CONFIG}; then
ln -rsf $FW_DIR/lrdmwl/88W8997_SU_sdio_uart_*.bin $FW_DIR/lrdmwl/88W8997_sdio.bin
ln -rsf $FW_DIR/regulatory_summit60.db $FW_DIR/regulatory.db
tar -cjf "$IMAGESDIR/laird-summit60-firmware-sdio-uart-$LAIRD_RELEASE_STRING.tar.bz2" \
	./lib/firmware/lrdmwl/88W8997_sdio.bin \
	./lib/firmware/lrdmwl/88W8997_SU_sdio_uart_*.bin \
	./lib/firmware/regulatory_summit60.db ./lib/firmware/regulatory.db
fi

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SU60_SDIO_SDIO=y" ${BR2_CONFIG}; then
ln -rsf $FW_DIR/lrdmwl/88W8997_SU_sdio_sdio_*.bin $FW_DIR/lrdmwl/88W8997_sdio.bin
ln -rsf $FW_DIR/regulatory_summit60.db $FW_DIR/regulatory.db
tar -cjf "$IMAGESDIR/laird-summit60-firmware-sdio-sdio-$LAIRD_RELEASE_STRING.tar.bz2" \
	./lib/firmware/lrdmwl/88W8997_sdio.bin \
	./lib/firmware/lrdmwl/88W8997_SU_sdio_sdio_*.bin \
	./lib/firmware/regulatory_summit60.db ./lib/firmware/regulatory.db
fi

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SU60_PCIE_UART=y" ${BR2_CONFIG}; then
ln -rsf $FW_DIR/lrdmwl/88W8997_SU_pcie_uart_*.bin $FW_DIR/lrdmwl/88W8997_pcie.bin
ln -rsf $FW_DIR/regulatory_summit60.db $FW_DIR/regulatory.db
tar -cjf "$IMAGESDIR/laird-summit60-firmware-pcie-uart-$LAIRD_RELEASE_STRING.tar.bz2" \
	./lib/firmware/lrdmwl/88W8997_pcie.bin \
	./lib/firmware/lrdmwl/88W8997_SU_pcie_uart_*.bin \
	./lib/firmware/regulatory_summit60.db ./lib/firmware/regulatory.db
fi

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SU60_PCIE_USB=y" ${BR2_CONFIG}; then
ln -rsf $FW_DIR/lrdmwl/88W8997_SU_pcie_usb_*.bin $FW_DIR/lrdmwl/88W8997_pcie.bin
ln -rsf $FW_DIR/regulatory_summit60.db $FW_DIR/regulatory.db
tar -cjf "$IMAGESDIR/laird-summit60-firmware-pcie-usb-$LAIRD_RELEASE_STRING.tar.bz2" \
	./lib/firmware/lrdmwl/88W8997_pcie.bin \
	./lib/firmware/lrdmwl/88W8997_SU_pcie_usb_*.bin \
	./lib/firmware/regulatory_summit60.db ./lib/firmware/regulatory.db
fi

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SU60_USB_UART=y" ${BR2_CONFIG}; then
ln -rsf $FW_DIR/lrdmwl/88W8997_SU_usb_uart_*.bin $FW_DIR/lrdmwl/88W8997_usb.bin
ln -rsf $FW_DIR/regulatory_summit60.db $FW_DIR/regulatory.db
tar -cjf "$IMAGESDIR/laird-summit60-firmware-usb-uart-$LAIRD_RELEASE_STRING.tar.bz2" \
	./lib/firmware/lrdmwl/88W8997_usb.bin \
	./lib/firmware/lrdmwl/88W8997_SU_usb_uart_*.bin \
	./lib/firmware/regulatory_summit60.db ./lib/firmware/regulatory.db
fi

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SOM60=y" ${BR2_CONFIG}; then
ln -rsf $FW_DIR/lrdmwl/88W8997_SOM_sdio_uart_*.bin $FW_DIR/lrdmwl/88W8997_sdio.bin
ln -rsf $FW_DIR/regulatory_summit60.db $FW_DIR/regulatory.db
tar -cjf "$IMAGESDIR/laird-som60-radio-firmware-$LAIRD_RELEASE_STRING.tar.bz2" \
	./lib/firmware/lrdmwl/88W8997_sdio.bin \
	./lib/firmware/lrdmwl/88W8997_SOM_sdio_uart_*.bin \
	./lib/firmware/regulatory_summit60.db ./lib/firmware/regulatory.db
fi

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_BCM4343_MFG=y" ${BR2_CONFIG}; then
ln -rsf $FW_DIR/regulatory_default.db $FW_DIR/regulatory.db
ln -rsf $FW_DIR/brcm/bcm4343w/brcmfmac43430-sdio-mfg.bin $FW_DIR/brcm/brcmfmac43430-sdio.bin;
ln -rsf $FW_DIR/brcm/bcm4343w/brcmfmac43430-sdio-fcc.txt $FW_DIR/brcm/brcmfmac43430-sdio.txt;
ln -rsf $FW_DIR/brcm/bcm4343w/4343w.hcd $FW_DIR/brcm/4343w.hcd;
ln -rsf $FW_DIR/brcm/bcm4343w/brcmfmac43430-sdio.clm_blob $FW_DIR/brcm/brcmfmac43430-sdio.clm_blob;
tar -cjf "$IMAGESDIR/laird-lwb-firmware-mfg-$LAIRD_RELEASE_STRING.tar.bz2" \
	./lib/firmware/regulatory_default.db ./lib/firmware/regulatory.db	\
	./lib/firmware/brcm/bcm4343w/brcmfmac43430-sdio-mfg.bin \
	./lib/firmware/brcm/bcm4343w/brcmfmac43430-sdio-fcc.txt \
	./lib/firmware/brcm/brcmfmac43430-sdio.txt \
	./lib/firmware/brcm/brcmfmac43430-sdio.bin \
	./lib/firmware/brcm/4343w.hcd \
	./lib/firmware/brcm/bcm4343w/4343w.hcd \
	./lib/firmware/brcm/brcmfmac43430-sdio.clm_blob \
	./lib/firmware/brcm/bcm4343w/brcmfmac43430-sdio.clm_blob \
	./lib/firmware/regulatory_default.db ./lib/firmware/regulatory.db
zip -j $IMAGESDIR/480-0108-$LAIRD_RELEASE_STRING.zip $IMAGESDIR/laird-lwb-firmware-mfg-$LAIRD_RELEASE_STRING.tar.bz2
fi

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_BCM4343=y" ${BR2_CONFIG}; then
create_bcm4343w_firmware_zipfile fcc  480-0079
create_bcm4343w_firmware_zipfile etsi 480-0080
create_bcm4343w_firmware_zipfile jp   480-0116
fi

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_BCM4339_MFG=y" ${BR2_CONFIG}; then
ln -rsf $FW_DIR/regulatory_default.db $FW_DIR/regulatory.db
ln -rsf $FW_DIR/brcm/bcm4339/brcmfmac4339-sdio-mfg.bin $FW_DIR/brcm/brcmfmac4339-sdio.bin;
ln -rsf $FW_DIR/brcm/bcm4339/brcmfmac4339-sdio-fcc.txt $FW_DIR/brcm/brcmfmac4339-sdio.txt;
ln -rsf $FW_DIR/brcm/bcm4339/4339.hcd $FW_DIR/brcm/4339.hcd;
tar -cjf "$IMAGESDIR/laird-lwb5-firmware-mfg-$LAIRD_RELEASE_STRING.tar.bz2" \
	./lib/firmware/regulatory_default.db ./lib/firmware/regulatory.db	\
	./lib/firmware/brcm/bcm4339/brcmfmac4339-sdio-mfg.bin \
	./lib/firmware/brcm/bcm4339/brcmfmac4339-sdio-fcc.txt \
	./lib/firmware/brcm/brcmfmac4339-sdio.bin \
	./lib/firmware/brcm/brcmfmac4339-sdio.txt \
	./lib/firmware/brcm/4339.hcd	\
	./lib/firmware/brcm/bcm4339/4339.hcd	\
	./lib/firmware/regulatory_default.db ./lib/firmware/regulatory.db
zip -j $IMAGESDIR/480-0109-$LAIRD_RELEASE_STRING.zip $IMAGESDIR/laird-lwb5-firmware-mfg-$LAIRD_RELEASE_STRING.tar.bz2
fi

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_BCM4339=y" ${BR2_CONFIG}; then
create_bcm4339_firmware_zipfile fcc  480-0081
create_bcm4339_firmware_zipfile etsi 480-0082
create_bcm4339_firmware_zipfile ic   480-0094
create_bcm4339_firmware_zipfile jp   480-0095
fi

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_AR6003=y" ${BR2_CONFIG}; then
ln -rsf $FW_DIR/regulatory_default.db $FW_DIR/regulatory.db
tar -cjf "$IMAGESDIR/laird-ath6k-6003-firmware-$LAIRD_RELEASE_STRING.tar.bz2" \
	./lib/firmware/ath6k/AR6003 \
	./lib/firmware/regulatory_default.db ./lib/firmware/regulatory.*
fi

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_AR6004=y" ${BR2_CONFIG}; then
ln -rsf $FW_DIR/regulatory_default.db $FW_DIR/regulatory.db
tar -cjf "$IMAGESDIR/laird-ath6k-6004-firmware-$LAIRD_RELEASE_STRING.tar.bz2" \
	./lib/firmware/ath6k/AR6004 \
	./lib/firmware/bluetopia \
	./lib/firmware/regulatory_default.db ./lib/firmware/regulatory.*
fi

echo "$BR2_LRD_PLATFORM POST IMAGE script: done."
