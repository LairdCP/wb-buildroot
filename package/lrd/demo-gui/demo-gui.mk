DEMO_GUI_VERSION = 5.9.4
DEMO_GUI_LICENSE = GPL-2.0
DEMO_GUI_SITE = $(TOPDIR)/package/lrd/demo-gui/demo
DEMO_GUI_SITE_METHOD = local
DEMO_GUI_DEPENDENCIES = qt5base libdrm cairo libplanes cjson lua lrd-network-manager
DEMO_GUI_QMAKE = $(QT5_QMAKE)

define DEMO_GUI_CONFIGURE_CMDS
    (cd $(@D); $(TARGET_MAKE_ENV) $(DEMO_GUI_QMAKE))
endef

define DEMO_GUI_BUILD_CMDS
    $(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define DEMO_GUI_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/misc/systime $(TARGET_DIR)/opt/
	$(INSTALL) -D -m 755 $(@D)/network/network-demo $(TARGET_DIR)/opt/
endef

$(eval $(generic-package))
