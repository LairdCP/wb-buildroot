#!/bin/sh

set_mac() {
    macb_device="$(ls "${1}")"
    [ -n "${macb_device}" ] || return

    macb_address="$(fw_printenv -n "${2}")"
    if [ -n "${macb_address}" ]; then
        ip link set "${macb_device}" address "${macb_address}"
    else
        echo "uboot mac address variable ${2} unset"
    fi
}

set_mac /sys/devices/platform/ahb/ahb:apb/f0028000.ethernet/net/ ethaddr
set_mac /sys/devices/platform/ahb/ahb:apb/f802c000.ethernet/net/ eth1addr
