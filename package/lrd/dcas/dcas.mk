#############################################################
#
# Laird DCAS
#
#############################################################
DCAS_VERSION = local
DCAS_SITE = package/lrd/externals/dcas
DCAS_SITE_METHOD = local

ifeq ($(BR2_PACKAGE_WB_LEGACY_SUMMIT_SUPPLICANT_BINARIES),y)
	DCAS_DEPENDENCIES = wb-legacy-summit-supplicant-binaries
else
	DCAS_DEPENDENCIES = sdcsdk
endif

DCAS_DEPENDENCIES += host-flatcc flatcc libssh

DCAS_MAKE_ENV = CC="$(TARGET_CC)" \
                    CXX="$(TARGET_CXX)" \
                    ARCH="$(KERNEL_ARCH)" \
                    CFLAGS="$(TARGET_CFLAGS)" \
                    FLATCC="$(HOST_DIR)/usr/bin/flatcc"

define DCAS_BUILD_CMDS
    $(MAKE) -C $(@D) clean
    $(DCAS_MAKE_ENV) $(MAKE) -C $(@D) dcas
endef

define DCAS_INSTALL_TARGET_CMDS
	$(INSTALL) -d -m 700 $(TARGET_DIR)/root/.ssh
	$(INSTALL) -D -t $(TARGET_DIR)/usr/bin -m 755 $(@D)/dcas
	$(INSTALL) -D -t $(TARGET_DIR)/etc -m 755 $(@D)/support/etc/dcas.conf
endef

define DCAS_INSTALL_INIT_SYSV
	$(INSTALL) -D -t $(TARGET_DIR)/etc/init.d/opt -m 755 $(@D)/support/etc/init.d/S99dcas
endef

define DCAS_UNINSTALL_TARGET_CMDS
	rm $(TARGET_DIR)/usr/bin/dcas
	rm $(TARGET_DIR)/etc/dcas.conf
	rm $(TARGET_DIR)/etc/init.d/S99dcas
endef

$(eval $(generic-package))
