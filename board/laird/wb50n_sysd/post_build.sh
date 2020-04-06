BOARD_DIR="$(realpath $(dirname $0))"
BUILD_TYPE="${2}"
DEVEL_KEYS="${3}"

. "${BOARD_DIR}/../post_build_common_60.sh" "${BOARD_DIR}"  "${BUILD_TYPE}"  "${DEVEL_KEYS}"
