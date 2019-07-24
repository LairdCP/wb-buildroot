#!/bin/sh

IMGFILE=$1
ROOTFS_EXTRA_SIZE=${2:-0}
SRCDIR=${0%/*}

MiBCONVERTER=$(( 1024 * 1024 ))

if [ -z "${IMGFILE}" ]; then
    echo "mksdimg.sh <output filename> [optional rootfs free space size in MiB]" >&2
    exit
fi

if [ ! -f "${SRCDIR}/rootfs.tar" ]; then
    echo "Could not find required rootfs.tar file." >&2
    exit
fi

[ "${ROOTFS_EXTRA_SIZE}" -eq "${ROOTFS_EXTRA_SIZE}" ] 2>/dev/null
if [ $? -ne 0 ]; then
		echo "rootfs free space size is not a number" >&2
		exit
fi

echo "[Creating card image...]"

# Calculate size of the rootfs file system
ROOTFS_FILE_SIZE=$(stat -c%s "${SRCDIR}/rootfs.tar")

# Set image free space to 10% of the used space by default
[ "${ROOTFS_EXTRA_SIZE}" -eq "0" ] &&
	ROOTFS_EXTRA_SIZE=$(( ROOTFS_FILE_SIZE * 11 / 10 ))

# Calculate partitions
BOOT_IMG_SIZE_MiB=48
BOOT_BLOCK_SIZE=512
BOOT_BLOCKS=$(( BOOT_IMG_SIZE_MiB * MiBCONVERTER / BOOT_BLOCK_SIZE ))

SWAP_IMG_SIZE_MiB=256

ROOTFS_IMG_SIZE_MiB=$(( (ROOTFS_FILE_SIZE + ROOTFS_EXTRA_SIZE) / MiBCONVERTER + 1 ))
ROOTFS_BLOCK_SIZE=1024
ROOTFS_BLOCKS=$(( ROOTFS_IMG_SIZE_MiB * MiBCONVERTER / ROOTFS_BLOCK_SIZE ))

BOOT_START_MiB=1
BOOT_END_MiB=$((BOOT_START_MiB + BOOT_IMG_SIZE_MiB))

SWAP_START_MiB=${BOOT_END_MiB}
SWAP_END_MiB=$((SWAP_START_MiB + SWAP_IMG_SIZE_MiB))

ROOTFS_START_MiB=${SWAP_END_MiB}
ROOTFS_END_MiB=$((ROOTFS_START_MiB + ROOTFS_IMG_SIZE_MiB))

TOTAL_IMG_SIZE_MiB=$((ROOTFS_END_MiB + 1))

# Create disk image placeholder
rm -f ${IMGFILE}
fallocate -l ${TOTAL_IMG_SIZE_MiB}MiB ${IMGFILE}
[ $? -ne 0 ] && exit

# Create image partition table
parted -s ${IMGFILE} mklabel msdos unit MiB \
    mkpart primary fat16 ${BOOT_START_MiB} ${BOOT_END_MiB} set 1 lba on set 1 boot on \
    mkpart primary linux-swap ${SWAP_START_MiB} ${SWAP_END_MiB} \
    mkpart primary ext4 ${ROOTFS_START_MiB} ${ROOTFS_END_MiB}

[ $? -ne 0 ] && exit

TMPDIR=$(mktemp -d)

echo "[Creating boot partition...]"

# Create boot partition image
mkfs.vfat -F 16 -n BOOT -S ${BOOT_BLOCK_SIZE} -C ${TMPDIR}/boot.img ${BOOT_BLOCKS} > /dev/null

# Add files to boot partition image
mcopy -i ${TMPDIR}/boot.img ${SRCDIR}/u-boot-spl.bin ::/boot.bin
mcopy -i ${TMPDIR}/boot.img ${SRCDIR}/u-boot.itb ::/
mcopy -i ${TMPDIR}/boot.img ${SRCDIR}/kernel.itb ::/

# Add boot partition to disk image
dd if=${TMPDIR}/boot.img of=${IMGFILE} conv=notrunc bs=1MiB seek=${BOOT_START_MiB} count=${BOOT_IMG_SIZE_MiB} status=none
rm -f ${TMPDIR}/boot.img

echo "[Creating swap partition...]"

# Create swap partition image
fallocate -l ${SWAP_IMG_SIZE_MiB}MiB ${TMPDIR}/swap.img
chmod 600 ${TMPDIR}/swap.img

# Format swap partition image
mkswap -L swap ${TMPDIR}/swap.img > /dev/null

# Add swap partition to disk image
dd if=${TMPDIR}/swap.img of=${IMGFILE} conv=notrunc bs=1MiB seek=${SWAP_START_MiB} count=${SWAP_IMG_SIZE_MiB} status=none
rm -f ${TMPDIR}/swap.img

echo "[Creating rootfs partition...]"

# Create rootfs directory for mkfs.ext4
mkdir ${TMPDIR}/rootfs.tmp
tar xf ${SRCDIR}/rootfs.tar -C ${TMPDIR}/rootfs.tmp

# Create rootfs partition image
mkfs.ext4 -q -L rootfs -F -b ${ROOTFS_BLOCK_SIZE} -d ${TMPDIR}/rootfs.tmp -E lazy_itable_init=0,lazy_journal_init=0 ${TMPDIR}/rootfs.img ${ROOTFS_BLOCKS}
rm -rf ${TMPDIR}/rootfs.tmp

# Add rootfs partition to disk image
dd if=${TMPDIR}/rootfs.img of=${IMGFILE} conv=notrunc bs=1MiB seek=${ROOTFS_START_MiB} count=${ROOTFS_IMG_SIZE_MiB} status=none
rm -f ${TMPDIR}/rootfs.img

rm -rf ${TMPDIR}

echo "[Compressing card image...]"
xz -9f ${IMGFILE}

echo "[Done]"
echo
echo "[Image file: ${IMGFILE}.xz]"
echo "SD Card Programming: umount /dev/sdX ; xz -dc ${IMGFILE}.xz | dd of=/dev/sdX bs=4M conv=fsync"
