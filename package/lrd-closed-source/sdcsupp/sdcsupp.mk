#############################################################
#
# SDC Supplicant
#
#############################################################

SDCSUPP_VERSION = local
SDCSUPP_SITE = package/lrd-closed-source/externals/wpa_supplicant
SDCSUPP_SITE_METHOD = local
SDCSUPP_DBUS_NEW_SERVICE = fi.w1.wpa_supplicant1
SDCSUPP_BINDIR = /usr/sbin

SDCSUPP_DEPENDENCIES = host-pkgconf libnl openssl
SDCSUPP_TARGET_DIR = $(TARGET_DIR)
SDCSUPP_MAKE_ENV = PKG_CONFIG="$(HOST_DIR)"/usr/bin/pkg-config

# old supplicant structure used $(@D)/wpa_supplicant/wpa_supplicant
SDCSUPP_D = $(@D)/wpa_supplicant


SDCSUPP_RADIO_FLAGS := CONFIG_SDC_RADIO_QCA45N=y CONFIG_DRIVER_NL80211=y
ifneq ($(BR2_PACKAGE_OPENSSL_FIPS),)
SDCSUPP_FIPS = CONFIG_FIPS=y
ifeq ($(BR2_PACKAGE_LAIRD_OPENSSL_FIPS),y)
SDCSUPP_FIPS += CONFIG_FIPS_LAIRD=y
endif
else
ifeq ($(BR2_PACKAGE_LAIRD_OPENSSL_FIPS_BINARIES),y)
SDCSUPP_FIPS = CONFIG_FIPS=y
SDCSUPP_FIPS += CONFIG_FIPS_LAIRD=y
endif
endif

ifeq ($(BR2_PACKAGE_SDCSUPP_LEGACY),y)
	SDCSUPP_CONFIG = $(SDCSUPP_D)/config_legacy
else
	SDCSUPP_DEPENDENCIES += dbus
	SDCSUPP_CONFIG = $(SDCSUPP_D)/config_openssl
endif

define SDCSUPP_BUILD_CMDS
	cp $(SDCSUPP_CONFIG) $(SDCSUPP_D)/.config
	$(MAKE) -C $(SDCSUPP_D) clean
	CFLAGS="-I$(STAGING_DIR)/usr/include/libnl3 $(TARGET_CFLAGS) -MMD -Wall -g" \
		$(SDCSUPP_MAKE_ENV) $(MAKE) -C $(SDCSUPP_D) V=1 NEED_TLS_LIBDL=1 $(SDCSUPP_FIPS) \
			$(SDCSUPP_RADIO_FLAGS) CROSS_COMPILE="$(TARGET_CROSS)" BINDIR=$(SDCSUPP_BINDIR)
	$(TARGET_CROSS)objcopy -S $(SDCSUPP_D)/wpa_supplicant $(SDCSUPP_D)/sdcsupp
	#(cd $(SDCSUPP_D) && CROSS_COMPILE=arm-sdc-linux-gnueabi ./sdc-build-linux.sh 4 1 2 3 1)
endef

ifeq ($(BR2_PACKAGE_SDCSUPP_WPA_CLI),y)
define SDCSUPP_INSTALL_WPA_CLI
	$(INSTALL) -D -m 755 $(SDCSUPP_D)/wpa_cli $(SDCSUPP_TARGET_DIR)$(SDCSUPP_BINDIR)/wpa_cli
endef
endif

ifeq ($(BR2_PACKAGE_SDCSUPP_WPA_PASSPHRASE),y)
define SDCSUPP_INSTALL_WPA_PASSPHRASE
	$(INSTALL) -D -m 755 $(SDCSUPP_D)/wpa_passphrase $(SDCSUPP_TARGET_DIR)/usr/bin/wpa_passphrase
endef
endif

ifneq ($(BR2_PACKAGE_SDCSUPP_LEGACY),y)

ifeq ($(BR2_PACKAGE_WPA_SUPPLICANT),y)
	# both wpa_supplicant and sdcsupp installed, postfix to avoid collision
	SDCSUPP_DBUS_SERVICE_POSTFIX = .summit
