#############################################################
#
# SDC2U driver and SDCU app for CCMP_FIPS
#
#############################################################

SDC2U_VERSION = local
SDC2U_SITE = package/lrd-closed-source/externals/sdc2u_fips
SDC2U_SITE_METHOD = local

SDC2U_DEPENDENCIES = openssl


MAKE_ENV = \
        ARCH=arm \
        CROSS_COMPILE=$(TARGET_CROSS) \
        KERNELDIR=$(LINUX_DIR)



define SDC2U_CONFIGURE_CMDS
endef

define SDC2U_BUILD_CMDS
	@echo \ --\> sdcu and sdc2u.ko
	$(MAKE) $(MAKE_ENV) -C $(@D)/sdcu
	@echo \ ---
endef

define SDC2U_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/sdcu/sdcu \
        $(TARGET_DIR)/usr/bin/sdcu
endef

define SDC2U_UNINSTALL_TARGET_CMDS
endef

$(eval $(generic-package))
