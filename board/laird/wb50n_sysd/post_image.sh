BOARD_DIR="$(dirname $0)"

export BR2_LRD_PLATFORM="${2}"
DEVEL_KEYS="${3}"

echo "${BR2_LRD_PLATFORM^^} POST IMAGE script: starting..."

case ${BR2_LRD_PLATFORM} in
	*"sd_sysd")
		SD=0
		;;
	*)
		SD=1
		;;
esac

. "${BOARD_DIR}/../post_image_common_60.sh" "${BOARD_DIR}" ${SD} "${DEVEL_KEYS}"

echo "${BR2_LRD_PLATFORM^^} POST IMAGE script: done."
