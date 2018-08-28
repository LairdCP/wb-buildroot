#!/usr/bin/env bash

DRIVE=$1
ARG=${1##*/}

if [[ ( -z $DRIVE ) || ( -z $ARG ) ]]
then
    echo "mksdcard.sh <device>"
    echo "  <device> is the SD card to be programmed (e.g., /dev/sdc)"
    exit
fi

if [ ! -f rootfs.tar ]; then
    echo "Could not find required rootfs.tar file. This script only works"
    echo "if the build was done for the som60sd target."
    exit
fi

OPT=${ARG::-1}

if [[ ( ! -z $OPT ) && ( "$OPT" == "sd" ) ]]
then
    PART_1="$DRIVE"1
    PART_2="$DRIVE"2
elif [[ ( ! -z $OPT ) && ( "$OPT" == "mmcblk" ) ]]
then
    PART_1="$DRIVE"p1
    PART_2="$DRIVE"p2
else
    echo "Invalid device name: $ARG"
    exit
fi

echo "*************************************************************************"
echo "WARNING: All data on "$DRIVE" now will be destroyed! Continue? [y/n]"
echo "*************************************************************************"
read ans
if ! [ $ans == 'y' ]
then
    exit
fi

echo "[Partitioning $DRIVE...]"

dd if=/dev/zero of=$DRIVE bs=1024 count=1024

SIZE=`fdisk -l $DRIVE | grep Disk | awk '{print $5}'`

echo DISK SIZE - $SIZE bytes

#CYLINDERS=`echo $SIZE/255/63/512 | bc`
#echo CYLINDERS - $CYLINDERS
#{
#    echo ,9,0x0C,*
#    echo ,,,-
#} | sfdisk -D -H 255 -S 63 -C $CYLINDERS $DRIVE
sfdisk $DRIVE << EOF
1M,48M,0xE,*
49M,,,-
EOF

echo "[Making filesystems...]"

mkfs.vfat -F 16 -n boot "$PART_1" &> /dev/null
mkfs.ext4 -L rootfs "$PART_2" &> /dev/null

echo "[Copying files...]"

mount "$PART_1" /mnt
cp u-boot-spl.bin /mnt/boot.bin
cp u-boot.itb /mnt
cp kernel.itb /mnt
sync
umount /mnt

mount "$PART_2" /mnt
tar xf rootfs.tar -C /mnt
sync
umount /mnt

echo "[Done]"
