#!/bin/sh

# Copyright (c) 2018-2020, Laird Connectivity
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
#

UDC_DIR=/sys/class/udc
GADGET_DIR=/sys/kernel/config/usb_gadget

create_gadgets () {
	proto=${1}
	counter=0

	[ -z "${proto}" ] && proto=rndis

	modprobe -qa atmel_usba_udc at91_udc
	modprobe -a usb_f_fs usb_f_${proto}

	if [ ! -d "${GADGET_DIR}" ]; then
		mount -t configfs none /sys/kernel/config
		[ -d "${GADGET_DIR}" ] || { echo "ConfigFS not found"; exit 1; }
	fi

	for udc_name in $(ls ${UDC_DIR}); do
		mkdir ${GADGET_DIR}/g${counter}
		cd ${GADGET_DIR}/g${counter}

		echo 0x0525 > idVendor

		if [ ${proto} == rndis ] || [ ${proto} == ncm ]; then
			echo 0xa4a2 > idProduct
			echo "1" > os_desc/use
			echo "0xcd" > os_desc/b_vendor_code
			echo "MSFT100" > os_desc/qw_sign
		else
			echo 0xa4a1 > idProduct
		fi

		mkdir strings/0x409
		if [ -e /sys/devices/soc0/soc_uid ]; then
			cat /sys/devices/soc0/soc_uid > strings/0x409/serialnumber
		else
			echo "deadbeefdeadbeef" > strings/0x409/serialnumber
		fi

		echo "Laird Connectivity" > strings/0x409/manufacturer
		echo "$(cat /sys/firmware/devicetree/base/model)" > strings/0x409/product

		mkdir -p configs/c.1/strings/0x409
		echo "USB Ethernet Configuration" > configs/c.1/strings/0x409/configuration

		# Create Ethernet config
		mkdir -p functions/${proto}.usb${counter}
		cd functions/${proto}.usb${counter}

		if [ ${proto} == rndis ]; then
			echo "ef" > class
			echo "04" > subclass
			echo "01" > protocol

			echo "RNDIS" > os_desc/interface.rndis/compatible_id
			echo "5162001" > os_desc/interface.rndis/sub_compatible_id
		elif [ ${proto} == ncm ]; then
			echo "WINNCM" > os_desc/interface.ncm/compatible_id
		fi

		echo "DE:AD:BE:EF:00:00" > dev_addr
		echo "DE:AD:BE:EF:01:00" > host_addr

		cd ../..

		ln -s functions/${proto}.usb${counter} configs/c.1
		ln -s configs/c.1 os_desc

		echo ${udc_name} > UDC

		counter=$((counter+1))
	done
}

destroy_gadgets () {
	counter=0

	for udc_name in $(ls ${UDC_DIR}); do
		gadget="${GADGET_DIR}/g${counter}"

		if [ -e ${gadget} ]; then
			echo "" > ${gadget}/UDC
			rm -rf ${gadget} 2>/dev/null
			rm -rf ${gadget} 2>/dev/null
		fi

		counter=$((counter+1))
	done
}

case "$1" in
	start)
		create_gadgets $2
		;;

	stop)
		destroy_gadgets
		;;

	*)
		echo $"Usage: $0 {start|stop} {rndis|ncm|ecm|eem}"
		exit 1
esac
