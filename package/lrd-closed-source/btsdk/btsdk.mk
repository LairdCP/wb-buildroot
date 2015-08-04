#############################################################
#
#BTSDK
#
#############################################################

ifeq ($(BR2_PACKAGE_BTSDK_PULL_FROM_SVN),y)
BTSDK_VERSION = $(BR2_PACKAGE_BTSDK_SVN_VERSION)
BTSDK_SITE = svn://10.1.10.7/dev_linux/sdk/trunk
BTSDK_SITE_METHOD = svn
else
BTSDK_VERSION = local
BTSDK_SITE = package/lrd-closed-source/externals/btsdk
BTSDK_SITE_METHOD = local
endif

BTSDK_DEPENDENCIES =
BTSDK_INSTALL_STAGING = YES
BTSDK_MAKE_ENV = CFLAGS="$(TARGET_CFLAGS)" PKG_CONFIG="$(HOST_DIR)/usr/bin/pkg-config"
BTSDK_TARGET_DIR = $(TARGET_DIR)

BTSDK_PLATFORM := $(call qstrip,$(BR2_LRD_PLATFORM))
ifeq ($(BTSDK_PLATFORM),wb45n)
    BTSDK_RADIO_FLAGS := CONFIG_SDC_RADIO_QCA45N=y
else ifeq ($(BTSDK_PLATFORM),wb40n)
    BTSDK_RADIO_FLAGS := CONFIG_SDC_RADIO_BCM40N=y
else
    $(error "ERROR: Expected BR2_LRD_PLATFORM to be wb45n or wb40n.")
endif

define BTSDK_BUILD_CMDS
    $(MAKE) -C $(@D) clean
	$(BTSDK_MAKE_ENV) $(MAKE) -j 1 -C $(@D) ARCH=$(KERNEL_ARCH) \
        CROSS_COMPILE="$(TARGET_CROSS)" $(BTSDK_RADIO_FLAGS)
endef

define BTSDK_INSTALL_STAGING_CMDS
	rm -f $(STAGING_DIR)/usr/lib/liblrd_btsdk.so*

	$(INSTALL) -D -m 0755 $(@D)/liblrd_btsdk.so.1.0 $(STAGING_DIR)/usr/lib/

	cd  $(STAGING_DIR)/usr/lib/ && ln -s liblrd_btsdk.so.1.0 liblrd_btsdk.so.1
	cd  $(STAGING_DIR)/usr/lib/ && ln -s liblrd_btsdk.so.1 liblrd_btsdk.so

	$(INSTALL) -D -m 0755 $(@D)/src/lrd_bt_sdk.h \
              			$(@D)/src/lrd_bt_errors.h \
              			$(STAGING_DIR)/usr/include/
endef

define BTSDK_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/liblrd_btsdk.so.1.0 $(BTSDK_TARGET_DIR)/usr/lib/liblrd_btsdk.so.1.0
endef

define BTSDK_UNINSTALL_TARGET_CMDS
	rm -f $(BTSDK_TARGET_DIR)/usr/lib/liblrd_btsdk.so.1.0
endef

$(eval $(generic-package))
