###############################################################
#
#libbluetopia
#
##############################################################


LIBBLUETOPIA_VERSION = 1.0
LIBBLUETOPIA_SOURCE = libbluetopia-$(LIBBLUETOPIA_VERSION).tar.bz2
LIBBLUETOPIA_SITE = $(TOPDIR)/package/lrd-closed-source/externals/libbluetopia
LIBBLUETOPIA_SITE_METHOD = local
LIBBLUETOPIA_INSTALL_STAGING = YES

LIBBLUETOPIA_DEPENDENCIES = linux
MAKE_ENV = \
        ARCH=arm \
        CROSS_COMPILE=$(TARGET_CROSS) \
        KERNELDIR=$(LINUX_DIR)

define LIBBLUETOPIA_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0755 $(@D)/lib/*.a $(STAGING_DIR)/usr/lib
	$(INSTALL) -D -m 0644 $(@D)/include/*.h $(STAGING_DIR)/usr/include
	$(INSTALL) -D -m 0644 $(@D)/debug/include/*.h $(STAGING_DIR)/usr/include
	$(INSTALL) -D -m 0755 $(@D)/debug/lib/*.a $(STAGING_DIR)/usr/lib
	$(INSTALL) -D -m 0755 $(@D)/profiles/*/lib/*.a $(STAGING_DIR)/usr/lib
	$(INSTALL) -D -m 0644 $(@D)/profiles/*/include/*.h $(STAGING_DIR)/usr/include
	$(INSTALL) -D -m 0755 $(@D)/profiles_gatt/*/lib/*.a $(STAGING_DIR)/usr/lib
	$(INSTALL) -D -m 0644 $(@D)/profiles_gatt/*/include/*.h $(STAGING_DIR)/usr/include
endef

define LIBBLUETOPIA_INSTALL_TARGET_CMDS
	$(MAKE) $(LINUX_MAKE_FLAGS) -C $(LINUX_DIR) M=$(@D)/USBDriver/driver/source/ modules_install
endef

define LIBBLUETOPIA_INSTALL_INITSCRIPT
	mkdir -p $(TARGET_DIR)/etc/init.d/
	$(INSTALL) -m 0755 $(@D)/USBDriver/driver/install/S95bluetooth $(TARGET_DIR)/etc/init.d/S95bluetooth
endef

LIBBLUETOPIA_POST_INSTALL_TARGET_HOOKS += LIBBLUETOPIA_INSTALL_INITSCRIPT

$(eval $(generic-package))
