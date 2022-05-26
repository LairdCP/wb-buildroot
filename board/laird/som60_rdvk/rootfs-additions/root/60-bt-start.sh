#!/bin/sh

mfg_mode=/sys/class/ieee80211/phy0/device/lrd/mfg_mode

[ -e "${mfg_mode}" ] && [ "$(cat ${mfg_mode})" == 1 ] && \
        baud=115200 || baud=3000000

/usr/bin/nohup /usr/bin/btattach -B /dev/ttyS1 -P h4 -S ${baud} &
