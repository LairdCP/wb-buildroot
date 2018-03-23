################################################################################
#
# Laird network-manager
#
################################################################################

LRD_NETWORK_MANAGER_VERSION = local
LRD_NETWORK_MANAGER_SITE = package/lrd/externals/lrd-network-manager
LRD_NETWORK_MANAGER_SITE_METHOD = local
LRD_NETWORK_MANAGER_INSTALL_STAGING = YES
LRD_NETWORK_MANAGER_DEPENDENCIES = host-pkgconf udev dbus-glib libnl gnutls \
	libgcrypt wireless_tools util-linux host-intltool readline libndp libgudev
LRD_NETWORK_MANAGER_LICENSE = GPL-2.0+ (app), LGPL-2.0+ (libnm-util)
LRD_NETWORK_MANAGER_LICENSE_FILES = COPYING libnm-util/COPYING

LRD_NETWORK_MANAGER_AUTORECONF = YES

LRD_NETWORK_MANAGER_CONF_ENV = \
	ac_cv_path_LIBGCRYPT_CONFIG=$(STAGING_DIR)/usr/bin/libgcrypt-config \
	ac_cv_file__etc_fedora_release=no \
	ac_cv_file__etc_mandriva_release=no \
	ac_cv_file__etc_debian_version=no \
	ac_cv_file__etc_redhat_release=no \
	ac_cv_file__etc_SuSE_release=no

LRD_NETWORK_MANAGER_CONF_OPTS = \
	--enable-ovs=no \
	--enable-ifcfg_rh=no \
	--disable-tests \
	--disable-qt \
	--disable-more-warnings \
	--without-docs \
	--with-crypto=gnutls \
	--with-iptables=/usr/sbin/iptables \
	--disable-ifupdown \
	--disable-ifnet

ifeq ($(BR2_PACKAGE_OFONO),y)
LRD_NETWORK_MANAGER_DEPENDENCIES += ofono
LRD_NETWORK_MANAGER_CONF_OPTS += --with-ofono
else
LRD_NETWORK_MANAGER_CONF_OPTS += --without-ofono
endif

ifeq ($(BR2_PACKAGE_LIBCURL),y)
LRD_NETWORK_MANAGER_DEPENDENCIES += libcurl
LRD_NETWORK_MANAGER_CONF_OPTS += --enable-concheck
else
LRD_NETWORK_MANAGER_CONF_OPTS += --disable-concheck
endif

ifeq ($(BR2_PACKAGE_LRD_NETWORK_MANAGER_TUI),y)
LRD_NETWORK_MANAGER_DEPENDENCIES += newt
LRD_NETWORK_MANAGER_CONF_OPTS += --with-nmtui=yes
else
LRD_NETWORK_MANAGER_CONF_OPTS += --with-nmtui=no
endif

ifeq ($(BR2_PACKAGE_LRD_NETWORK_MANAGER_PPPD),y)
LRD_NETWORK_MANAGER_DEPENDENCIES += pppd
LRD_NETWORK_MANAGER_CONF_OPTS += --enable-ppp
else
LRD_NETWORK_MANAGER_CONF_OPTS += --disable-ppp
endif

ifeq ($(BR2_PACKAGE_LRD_NETWORK_MANAGER_MODEM_MANAGER),y)
LRD_NETWORK_MANAGER_DEPENDENCIES += modem-manager
LRD_NETWORK_MANAGER_CONF_OPTS += --with-modem-manager-1
else
LRD_NETWORK_MANAGER_CONF_OPTS += --without-modem-manager-1
endif

ifeq ($(BR2_PACKAGE_DHCP_CLIENT),y)
LRD_NETWORK_MANAGER_CONF_OPTS += --with-dhclient=/sbin/dhclient
endif

ifeq ($(BR2_PACKAGE_DHCPCD),y)
LRD_NETWORK_MANAGER_CONF_OPTS += --with-dhcpcd=/sbin/dhcpcd
endif

# uClibc by default doesn't have backtrace support, so don't use it
ifeq ($(BR2_TOOLCHAIN_USES_UCLIBC),y)
LRD_NETWORK_MANAGER_CONF_OPTS += --disable-crashtrace
endif

define LRD_NETWORK_MANAGER_INSTALL_INIT_SYSV
	$(INSTALL) -m 0755 -D package/network-manager/S45network-manager $(TARGET_DIR)/etc/init.d/S45network-manager
endef

define LRD_NETWORK_MANAGER_INSTALL_INIT_SYSTEMD
	mkdir -p $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants

	ln -sf /usr/lib/systemd/system/NetworkManager.service \
		$(TARGET_DIR)/etc/systemd/system/dbus-org.freedesktop.NetworkManager.service

	ln -sf /usr/lib/systemd/system/NetworkManager.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/NetworkManager.service

	ln -sf /usr/lib/systemd/system/NetworkManager-dispatcher.service \
		$(TARGET_DIR)/etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service
endef

$(eval $(autotools-package))
