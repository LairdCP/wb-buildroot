# enable tracing and exit on errors
set -x -e

WB50N_SYSD_RDVK_DIR="$(realpath $(dirname $0))"
WB50N_SYSD_DIR="${WB50N_SYSD_RDVK_DIR}/../wb50n_sysd"

export BR2_LRD_PLATFORM="${2}"

echo "${BR2_LRD_PLATFORM^^} POST BUILD script: starting..."

# source the common post build script
. "${WB50N_SYSD_RDVK_DIR}/../post_build_common_60.sh" "${WB50N_SYSD_DIR}" 1

rsync -rlptDWK --exclude=.empty "${WB50N_SYSD_RDVK_DIR}/rootfs-extra/" "${TARGET_DIR}"

echo "${BR2_LRD_PLATFORM^^} POST BUILD script: done."
