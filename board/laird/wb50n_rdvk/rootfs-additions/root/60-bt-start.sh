#!/bin/sh

/usr/bin/nohup /usr/libexec/bluetooth/bluetoothd &

sleep 1

mfg_mode=/sys/class/ieee80211/phy0/device/lrd/mfg_mode
[ -f "${mfg_mode}" ] && read -r mfg_val < ${mfg_mode} && \
[ "${mfg_val}" = 1 ] && baud=115200 || baud=3000000

/usr/bin/nohup /usr/bin/btattach -B /dev/ttyS1 -P h4 -S ${baud} &

bluetoothctl power on
