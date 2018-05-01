IMAGESDIR="$1"
TOPDIR="`pwd`"

# enable tracing and exit on errors
set -x -e

if [ -z "$LAIRD_RELEASE_STRING" ]; then
	LAIRD_RELEASE_STRING=`date +%Y%m%d`
fi

echo "$BR2_LRD_PLATFORM\n"
echo "$BR2_LRD_PRODUCT\n"
echo "$LAIRD_RELEASE_STRING\n"
echo "Destination: ${IMAGESDIR}/${BR2_LRD_PLATFORM}_${LAIRD_RELEASE_STRING// /_}.swu\n"

FILES="sw-description $2"
for i in $FILES; do
	if [ -f $i ]; then
		echo $i
	fi
done | cpio -ov -H crc > ${IMAGESDIR}/${BR2_LRD_PLATFORM}_${LAIRD_RELEASE_STRING// /_}.swu
