#############################################################
#
# SDC CLI
#
#############################################################

SDCCLI_VERSION = local
SDCCLI_SITE = package/lrd-closed-source/externals/sdc_cli
SDCCLI_SITE_METHOD = local

SDCCLI_DEPENDENCIES = libnl libedit

ifeq ($(BR2_PACKAGE_SDCSDK_NM),y)
SDCCLI_DEPENDENCIES += sdcsdk_nm
SDCCLI_OPTS = _LRD_NMWRAPPER=y
else
SDCCLI_DEPENDENCIES += sdcsdk
endif

ifeq ($(BR2_PACKAGE_SDCCLI_SDC_CLI),y)
define BUILD_SDC_CLI_CMD
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) $(SDCCLI_OPTS) -C $(@D) sdc_cli
endef

define INSTALL_SDC_CLI_CMD
	$(INSTALL) -D -m 755 $(@D)/bin/sdc_cli $(TARGET_DIR)/usr/bin/sdc_cli
endef

define UNINSTALL_SDC_CLI_CMD
	rm -f $(TARGET_DIR)/usr/bin/sdc_cli
endef
endif

ifeq ($(BR2_PACKAGE_SDCCLI_SMU_CLI),y)
define BUILD_SMU_CLI_CMD
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) $(SDCCLI_OPTS) -C $(@D) smu_cli
endef

define INSTALL_SDC_SMU_CMD
	$(INSTALL) -D -m 755 $(@D)/bin/smu_cli $(TARGET_DIR)/usr/sbin/smu_cli
endef

define UNINSTALL_SDC_SMU_CMD
	rm -f $(TARGET_DIR)/usr/sbin/smu_cli
endef
endif

define SDCCLI_BUILD_CMDS
	$(BUILD_SDC_CLI_CMD)
	$(BUILD_SMU_CLI_CMD)
endef

define SDCCLI_INSTALL_TARGET_CMDS
	$(INSTALL_SDC_CLI_CMD)
	$(INSTALL_SDC_SMU_CMD)
endef

define SDCCLI_UNINSTALL_TARGET_CMDS
	$(UNINSTALL_SDC_CLI_CMD)
	$(UNINSTALL_SDC_SMU_CMD)
endef

$(eval $(generic-package))
