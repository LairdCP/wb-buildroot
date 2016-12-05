modprobe mwifiex_sdio
sleep 30
ifconfig mlan0 up
iw mlan0 connect ccopen1
sleep 3
udhcpc -i mlan0
