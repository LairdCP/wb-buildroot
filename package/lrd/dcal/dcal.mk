#############################################################
#
# Laird DCAL
#
#############################################################

DCAL_VERSION = local
DCAL_SITE = package/lrd/externals/dcal
DCAL_SITE_METHOD = local

DCAL_DEPENDENCIES += host-flatcc flatcc libssh

DCAL_MAKE_ENV += CROSS_COMPILE="$(TARGET_CROSS)"

ifeq ($(BR2_PACKAGE_DCAL_TEST_APPS),y)
define BUILD_EXAMPLE_APPS
    $(DCAL_MAKE_ENV) $(MAKE) -j 1 -C $(@D) test_clean
    $(DCAL_MAKE_ENV) $(MAKE) -j 1 -C $(@D) test_apps
endef
endif

define DCAL_BUILD_CMDS
    $(DCAL_MAKE_ENV) $(MAKE) -C $(@D) clean
    $(DCAL_MAKE_ENV) $(MAKE) -C $(@D) dcal
    $(BUILD_EXAMPLE_APPS)
endef

define DCAL_INSTALL_STAGING_CMDS
endef

ifeq ($(BR2_PACKAGE_DCAL_TEST_APPS),y)
define INSTALL_EXAMPLE_APPS
		mkdir -p $(TARGET_DIR)/user/share/dcal/examples
		mkdir -p $(TARGET_DIR)/user/share/dcal/unit-tests/
		$(INSTALL) -D -m 755 $(@D)/apps/examples/* $(TARGET_DIR)/user/share/dcal/examples/
		$(INSTALL) -D -m 755 $(@D)/apps/unit-tests/* $(TARGET_DIR)/user/share/dcal/unit-tests/
endef
endif

define DCAL_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/api/libdcal.so.1.0 $(TARGET_DIR)/usr/lib/libdcal.so.1.0
	ln -fs $(TARGET_DIR)/usr/lib/libdcal.so.1.0 $(TARGET_DIR)/usr/lib/libdcal.so.1
	ln -fs $(TARGET_DIR)/usr/lib/libdcal.so.1.0 $(TARGET_DIR)/usr/lib/libdcal.so
	$(INSTALL_EXAMPLE_APPS)
endef

define DCAL_UNINSTALL_TARGET_CMDS
	rm $(TARGET_DIR)/usr/lib/libdcal.so
	rm $(TARGET_DIR)/usr/lib/libdcal.so.1
	rm $(TARGET_DIR)/usr/lib/libdcal.so.1.0
	rm -rf $(TARGET_DIR)/user/share/dcal/
endef

$(eval $(generic-package))
