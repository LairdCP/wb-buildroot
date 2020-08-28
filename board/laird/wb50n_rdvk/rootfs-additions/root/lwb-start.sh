#!/bin/sh
COMMAND=$1

if [ "$#" -ne 1 ]; then
	COMMAND=start
fi

# Requirement - Radio must be reset during reboot

# pioA31 is connected to wl_reg_on and must be high for the radio to operate
# pioA31 is initialized high by uboot and remains high unless modified by this script
# Current card detect implementation does not poll the slot so radio must be functional
# when the mmc driver loads at boot
# wl_reg_on must not be de-asserted after the mmc driver loads and enumerates the slot
# Therefore wl_reg_on is deasserted at power down to implement the required reset

case "$COMMAND" in
	start)
	modprobe brcmfmac
		;;
	stop)
		modprobe -r brcmfmac
		echo 31 > /sys/class/gpio/export
		echo out > /sys/class/gpio/pioA31/direction
		echo 0 > /sys/class/gpio/pioA31/value
		sleep 1
		;;
esac
