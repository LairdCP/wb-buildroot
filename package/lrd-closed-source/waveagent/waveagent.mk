WAVEAGENT_VERSION = v7.3.0
WAVEAGENT_SITE = git@git.devops.rfpros.com:cp_vendor_apps/waveagent.git
WAVEAGENT_SITE_METHOD = git
WAVEAGENT_LICENSE = VeriWave
WAVEAGENT_LICENSE_FILES = license.rtf

define WAVEAGENT_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) CC='$(TARGET_CC) $$(CFLAGS) $$(LDFLAGS)' -C $(@D)/src/linux
endef

define WAVEAGENT_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 -t $(TARGET_DIR)/usr/bin $(@D)/src/linux/waveagent
endef

$(eval $(generic-package))
