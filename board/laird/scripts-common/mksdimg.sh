#!/usr/bin/env bash
#********************************************ENTER IN IMAGE SIZES IN MiB******************************************

echo "IMAGE SIZES ARE IN MiB!!"
IMGFILE=$1
IMGUSERSIZE=$2
BLKSIZE=512

if [[ ( -z $IMGFILE ) ]]
then
    echo "mksdimg.sh <output filename> [optional output file size in MiB]"
    exit
fi

if [ ! -f rootfs.tar ]; then
    echo "Could not find required rootfs.tar file. This script only works"
    echo "if the build was done for the som60sd target."
    exit
fi

DYNAMICFILESIZE=$(stat -c%s "rootfs.tar")
MiBCONVERTER=$((1024*1024))
DYNAMICFILESIZE=$((DYNAMICFILESIZE / MiBCONVERTER))

if [[ ( $IMGUSERSIZE ) ]]
then
   ISNUMBER='^[0-9]+$'

	if ! [[ $IMGUSERSIZE =~ $ISNUMBER ]] ; 
	then
		echo "error: Not a number" >&2; exit 1
	fi

    echo "[Setting filesystem to user defined size...]"
    let IMGSIZE=$IMGUSERSIZE*1024*1024
    let	CHECKSIZE=$((DYNAMICFILESIZE + 80))*1024*1024

	if [[ $IMGSIZE < $CHECKSIZE ]]
	then
		echo "Warning image size ($((CHECKSIZE / MiBCONVERTER)) MiB) size smaller than recommend size ($((CHECKSIZE / MiBCONVERTER))) MiB"
	fi
fi

if [[ (-z $IMGUSERSIZE ) ]]
then
	let IMGSIZE=$((DYNAMICFILESIZE +80))*1024*1024
fi

let IMGBLKS=${IMGSIZE}/${BLKSIZE}

echo "[Creating image file...]"
dd if=/dev/zero of=${IMGFILE} bs=${BLKSIZE} count=${IMGBLKS}
LOOPNAME=$(losetup -f)
losetup $LOOPNAME ${IMGFILE}

echo "[Partitioning block device...]"
SIZE=`fdisk -l $LOOPNAME | grep Disk | awk '{print $5}'`

echo DISK SIZE - $SIZE bytes

sfdisk $LOOPNAME << EOF
1M,48M,0xE,*
49M,,,-
EOF

echo "[Making filesystems...]"
# IMPORTANT: These offsets must match the partitions created above!
LOOPNAME1=$(losetup -f)
losetup -o 1048576 $LOOPNAME1 $LOOPNAME
LOOPNAME2=$(losetup -f)
losetup -o 51380224 $LOOPNAME2 $LOOPNAME

mkfs.vfat -F 16 -n boot $LOOPNAME1 &> /dev/null
mkfs.ext4 -L rootfs $LOOPNAME2 &> /dev/null

echo "[Copying files...]"
mount -t vfat $LOOPNAME1 /mnt
cp u-boot-spl.bin /mnt/boot.bin || echo "Script failed, check image size recommend: $((CHECKSIZE / MiBCONVERTER)) MiB"
cp u-boot.itb /mnt
cp kernel.itb /mnt
sync
umount /mnt

mount $LOOPNAME2 /mnt
tar xf rootfs.tar -C /mnt ||  echo "Script failed, check image size recommend: $((CHECKSIZE / MiBCONVERTER)) MiB"
sync
umount /mnt

losetup -d $LOOPNAME1
losetup -d $LOOPNAME2
losetup -d $LOOPNAME

echo "[Done]"
