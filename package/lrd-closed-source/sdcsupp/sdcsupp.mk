#############################################################
#
# SDC Supplicant
#
#############################################################

SDCSUPP_VERSION = local
SDCSUPP_SITE = package/lrd-closed-source/externals/wpa_supplicant
SDCSUPP_SITE_METHOD = local
SDCSUPP_DBUS_NEW_SERVICE = fi.w1.wpa_supplicant1

SDCSUPP_DEPENDENCIES = host-pkgconf libnl openssl
SDCSUPP_TARGET_DIR = $(TARGET_DIR)
SDCSUPP_MAKE_ENV = PKG_CONFIG="$(HOST_DIR)"/usr/bin/pkg-config

# old supplicant structure used $(@D)/wpa_supplicant/wpa_supplicant
SDCSUPP_D = $(@D)/wpa_supplicant

SDCSUPP_RADIO_FLAGS := CONFIG_SDC_RADIO_QCA45N=y CONFIG_DRIVER_NL80211=y
ifneq ($(BR2_PACKAGE_OPENSSL_FIPS),)
SDCSUPP_FIPS = CONFIG_FIPS=y
endif

ifeq ($(BR2_PACKAGE_LRD_LEGACY),y)
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
            $(SDCSUPP_RADIO_FLAGS) CROSS_COMPILE="$(TARGET_CROSS)"
    $(TARGET_CROSS)objcopy -S $(SDCSUPP_D)/wpa_supplicant $(SDCSUPP_D)/sdcsupp
    #(cd $(SDCSUPP_D) && CROSS_COMPILE=arm-sdc-linux-gnueabi ./sdc-build-linux.sh 4 1 2 3 1)
endef

ifneq ($(BR2_PACKAGE_LRD_LEGACY),y)
define SDCSUPP_INSTALL_DBUS_NEW
	$(INSTALL) -m 0644 -D \
		$(SDCSUPP_D)/dbus/$(SDCSUPP_DBUS_NEW_SERVICE).service \
		$(TARGET_DIR)/usr/share/dbus-1/system-services/summit.$(SDCSUPP_DBUS_NEW_SERVICE).service
endef
endif

ifeq ($(BR2_PACKAGE_SDCSUPP_WPA_CLI),y)
define SDCSUPP_INSTALL_WPA_CLI
	$(INSTALL) -D -m 755 $(SDCSUPP_D)/wpa_cli $(SDCSUPP_TARGET_DIR)/usr/bin/wpa_cli
endef
endif

ifneq ($(BR2_PACKAGE_LRD_LEGACY),y)
define SDCSUPP_INSTALL_DBUS
	$(INSTALL) -m 0644 -D \
		$(SDCSUPP_D)/dbus/dbus-wpa_supplicant.conf \
		$(TARGET_DIR)/etc/dbus-1/system.d/wpa_supplicant.conf
	$(SDCSUPP_INSTALL_DBUS_NEW)
endef
endif

define SDCSUPP_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(SDCSUPP_D)/sdcsupp $(SDCSUPP_TARGET_DIR)/usr/bin/sdcsupp
	$(SDCSUPP_INSTALL_WPA_CLI)
	$(SDCSUPP_INSTALL_DBUS)
endef

define SDCSUPP_UNINSTALL_TARGET_CMDS
	rm -f $(SDCSUPP_TARGET_DIR)/usr/bin/sdcsupp
endef

$(eval $(generic-package))
