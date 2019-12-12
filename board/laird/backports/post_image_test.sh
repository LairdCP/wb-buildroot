# enable tracing and exit on errors
set -x -e

[ -n "${LAIRD_RELEASE_STRING}" ] && RELEASE_SUFFIX="-${LAIRD_RELEASE_STRING}"

BACKPORTS_TEST_DIR=$(echo ${BUILD_DIR}/host-backports-test* | head -1)

mkdir -p ${BINARIES_DIR}

cp ${BACKPORTS_TEST_DIR}/ckmake.log \
	${BINARIES_DIR}/ckmake-regression-test${RELEASE_SUFFIX}.log

cp ${BACKPORTS_TEST_DIR}/ckmake-report.log \
	${BINARIES_DIR}/ckmake-report-regression-test-${RELEASE_SUFFIX}.log

if grep -q FAIL ${BACKPORTS_TEST_DIR}/ckmake-report.log; then
	echo "Failure reported in backports regression tests."
	exit 1
fi
