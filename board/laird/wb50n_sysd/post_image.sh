BOARD_DIR="$(dirname $0)"

export BR2_LRD_PLATFORM="$2"
export BR2_LRD_PRODUCT=wb50n

echo "${BR2_LRD_PLATFORM^^} POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

source "$BOARD_DIR/../post_image_common_60.sh" "$BOARD_DIR"

echo "${BR2_LRD_PLATFORM^^} POST IMAGE script: done."
