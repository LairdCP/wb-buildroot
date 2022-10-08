#!/bin/sh

set -e

DATA_MOUNT=/data

case $1 in
	start)
		# Mount proper data device (based on boot side)
		BLOCK=$(sed -n 's/.*ubi\.block=[0-9]*,\([0-9]*\).*/\1/p' /proc/cmdline)
		OVERLAY=$((BLOCK + 1))
		DATA_DEVICE=/dev/ubi0_${OVERLAY}
		/bin/systemd-mount -o noatime,noexec,nosuid,nodev --fsck=no -t ubifs ${DATA_DEVICE} ${DATA_MOUNT}

		# Create encrypted data directory
		DATA_SECRET=${DATA_MOUNT}/secret
		mkdir -p ${DATA_SECRET}

		FSCRYPT_KEY=ffffffffffffffff

		keyctl search %:_builtin_fs_keys logon fscrypt:${FSCRYPT_KEY} @us

		fscryptctl set_policy ${FSCRYPT_KEY} ${DATA_SECRET}

		# Need to access the encrypted directory once so that the key
		# gets loaded
		touch ${DATA_SECRET}/.mounted

		. do_factory_reset.sh check

		echo "Secure Boot Cycle Complete" > /dev/console
		;;

	stop)
		/bin/systemd-umount ${DATA_MOUNT}
		echo 3 > /proc/sys/vm/drop_caches
		;;
esac
