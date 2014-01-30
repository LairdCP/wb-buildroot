#############################################################
#
# ar6kl tools
#
#############################################################

AR6KL_TOOLS_V311_VERSION = 3.1.1
AR6KL_TOOLS_V311_SITE = http://boris.corp.lairdtech.com/scratch/archive-closed-source
AR6KL_TOOLS_V311_SOURCE = AR6K_Linux_ISC_$(AR6KL_TOOLS_V311_VERSION)_RC_Release.tgz

define AR6KL_TOOLS_V311_CONFIGURE_CMDS
	(cd $(@D) && tar zxf AR6K_PKG_ISC.build_3.1_RC.563.tgz)
endef

define AR6KL_TOOLS_V311_BUILD_CMDS
    $(MAKE) -C $(@D)/host/tools/dbgParser CC="$(TARGET_CC)" ARCH=arm
endef

define AR6KL_TOOLS_V311_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 755 $(@D)/host/tools/dbgParser/dbgParser $(TARGET_DIR)/usr/bin/dbgParser
    $(INSTALL) -D -m 755 $(@D)/include/dbglog.h $(TARGET_DIR)/etc/ar6kl-tools/dbgParser/include/dbglog.h
    $(INSTALL) -D -m 755 $(@D)/include/dbglog_id.h $(TARGET_DIR)/etc/ar6kl-tools/dbgParser/include/dbglog_id.h
endef

$(eval $(generic-package))
