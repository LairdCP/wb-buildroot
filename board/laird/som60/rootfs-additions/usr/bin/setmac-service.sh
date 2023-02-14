#!/bin/sh

macb0_device="$(ls /sys/devices/platform/ahb/ahb:apb/f0028000.ethernet/net/)"
macb1_device="$(ls /sys/devices/platform/ahb/ahb:apb/f802c000.ethernet/net/)"

[ -n "${macb0_device}" ] && [ -n "$(fw_printenv -n eth1addr)" ] && ip link set "${macb0_device}" address $(fw_printenv -n eth1addr)
[ -n "${macb1_device}" ] && [ -n "$(fw_printenv -n ethaddr)" ] && ip link set "${macb1_device}" address $(fw_printenv -n ethaddr)
