TARGETDIR=$1

echo "COMMON POST BUILD legacy script: starting..."

# enable tracing and exit on errors
set -x -e

# Set root password to ’root’. Password generated with
# mkpasswd, from the ’whois’ package in Debian/Ubuntu.
## sed -i ’s%^root::%root:8kfIfYHmcyQEE:%’ $TARGETDIR/etc/shadow

# Application/log file mount point
#mkdir -p $TARGETDIR/applog
## grep -q "^/dev/mtdblock7" $TARGETDIR/etc/fstab || \
## echo "/dev/mtdblock7\t\t/applog\tjffs2\tdefaults\t\t0\t0" \
## >> $TARGETDIR/etc/fstab

# disable 3.8* ipv6 module to kernel space corruption - temporary
# pv6-/-netlink conflict
# bluetooth init conflict
#for p in $TARGETDIR/lib/modules/3.8*/kernel/net/ipv6
#do
#  [ -f $p/ipv6.ko ] && ( cd $p && mv -- ipv6.ko -ipv6.ko )
#done

# remove default ssh init file
# real version is in init.d/opt and works w/ inetd or standalone
rm -f $TARGETDIR/etc/init.d/S50sshd

# remove default init's, they are replaced
rm -f $TARGETDIR/etc/init.d/S50lighttpd
rm -f $TARGETDIR/etc/init.d/S01logging
rm -f $TARGETDIR/etc/init.d/S20urandom
rm -f $TARGETDIR/etc/init.d/S40wifi
rm -f $TARGETDIR/etc/init.d/S40network

#remove the dhcp init scripts
rm -f $TARGETDIR/etc/init.d/S80dhcp-relay
rm -f $TARGETDIR/etc/init.d/S80dhcp-server

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

# Copy the rootfs-additions-common in place first.
# If necessary, these can be overwritten by the product specific rootfs-additions.
tar c --exclude=.svn --exclude=.empty -C board/laird/rootfs-additions-common/ . | tar x -C $TARGETDIR/

# install libnl*.so.3 links
( cd "$TARGETDIR/usr/lib" \
  && ln -sf libnl-3.so libnl.so.3 \
  && ln -sf libnl-genl-3.so libnl-genl.so.3 )

# create missing symbolic link
# TODO: shouldn't have to do this here, temporary workaround
( cd $TARGETDIR/usr/lib \
  && ln -sf libsdc_sdk.so.1.0 libsdc_sdk.so.1 )

# wireless.sh won't be able to create this with the ro filesystem
( cd $TARGETDIR \
  && ln -sf /etc/network/wireless.sh sbin/wireless )

# Services to disable by default
[ -f $TARGETDIR/etc/init.d/S??lighttpd ] \
&& chmod a-x $TARGETDIR/etc/init.d/S??lighttpd
[ -f $TARGETDIR/etc/init.d/S??openvpn ] \
&& chmod a-x $TARGETDIR/etc/init.d/S??openvpn     #not ready for use

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

echo "COMMON POST BUILD script: done."
