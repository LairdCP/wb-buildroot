BR2_LRD_PLATFORM=wb45n

echo "${BR2_LRD_PLATFORM^^} POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

# source the common post image script
. "board/laird/post_image_common.sh" "${BINARIES_DIR}"

word=$(stat -c "%s" ${BINARIES_DIR}/kernel.bin)
if [ ${word} -gt 2359296 ]; then
	echo "kernel size exceeded 18 block limit, failed"
	exit 1
fi

echo "${BR2_LRD_PLATFORM^^} POST IMAGE script: done."
