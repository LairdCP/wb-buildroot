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
endif

DCAS_DEPENDENCIES += host-flatcc flatcc libssh

ifeq ($(BR2_LRD_PLATFORM_SOM60),y)
	DCAS_DEPENDENCIES = sdcsdk_nm
	SDCSDK_PLATFORM := CONFIG_SDC_PLATFORM=som60
else
	DCAS_DEPENDENCIES = sdcsdk
	SDCSDK_PLATFORM := CONFIG_SDC_PLATFORM=wb50n
endif

DCAS_MAKE_ENV = CC="$(TARGET_CC)" \
                    CXX="$(TARGET_CXX)" \
                    ARCH="$(KERNEL_ARCH)" \
                    CFLAGS="$(TARGET_CFLAGS)" \
                    FLATCC="$(HOST_DIR)/usr/bin/flatcc" \
					PKG_CONFIG="$(HOST_DIR)/usr/bin/pkg-config"

define DCAS_BUILD_CMDS
    $(MAKE) -C $(@D) clean
    $(DCAS_MAKE_ENV) $(MAKE) -C $(@D) dcas $(SDCSDK_PLATFORM)
endef

define DCAS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/dcas $(TARGET_DIR)/usr/bin/dcas
	mkdir -p $(TARGET_DIR)/etc/dcas
	$(INSTALL) -D -m 644 package/lrd/dcas/dcas.conf $(TARGET_DIR)/etc/dcas/dcas.conf
endef

define DCAS_UNINSTALL_TARGET_CMDS
	rm $(TARGET_DIR)/usr/bin/dcas
	rm $(TARGET_DIR)/etc/dcas -fr
endef

define DCAS_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 package/lrd/dcas/dcas.service \
		$(TARGET_DIR)/usr/lib/systemd/system/dcas.service
	mkdir -p $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
	ln -fs ../../../../usr/lib/systemd/system/dcas.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/dcas.service
	$(INSTALL) -D -m 755 package/lrd/dcas/S99dcas $(TARGET_DIR)/etc/dcas/S99dcas
endef

define DCAS_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 755 package/lrd/dcas/S99dcas \
		$(TARGET_DIR)/etc/init.d/S99dcas
endef

$(eval $(generic-package))
