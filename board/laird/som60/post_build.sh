BOARD_DIR="$(realpath $(dirname $0))"

export BR2_LRD_PLATFORM="${2}"

echo "${BR2_LRD_PLATFORM^^} POST BUILD script: starting..."

[[ ${BR2_LRD_PLATFORM} == *"sd" ]] || [[ ${BR2_LRD_PLATFORM} == *"sd_mfg" ]]
SD=$?

# source the common post build script
. "${BOARD_DIR}/../post_build_common_60.sh" "${BOARD_DIR}"  ${SD}

[ -f ${TARGET_DIR}/lib/firmware/regulatory_summit60.db ] && \
    ln -sfr ${TARGET_DIR}/lib/firmware/regulatory_summit60.db ${TARGET_DIR}/lib/firmware/regulatory.db

echo "${BR2_LRD_PLATFORM^^} POST BUILD script: done."
