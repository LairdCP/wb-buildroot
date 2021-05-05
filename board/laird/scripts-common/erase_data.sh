#!/bin/sh

MOUNT_POINT=/tmp/ubi_mount_point
DATA_SECRET_SRC=/data/secret
DATA_SECRET_TARGET=${MOUNT_POINT}/secret
DATA_SRC=/data
DATA_TARGET=${MOUNT_POINT}
do_data_migration=1

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

	if [ "${do_data_migration}" -ne 0 ]; then

		#Prepare /data/secret
		if [ -d "${DATA_SECRET_SRC}"  ]; then
			mkdir -p "${DATA_SECRET_TARGET}"
			#mount_data.service should be active when securefs is enabled.
			/bin/systemctl -q is-active mount_data
			if [ "$?" -eq 0 ]; then
				#Needs keyring to access secret data.
				/bin/keyctl link @us @s
				#Target dir is not encrypted anymore after nand erase. Encrypt it before migrating data.
				FSCRYPT_KEY=ffffffffffffffff
				/bin/fscryptctl set_policy ${FSCRYPT_KEY} ${DATA_SECRET_TARGET}
			fi
		fi

		cp -fa "${DATA_SRC}"/* "${DATA_TARGET}"/ || exit_on_error 1 "Data Copying.. Failed"
	fi

	#Unmount the data device
	/bin/umount "${MOUNT_POINT}" || exit_on_error 0 "Unmounting ${MOUNT_POINT} Failed"
}

mkdir -p "${MOUNT_POINT}" || exit_on_error 0 "Directory Creation for ${MOUNT_POINT} Failed"

#Don't migrate data from SD
cmdline=$(cat /proc/cmdline)
rootsd="/dev/mmc" #SD builds boot from /dev/mmc*
case ${cmdline} in
	*${rootsd}*) do_data_migration=0 ;;
esac

#Don't migrate if /data not mounted
if ! grep -qs "${DATA_SRC} " /proc/mounts; then
	echo "Data from ${DATA_SRC} not migrated, because it was not mounted." | systemd-cat -t "${0}" -p warning
	do_data_migration=0
fi

for name in ${1}; do
	find_ubi_device "${name}"
	migrate_data "${ubi_dev}"
done

rm -rf "${MOUNT_POINT}"
