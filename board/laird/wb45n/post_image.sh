IMAGESDIR="$1"

export BR2_LRD_PLATFORM=wb45n
export BR2_LRD_PRODUCT=wb45n

echo "WB45n POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

# source the common post image script
source "board/laird/post_image_common.sh" "$IMAGESDIR"

word=$(stat -c "%s" ${IMAGESDIR}/kernel.bin)
if [ $word -gt 2359296 ]
then
	echo "kernel size exceeded 18 block limit, failed"
	exit 1
fi

echo "WB45n POST IMAGE script: done."
