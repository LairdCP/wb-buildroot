BR2_LRD_PRODUCT="$(sed -n 's,^BR2_DEFCONFIG=".*/\(.*\)_defconfig"$,\1,p' ${BR2_CONFIG})"
BOARD_DIR="$(realpath $(dirname $0))"

echo "${BR2_LRD_PRODUCT^^} POST BUILD legacy script: starting..."

# source the common post build legacy script
source "board/laird/post_build_common_legacy.sh" "${TARGET_DIR}"

# Copy the product specific rootfs additions
rsync -rlptDWK --exclude=.empty "${BOARD_DIR}/rootfs-additions/" "${TARGET_DIR}"

# create a compressed backup copy of the /e/n/i file
gzip -c ${TARGET_DIR}/etc/network/interfaces >${TARGET_DIR}/etc/network/interfaces~.gz

# Services to enable or disable by default
chmod a+x ${TARGET_DIR}/etc/init.d/S??lighttpd

# adjust ssh_config and sshd_config to stop using root and use /etc/ instead.
sed -i "s/AuthorizedKeysFile.*/AuthorizedKeysFile\t\/etc\/.ssh\/authorized_keys/" ${TARGET_DIR}/etc/ssh/sshd_config
echo "IdentityFile /etc/.ssh/identity" >> ${TARGET_DIR}/etc/ssh/ssh_config
echo "IdentityFile /etc/.ssh/id_rsa" >> ${TARGET_DIR}/etc/ssh/ssh_config
echo "IdentityFile /etc/.ssh/id_rsa" >> ${TARGET_DIR}/etc/ssh/ssh_config
echo "UserKnownHostsFile /etc/.ssh/known_hosts" >> ${TARGET_DIR}/etc/ssh/ssh_config

# add SSH directorys in /etc/
mkdir -p ${TARGET_DIR}/etc/.ssh
touch ${TARGET_DIR}/etc/.ssh/authorized_keys

# make sure SSH permissions are correct
chmod 700 ${TARGET_DIR}/etc/.ssh
chmod 600 ${TARGET_DIR}/etc/.ssh/authorized_keys

# adjust DCAS SSH location
sed -i "s/dcas_auth_dir.*/dcas_auth_dir=\/etc\/.ssh/" ${TARGET_DIR}/etc/dcas.conf
sed -i "s/DEFAULT_AUTH_DIR=.*/DEFAULT_AUTH_DIR=\/etc\/.ssh/" ${TARGET_DIR}/etc/init.d/opt/S99dcas

# Fixup and add debugfs to fstab
grep -q "/sys/kernel/debug" ${TARGET_DIR}/etc/fstab ||\
	echo 'nodev /sys/kernel/debug   debugfs   defaults   0  0' >> ${TARGET_DIR}/etc/fstab

echo "${BR2_LRD_PRODUCT^^} POST BUILD script: done."
