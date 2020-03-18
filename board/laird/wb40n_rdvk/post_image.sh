BR2_LRD_PRODUCT="$(sed -n 's,^BR2_DEFCONFIG=".*/\(.*\)_defconfig"$,\1,p' ${BR2_CONFIG})"
TOPDIR="${PWD}"

echo "${BR2_LRD_PRODUCT^^} POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

# source the common post image script
. "board/laird/post_image_common.sh" "${BINARIES_DIR}"

echo "${BR2_LRD_PRODUCT^^} POST IMAGE script: done."
