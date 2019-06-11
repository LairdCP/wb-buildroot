#!/bin/sh
#
DATA_MOUNT=/data

# Mount proper data device (based on boot side)
BLOCK=`sed -n 's/.*ubi\.block=[0-9]*,\([0-9]*\).*/\1/p' /proc/cmdline`
OVERLAY=$((BLOCK + 1))
DATA_DEVICE=ubi0_${OVERLAY}
mount -o noatime,noexec,nosuid,nodev -t ubifs ${DATA_DEVICE} ${DATA_MOUNT}

# Create encrypted data directory
DATA_SECRET=${DATA_MOUNT}/secret
mkdir -p ${DATA_SECRET}

FSCRYPT_KEY=ffffffffffffffff
fscryptctl set_policy ${FSCRYPT_KEY} ${DATA_SECRET}
touch ${DATA_SECRET}/.mounted

# Create Network Manager directory
DATA_NM_CONNECTIONS=${DATA_SECRET}/NetworkManager/system-connections
mkdir -p ${DATA_NM_CONNECTIONS}

# cp default profiles to the new path
for f in /etc/NetworkManager/system-connections/* ; do
	nf=${DATA_NM_CONNECTIONS}/$(basename ${f})
	if [ ! -f ${nf} ] ; then
		cp ${f} ${DATA_NM_CONNECTIONS}/
	fi
done
