#!/bin/sh

NM_CONF_DIR=/etc/NetworkManager
NM_CONF_FILE=${NM_CONF_DIR}/NetworkManager.conf

WEBLCM_CONF_DIR=/etc/weblcm-python
WEBLCM_CONF_FILE=${WEBLCM_CONF_DIR}/weblcm-python.ini

FIREWALLD_CONF_DIR=/etc/firewalld
FIREWALLD_CONF_FILE=${FIREWALLD_CONF_DIR}/firewalld.conf

FACTORY_SETTING_TARGET=/data/secret
NM_CONF_FILE_TARGET=${FACTORY_SETTING_TARGET}/NetworkManager/NetworkManager.conf
WEBLCM_CONF_FILE_TARGET=${FACTORY_SETTING_TARGET}/weblcm-python/weblcm-python.ini
FIREWALLD_CONF_FILE_TARGET=${FACTORY_SETTING_TARGET}/firewalld/firewalld.conf

exit_on_error() {
	echo "${1}"
	exit 1
}

do_check_and_reset() {

	mkdir -p ${FACTORY_SETTING_TARGET} || exit_on_error "Creating target dir.. Failed"

	if [ ! -f "${NM_CONF_FILE_TARGET}" ] && [ -f "${NM_CONF_FILE}" ]; then
		cp -fa ${NM_CONF_DIR} ${FACTORY_SETTING_TARGET}/ || exit_on_error "Copying NetworkManager data.. Failed"
	fi

	if [ ! -f "${WEBLCM_CONF_FILE_TARGET}" ] && [ -f "${WEBLCM_CONF_FILE}" ]; then
		cp -fa ${WEBLCM_CONF_DIR} ${FACTORY_SETTING_TARGET}/ || exit_on_error "Copying weblcm-python data.. Failed"
	fi

	if [ ! -f "${FIREWALLD_CONF_FILE_TARGET}" ] && [ -f "${FIREWALLD_CONF_FILE}" ]; then
		cp -fa ${FIREWALLD_CONF_DIR} ${FACTORY_SETTING_TARGET}/ || exit_on_error "Copying firewalld data.. Failed"
	fi
}

do_delete() {
	#Delete all user data
	rm -fr ${FACTORY_SETTING_TARGET}/*
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

