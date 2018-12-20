#############################################################
#
# SDC SDK NM
#
#############################################################

SDCSDK_NM_VERSION = local
SDCSDK_NM_SITE = package/lrd-closed-source/externals/sdcsdk_nm
SDCSDK_NM_SITE_METHOD = local

SDCSDK_NM_DEPENDENCIES = libnl host-pkgconf openssl lrd-network-manager
SDCSDK_NM_INSTALL_STAGING = YES
SDCSDK_NM_MAKE_ENV = CFLAGS="$(TARGET_CFLAGS)" PKG_CONFIG="$(HOST_DIR)/usr/bin/pkg-config"
SDCSDK_NM_TARGET_DIR = $(TARGET_DIR)

define SDCSDK_NM_BUILD_CMDS
    $(MAKE) -C $(@D) clean
	$(SDCSDK_NM_MAKE_ENV) $(MAKE) -j 1 -C $(@D) ARCH=$(KERNEL_ARCH) \
        CROSS_COMPILE="$(TARGET_CROSS)" $(SDCSDK_RADIO_FLAGS)
endef

define SDCSDK_NM_INSTALL_STAGING_CMDS
    rm -f $(STAGING_DIR)/usr/lib/libsdc_sdk.so*
	$(INSTALL) -D -m 0755 $(@D)/libsdc_sdk.so.1.0 $(STAGING_DIR)/usr/lib/
	cd  $(STAGING_DIR)/usr/lib/ && ln -s libsdc_sdk.so.1.0 libsdc_sdk.so.1
	cd  $(STAGING_DIR)/usr/lib/ && ln -s libsdc_sdk.so.1 libsdc_sdk.so
	$(INSTALL) -D -m 0644 $(@D)/src/sdc_sdk.h \
              $(@D)/src/sdc_sdk_types.h \
              $(@D)/src/sdc_sdk_deprecated.h \
              $(@D)/src/sdc_sdk_events.h \
              $(@D)/src/include/lrd_sdk_eni.h \
              $(@D)/src/sdc_sdk_private.h \
              $(@D)/src/sdk_version.h \
              $(@D)/src/include/libsdcsdk_sys.h \
              $(@D)/src/include/libnm_wrapper.h \
              $(@D)/src/include/libnm_wrapper_helper.h \
              $(STAGING_DIR)/usr/include/
endef

define SDCSDK_NM_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/libsdc_sdk.so.1.0 $(SDCSDK_NM_TARGET_DIR)/usr/lib/libsdc_sdk.so.1.0
	cd  $(SDCSDK_NM_TARGET_DIR)/usr/lib/ && ln -sf libsdc_sdk.so.1.0 libsdc_sdk.so.1
endef

define SDCSDK_NM_UNINSTALL_TARGET_CMDS
	rm -f $(SDCSDK_NM_TARGET_DIR)/usr/lib/libsdc_sdk.so*
endef

$(eval $(generic-package))
