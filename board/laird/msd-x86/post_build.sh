TARGETDIR=$1

export BR2_LRD_PLATFORM=msd-x86

echo "MSD-x86 POST BUILD script: starting..."

# enable tracing and exit on errors
set -x -e

# cleanup
rm -f  -- $TARGETDIR/lib64 $TARGETDIR/usr/lib64
rm -rf -- $TARGETDIR/var/cache
rm -f -- $TARGETDIR/etc/ld.*
rm -f -- $TARGETDIR/etc/os-release
rm -rf -- $TARGETDIR/etc/libnl
rm -rf -- $TARGETDIR/etc/ssl
rm -rf -- $TARGETDIR/etc/wireless-regdb
rm -rf -- $TARGETDIR/usr/share
rm -rf -- $TARGETDIR/usr/sbin/nl* $TARGETDIR/usr/sbin/genl*
rm -f  -- $TARGETDIR/sbin/regdbdump
rm -f  -- $TARGETDIR/usr/lib/libstdc++*
rm -f  -- $TARGETDIR/usr/lib/terminfo
rm -f  -- $TARGETDIR/lib/ld-*
rm -f  -- $TARGETDIR/lib/libc[.-]*so*
rm -f  -- $TARGETDIR/lib/libdl[.-]*so*
rm -f  -- $TARGETDIR/lib/libm[.-]*so*
rm -f  -- $TARGETDIR/lib/libnsl[.-]*so*
rm -f  -- $TARGETDIR/lib/libnss[._-]*so*
rm -f  -- $TARGETDIR/lib/libpthread[.-]*so*
rm -f  -- $TARGETDIR/lib/libresolv[.-]*so*
rm -f  -- $TARGETDIR/lib/libcrypt[.-]*so*
rm -f  -- $TARGETDIR/lib/librt[.-]*so*
rm -f  -- $TARGETDIR/lib/libutil[.-]*so*
rm -f  -- $TARGETDIR/lib/libgcc_s[.-]*so*

# fips cleanup - shoudl be harmless on non-fips
rm -rf -- $TARGETDIR/usr/local
rm -f  -- $TARGETDIR/lib/modules/*/modules*
rm -rf -- $TARGETDIR/lib/modules/*/kernel

# copy log_dump
cp board/laird/rootfs-additions-common/usr/bin/log_dump $TARGETDIR/usr/bin/

echo "MSD-x86 POST BUILD script: done."
