#!/bin/sh

DATA_MOUNT=/data

case $1 in
	start)
		# Mount proper data device (based on boot side)
		BLOCK=`sed -n 's/.*ubi\.block=[0-9]*,\([0-9]*\).*/\1/p' /proc/cmdline`
		OVERLAY=$((BLOCK + 1))
		DATA_DEVICE=ubi0_${OVERLAY}
		mount -o noatime,noexec,nosuid,nodev -t ubifs ${DATA_DEVICE} ${DATA_MOUNT}

		# Create encrypted data directory
		DATA_SECRET=${DATA_MOUNT}/secret
		mkdir -p ${DATA_SECRET}

		FSCRYPT_KEY=ffffffffffffffff
		fscryptctl set_policy ${FSCRYPT_KEY} ${DATA_SECRET}

		# Need to access the encrypted directory once so that the key
		# gets loaded
		touch ${DATA_SECRET}/.mounted

		DATA_NM_CONNECTIONS=${DATA_SECRET}/NetworkManager/system-connections
		if [ ! -d ${DATA_NM_CONNECTIONS} ]; then
			# Create Network Manager directory
			mkdir -p ${DATA_NM_CONNECTIONS}
			# cp default profiles to the new path
			SOURCE_NM_CONNECTIONS=/etc/NetworkManager/system-connections
			[ "$(ls -A ${SOURCE_NM_CONNECTIONS}/)"  ] && cp -rf ${SOURCE_NM_CONNECTIONS}/* ${DATA_NM_CONNECTIONS}/ || echo "Warning: No default NetworkManager profiles available"
		fi

		# Check if mount_data success
		if [[ -d ${DATA_NM_CONNECTIONS} && -n "$(ls -A ${DATA_NM_CONNECTIONS})" ]]
		then
			echo "Secure Boot Cycle Complete" > /dev/console
		fi
		;;

	stop)
		umount ${DATA_MOUNT}
		echo 3 > /proc/sys/vm/drop_caches
		;;
esac
