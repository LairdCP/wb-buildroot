./gpio-init.sh
sleep 2
modprobe mwlwifi_sdio
sleep 2
./gpio-release.sh
sleep 25
ifconfig wlan0 up
# iw wlan0 connect ccopen1
# sleep 1
# udhcpc -i wlan0
