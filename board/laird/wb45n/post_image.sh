BR2_LRD_PLATFORM=wb45n

echo "${BR2_LRD_PLATFORM^^} POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

# source the common post image script
. "board/laird/post_image_common.sh" "${BINARIES_DIR}"

echo "${BR2_LRD_PLATFORM^^} POST IMAGE script: done."
