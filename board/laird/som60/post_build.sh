BOARD_DIR="$(dirname $0)"

export BR2_LRD_PLATFORM="${2}"

echo "${BR2_LRD_PLATFORM^^} POST BUILD script: starting..."

[[ ${BR2_LRD_PLATFORM} == *"sd" ]] || [[ ${BR2_LRD_PLATFORM} == *"sd_mfg" ]]
SD=$?

# source the common post build script
. "${BOARD_DIR}/../post_build_common_60.sh" "${BOARD_DIR}"  ${SD}

[ -f ${TARGET_DIR}/lib/firmware/regulatory_summit60.db ] && \
    ln -sfr ${TARGET_DIR}/lib/firmware/regulatory_summit60.db ${TARGET_DIR}/lib/firmware/regulatory.db

if (( ${SD} )); then
	grep -q "/dev/mmcblk0p2" ${TARGET_DIR}/etc/fstab ||\
		echo '/dev/mmcblk0p2 swap swap defaults 0 0' >> ${TARGET_DIR}/etc/fstab

	grep -q "/dev/mmcblk0p1" ${TARGET_DIR}/etc/fstab ||\
		echo '/dev/mmcblk0p1 /boot vfat defaults 0 0' >> ${TARGET_DIR}/etc/fstab
fi

echo "${BR2_LRD_PLATFORM^^} POST BUILD script: done."
