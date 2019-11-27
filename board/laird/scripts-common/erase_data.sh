#!/bin/sh

UBI_MOUNT_POINT=/tmp/ubi_mount_point

mkdir -p "${UBI_MOUNT_POINT}"

for name in ${1}; do
	for f in /sys/class/ubi/*; do
		if [ -f "${f}/name" ]; then
			if [ "${name}" == `cat "${f}/name"` ]; then
				/bin/mount -o noatime -t ubifs "/dev/${f#/sys/class/ubi/}" "${UBI_MOUNT_POINT}"
				rm -rf "${UBI_MOUNT_POINT}"/*
				/bin/umount "${UBI_MOUNT_POINT}"
			fi
		fi
	done
done

rm -rf "${UBI_MOUNT_POINT}"
