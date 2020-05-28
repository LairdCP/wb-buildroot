#!/bin/sh

# This script is called from our systemd unit file to mount or unmount
# a USB drive.

usage()
{
    echo "Usage: $0 {add|remove} device_name (e.g. /dev/sdb1) [mount_user]"
    exit 1
}

if [ $# -lt 2 ]; then
    usage
fi

# This allows set default parameters (used for setting user name)
test -r /etc/default/usb-mount && . /etc/default/usb-mount

ACTION=${1}
DEVICE=${2}

DEVBASE=${DEVICE#/dev/*}
MOUNT_ROOT="$(readlink -f /media)"

case ${DEVBASE} in
	mmc*) MOUNT_USER=${3:-${MOUNT_USER_MMC}} ;;
	*) MOUNT_USER=${3:-${MOUNT_USER_USB}} ;;
esac

# See if this drive is already mounted, and if so where
MOUNT_POINT="$(/bin/awk -v DEV=${DEVICE} '($1 == DEV) { print $2 }' /proc/mounts)"

do_mount()
{
    if [ -n "${MOUNT_POINT}" ]; then
        echo "Warning: ${DEVICE} is already mounted at ${MOUNT_POINT}"
        exit 1
    fi

    # Get info for this drive: $ID_FS_LABEL, $ID_FS_UUID, and $ID_FS_TYPE
    if [ -z "${ID_FS_TYPE}" ]; then
        eval $(/sbin/blkid -o udev ${DEVICE})
        [ -n "${ID_FS_TYPE}" ] || \
			{ echo "${DEVICE} is not a fileystem"; exit 1; }
    fi

    # Figure out a mount point to use
    LABEL=${ID_FS_LABEL}
    if [ -z "${LABEL}" ]; then
        LABEL=${DEVBASE}
    elif /bin/grep -q " ${MOUNT_ROOT}/${LABEL} " /proc/mounts; then
        # Already in use, make a unique one
        LABEL="${LABEL}-${DEVBASE}"
    fi
    MOUNT_POINT="${MOUNT_ROOT}/${LABEL}"

    echo "Mount point: ${MOUNT_POINT}"

    /bin/mkdir -p "${MOUNT_POINT}"

    # Global mount options
    OPTS="rw,relatime,noexec,nosuid,nodev"

    # File system type specific mount options
    if [ ${ID_FS_TYPE} == "vfat" ]; then
        OPTS="${OPTS},users,umask=000,shortname=mixed,utf8=1,flush"
        if [ -n "$MOUNT_USER" ]; then
            OPTS="${OPTS},uid=`id -u ${MOUNT_USER}`,gid=`id -g ${MOUNT_USER}`"
        else
            OPTS="${OPTS},gid=100"
        fi
    fi

    if ! /bin/mount -o ${OPTS} ${DEVICE} ${MOUNT_POINT}; then
        echo "Error mounting ${DEVICE} (status = $?)"
        /bin/rmdir ${MOUNT_POINT}
        exit 1
    fi

    # Change ownership of mounted drive to user, if specified
    [ -z "${MOUNT_USER}" ] || chown ${MOUNT_USER} ${MOUNT_POINT}

    echo "**** Mounted ${DEVICE} at ${MOUNT_POINT} ****"
}

do_unmount()
{
    for f in ${MOUNT_POINT} ; do
        case "${f}" in
		"${MOUNT_ROOT}"*)
            /bin/umount -l ${f} && echo "**** Unmounted ${f} ${DEVICE}" ;;
        "") echo "Warning: ${DEVICE} is not mounted" ;;
        *) echo "Warning: ${DEVICE} is not managed by usb-mount" ;;
        esac
    done

    # Delete all empty dirs in MOUNT_ROOT that aren't being used as mount
    # points. This is kind of overkill, but if the drive was unmounted
    # prior to removal we no longer know its mount point, and we don't
    # want to leave it orphaned...
    for f in ${MOUNT_ROOT}/* ; do
        if [ -e "${f}" ] && [ -z "$(ls -A ${f})" ]; then
            if ! /bin/grep -qF " ${f} " /proc/mounts; then
                echo "**** Removing mount point ${f}"
                /bin/rmdir "${f}"
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
