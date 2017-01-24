#!/bin/sh

set -u
set -e

readonly PATCHRAM_DEBUG_ARG="-d"

NOHUP_EXE="/usr/bin/nohup"
PATCHRAM_EXE="/usr/bin/brcm_patchram_plus"
BLUETOOTHD_EXE="/usr/libexec/bluetooth/bluetoothd"
BT_FW_FILE="/lib/firmware/brcm/4343w.hcd"
BT_UART_DEV="/dev/ttyS1"

test -x "${NOHUP_EXE}"
test -x "${PATCHRAM_EXE}"
test -x "${BLUETOOTHD_EXE}"
test -f "${BT_FW_FILE}"
test -c "${BT_UART_DEV}"

echo 30 > /sys/class/gpio/export
echo high > /sys/class/gpio/pioA30/direction

"${NOHUP_EXE}" "${BLUETOOTHD_EXE}" &

sleep 1

"${PATCHRAM_EXE}" \
	--patchram "${BT_FW_FILE}" \
	--no2bytes \
	--tosleep 1000 \
	"${BT_UART_DEV}"

hciattach "${BT_UART_DEV}" any

hciconfig hci0 up

hciconfig
