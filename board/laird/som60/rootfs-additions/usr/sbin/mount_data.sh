#!/bin/sh
#
DATA_MOUNT=/data

# Mount proper data device (based on boot side)
BLOCK=`sed -n 's/.*ubi\.block=[0-9]*,\([0-9]*\).*/\1/p' /proc/cmdline`
OVERLAY=$((BLOCK + 1))
DATA_DEVICE=ubi0_${OVERLAY}
mount -o noatime,noexec,nosuid,nodev -t ubifs ${DATA_DEVICE} ${DATA_MOUNT}

# Create Network Manager directory
DATA_NM_CONNECTIONS=${DATA_MOUNT}/etc/NetworkManager/system-connections
mkdir -p ${DATA_NM_CONNECTIONS}

# cp default profiles to the new path
for f in /etc/NetworkManager/system-connections/* ; do
	nf=${DATA_NM_CONNECTIONS}/$(basename ${f})
	if [ ! -f ${nf} ] ; then
		cp ${f} ${DATA_NM_CONNECTIONS}/
	fi
done

touch ${DATA_MOUNT}/.mounted
