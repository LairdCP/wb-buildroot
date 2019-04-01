BOARD_DIR="$(dirname $0)"

export BR2_LRD_PLATFORM="${2}"

echo "${BR2_LRD_PLATFORM^^} POST IMAGE script: starting..."

[[ ${BR2_LRD_PLATFORM} == *"sd_sysd" ]]
SD=$?

. "${BOARD_DIR}/../post_image_common_60.sh" "${BOARD_DIR}" ${SD}

echo "${BR2_LRD_PLATFORM^^} POST IMAGE script: done."
