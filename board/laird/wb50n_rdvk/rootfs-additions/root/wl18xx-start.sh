echo 31 > /sys/class/gpio/export 
echo out > /sys/class/gpio/pioA31/direction 
/root/wl18xx-down.sh
modprobe wlcore
modprobe wlcore_sdio
modprobe wl18xx
sleep 1
/root/wl18xx-up.sh
sleep 3
ifconfig wlan0 up
iw wlan0 connect ccopen1
sleep 1
udhcpc -i wlan0

