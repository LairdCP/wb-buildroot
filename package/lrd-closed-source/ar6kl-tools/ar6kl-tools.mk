#############################################################
#
# ar6kl tools
#
#############################################################

AR6KL_TOOLS_VERSION = local
AR6KL_TOOLS_SITE    = package/lrd-closed-source/externals/ath6kl_devkit
AR6KL_TOOLS_SITE_METHOD = local
AR6KL_TOOLS_DEPENDENCIES = libnl host-pkgconf

define AR6KL_TOOLS_BUILD_CMDS
	$(MAKE) -C $(@D)/Proprietary_tools/libtcmd \
            CC="$(TARGET_CC)" AR="$(TARGET_AR)" \
            PKGCONFIG="$(HOST_DIR)/usr/bin/pkg-config"
    $(MAKE) -C $(@D)/Proprietary_tools/ath6kl-tcmd \
               CC="$(TARGET_CC)" AR="$(TARGET_AR)" \
               PKGCONFIG="$(HOST_DIR)/usr/bin/pkg-config"
    $(MAKE) -C $(@D)/Proprietary_tools/ath6kl-wmiconfig \
               CC="$(TARGET_CC)" AR="$(TARGET_AR)" \
               PKGCONFIG="$(HOST_DIR)/usr/bin/pkg-config"
endef

define AR6KL_TOOLS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/Proprietary_tools/ath6kl-tcmd/athtestcmd $(TARGET_DIR)/usr/bin/athtestcmd
	$(INSTALL) -D -m 755 $(@D)/Proprietary_tools/ath6kl-wmiconfig/wmiconfig $(TARGET_DIR)/usr/bin/wmiconfig
endef

$(eval $(generic-package))
