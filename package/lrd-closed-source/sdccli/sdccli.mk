#############################################################
#
# SDC CLI
#
#############################################################

ifeq ($(BR2_PACKAGE_SDCCLI_PULL_FROM_SVN),y)
SDCCLI_VERSION = $(BR2_PACKAGE_SDCCLI_SVN_VERSION)
SDCCLI_SITE = svn://10.1.10.7/tests/sdc_cli/trunk
SDCCLI_SITE_METHOD = svn
else
SDCCLI_VERSION = local
SDCCLI_SITE = package/lrd-closed-source/externals/sdc_cli
SDCCLI_SITE_METHOD = local
endif

SDCCLI_DEPENDENCIES = libnl sdcsdk libedit

ifeq ($(BR2_PACKAGE_BTSDK),y)
    TARGET_CFLAGS += -DBLUETOOTH
    SDCCLI_MAKE_ENV = BLUETOOTH=y
    SDCCLI_DEPENDENCIES += btsdk
endif

SDCCLI_MAKE_ENV += CC="$(TARGET_CC)" \
                  CXX="$(TARGET_CXX)" \
                  ARCH="$(KERNEL_ARCH)" \
                  CFLAGS="$(TARGET_CFLAGS)"

define SDCCLI_BUILD_CMDS
    $(MAKE) -C $(@D) clean
	$(SDCCLI_MAKE_ENV) $(MAKE) -C $(@D)
endef

define SDCCLI_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/bin/sdc_cli $(TARGET_DIR)/usr/bin/sdc_cli
	$(INSTALL) -D -m 755 $(@D)/bin/smu_cli $(TARGET_DIR)/usr/sbin/smu_cli
endef

define SDCCLI_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/sdc_cli
	rm -f $(TARGET_DIR)/usr/sbin/smu_cli
endef

$(eval $(generic-package))
