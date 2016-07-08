rm /lib/firmware/ath6k/AR6004/hw3.0/bdata.bin
rm /lib/firmware/ath6k/AR6004/hw3.0/fw-5.bin
ln -s /lib/firmware/ath6k/AR6004/hw3.0/qca_bdata_v3.5.0.349-1.bin /lib/firmware/ath6k/AR6004/hw3.0/bdata.bin
ln -s /lib/firmware/ath6k/AR6004/hw3.0/qca_fw_v3.5.0.349-1.bin /lib/firmware/ath6k/AR6004/hw3.0/fw-5.bin
modprobe ath6kl_core
modprobe ath6kl_sdio
sleep 3
ifconfig wlan0 up
iw wlan0 connect ccopen1
sleep 1
udhcpc -i wlan0
