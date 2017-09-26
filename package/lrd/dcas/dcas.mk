#############################################################
#
# Laird DCAS
#
#############################################################
DCAS_VERSION = local
DCAS_SITE = package/lrd/externals/dcas
DCAS_SITE_METHOD = local

ifeq ($(BR2_PACKAGE_MSD_BINARIES),y)
	DCAS_DEPENDENCIES = msd-binaries
else ifeq ($(BR2_PACKAGE_MSD40N_BINARIES),y)
	DCAS_DEPENDENCIES = msd40n-binaries
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
	$(INSTALL) -D -m 755 $(@D)/dcas $(TARGET_DIR)/usr/bin/dcas
	mkdir -p $(TARGET_DIR)/etc/dcas
	cp -v $(@D)/test/ssh_host_* $(TARGET_DIR)/etc/dcas
	install -D -m 755 $(@D)/support/S99dcas $(TARGET_DIR)/etc/init.d/opt/S99dcas
endef

define DCAS_UNINSTALL_TARGET_CMDS
	rm $(TARGET_DIR)/usr/bin/dcas
	rm -rf $(TARGET_DIR)/etc/dcas
	rm $(TARGET_DIR)/etc/init.d/opt/S99dcas
endef

$(eval $(generic-package))
