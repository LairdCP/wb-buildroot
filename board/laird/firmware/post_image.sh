IMAGESDIR="$1"

export BR2_LRD_PLATFORM=laird-radio-firmware
export FW_DIR="$TARGET_DIR/lib/firmware"

echo "$BR2_LRD_PLATFORM POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

[ -z "$LAIRD_RELEASE_STRING" ] && LAIRD_RELEASE_STRING="$(date +%Y%m%d)"

cd $TARGET_DIR

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_ST60_SDIO_UART=y" ${BR2_CONFIG}; then
ln -rsf $FW_DIR/lrdmwl/88W8997_ST_sdio_uart_*.bin $FW_DIR/lrdmwl/88W8997_sdio.bin
tar -cjf "$IMAGESDIR/laird-sterling60-firmware-sdio-uart-$LAIRD_RELEASE_STRING.tar.bz2" \
	./lib/firmware/lrdmwl/88W8997_sdio.bin \
	./lib/firmware/lrdmwl/88W8997_ST_sdio_uart_*.bin \
fi

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_ST60_SDIO_SDIO=y" ${BR2_CONFIG}; then
ln -rsf $FW_DIR/lrdmwl/88W8997_ST_sdio_sdio_*.bin $FW_DIR/lrdmwl/88W8997_sdio.bin
tar -cjf "$IMAGESDIR/laird-sterling60-firmware-sdio-sdio-$LAIRD_RELEASE_STRING.tar.bz2" \
	./lib/firmware/lrdmwl/88W8997_sdio.bin \
	./lib/firmware/lrdmwl/88W8997_ST_sdio_sdio_*.bin \
fi

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_ST60_PCIE_UART=y" ${BR2_CONFIG}; then
ln -rsf $FW_DIR/lrdmwl/88W8997_ST_pcie_uart_*.bin $FW_DIR/lrdmwl/88W8997_pcie.bin
tar -cjf "$IMAGESDIR/laird-sterling60-firmware-pcie-uart-$LAIRD_RELEASE_STRING.tar.bz2" \
	./lib/firmware/lrdmwl/88W8997_pcie.bin \
	./lib/firmware/lrdmwl/88W8997_ST_pcie_uart_*.bin \
fi

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_ST60_PCIE_USB=y" ${BR2_CONFIG}; then
ln -rsf $FW_DIR/lrdmwl/88W8997_ST_pcie_usb_*.bin $FW_DIR/lrdmwl/88W8997_pcie.bin
tar -cjf "$IMAGESDIR/laird-sterling60-firmware-pcie-usb-$LAIRD_RELEASE_STRING.tar.bz2" \
	./lib/firmware/lrdmwl/88W8997_pcie.bin \
	./lib/firmware/lrdmwl/88W8997_ST_pcie_usb_*.bin \
fi

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_ST60_USB_UART=y" ${BR2_CONFIG}; then
ln -rsf $FW_DIR/lrdmwl/88W8997_ST_usb_uart_*.bin $FW_DIR/lrdmwl/88W8997_usb.bin
tar -cjf "$IMAGESDIR/laird-sterling60-firmware-usb-uart-$LAIRD_RELEASE_STRING.tar.bz2" \
	./lib/firmware/lrdmwl/88W8997_usb.bin \
	./lib/firmware/lrdmwl/88W8997_ST_usb_uart_*.bin \
fi

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SU60_SDIO_UART=y" ${BR2_CONFIG}; then
ln -rsf $FW_DIR/lrdmwl/88W8997_SU_sdio_uart_*.bin $FW_DIR/lrdmwl/88W8997_sdio.bin
tar -cjf "$IMAGESDIR/laird-summit60-firmware-sdio-uart-$LAIRD_RELEASE_STRING.tar.bz2" \
	./lib/firmware/lrdmwl/88W8997_sdio.bin \
	./lib/firmware/lrdmwl/88W8997_SU_sdio_uart_*.bin \
fi

ln -rsf $FW_DIR/lrdmwl/88W8997_SU_sdio_sdio_*.bin $FW_DIR/lrdmwl/88W8997_sdio.bin
tar -cjf "$IMAGESDIR/laird-summit60-firmware-sdio-sdio-$LAIRD_RELEASE_STRING.tar.bz2" \
	./lib/firmware/lrdmwl/88W8997_sdio.bin \
	./lib/firmware/lrdmwl/88W8997_SU_sdio_sdio_*.bin \
fi

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SU60_PCIE_UART=y" ${BR2_CONFIG}; then
ln -rsf $FW_DIR/lrdmwl/88W8997_SU_pcie_uart_*.bin $FW_DIR/lrdmwl/88W8997_pcie.bin
tar -cjf "$IMAGESDIR/laird-summit60-firmware-pcie-uart-$LAIRD_RELEASE_STRING.tar.bz2" \
	./lib/firmware/lrdmwl/88W8997_pcie.bin \
	./lib/firmware/lrdmwl/88W8997_SU_pcie_uart_*.bin \
fi

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SU60_PCIE_USB=y" ${BR2_CONFIG}; then
ln -rsf $FW_DIR/lrdmwl/88W8997_SU_pcie_usb_*.bin $FW_DIR/lrdmwl/88W8997_pcie.bin
tar -cjf "$IMAGESDIR/laird-summit60-firmware-pcie-usb-$LAIRD_RELEASE_STRING.tar.bz2" \
	./lib/firmware/lrdmwl/88W8997_pcie.bin \
	./lib/firmware/lrdmwl/88W8997_SU_pcie_usb_*.bin \
fi

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SU60_USB_UART=y" ${BR2_CONFIG}; then
ln -rsf $FW_DIR/lrdmwl/88W8997_SU_usb_uart_*.bin $FW_DIR/lrdmwl/88W8997_usb.bin
tar -cjf "$IMAGESDIR/laird-summit60-firmware-usb-uart-$LAIRD_RELEASE_STRING.tar.bz2" \
	./lib/firmware/lrdmwl/88W8997_usb.bin \
	./lib/firmware/lrdmwl/88W8997_SU_usb_uart_*.bin \
fi

if grep -qF "BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SOM60=y" ${BR2_CONFIG}; then
ln -rsf $FW_DIR/lrdmwl/88W8997_SOM_sdio_uart_*.bin $FW_DIR/lrdmwl/88W8997_sdio.bin
tar -cjf "$IMAGESDIR/laird-som60-radio-firmware-$LAIRD_RELEASE_STRING.tar.bz2" \
	./lib/firmware/lrdmwl/88W8997_sdio.bin \
	./lib/firmware/lrdmwl/88W8997_SOM_sdio_uart_*.bin \
fi

echo "$BR2_LRD_PLATFORM POST IMAGE script: done."
