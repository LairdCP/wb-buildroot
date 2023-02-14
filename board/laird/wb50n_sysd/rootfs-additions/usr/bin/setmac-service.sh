#!/bin/sh

[ -d /sys/devices/platform/ahb/ahb:apb/f802c000.ethernet ] && [ -n "$(fw_printenv -n ethaddr)" ] && ip link set eth0 address $(fw_printenv -n ethaddr)
