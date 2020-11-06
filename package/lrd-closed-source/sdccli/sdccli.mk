#############################################################
#
# SDC CLI
#
#############################################################

SDCCLI_VERSION = local
SDCCLI_SITE = package/lrd-closed-source/externals/sdc_cli
SDCCLI_SITE_METHOD = local

ifeq ($(BR2_PACKAGE_SDCSDK_NM),y)
	SDCCLI_DEPENDENCIES = libnl sdcsdk_nm libedit
	TARGET_CFLAGS += -D_LRD_NMWRAPPER
else
	SDCCLI_DEPENDENCIES = libnl sdcsdk libedit
endif

SDCCLI_MAKE_ENV += CC="$(TARGET_CC)" \
                  CXX="$(TARGET_CXX)" \
                  ARCH="$(KERNEL_ARCH)" \
                  CFLAGS="$(TARGET_CFLAGS)"

ifeq ($(BR2_PACKAGE_SDCCLI_SDC_CLI),y)
define BUILD_SDC_CLI_CMD
	$(SDCCLI_MAKE_ENV) $(MAKE) -C $(@D) sdc_cli
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
	$(SDCCLI_MAKE_ENV) $(MAKE) -C $(@D) smu_cli
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
