BOARD_DIR="$(realpath $(dirname $0))"

export BR2_LRD_PLATFORM=wb50n

echo "${BR2_LRD_PLATFORM^^} POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

# Ubinize the squash filesystems
(
cd ${BINARIES_DIR}
${HOST_DIR}/sbin/ubinize -o sqroot.ubi -m 0x800 -p 0x20000 \
	${BOARD_DIR}/squashfs-ubinize.cfg
cp sqroot.ubi sqroot.bin
)

# source the common post image script
. "${BOARD_DIR}/../post_image_common.sh" "${BINARIES_DIR}"

echo "${BR2_LRD_PLATFORM^^} POST IMAGE script: done."
