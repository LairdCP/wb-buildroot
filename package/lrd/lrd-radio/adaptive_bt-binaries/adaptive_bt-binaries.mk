ifneq ($(BR2_LRD_DEVEL_BUILD),y)
ADAPTIVE_BT_BINARIES_VERSION = $(call qstrip,$(BR2_PACKAGE_LRD_RADIO_STACK_VERSION_VALUE))
ADAPTIVE_BT_BINARIES_LICENSE = LGPL-2.1
ADAPTIVE_BT_BINARIES_STRIP_COMPONENTS = 0


ifeq ($(BR2_arm),y)
ifeq ($(BR2_ARM_EABIHF),y)
ADAPTIVE_BT_BINARIES_TYPE = -arm-eabihf
else
ADAPTIVE_BT_BINARIES_TYPE = -arm-eabi
endif
else ifeq ($(BR2_aarch64),y)
ADAPTIVE_BT_BINARIES_TYPE = -aarch64
else ifeq ($(BR2_PACKAGE_ADAPTIVE_BT_BINARIES)$(BR_BUILDING),yy)
$(error "Unknown architecture")
endif


ADAPTIVE_BT_BINARIES_SOURCE = adaptive_bt-src-$(ADAPTIVE_BT_BINARIES_VERSION).tar.gz

ifeq ($(MSD_BINARIES_SOURCE_LOCATION),laird_internal)
	ADAPTIVE_BT_BINARIES_SITE = https://files.devops.rfpros.com/builds/linux/adaptive_bt/src/$(ADAPTIVE_BT_BINARIES_VERSION)
else
	ADAPTIVE_BT_BINARIES_SITE = https://github.com/LairdCP/wb-package-archive/releases/download/LRD-REL-$(ADAPTIVE_BT_BINARIES_VERSION)
endif

define ABT_BINARIES_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/usr/bin/adaptive_bt $(TARGET_DIR)/usr/bin/adaptive_bt
endef

define ADAPTIVE_BT_BINARIES_INSTALL_TARGET_CMDS
	$(AWM_BINARIES_INSTALL_TARGET_CMDS)
endef

define ADAPTIVE_BT_BINARIES_INSTALL_INIT_SYSTEMD
	$(INSTALL) -m 0644 -D $(@D)/usr/lib/systemd/system/adaptive_bt.service \
		$(TARGET_DIR)/usr/lib/systemd/system/adaptive_bt.service
	$(INSTALL) -d $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
	ln -rsf $(TARGET_DIR)/usr/lib/systemd/system/adaptive_bt.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/adaptive_bt.service
endef

define ADAPTIVE_WW_BINARIES_INSTALL_INIT_SYSV
	$(INSTALL) -m 0755 -D $(@D)/etc/init.d/adaptive_bt $(TARGET_DIR)/etc/init.d/S30adaptive_bt
endef

endif

$(eval $(generic-package))
