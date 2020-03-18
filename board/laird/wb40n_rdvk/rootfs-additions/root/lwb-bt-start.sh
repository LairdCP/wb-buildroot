#!/bin/sh

echo 23 > /sys/class/gpio/export
echo high > /sys/class/gpio/pioA23/direction

/usr/bin/nohup /usr/libexec/bluetooth/bluetoothd &

sleep 1

/usr/bin/nohup /usr/bin/btattach -B /dev/ttyS1 -P bcm &

/usr/bin/hciconfig hci0 up
