#!/bin/sh

case "${DEVPATH}" in
*/f0028000.ethernet/*)
    mac="$(fw_printenv -n ethaddr)"
    ;;
*/f802c000.ethernet/*)
    mac="$(fw_printenv -n eth1addr)"
    ;;
*)
    echo "unrecognized device ${DEVPATH}"
    exit
    ;;
esac

[ -n "${mac}" ] && ip link set "${INTERFACE}" address "${mac}"
