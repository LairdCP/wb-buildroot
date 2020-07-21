echo "COMMON POST BUILD legacy script: starting..."

# enable tracing and exit on errors
set -x -e

# remove default ssh init file
# real version is in init.d/opt and works w/ inetd or standalone
rm -f ${TARGET_DIR}/etc/init.d/S50sshd

# remove default init's, they are replaced
rm -f ${TARGET_DIR}/etc/init.d/S50lighttpd
rm -f ${TARGET_DIR}/etc/init.d/S20urandom
rm -f ${TARGET_DIR}/etc/init.d/S40network

#remove the dhcp init scripts
rm -f ${TARGET_DIR}/etc/init.d/S80dhcp-relay
rm -f ${TARGET_DIR}/etc/init.d/S80dhcp-server

# remove perl cruft
rm -f ${TARGET_DIR}/etc/ssl/misc/tsget
rm -f ${TARGET_DIR}/etc/ssl/misc/CA.pl
rm -f ${TARGET_DIR}/usr/bin/pcf2vpnc
rm -f ${TARGET_DIR}/usr/bin/chkdupexe

# remove debian cruft
rm -fr ${TARGET_DIR}/etc/network/if-*

# Copy the rootfs-additions-common in place first.
# If necessary, these can be overwritten by the product specific rootfs-additions.
rsync -rlptDWK --exclude=.empty "board/laird/rootfs-additions-common/" "${TARGET_DIR}"

# install libnl*.so.3 links
ln -rsf ${TARGET_DIR}/usr/lib/libnl-3.so ${TARGET_DIR}/usr/lib/libnl.so.3
ln -rsf ${TARGET_DIR}/usr/lib/libnl-genl-3.so ${TARGET_DIR}/usr/lib/libnl-genl.so.3

# create missing symbolic link
# TODO: shouldn't have to do this here, temporary workaround
ln -rsf ${TARGET_DIR}/usr/lib/libsdc_sdk.so.1.0 ${TARGET_DIR}/usr/lib/libsdc_sdk.so.1

# wireless.sh won't be able to create this with the ro filesystem
ln -rsf ${TARGET_DIR}/etc/network/wireless.sh ${TARGET_DIR}/sbin/wireless

# Services to disable by default
[ -f ${TARGET_DIR}/etc/init.d/S??lighttpd ] && \
	chmod a-x ${TARGET_DIR}/etc/init.d/S??lighttpd

# background the bluetooth init-script
[ -x ${TARGET_DIR}/etc/init.d/S95bluetooth ] && \
	mv ${TARGET_DIR}/etc/init.d/S95bluetooth ${TARGET_DIR}/etc/init.d/S95bluetooth.bg

# create a compressed backup copy of the /e/n/i file
gzip -c ${TARGET_DIR}/etc/network/interfaces >${TARGET_DIR}/etc/network/interfaces~.gz

# Create default firmware description file.
# This may be overwritten by a proper release file.
LOCRELSTR="${LAIRD_RELEASE_STRING}"
if [ -z "${LOCRELSTR}" ] || [ "${LOCRELSTR}" == "0.0.0.0" ]; then
	LOCRELSTR="Summit Linux development build 0.${BR2_LRD_BRANCH}.0.0 $(date +%Y%m%d)"
fi

[ -z "${VERSION}" ] && LOCVER="0.${BR2_LRD_BRANCH}.0.0" || LOCVER="${VERSION}"

echo -ne \
"NAME=\"Summit Linux\"\n"\
"VERSION=\"${LOCRELSTR}\"\n"\
"ID=${BR2_LRD_PRODUCT}\n"\
"VERSION_ID=${LOCVER}\n"\
"BUILD_ID=${LOCRELSTR##* }\n"\
"PRETTY_NAME=\"${LOCRELSTR}\"\n"\
>  "${TARGET_DIR}/usr/lib/os-release"

ln -rsf ${TARGET_DIR}/usr/lib/os-release ${TARGET_DIR}/etc/os-release

echo "COMMON POST BUILD script: done."
