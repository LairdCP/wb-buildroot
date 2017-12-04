#############################################################
#
# SDC CLI
#
#############################################################

SDCCLI_VERSION = local
SDCCLI_SITE = package/lrd-closed-source/externals/sdc_cli
SDCCLI_SITE_METHOD = local

SDCCLI_DEPENDENCIES = libnl sdcsdk libedit

SDCCLI_MAKE_ENV += CC="$(TARGET_CC)" \
                  CXX="$(TARGET_CXX)" \
                  ARCH="$(KERNEL_ARCH)" \
                  CFLAGS="$(TARGET_CFLAGS)"

define SDCCLI_BUILD_CMDS
    $(MAKE) -C $(@D) clean
	$(SDCCLI_MAKE_ENV) $(MAKE) -C $(@D)
endef

ifeq ($(BR2_PACKAGE_SDCCLI_SMU_CLI),y)
define SDCCLI_INSTALL_SMU_CLI
	$(INSTALL) -D -m 755 $(@D)/bin/smu_cli $(TARGET_DIR)/usr/sbin/smu_cli
endef
endif

define SDCCLI_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/bin/sdc_cli $(TARGET_DIR)/usr/bin/sdc_cli
	$(SDCCLI_INSTALL_SMU_CLI)
endef

define SDCCLI_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/sdc_cli
	rm -f $(TARGET_DIR)/usr/sbin/smu_cli
endef

$(eval $(generic-package))
