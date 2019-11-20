BOARD_DIR="$(dirname $0)"

export BR2_LRD_PLATFORM="${2}"

echo "${BR2_LRD_PLATFORM^^} POST IMAGE script: starting..."

# enable tracing and exit on errors
set -x -e

[ -z "${BR2_LRD_PRODUCT}" ] && \
	BR2_LRD_PRODUCT="$(sed -n 's,^BR2_DEFCONFIG=".*/\(.*\)_defconfig"$,\1,p' ${BR2_CONFIG})"

# Tooling checks
mkimage=${HOST_DIR}/bin/mkimage
atmel_pmecc_params=${BUILD_DIR}/uboot-custom/tools/atmel_pmecc_params

die() { echo "$@" >&2; exit 1; }
test -x ${mkimage} || \
	die "No mkimage found (host-uboot-tools has not been built?)"
test -x ${atmel_pmecc_params} || \
	die "no atmel_pmecc_params found (uboot has not been built?)"


# Then update SPL with appended keyed DTB
cat "${BINARIES_DIR}/u-boot-spl-nodtb.bin"  "${BINARIES_DIR}/u-boot-spl.dtb" > "${BINARIES_DIR}/u-boot-spl.bin"

# Regenerate Atmel PMECC boot.bin
${mkimage} -T atmelimage -n $(${atmel_pmecc_params}) -d ${BINARIES_DIR}/u-boot-spl.bin ${BINARIES_DIR}/boot.bin

# wbx3 sd card loading tools
cp ${BOARD_DIR}/../scripts-common/mksdcard-wbx3.sh ${BINARIES_DIR}/mksdcard.sh
cp ${BOARD_DIR}/../scripts-common/mksdimg-wbx3.sh ${BINARIES_DIR}/mksdimg.sh

echo "${BR2_LRD_PLATFORM^^} POST IMAGE script: done."
