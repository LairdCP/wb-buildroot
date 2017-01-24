set -x -e
TARGETDIR=$1

export BR2_LRD_PLATFORM=wb50n
echo "WB50n_RDVK POST BUILD script: starting..."

# remove default ssh init file
# real version is in init.d/opt and works w/ inetd or standalone
rm -f $TARGETDIR/etc/init.d/S50sshd

# remove default init's, they are replaced
rm -f $TARGETDIR/etc/init.d/S50lighttpd
rm -f $TARGETDIR/etc/init.d/S01logging
rm -f $TARGETDIR/etc/init.d/S20urandom

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

# Copy the product specific rootfs additions - we don't currently use rootfs-common
tar c --exclude=.svn --exclude=.empty -C board/laird/wb50n_rdvk/rootfs-additions/ . | tar x -C $TARGETDIR/

# install libnl*.so.3 links
( cd "$TARGETDIR/usr/lib" \
  && ln -sf libnl-3.so libnl.so.3 \
  && ln -sf libnl-genl-3.so libnl-genl.so.3 )

# create missing symbolic link
# TODO: shouldn't have to do this here, temporary workaround
( cd $TARGETDIR/usr/lib \
  && ln -sf libsdc_sdk.so.1.0 libsdc_sdk.so.1 )

# Services to disable by default
[ -f $TARGETDIR/etc/init.d/S??lighttpd ] \
&& chmod a-x $TARGETDIR/etc/init.d/S??lighttpd
[ -f $TARGETDIR/etc/init.d/S??openvpn ] \
&& chmod a-x $TARGETDIR/etc/init.d/S??openvpn     #not ready for use
[ -f $TARGETDIR/etc/init.d/S??bluetooth ] \
&& chmod a-x $TARGETDIR/etc/init.d/S??bluetooth

# background the bluetooth init-script
[ -x $TARGETDIR/etc/init.d/S95bluetooth ] \
&& mv $TARGETDIR/etc/init.d/S95bluetooth $TARGETDIR/etc/init.d/S95bluetooth.bg

# create a compressed backup copy of the /e/n/i file
gzip -c $TARGETDIR/etc/network/interfaces >$TARGETDIR/etc/network/interfaces~.gz

# Create default firmware description file.
# This may be overwritten by a proper release file.
if [ -z "$LAIRD_RELEASE_STRING" ]; then
  echo "Laird Linux development build `date +%Y%m%d`" \
    > $TARGETDIR/etc/laird-release
else
  echo "$LAIRD_RELEASE_STRING" > $TARGETDIR/etc/laird-release
fi

# Fixup and add debugfs to fstab
echo 'nodev /sys/kernel/debug   debugfs   defaults   0  0' >> $TARGETDIR/etc/fstab

mkdir -p $TARGETDIR/etc/NetworkManager/system-connections

echo "WB50n RDVK POST BUILD script: done."
