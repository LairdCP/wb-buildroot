#############################################################
#
# ar6kl tools
#
#############################################################

AR6KL_TOOLS_VERSION = local
AR6KL_TOOLS_SITE    = package/lrd-closed-source/externals/ath6kl_devkit
AR6KL_TOOLS_SITE_METHOD = local
AR6KL_TOOLS_DEPENDENCIES = libnl host-pkgconf

ifeq ($(BR2_PACKAGE_AR6KL_TOOLS_6004_SUPPORT),y)
AR6KL_TOOLS_CHIP_FLAGS = -DSUPPORT_6004
AR6KL_TOOLS_SUFFIX = _6004
endif

AR6KL_TOOLS_OPTS = CC="$(TARGET_CC)" AR="$(TARGET_AR)" PKGCONFIG="$(PKG_CONFIG_HOST_BINARY)"

define AR6KL_TOOLS_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(AR6KL_TOOLS_OPTS) -C $(@D)/Proprietary_tools/libtcmd
	$(TARGET_MAKE_ENV) $(MAKE) $(AR6KL_TOOLS_OPTS) -C $(@D)/Proprietary_tools/ath6kl-tcmd$(AR6KL_TOOLS_SUFFIX)
	$(TARGET_MAKE_ENV) $(MAKE) $(AR6KL_TOOLS_OPTS) -C $(@D)/Proprietary_tools/ath6kl-wmiconfig CHIP_SUPPORT="$(AR6KL_TOOLS_CHIP_FLAGS)"
	$(TARGET_MAKE_ENV) $(MAKE) $(AR6KL_TOOLS_OPTS) -C $(@D)/AR6K_PKG_ISC/host/tools/dbgParser CC="$(TARGET_CC)" ARCH=arm
endef

define AR6KL_TOOLS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/Proprietary_tools/ath6kl-tcmd$(AR6KL_TOOLS_SUFFIX)/athtestcmd $(TARGET_DIR)/usr/bin/athtestcmd
	$(INSTALL) -D -m 755 $(@D)/Proprietary_tools/ath6kl-wmiconfig/wmiconfig $(TARGET_DIR)/usr/bin/wmiconfig

	$(INSTALL) -D -m 755 $(@D)/AR6K_PKG_ISC/host/tools/dbgParser/dbgParser $(TARGET_DIR)/usr/bin/dbgParser
	$(INSTALL) -D -m 644 $(@D)/AR6K_PKG_ISC/include/dbglog$(AR6KL_TOOLS_SUFFIX).h $(TARGET_DIR)/etc/ar6kl-tools/dbgParser/include/dbglog.h
	$(INSTALL) -D -m 644 $(@D)/AR6K_PKG_ISC/include/dbglog_id$(AR6KL_TOOLS_SUFFIX).h $(TARGET_DIR)/etc/ar6kl-tools/dbgParser/include/dbglog_id.h
endef

$(eval $(generic-package))
