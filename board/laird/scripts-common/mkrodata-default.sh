#!/bin/sh
#
# mkrodata-default.sh - Create read-only factory data image
#
# usage: mkrodata-default.sh <buildroot dir>
#
# This script requires the modified 'fscryptctl' binary (from the build artifacts)
# to be located in the current directory.
#
# This script must be run as root!
#
[ $# -lt 1 ] && echo "usage: mkrodata-default.sh <buildroot dir>" && exit 1

WEBLCM_DIR=${1}/package/lrd/externals/weblcm-python/ssl
BOARD_DIR=${1}/board/laird/configs-common/keys

./mkrodata.sh ${BOARD_DIR}/key-fs.bin ${BOARD_DIR}/dev.pem ${WEBLCM_DIR}/server.crt ${WEBLCM_DIR}/server.key ${WEBLCM_DIR}/ca.crt

mv -f rodata.img ${1}/package/lrd/lrd-encrypted-storage-toolkit/rootfs/etc/rodata
