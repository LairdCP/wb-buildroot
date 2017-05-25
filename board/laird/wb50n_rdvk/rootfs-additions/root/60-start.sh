./gpio-init.sh
sleep 2
modprobe lrdmwl_sdio
modprobe btmrvl_sdio
sleep 2
./gpio-release.sh