else
	# only sdcsupp installed, no postfix needed
	SDCSUPP_DBUS_SERVICE_POSTFIX =
endif

define SDCSUPP_INSTALL_DBUS_NEW
	$(INSTALL) -m 0644 -D \
		$(SDCSUPP_D)/dbus/$(SDCSUPP_DBUS_NEW_SERVICE).service \
		$(TARGET_DIR)/usr/share/dbus-1/system-services/$(SDCSUPP_DBUS_NEW_SERVICE).service$(SDCSUPP_DBUS_SERVICE_POSTFIX)
endef

define SDCSUPP_INSTALL_DBUS
	$(INSTALL) -m 0644 -D \
		$(SDCSUPP_D)/dbus/dbus-wpa_supplicant.conf \
		$(TARGET_DIR)/etc/dbus-1/system.d/wpa_supplicant.conf
	$(SDCSUPP_INSTALL_DBUS_NEW)
endef

define SDCSUPP_INSTALL_WPA_CLIENT_SO
	$(INSTALL) -m 0644 -D $(@D)/$(WPA_SUPPLICANT_SUBDIR)/libwpa_client.so \
		$(TARGET_DIR)/usr/lib/libwpa_client.so
endef

# install the wpa_client library
SDCSUPP_INSTALL_STAGING = YES

define SDCSUPP_INSTALL_STAGING_WPA_CLIENT_SO
	$(INSTALL) -m 0644 -D $(@D)/$(WPA_SUPPLICANT_SUBDIR)/libwpa_client.so \
		$(STAGING_DIR)/usr/lib/libwpa_client.so
	$(INSTALL) -m 0644 -D $(@D)/src/common/wpa_ctrl.h \
		$(STAGING_DIR)/usr/include/wpa_ctrl.h
endef

endif

define SDCSUPP_INSTALL_STAGING_CMDS
	$(SDCSUPP_INSTALL_STAGING_WPA_CLIENT_SO)
endef

define SDCSUPP_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(SDCSUPP_D)/sdcsupp $(SDCSUPP_TARGET_DIR)$(SDCSUPP_BINDIR)/sdcsupp
	$(SDCSUPP_INSTALL_WPA_CLI)
	$(SDCSUPP_INSTALL_WPA_PASSPHRASE)
	$(SDCSUPP_INSTALL_DBUS)
	$(SDCSUPP_INSTALL_WPA_CLIENT_SO)
endef

define SDCSUPP_INSTALL_INIT_SYSTEMD
	$(INSTALL) -m 0644 -D $(SDCSUPP_D)/systemd/wpa_supplicant.service \
		$(TARGET_DIR)/usr/lib/systemd/system/wpa_supplicant.service
	$(INSTALL) -m 0644 -D $(SDCSUPP_D)/systemd/wpa_supplicant@.service \
		$(TARGET_DIR)/usr/lib/systemd/system/wpa_supplicant@.service
	$(INSTALL) -m 0644 -D $(SDCSUPP_D)/systemd/wpa_supplicant-nl80211@.service \
		$(TARGET_DIR)/usr/lib/systemd/system/wpa_supplicant-nl80211@.service
	$(INSTALL) -m 0644 -D $(SDCSUPP_D)/systemd/wpa_supplicant-wired@.service \
		$(TARGET_DIR)/usr/lib/systemd/system/wpa_supplicant-wired@.service
	$(INSTALL) -m 0644 -D $(SDCSUPP_PKGDIR)/50-wpa_supplicant.preset \
		$(TARGET_DIR)/usr/lib/systemd/system-preset/50-wpa_supplicant.preset
endef

ifeq ($(BR2_INIT_NONE),y)
SDCSUPP_POST_INSTALL_TARGET_HOOKS += SDCSUPP_INSTALL_INIT_SYSTEMD
endif

define SDCSUPP_UNINSTALL_TARGET_CMDS
	rm -f $(SDCSUPP_TARGET_DIR)$(SDCSUPP_BINDIR)/sdcsupp
endef

$(eval $(generic-package))
