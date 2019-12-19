#!/bin/sh

MOUNT_POINT=/tmp/ubi_mount_point
DATA_SECRET_SRC=/data/secret
DATA_SECRET_TARGET=${MOUNT_POINT}/secret
DATA_NONSECRET_SRC=/data/misc
DATA_NONSECRET_TARGET=${MOUNT_POINT}/misc

exit_on_error() {
	[ "${1}" == 1 ] && /bin/umount "${MOUNT_POINT}"
	echo "${2}"
	exit 1
}

find_ubi_device() {
	ubi_dev=""
	for f in /sys/class/ubi/*; do
		if [ -f "${f}/name" ]; then
			if [ "${1}" == `cat "${f}/name"` ]; then
				ubi_dev="/dev/${f#/sys/class/ubi/}"
				break
			fi
		fi
	done
	[ -z "${ubi_dev}" ] && exit_on_error 0 "UBI Volume ${1} Does not Exist"
}

migrate_data() {

	#Create mount point and mount the data device
	/bin/mount -o noatime -t ubifs "${1}" "${MOUNT_POINT}" || exit_on_error 0 "Mounting ${DATA_DEVICE} to ${MOUNT_POINT} Failed"
	#Wipe data patition
	rm -rf "${MOUNT_POINT}"/*
	#Migrate secret data if exists
	if [ -d "${DATA_SECRET_SRC}"  ]; then
		#Needs keyring to access secret data
		/bin/keyctl link @us @s
		mkdir -p "${DATA_SECRET_TARGET}" || exit_on_error 1 "Directory Creation for ${DATA_SECRET_TARGET} Failed"
		#migrate the secret data
		/bin/rsync -rlptDW --exclude=.mounted "${DATA_SECRET_SRC}/" "${DATA_SECRET_TARGET}" || exit_on_error 1 "Data Copying.. Failed"
	fi
	#Migrate misc data if exists
	if [ -d "${DATA_NONSECRET_SRC}"  ]; then
		mkdir -p "${DATA_NONSECRET_TARGET}" || exit_on_error 1 "Directory Creation for ${DATA_NONSECRET_TARGET} Failed"
		#migrate the misc data
		/bin/rsync -rlptDW --exclude=.mounted "${DATA_NONSECRET_SRC}/" "${DATA_NONSECRET_TARGET}" || exit_on_error 1 "Data Copying.. Failed"
	fi
	#Unmount the data device
	/bin/umount "${MOUNT_POINT}" || exit_on_error 0 "Unmounting ${MOUNT_POINT} Failed"
}

mkdir -p "${MOUNT_POINT}" || exit_on_error 0 "Directory Creation for ${MOUNT_POINT} Failed"

for name in ${1}; do
	find_ubi_device "${name}"
	migrate_data "${ubi_dev}"
done

rm -rf "${MOUNT_POINT}"
