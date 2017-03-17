set -x -e
TARGETDIR=$1

export BR2_LRD_PLATFORM=wb50n
echo "WB50n_RDVK POST BUILD script: starting..."

# remove bash cruft
rm -fr $TARGETDIR/etc/bash*
rm -f $TARGETDIR/root/.bash*
rm -f $TARGETDIR/sbin/rtpr
rm -f $TARGETDIR/usr/share/getopt/getopt-parse.bash

# remove perl cruft
rm -f $TARGETDIR/etc/ssl/misc/tsget
rm -f $TARGETDIR/etc/ssl/misc/CA.pl
rm -f $TARGETDIR/usr/bin/pcf2vpnc
rm -f $TARGETDIR/usr/bin/chkdupexe

# remove debian cruft
rm -fr $TARGETDIR/etc/network/if-*

# remove buildroot cruft
rm -f $TARGETDIR/etc/os-release

# remove conflicting rcK
rm -f $TARGETDIR/etc/init.d/rcK

# remove /run due to our somewhat-wonky redirection of it to /tmp via a symlink
# avoids breaking the build, but it will also loose stuff if a package needs to
# create something in /run or a subdirectory.
rm -rf $TARGETDIR/run

# source the common post build script
source "board/laird/post_build_common.sh" "$TARGETDIR"

# Copy the product specific rootfs additions - we don't currently use rootfs-common
tar c --exclude=.svn --exclude=.empty -C board/laird/wb50n_rdvk/rootfs-additions/ . | tar x -C $TARGETDIR/

# Fixup and add debugfs to fstab
echo 'nodev /sys/kernel/debug   debugfs   defaults   0  0' >> $TARGETDIR/etc/fstab

echo "WB50n RDVK POST BUILD script: done."
