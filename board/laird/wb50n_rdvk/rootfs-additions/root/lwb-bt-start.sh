#!/bin/sh

set -u
set -e

readonly PATCHRAM_DEBUG_ARG="-d"

PATCHRAM_EXE="/usr/bin/brcm_patchram_plus"
BT_FW_FILE="/lib/firmware/brcm/4343w.hcd"
BT_UART_DEV="/dev/ttyS1"

test -x "${PATCHRAM_EXE}"
test -f "${BT_FW_FILE}"
test -c "${BT_UART_DEV}"

echo 30 > /sys/class/gpio/export
echo high > /sys/class/gpio/pioA30/direction
echo 1 > /sys/class/gpio/pioA30/value

sleep 1

"${PATCHRAM_EXE}" \
	--patchram "${BT_FW_FILE}" \
	--no2bytes \
	--tosleep 1000 \
	"${BT_UART_DEV}"

hciattach "${BT_UART_DEV}" any

hciconfig hci0 up

hciconfig
