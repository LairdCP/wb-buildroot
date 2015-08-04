MC_MINT_VERSION = 1.2
MC_MINT_SOURCE = mint-$(MC_MINT_VERSION).tar.gz
MC_MINT_SITE = http://downloads.sourceforge.net/project/mc-mint/mc-mint/Mint%201.2
MC_MINT_DEPENDENCIES =

define MC_MINT_BUILD_CMDS
	CC="$(TARGET_CC)" $(MAKE) -C $(@D)
endef

define MC_MINT_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/mint $(TARGET_DIR)/usr/bin/
endef

$(eval $(generic-package))

