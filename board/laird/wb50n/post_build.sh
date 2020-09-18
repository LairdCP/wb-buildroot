BUILD_TYPE="${2}"

echo "WB50n POST BUILD legacy script: starting..."

# source the common post build legacy script
. board/laird/post_build_common_legacy.sh "${BUILD_TYPE}"

echo "WB50n POST BUILD script: done."
