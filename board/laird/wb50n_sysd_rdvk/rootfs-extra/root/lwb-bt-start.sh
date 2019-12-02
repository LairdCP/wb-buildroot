#!/bin/sh

echo 30 > /sys/class/gpio/export
echo high > /sys/class/gpio/pioA30/direction

/usr/bin/nohup /usr/libexec/bluetooth/bluetoothd &

sleep 1

/usr/bin/nohup /usr/bin/btattach -B /dev/ttyS1 -P bcm &

/usr/bin/hciconfig hci0 up
