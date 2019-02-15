#!/bin/sh

case "$1" in
	start)
		if [ ! -f /sys/class/gpio/pioE5/value ]; then
			echo 133 > /sys/class/gpio/export 2> /dev/null
			echo out > /sys/class/gpio/pioE5/direction
		fi
		echo 1 > /sys/class/gpio/pioE5/value

		/usr/bin/bccmd -t bcsp -d /dev/ttyS4 -b 115200 psload -r /lib/firmware/bluetopia/DWM-W311.psr >/dev/null
		/usr/bin/hciattach -p /dev/ttyS4 bcsp 115200 >/dev/null
		;;

	stop)
		killall hciattach
		echo 0 > /sys/class/gpio/pioE5/value
		;;

	*)
		echo $"Usage: $0 {start|stop}"
		exit 1
		;;
esac
