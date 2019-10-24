BOARD_DIR="$(dirname $0)"

export BR2_LRD_PLATFORM="${2}"

echo "${BR2_LRD_PLATFORM^^} POST BUILD script: starting..."

[[ ${BR2_LRD_PLATFORM} == *"sd_sysd" ]]
SD=$?

# source the common post build script
. "${BOARD_DIR}/../post_build_common_60.sh" "${BOARD_DIR}" ${SD}

echo "${BR2_LRD_PLATFORM^^} POST BUILD script: done."
