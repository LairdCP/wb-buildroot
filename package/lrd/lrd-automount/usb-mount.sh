#!/bin/sh

# This script is called from our systemd unit file to mount or unmount
# a USB drive.

usage()
{
    echo "Usage: $0 {add|remove} device_name (e.g. /dev/sdb1)"
    exit 1
}

if [[ $# -ne 2 ]]; then
    usage
fi

ACTION=$1
DEVICE=$2
DEVBASE=${DEVICE#/dev/*}

# See if this drive is already mounted, and if so where
MOUNT_POINT=$(/bin/mount | /bin/grep -F "${DEVICE} " | /usr/bin/awk '{ print $3 }')

do_mount()
{
    if [ -n "${MOUNT_POINT}" ]; then
        echo "Warning: ${DEVICE} is already mounted at ${MOUNT_POINT}"
        exit 1
    fi

    # Get info for this drive: $ID_FS_LABEL, $ID_FS_UUID, and $ID_FS_TYPE
    eval $(/sbin/blkid -o udev ${DEVICE})

    [ -n "${ID_PART_TABLE_TYPE}" ] && exit 0

    # Figure out a mount point to use
    LABEL=${ID_FS_LABEL}
    if [ -z "${LABEL}" ]; then
        LABEL=${DEVBASE}
    elif /bin/grep -q " /media/${LABEL} " /proc/mounts; then
        # Already in use, make a unique one
        LABEL+="-${DEVBASE}"
    fi
    MOUNT_POINT="/media/${LABEL}"

    echo "Mount point: ${MOUNT_POINT}"

    /bin/mkdir -p ${MOUNT_POINT}

    # Global mount options
    OPTS="rw,relatime"

    # File system type specific mount options
    if [ ${ID_FS_TYPE} == "vfat" ]; then
        OPTS+=",users,gid=100,umask=000,shortname=mixed,utf8=1,flush"
    fi

    if ! /bin/mount -o ${OPTS} ${DEVICE} ${MOUNT_POINT}; then
        echo "Error mounting ${DEVICE} (status = $?)"
        /bin/rmdir ${MOUNT_POINT}
        exit 1
    fi

    echo "**** Mounted ${DEVICE} at ${MOUNT_POINT} ****"
}

do_unmount()
{
    case "${MOUNT_POINT}" in
	"/media/"*) 
	    /bin/umount -l ${DEVICE} && echo "**** Unmounted ${DEVICE}" ;;
	"") echo "Warning: ${DEVICE} is not mounted" ;;
	*) echo "Warning: ${DEVICE} is not managed by usb-mount" ;;
    esac

    # Delete all empty dirs in /media that aren't being used as mount
    # points. This is kind of overkill, but if the drive was unmounted
    # prior to removal we no longer know its mount point, and we don't
    # want to leave it orphaned...
    for f in /media/* ; do
        if [ -d "$f" ] && [ -z "$(ls -A \"$f\")" ]; then
            if ! /bin/grep -qF " $f " /proc/mounts; then
                echo "**** Removing mount point $f"
                /bin/rmdir "$f"
            fi
        fi
    done
}

case "${ACTION}" in
    add)
        do_mount
        ;;
    remove)
        do_unmount
        ;;
    *)
        usage
        ;;
esac
