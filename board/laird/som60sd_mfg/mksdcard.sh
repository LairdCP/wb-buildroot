#!/usr/bin/env bash

DRIVE=$1

if [[ -z $DRIVE ]]
then
    echo "mksdcard.sh <device>"
    echo "  <device> is the SD card to be programmed (e.g., /dev/sdc)"
    exit
fi

echo "All data on "$DRIVE" now will be destroyed! Continue? [y/n]"
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

mkfs.vfat -F 16 -n boot "$DRIVE"1 &> /dev/null
mkfs.ext4 -L rootfs "$DRIVE"2 &> /dev/null

echo "[Copying files...]"

mount "$DRIVE"1 /mnt
cp u-boot-spl.bin /mnt/boot.bin
cp u-boot.itb /mnt
cp kernel.itb /mnt
sync
umount /mnt

mount "$DRIVE"2 /mnt
tar xf rootfs.tar -C /mnt
sync
umount /mnt

echo "[Done]"
