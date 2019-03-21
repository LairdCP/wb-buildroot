#!/usr/bin/env bash

DRIVE=${1}
ARG=${1##*/}
SRCDIR=${0%/*}
DRIVE_SIZE=/sys/block/${DRIVE##*/}/size

if [ -z ${DRIVE} ] || [ -z ${ARG} ]; then
    echo "mksdcard.sh <device>"
    echo "  <device> is the SD card to be programmed (e.g., /dev/sdc)"
    exit
fi

if [ ! -b ${DRIVE} ] || [ "$(cat ${DRIVE_SIZE})" -eq 0 ]; then
    echo "Can not find destination drive \"${DRIVE}\""
    exit
fi

if [ ! -e ${SRCDIR}/rootfs.tar ]; then
    echo "Can not find required rootfs.tar file. This script only works"
    echo "if the build was done for the som60sd target."
    exit
fi

OPT=${ARG::-1}

case "$OPT" in
    "sd")
        PART_BOOT=${DRIVE}1
        PART_SWAP=${DRIVE}2
        PART_ROOTFS=${DRIVE}3
        ;;

    "mmcblk")
        PART_BOOT=${DRIVE}p1
        PART_SWAP=${DRIVE}p2
        PART_ROOTFS=${DRIVE}p3
        ;;

    *)
        echo "Invalid device name: ${ARG}"
        exit
        ;;
esac

# Un-mount all mounted partitions
umount -f ${DRIVE}? &> /dev/null

# Check if device is busy
hdparm -z ${DRIVE} >/dev/null || exit

echo "[Partitioning ${DRIVE}...]"

# Wipe MBR and Partition Table
dd if=/dev/zero of=${DRIVE} bs=512 count=1

# Create new partition table
sfdisk ${DRIVE} << EOF
1M,48M,0xE,*
49M,256M,S,-
305M,,,-
EOF

[ $? -ne 0 ] && exit

echo "[Making file systems...]"

# Format newly created partitions
mkfs.vfat -F 16 -n boot ${PART_BOOT} &> /dev/null
mkswap ${PART_SWAP} &> /dev/null
mkfs.ext4 -L rootfs ${PART_ROOTFS} &> /dev/null

echo "[Copying files...]"

MNT_BOOT=/mnt/${PART_BOOT##*/}
MNT_ROOTFS=/mnt/${PART_ROOTFS##*/}

# Copy files to boot partition
mkdir -p ${MNT_BOOT}
mount ${PART_BOOT} ${MNT_BOOT} || exit

cp ${SRCDIR}/u-boot-spl.bin ${MNT_BOOT}/boot.bin
cp ${SRCDIR}/u-boot.itb ${MNT_BOOT}
cp ${SRCDIR}/kernel.itb ${MNT_BOOT}
sync

umount ${MNT_BOOT} && rm -rf ${MNT_BOOT}

# Copy files to rootfs partition
mkdir -p ${MNT_ROOTFS}
mount ${PART_ROOTFS} ${MNT_ROOTFS} || exit

tar xf ${SRCDIR}/rootfs.tar -C ${MNT_ROOTFS}
sync

umount ${MNT_ROOTFS} && rm -rf ${MNT_ROOTFS}

echo "[Done]"
