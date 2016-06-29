rm /lib/firmware/ath6k/AR6004/hw3.0/bdata.bin
rm /lib/firmware/ath6k/AR6004/hw3.0/fw-5.bin
ln -s /lib/firmware/ath6k/AR6004/hw3.0/50NBTBDF0xa02.bin /lib/firmware/ath6k/AR6004/hw3.0/bdata.bin
ln -s /lib/firmware/ath6k/AR6004/hw3.0/fw_v3.5.0.10009.bin /lib/firmware/ath6k/AR6004/hw3.0/fw-5.bin
ifrc wlan0 start
