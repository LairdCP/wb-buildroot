BUILD_TYPE="${2}"

echo "WB45n POST BUILD script: starting..."

# source the common post build script
. board/laird/post_build_common_legacy.sh "${BUILD_TYPE}"

echo "WB45n POST BUILD script: done."
