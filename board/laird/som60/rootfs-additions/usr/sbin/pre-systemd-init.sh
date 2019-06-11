#!/bin/sh
# Pre-systemd init script
# This script sets up a writeable partition and mount it to
# /perm before starting systemd; this is necessary because a
# few systemd requirements (logging, and a machine-id file)
# require a writeable filesystem.


PERM_MOUNT=/perm
PERM_DEVICE=ubi0_6

mount -t ubifs -o noatime,nosuid,noexec ${PERM_DEVICE} ${PERM_MOUNT}

mkdir -p ${PERM_MOUNT}/etc
# Make sure there is at least an empty machine-id file
# (Referenced from symlink on the rootfs)
touch ${PERM_MOUNT}/etc/machine-id

mkdir -p ${PERM_MOUNT}/log/journal

touch ${PERM_MOUNT}/.mounted

# Start init
exec /usr/sbin/init
