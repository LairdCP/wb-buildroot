#!/bin/sh

FACTORY_SETTING_TARGET=/data/secret/

exit_on_error() {
	echo "${1}"
	exit 1
}

do_check_and_reset() {

	if [ ! -d ${FACTORY_SETTING_TARGET} ]; then
		mkdir -p ${FACTORY_SETTING_TARGET}
		cp -fa /etc/NetworkManager ${FACTORY_SETTING_TARGET} || exit_on_error 1 "Copying NetworkManager data.. Failed"
		cp -fa /etc/weblcm-python ${FACTORY_SETTING_TARGET} || exit_on_error 1 "Copying weblcm-python data.. Failed"
		sync
	fi
}

do_delete() {
	#Delete all user data
	rm -fr ${FACTORY_SETTING_TARGET}
}

case $1 in
	check)
		do_check_and_reset
		;;

	reset)
		do_delete
		do_check_and_reset
		;;
esac

