WB50N_SYSD_RDVK_DIR="$(realpath $(dirname $0))"
WB50N_SYSD_DIR="${WB50N_SYSD_RDVK_DIR}/../wb50n_sysd"

export BR2_LRD_PLATFORM="${2}"
DEVEL_KEYS="${3}"

echo "${BR2_LRD_PLATFORM^^} POST IMAGE script: starting..."

. "${WB50N_SYSD_RDVK_DIR}/../post_image_common_60.sh" "${WB50N_SYSD_DIR}" 1 "${DEVEL_KEYS}"

echo "${BR2_LRD_PLATFORM^^} POST IMAGE script: done."
