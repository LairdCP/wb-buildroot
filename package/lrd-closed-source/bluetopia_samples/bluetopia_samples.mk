##############################################################
#
#BLUETOPIA_SAMPLES
#
#############################################################

BLUETOPIA_SAMPLES_VERSION = 1.0
BLUETOPIA_SAMPLES_SOURCE = BLUETOPIA_SAMPLES-$(BLUETOPIA_SAMPLES_VERSION).tar.bz2
BLUETOPIA_SAMPLES_SITE = $(TOPDIR)/package/lrd-closed-source/externals/bluetopia-samples/
BLUETOPIA_SAMPLES_SITE_METHOD = local
BLUETOPIA_SAMPLES_DEPENDENCIES = libbluetopia


define BLUETOPIA_SAMPLES_BUILD_CMDS
    $(MAKE) CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D)/LinuxHCI all
	$(MAKE) CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D)/LinuxSCO all
	$(MAKE) CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D)/LinuxSDP all
	$(MAKE) CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D)/LinuxL2CAP all
	$(MAKE) CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D)/LinuxSPP all
	$(MAKE) CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D)/LinuxHDS all
	$(MAKE) CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D)/LinuxHFR all
	$(MAKE) CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D)/LinuxHID all
	$(MAKE) CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D)/LinuxHID_Host all
	$(MAKE) CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D)/LinuxSPPLE all
endef


define BLUETOPIA_SAMPLES_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/LinuxHCI/LinuxHCI $(TARGET_DIR)/usr/bin/LinuxHCI
	$(INSTALL) -D -m 0755 $(@D)/LinuxSCO/LinuxSCO $(TARGET_DIR)/usr/bin/LinuxSCO
	$(INSTALL) -D -m 0755 $(@D)/LinuxSDP/LinuxSDP $(TARGET_DIR)/usr/bin/LinuxSDP
	$(INSTALL) -D -m 0755 $(@D)/LinuxL2CAP/LinuxL2CAP $(TARGET_DIR)/usr/bin/LinuxL2CAP
	$(INSTALL) -D -m 0755 $(@D)/LinuxSPP/LinuxSPP $(TARGET_DIR)/usr/bin/LinuxSPP
	$(INSTALL) -D -m 0755 $(@D)/LinuxHDS/LinuxHDS $(TARGET_DIR)/usr/bin/LinuxHDS
	$(INSTALL) -D -m 0755 $(@D)/LinuxHFR/LinuxHFR $(TARGET_DIR)/usr/bin/LinuxHFR
	$(INSTALL) -D -m 0755 $(@D)/LinuxHID/LinuxHID $(TARGET_DIR)/usr/bin/LinuxHID
	$(INSTALL) -D -m 0755 $(@D)/LinuxHID_Host/LinuxHID_Host $(TARGET_DIR)/usr/bin/LinuxHID_Host
	$(INSTALL) -D -m 0755 $(@D)/LinuxSPPLE/LinuxSPPLE $(TARGET_DIR)/usr/bin/LinuxSPPLE
endef

$(eval $(generic-package))
