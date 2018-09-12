#!/bin/sh

UDC_DIR=/sys/class/udc
GADGET_DIR=/sys/kernel/config/usb_gadget

create_gadgets () {
	counter=0

	[ -d $GADGET_DIR ] || exit 1;

	for udc_name in $(ls $UDC_DIR); do
		mkdir $GADGET_DIR/g$counter
		cd $GADGET_DIR/g$counter

		echo 0x0525 > idVendor
		echo 0xa4a2 > idProduct

		echo "1" > os_desc/use
		echo "0xcd" > os_desc/b_vendor_code
		echo "MSFT100" > os_desc/qw_sign

		mkdir strings/0x409
		if [ -e /sys/devices/soc0/soc_uid ]; then
			cat /sys/devices/soc0/soc_uid > strings/0x409/serialnumber
		else
			echo "deadbeefdeadbeef" > strings/0x409/serialnumber
		fi

		echo "Laird Technologies" > strings/0x409/manufacturer
		echo "SOM60" > strings/0x409/product

		mkdir -p configs/c.1/strings/0x409
		echo "USB RNDIS Ethernet Configuration" > configs/c.1/strings/0x409/configuration

		# Create RNDIS Ethernet config
		mkdir -p functions/rndis.usb$counter

		cd functions/rndis.usb$counter

		echo "ef" > class
		echo "04" > subclass
		echo "01" > protocol

		echo "RNDIS" > os_desc/interface.rndis/compatible_id
		echo "5162001" > os_desc/interface.rndis/sub_compatible_id

		cd ../..

		ln -s functions/rndis.usb$counter configs/c.1
		ln -s configs/c.1 os_desc

		echo $udc_name > UDC

		counter=$((counter+1))
	done
}

destroy_gadgets () {
	counter=0

	for udc_name in $(ls $UDC_DIR); do
		gadget="$GADGET_DIR/g$counter"

		if [ -e $gadget ]; then
			echo "" > $gadget/UDC
			rm -rf $gadget 2>/dev/null
			rm -rf $gadget 2>/dev/null
		fi

		counter=$((counter+1))
	done
}

case "$1" in
	start)
		create_gadgets
		;;

	stop)
		destroy_gadgets
		;;

	*)
		echo $"Usage: $0 {start|stop}"
		exit 1
esac
