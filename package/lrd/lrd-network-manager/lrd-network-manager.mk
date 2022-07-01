################################################################################
#
# Laird network-manager
#
################################################################################

LRD_NETWORK_MANAGER_CVE_PRODUCT = network-manager
LRD_NETWORK_MANAGER_CVE_VERSION = 1.32.0

ifeq ($(BR2_LRD_DEVEL_BUILD),)
ifneq ($(BR2_PACKAGE_LRD_RADIO_STACK_VERSION_VALUE),)

LRD_NETWORK_MANAGER_VERSION = $(call qstrip,$(BR2_PACKAGE_LRD_RADIO_STACK_VERSION_VALUE))
LRD_NETWORK_MANAGER_SOURCE = lrd-network-manager-src-$(LRD_NETWORK_MANAGER_VERSION).tar.xz
ifeq ($(MSD_BINARIES_SOURCE_LOCATION),laird_internal)
  LRD_NETWORK_MANAGER_SITE = https://files.devops.rfpros.com/builds/linux/lrd-network-manager/src/$(LRD_NETWORK_MANAGER_VERSION)
else
  LRD_NETWORK_MANAGER_SITE = https://github.com/LairdCP/wb-package-archive/releases/download/LRD-REL-$(LRD_NETWORK_MANAGER_VERSION)
endif

endif
endif

ifeq ($(LRD_NETWORK_MANAGER_VERSION),)

LRD_NETWORK_MANAGER_VERSION = local
LRD_NETWORK_MANAGER_SITE = package/lrd/externals/lrd-network-manager
LRD_NETWORK_MANAGER_SITE_METHOD = local

endif

LRD_NETWORK_MANAGER_INSTALL_STAGING = YES
LRD_NETWORK_MANAGER_DEPENDENCIES = host-pkgconf udev gnutls libglib2 \
	libgcrypt util-linux host-intltool readline libndp
LRD_NETWORK_MANAGER_LICENSE = GPL-2.0+ (app), LGPL-2.1+ (libnm)
LRD_NETWORK_MANAGER_LICENSE_FILES = COPYING COPYING.LGPL CONTRIBUTING.md

LRD_NETWORK_MANAGER_AUTORECONF = YES

LRD_NETWORK_MANAGER_CONF_ENV = \
	ac_cv_path_LIBGCRYPT_CONFIG=$(STAGING_DIR)/usr/bin/libgcrypt-config \
	ac_cv_file__etc_fedora_release=no \
	ac_cv_file__etc_mandriva_release=no \
	ac_cv_file__etc_debian_version=no \
	ac_cv_file__etc_redhat_release=no \
	ac_cv_file__etc_SuSE_release=no

LRD_NETWORK_MANAGER_CONF_OPTS = \
	--without-tests \
	--disable-qt \
	--disable-more-warnings \
	--with-crypto=gnutls \
	--with-iptables=/usr/sbin/iptables \
	--disable-ifupdown \
	--without-nm-cloud-setup

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
LRD_NETWORK_MANAGER_CONF_OPTS += --with-dhcpcd=/sbin/dhcpcd --with-dhcpcd-supports-ipv6=yes
endif

ifeq ($(BR2_PACKAGE_LRD_NETWORK_MANAGER_OVS),y)
LRD_NETWORK_MANAGER_CONF_OPTS += --enable-ovs
LRD_NETWORK_MANAGER_DEPENDENCIES += jansson
else
LRD_NETWORK_MANAGER_CONF_OPTS += --disable-ovs
endif

ifeq ($(BR2_PACKAGE_GOBJECT_INTROSPECTION),y)
LRD_NETWORK_MANAGER_DEPENDENCIES += gobject-introspection
LRD_NETWORK_MANAGER_CONF_OPTS += --enable-introspection
else
LRD_NETWORK_MANAGER_CONF_OPTS += --disable-introspection
endif

ifeq ($(BR2_PACKAGE_LRD_FACTORY_RESET_TOOLKIT),y)
define LRD_NETWORK_MANAGER_UPDATE_SERVICE
	sed -i -e '/^ExecStart=/ s#.*#ExecStart=/usr/sbin/NetworkManager --no-daemon --config-dir=/data/secret/NetworkManager/conf.d --config=/data/secret/NetworkManager/NetworkManager.conf --state-file=/data/secret/NetworkManager/NetworkManager.state#g' $(TARGET_DIR)/usr/lib/systemd/system/NetworkManager.service
endef
endif

define LRD_NETWORK_MANAGER_INSTALL_INIT_SYSV
	$(INSTALL) -m 0755 -D package/network-manager/S45network-manager $(TARGET_DIR)/etc/init.d/S45network-manager
endef

define LRD_NETWORK_MANAGER_INSTALL_INIT_SYSTEMD
	ln -rsf $(TARGET_DIR)/usr/lib/systemd/system/NetworkManager.service \
		$(TARGET_DIR)/etc/systemd/system/dbus-org.freedesktop.NetworkManager.service

	$(LRD_NETWORK_MANAGER_UPDATE_SERVICE)
endef

$(eval $(autotools-package))
