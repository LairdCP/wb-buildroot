BOARD_DIR="$(dirname $0)"

export BR2_LRD_PLATFORM="${2}"
DEVEL_KEYS="${3}"

echo "${BR2_LRD_PLATFORM^^} POST IMAGE script: starting..."

[[ ${BR2_LRD_PLATFORM} == *"sd" ]] || [[ ${BR2_LRD_PLATFORM} == *"sd_mfg" ]]
SD=$?

. "${BOARD_DIR}/../post_image_common_60.sh" "${BOARD_DIR}" ${SD} "${DEVEL_KEYS}"

echo "${BR2_LRD_PLATFORM^^} POST IMAGE script: done."
