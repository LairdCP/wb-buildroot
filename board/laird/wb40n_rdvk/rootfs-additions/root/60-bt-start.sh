#!/bin/sh

/usr/bin/nohup /usr/libexec/bluetooth/bluetoothd &

sleep 1

/usr/bin/nohup /usr/bin/btattach -B /dev/ttyS1 -P h4 -S 3000000 &

bluetoothctl power up
