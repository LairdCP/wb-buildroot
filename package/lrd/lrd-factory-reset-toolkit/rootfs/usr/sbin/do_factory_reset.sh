#!/bin/sh

FACTORY_SETTING_SOURCE=/usr/share/factory/etc
FACTORY_SETTING_DEFAULT_ZONE=/usr/share/zoneinfo

USER_SETTINGS_TARGET=/data/secret

FACTORY_SETTING_LOCALTIME=/etc/localtime
FACTORY_SETTING_TIMEZONE=/etc/timezone
FACTORY_SETTING_ADJTIME_FILE=/etc/adjtime

BLUETOOTH_STATE_DIR=/data/secret/lib/bluetooth

exit_on_error() {
	echo "${1}"
	exit 1
}

do_check_and_reset() {

    mkdir -p ${USER_SETTINGS_TARGET} || exit_on_error "Creating target dir.. Failed"

    cp -r ${FACTORY_SETTING_SOURCE}/* ${USER_SETTINGS_TARGET} || exit_on_error "Copying factory default files failed"

    # timezone file should be included in backup but we create a default if it
    # is not present. Localtime requires a valid timezone.
    if [ ! -f "${USER_SETTINGS_TARGET}/timezone" ]; then
		echo "Etc/UTC" > "${FACTORY_SETTING_TIMEZONE}"
    fi

    ln -sf   ${FACTORY_SETTING_DEFAULT_ZONE}/$(cat ${FACTORY_SETTING_TIMEZONE}) $(readlink ${FACTORY_SETTING_LOCALTIME}) || exit_on_error "Unable to create localtime link"

	touch "${FACTORY_SETTING_ADJTIME_FILE}" || exit_on_error "unable to create adjtime file"

	if [ ! -d "${BLUETOOTH_STATE_DIR}" ]; then
		mkdir -p ${BLUETOOTH_STATE_DIR}
	fi
}

do_delete() {
	# Delete all user data, but not the /data/secret dir as it is encrypted.
	find /data -maxdepth 1 -mindepth 1 ! -name secret -exec rm -fr {} \;
	rm -fr ${USER_SETTINGS_TARGET}/*
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

