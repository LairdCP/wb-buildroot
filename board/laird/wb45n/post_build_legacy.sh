TARGETDIR=$1

export BR2_LRD_PLATFORM=wb45n

echo "WB45n POST BUILD legacy script: starting..."

# source the common post build legacy script
source "board/laird/post_build_common_legacy.sh" "$TARGETDIR"

# Copy the product specific rootfs additions
tar c --exclude=.svn --exclude=.empty -C board/laird/wb45n/rootfs-additions/ . | tar x -C $TARGETDIR/

# create a compressed backup copy of the /e/n/i file
gzip -c $TARGETDIR/etc/network/interfaces >$TARGETDIR/etc/network/interfaces~.gz

# Services to enable or disable by default
chmod a+x $TARGETDIR/etc/init.d/S??lighttpd

# Remove the custom bluetooth init-script if bluez utility is not included
[ -x $TARGETDIR/usr/sbin/hciconfig ] || rm -f /etc/init.d/opt/S??bluetooth

# adjust ssh_config and sshd_config to stop using root and use /etc/ instead.
sed -i "s/AuthorizedKeysFile.*/AuthorizedKeysFile\t\/etc\/.ssh\/authorized_keys/" $TARGETDIR/etc/ssh/sshd_config
echo "IdentityFile /etc/.ssh/identity" >> $TARGETDIR/etc/ssh/ssh_config
echo "IdentityFile /etc/.ssh/id_rsa" >> $TARGETDIR/etc/ssh/ssh_config
echo "IdentityFile /etc/.ssh/id_rsa" >> $TARGETDIR/etc/ssh/ssh_config
echo "UserKnownHostsFile /etc/.ssh/known_hosts" >> $TARGETDIR/etc/ssh/ssh_config

# add SSH directorys in /etc/
mkdir -p $TARGETDIR/etc/.ssh
touch $TARGETDIR/etc/.ssh/authorized_keys

# make sure SSH permissions are correct
chmod 700 $TARGETDIR/etc/.ssh
chmod 600 $TARGETDIR/etc/.ssh/authorized_keys

# adjust DCAS SSH location
sed -i "s/dcas_auth_dir.*/dcas_auth_dir=\/etc\/.ssh/" $TARGETDIR/etc/dcas.conf
sed -i "s/DEFAULT_AUTH_DIR=.*/DEFAULT_AUTH_DIR=\/etc\/.ssh/" $TARGETDIR/etc/init.d/S99dcas

# Fixup and add debugfs to fstab
echo 'nodev /sys/kernel/debug   debugfs   defaults   0  0' >> $TARGETDIR/etc/fstab

echo "WB45n POST BUILD script: done."
