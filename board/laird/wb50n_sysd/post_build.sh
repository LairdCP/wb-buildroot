BOARD_DIR="$(dirname $0)"

export BR2_LRD_PLATFORM="$2"

echo "${BR2_LRD_PLATFORM^^} POST BUILD script: starting..."

# source the common post build script
source "$BOARD_DIR/../post_build_common_60.sh" "$BOARD_DIR"

echo "${BR2_LRD_PLATFORM^^} POST BUILD script: done."
