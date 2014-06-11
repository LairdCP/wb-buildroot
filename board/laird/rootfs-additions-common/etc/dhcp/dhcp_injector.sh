#!/usr/bin/env ash

# Event
case $action in
	deconfig)
		dhcp_injector -s DECONFIG
		;;

	renew)
		dhcp_injector -s RENEWED
		;;

	bound)
		dhcp_injector -s BOUND
		;;

	leasefail)
		dhcp_injector -s LEASEFAIL
		;;

	nak)
		dhcp_injector -s NAK
		;;

	requesting)
		dhcp_injector -s REQUESTING
		;;

	renewing)
		dhcp_injector -s RENEWING
		;;

	rebinding)
		dhcp_injector -s REBINDING
		;;

	released)
		dhcp_injector -s RELEASED
		;;

	*)
		;;
esac

exit 0;
