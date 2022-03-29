#############################################################
#
# SDC SDK
#
#############################################################

SDCSDK_VERSION = local
SDCSDK_SITE = package/lrd-closed-source/externals/sdk
SDCSDK_SITE_METHOD = local
SDCSDK_INSTALL_STAGING = YES

SDCSDK_DEPENDENCIES = libnl host-pkgconf

define SDCSDK_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)
endef

define SDCSDK_INSTALL_STAGING_CMDS
	ln -rsf $(TARGET_DIR)/usr/lib/libsdc_sdk.so.1 $(STAGING_DIR)/usr/lib/libsdc_sdk.so
	$(INSTALL) -D -m 0644 -t $(STAGING_DIR)/usr/include \
		$(@D)/src/sdc_sdk.h \
		$(@D)/src/sdc_events.h \
		$(@D)/src/linux/include/linux_perm_stor.h \
		$(@D)/src/sdk_version.h \
		$(@D)/src/config_strings.h \
		$(@D)/src/linux/include/lrd_sdk_pil.h \
		$(@D)/src/sdc_sdk_private.h \
		$(@D)/src/linux/include/lrd_sdk_eni.h
endef

define SDCSDK_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/libsdc_sdk.so.1.0 $(TARGET_DIR)/usr/lib/libsdc_sdk.so.1.0
	ln -rsf $(TARGET_DIR)/usr/lib/libsdc_sdk.so.1.0 $(TARGET_DIR)/usr/lib/libsdc_sdk.so.1
	$(INSTALL) -D -m 0755 $(@D)/dhcp_injector $(TARGET_DIR)/usr/bin/dhcp_injector
endef

define SDCSDK_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/lib/libsdc_sdk.so*
	rm -f $(TARGET_DIR)/usr/bin/dhcp_injector
endef

$(eval $(generic-package))
