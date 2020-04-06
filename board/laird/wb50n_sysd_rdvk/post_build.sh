WB50N_SYSD_RDVK_DIR="$(realpath $(dirname $0))"
WB50N_SYSD_DIR="$(realpath ${WB50N_SYSD_RDVK_DIR}/../wb50n_sysd)"

BUILD_TYPE="${2}"
DEVEL_KEYS="${3}"

. "${WB50N_SYSD_RDVK_DIR}/../post_build_common_60.sh" "${WB50N_SYSD_DIR}" "${BUILD_TYPE}" "${DEVEL_KEYS}"

rsync -rlptDWK --exclude=.empty "${WB50N_SYSD_RDVK_DIR}/rootfs-extra/" "${TARGET_DIR}"
