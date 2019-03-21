BOARD_DIR="$(dirname $0)"

export BR2_LRD_PLATFORM="$2"

echo "${BR2_LRD_PLATFORM^^} POST BUILD script: starting..."

# source the common post build script
source "$BOARD_DIR/../post_build_common_60.sh" "$BOARD_DIR"

[ -f ${TARGET_DIR}/lib/firmware/regulatory_summit60.db ] && \
    ln -sfr ${TARGET_DIR}/lib/firmware/regulatory_summit60.db ${TARGET_DIR}/lib/firmware/regulatory.db

grep -q "/dev/mmcblk0p2" ${TARGET_DIR}/etc/fstab ||\
	echo '/dev/mmcblk0p2 swap swap defaults 0 0' >> ${TARGET_DIR}/etc/fstab

echo "${BR2_LRD_PLATFORM^^} POST BUILD script: done."
