BOARD_DIR="$(dirname $0)"

export BR2_LRD_PLATFORM="${2}"

echo "${BR2_LRD_PLATFORM^^} POST BUILD script: starting..."

[[ ${BR2_LRD_PLATFORM} == *"sd" ]] || [[ ${BR2_LRD_PLATFORM} == *"sd_mfg" ]]
SD=$?

# source the common post build script
. "${BOARD_DIR}/../post_build_common_60.sh" "${BOARD_DIR}"  ${SD}

if [ ${SD} -eq 0 ]; then
	rm -fr "${TARGET_DIR}/etc/tmpfiles.d"
	rm -fr "${TARGET_DIR}/etc/systemd/system/tmp.mount.d"
	rm -fr "${TARGET_DIR}/etc/systemd/system/local-fs.target.wants"
	rm -f "${TARGET_DIR}/etc/systemd/system/mount_data.service"
	rm -f "${TARGET_DIR}/usr/sbin/mount_data.sh"
	rm -f "${TARGET_DIR}/usr/sbin/pre-systemd-init.sh"
	rm -f "${TARGET_DIR}/etc/machine-id"
	rm -f "${TARGET_DIR}/etc/NetworkManager/conf.d/default-keyfile-path.conf"
	rm -f "${TARGET_DIR}/etc/systemd/system/NetworkManager.service.d/10-inherit-keyring.conf"
else
	# Securely mount /var on tmpfs
	echo "tmpfs /var tmpfs mode=1777,noexec,nosuid,nodev 0 0" >> ${TARGET_DIR}/etc/fstab
fi


[ -f ${TARGET_DIR}/lib/firmware/regulatory_summit60.db ] && \
    ln -sfr ${TARGET_DIR}/lib/firmware/regulatory_summit60.db ${TARGET_DIR}/lib/firmware/regulatory.db

if [ ${SD} -eq 0 ]; then
	grep -q "/dev/mmcblk0p2" ${TARGET_DIR}/etc/fstab ||\
		echo '/dev/mmcblk0p2 swap swap defaults 0 0' >> ${TARGET_DIR}/etc/fstab

	grep -q "/dev/mmcblk0p1" ${TARGET_DIR}/etc/fstab ||\
		echo '/dev/mmcblk0p1 /boot vfat defaults 0 0' >> ${TARGET_DIR}/etc/fstab
fi

echo "${BR2_LRD_PLATFORM^^} POST BUILD script: done."
