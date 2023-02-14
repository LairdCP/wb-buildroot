#!/bin/sh

case "${DEVPATH}" in
*/f802c000.ethernet/*)
	mac="$(fw_printenv -n ethaddr)"
	;;
*)
	echo "unrecognized device ${DEVPATH}"
	exit
	;;
esac

[ -n "${mac}" ] && ip link set "${INTERFACE}" address "${mac}"
