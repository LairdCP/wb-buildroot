#!/usr/bin/env ash

# Event
case $action in
	deconfig)
		event_injector -t 24 -s 1
		;;

	renew)
		event_injector -t 24 -s 4
		;;

	bound)
		event_injector -t 24 -s 6
		;;

	leasefail)
		event_injector -t 24 -s 8
		;;

	nak)
		event_injector -t 24 -s 7
		;;

	requesting)
		event_injector -t 24 -s 2
		;;

	renewing)
		event_injector -t 24 -s 3
		;;

	rebinding)
		event_injector -t 24 -s 5
		;;

	released)
		event_injector -t 24 -s 9
		;;

	*)
		;;
esac

exit 0;
