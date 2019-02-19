TLSDATE_VERSION = 0.0.13
TLSDATE_SITE = http://ftp.de.debian.org/debian/pool/main/t/tlsdate
TLSDATE_SOURCE = tlsdate_${TLSDATE_VERSION}.orig.tar.xz
TLSDATE_DEPENDENCIES = host-pkgconf openssl libevent
TLSDATE_CONF_OPTS = --disable-hardened-checks --without-polarssl
TLSDATE_AUTORECONF = YES

ifeq ($(BR2_PACKAGE_LIBSECCOMP),)
TLSDATE_CONF_OPTS += --disable-seccomp-filter
endif

ifeq ($(BR2_PACKAGE_DBUS),y)
TLSDATE_DEPENDENCIES += dbus
TLSDATE_CONF_OPTS += --enable-dbus

define TLSDATE_INSTALL_DBUS_CONF
	$(INSTALL) -m 0644 package/tlsdate/org.torproject.tlsdate.conf $(TARGET_DIR)/etc/dbus-1/system.d
endef
TLSDATE_POST_INSTALL_TARGET_HOOKS += TLSDATE_INSTALL_DBUS_CONF
endif

define TLSDATE_INSTALL_DAEMON_INITSCRIPT
	$(INSTALL) -m 0755 package/tlsdate/S75tlsdate $(TARGET_DIR)/etc/init.d/
endef
TLSDATE_POST_INSTALL_TARGET_HOOKS += TLSDATE_INSTALL_DAEMON_INITSCRIPT

$(eval $(autotools-package))
