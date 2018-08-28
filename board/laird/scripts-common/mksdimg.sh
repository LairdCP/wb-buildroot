#!/usr/bin/env bash

IMGFILE=$1
BLKSIZE=512

let IMGSIZE=200*1024*1024
let IMGBLKS=${IMGSIZE}/${BLKSIZE}

if [[ ( -z $IMGFILE ) ]]
then
    echo "mksdimg.sh <file>"
    echo "  Make SD card image, where <file> is the file to contain the SD card image"
    exit
fi

if [ ! -f rootfs.tar ]; then
    echo "Could not find required rootfs.tar file. This script only works"
    echo "if the build was done for the som60sd target."
    exit
fi

echo "[Creating image file...]"
dd if=/dev/zero of=${IMGFILE} bs=${BLKSIZE} count=${IMGBLKS}
losetup /dev/loop0 ${IMGFILE}

echo "[Partitioning block device...]"
SIZE=`fdisk -l /dev/loop0 | grep Disk | awk '{print $5}'`

echo DISK SIZE - $SIZE bytes

sfdisk /dev/loop0 << EOF
1M,48M,0xE,*
49M,,,-
EOF

echo "[Making filesystems...]"
# IMPORTANT: These offsets must match the partitions created above!
losetup -o 1048576 /dev/loop1 /dev/loop0
losetup -o 51380224 /dev/loop2 /dev/loop0

mkfs.vfat -F 16 -n boot /dev/loop1 &> /dev/null
mkfs.ext4 -L rootfs /dev/loop2 &> /dev/null

echo "[Copying files...]"

mount /dev/loop1 /mnt
cp u-boot-spl.bin /mnt/boot.bin
cp u-boot.itb /mnt
cp kernel.itb /mnt
sync
umount /mnt

mount /dev/loop2 /mnt
tar xf rootfs.tar -C /mnt
sync
umount /mnt

losetup -d /dev/loop2
losetup -d /dev/loop1
losetup -d /dev/loop0

echo "[Done]"
