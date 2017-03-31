#!/bin/sh

set -u
set -e

readonly PATCHRAM_DEBUG_ARG="-d"

NOHUP_EXE="/usr/bin/nohup"
PATCHRAM_EXE="/usr/bin/patchram"
BLUETOOTHD_EXE="/usr/libexec/bluetooth/bluetoothd"
BT_FW_FILE="/lib/firmware/brcm/4339.hcd"
BT_UART_DEV="/dev/ttyS1"

test -x "${NOHUP_EXE}" || { echo "$NOHUP_EXE n/a" ; exit 1; }
test -x "${PATCHRAM_EXE}" || { echo "$PATCHRAM_EXE n/a" ; exit 1; }
test -x "${BLUETOOTHD_EXE}" || { echo "$BLUETOOTHD_EXE n/a" ; exit 1; }
test -f "${BT_FW_FILE}" || { echo "$BT_FW_FILE n/a" ; exit 1; }
test -c "${BT_UART_DEV}" || { echo "$BT_UART_DEV n/a" ; exit 1; }

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
