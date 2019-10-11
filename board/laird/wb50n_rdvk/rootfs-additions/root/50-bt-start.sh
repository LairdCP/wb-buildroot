#!/bin/sh

echo 133 > /sys/class/gpio/export
echo high > /sys/class/gpio/pioE5/direction

/usr/bin/nohup /usr/libexec/bluetooth/bluetoothd &

sleep 1

/usr/bin/bccmd -t bcsp -d /dev/ttyS4 -b 115200 psload -r /lib/firmware/bluetopia/DWM-W311.psr
/usr/bin/hciattach -p /dev/ttyS4 bcsp 115200
