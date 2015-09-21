TARGETDIR=$1

export BR2_LRD_PLATFORM=msd45n

echo "MSD45n POST BUILD script: starting..."

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
mkdir -p  $TARGETDIR/usr/smartBASICTemp
mv        $TARGETDIR/usr/share/smartBASIC $TARGETDIR/usr/smartBASICTemp
rm -rf -- $TARGETDIR/usr/share
mkdir -p  $TARGETDIR/usr/share
mv        $TARGETDIR/usr/smartBASICTemp/smartBASIC $TARGETDIR/usr/share
rm -rf -- $TARGETDIR/usr/smartBASICTemp
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

# copy firmware files
mkdir -p $TARGETDIR/lib/firmware
tar c --exclude=.svn -C board/laird/wb45n/rootfs-additions/lib/firmware . | tar x -C $TARGETDIR/lib/firmware

# create missing symbolic link
# TODO: shouldn't have to do this here, temporary workaround
( cd $TARGETDIR/usr/lib \
  && ln -sf libsdc_sdk.so.1.0 libsdc_sdk.so.1 )

# create missing symbolic link
# TODO: shouldn't have to do this here, temporary workaround
( cd $TARGETDIR/usr/lib \
  && ln -sf liblrd_btsdk.so.1.0 liblrd_btsdk.so.1 )

echo "MSD45n POST BUILD script: done."
