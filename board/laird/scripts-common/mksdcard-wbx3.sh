#!/bin/sh

set -e

DRIVE=${1}
ARG=${1##*/}
SRCDIR=${0%/*}
DRIVE_SIZE=/sys/block/${DRIVE##*/}/size

if [ -z "${DRIVE}" ] || [ -z "${ARG}" ]; then
    echo "mksdcard.sh <device>"
    echo "  <device> is the SD card to be programmed (e.g., /dev/sdc)"
    exit
fi

if [ ! -b ${DRIVE} ] || [ "$(cat ${DRIVE_SIZE})" -eq 0 ]; then
    echo "Can not find destination drive \"${DRIVE}\""
    exit
fi

case "${ARG}" in
    sd*)
        PART_BOOT=${DRIVE}1
        ;;

    mmcblk*)
        PART_BOOT=${DRIVE}p1
        ;;

    *)
        echo "Invalid device name: ${ARG}"
        exit
        ;;
esac

which udisksctl > /dev/null && udisk=1 || udisk=0

unmount_all() {
	local drives="$(mount |grep -oP "^${1}\d+")"

	for f in ${drives} ; do
		if [ ${udisk} -ne 0 ]; then
			udisksctl unmount -f -b ${f} >/dev/null
		else
			umount -f ${f} >/dev/null
		fi
	done

	[ -z "${drives}" ] || sleep 1
}

# Un-mount all mounted partitions
unmount_all ${DRIVE}

# Check if device is busy
hdparm -z ${DRIVE} >/dev/null

echo "[Partitioning ${DRIVE}...]"

# Wipe MBR and Partition Table
dd if=/dev/zero of=${DRIVE} bs=512 count=1 status=none
dd if=/dev/zero of=${DRIVE} bs=1KiB count=1 seek=1024 status=none

parted -s ${DRIVE} mklabel msdos unit MiB \
    mkpart primary fat16 1 49 set 1 lba on set 1 boot on

[ $? -ne 0 ] && exit

sync
sleep 1

echo "[Making file systems...]"

# Format newly created partitions
mkfs.vfat -F 16 -n BOOT ${PART_BOOT} >/dev/null
sync

echo "[Copying files...]"

MNT_BOOT=/mnt/${PART_BOOT##*/}

# Copy files to boot partition
mkdir -p ${MNT_BOOT}
mount ${PART_BOOT} ${MNT_BOOT}

cp ${SRCDIR}/u-boot-spl.bin ${MNT_BOOT}/boot.bin
cp ${SRCDIR}/u-boot.itb ${MNT_BOOT}
sync

umount -f ${MNT_BOOT} && rm -rf ${MNT_BOOT}

unmount_all ${DRIVE}

echo "[Done]"
