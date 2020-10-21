ifneq ($(BR2_LRD_DEVEL_BUILD),y)
ADAPTIVE_WW_BINARIES_VERSION = $(call qstrip,$(BR2_PACKAGE_LRD_RADIO_STACK_VERSION_VALUE))
ADAPTIVE_WW_BINARIES_LICENSE = LGPL-2.1
ADAPTIVE_WW_BINARIES_STRIP_COMPONENTS = 0

ADAPTIVE_WW_BINARIES_SOURCE = adaptive_ww$(call qstrip,$(BR2_PACKAGE_ADAPTIVE_WW_BINARIES_OPENSSL)$(BR2_PACKAGE_LRD_RADIO_STACK_ARCH))-$(ADAPTIVE_WW_BINARIES_VERSION).tar.bz2

ifeq ($(MSD_BINARIES_SOURCE_LOCATION),laird_internal)
  ADAPTIVE_WW_BINARIES_SITE = https://files.devops.rfpros.com/builds/linux/adaptive_ww/laird/$(ADAPTIVE_WW_BINARIES_VERSION)
else
  ADAPTIVE_WW_BINARIES_SITE = https://github.com/LairdCP/wb-package-archive/releases/download/LRD-REL-$(ADAPTIVE_WW_BINARIES_VERSION)
endif

ifeq ($(BR2_PACKAGE_ADAPTIVE_WW_BINARIES_REGPWRDB),y)
define AWM_BINARIES_REGPWRDB_INSTALL_TARGET_CMDS
	if [ -e "$(@D)/lib/firmware/lrdmwl/regpwr.db" ]; then \
		$(INSTALL) -D -m 0644 $(@D)/lib/firmware/lrdmwl/regpwr.db $(TARGET_DIR)/lib/firmware/lrdmwl/regpwr.db; \
	else \
		$(INSTALL) -D -m 0644 $(@D)/lib/firmware/regpwr.db $(TARGET_DIR)/lib/firmware/regpwr.db; \
	fi
endef
endif

define AWM_BINARIES_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/usr/bin/adaptive_ww $(TARGET_DIR)/usr/bin/adaptive_ww
endef

define ADAPTIVE_WW_BINARIES_INSTALL_TARGET_CMDS
	$(AWM_BINARIES_REGPWRDB_INSTALL_TARGET_CMDS)
	$(AWM_BINARIES_INSTALL_TARGET_CMDS)
endef

define ADAPTIVE_WW_BINARIES_INSTALL_INIT_SYSTEMD
	$(INSTALL) -m 0644 -D $(@D)/usr/lib/systemd/system/adaptive_ww.service \
		$(TARGET_DIR)/usr/lib/systemd/system/adaptive_ww.service
	$(INSTALL) -d $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
	ln -rsf $(TARGET_DIR)/usr/lib/systemd/system/adaptive_ww.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/adaptive_ww.service
endef

define ADAPTIVE_WW_BINARIES_INSTALL_INIT_SYSV
	$(INSTALL) -m 0755 -D $(@D)/etc/init.d/adaptive_ww $(TARGET_DIR)/etc/init.d/S30adaptive_ww
endef

endif

$(eval $(generic-package))
