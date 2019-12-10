#############################################################
#
# SDC SDK
#
#############################################################

SDCSDK_VERSION = local
SDCSDK_SITE = package/lrd-closed-source/externals/sdk
SDCSDK_SITE_METHOD = local

SDCSDK_DEPENDENCIES = libnl host-pkgconf
SDCSDK_INSTALL_STAGING = YES
SDCSDK_MAKE_ENV = CFLAGS="$(TARGET_CFLAGS)" PKG_CONFIG="$(HOST_DIR)/usr/bin/pkg-config"
SDCSDK_TARGET_DIR = $(TARGET_DIR)

SDCSDK_PLATFORM := $(call qstrip,$(BR2_LRD_PLATFORM))
SDCSDK_RADIO_FLAGS := CONFIG_SDC_RADIO_QCA45N=y

define SDCSDK_BUILD_CMDS
    $(MAKE) -C $(@D) clean
	$(SDCSDK_MAKE_ENV) $(MAKE) -j 1 -C $(@D) ARCH=$(KERNEL_ARCH) \
        CROSS_COMPILE="$(TARGET_CROSS)" $(SDCSDK_RADIO_FLAGS)
endef

define SDCSDK_INSTALL_STAGING_CMDS
    rm -f $(STAGING_DIR)/usr/lib/libsdc_sdk.so*
	rm -f $(STAGING_DIR)/usr/bin/dhcp_injector
	$(INSTALL) -D -m 0755 $(@D)/libsdc_sdk.so.1.0 $(STAGING_DIR)/usr/lib/
	$(INSTALL) -D -m 0755 $(@D)/dhcp_injector $(STAGING_DIR)/usr/bin/
	cd  $(STAGING_DIR)/usr/lib/ && ln -s libsdc_sdk.so.1.0 libsdc_sdk.so.1
	cd  $(STAGING_DIR)/usr/lib/ && ln -s libsdc_sdk.so.1 libsdc_sdk.so
	$(INSTALL) -D -m 0644 $(@D)/src/sdc_sdk.h \
              $(@D)/src/sdc_events.h \
			  $(@D)/src/linux/include/linux_perm_stor.h \
			  $(@D)/src/sdk_version.h \
			  $(@D)/src/config_strings.h \
			  $(@D)/src/linux/include/lrd_sdk_pil.h \
			  $(@D)/src/sdc_sdk_private.h \
			  $(@D)/src/linux/include/lrd_sdk_eni.h \
              $(STAGING_DIR)/usr/include/
endef

define SDCSDK_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/libsdc_sdk.so.1.0 $(SDCSDK_TARGET_DIR)/usr/lib/libsdc_sdk.so.1.0
	cd  $(SDCSDK_TARGET_DIR)/usr/lib/ && ln -sf libsdc_sdk.so.1.0 libsdc_sdk.so.1
	$(INSTALL) -D -m 0755 $(@D)/dhcp_injector $(SDCSDK_TARGET_DIR)/usr/bin/dhcp_injector
endef

define SDCSDK_UNINSTALL_TARGET_CMDS
	rm -f $(SDCSDK_TARGET_DIR)/usr/lib/libsdc_sdk.so*
	rm -f $(SDCSDK_TARGET_DIR)/usr/bin/dhcp_injector
endef

$(eval $(generic-package))
