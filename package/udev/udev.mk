#############################################################
#
# udev
#
#############################################################
UDEV_VERSION = 182
UDEV_SOURCE = udev-$(UDEV_VERSION).tar.bz2
UDEV_SITE = $(BR2_KERNEL_MIRROR)/linux/utils/kernel/hotplug/
UDEV_INSTALL_STAGING = YES

# mq_getattr is in librt
UDEV_CONF_ENV += LIBS=-lrt

UDEV_CONF_OPT =			\
	--sbindir=/sbin		\
	--with-rootlibdir=/lib	\
	--libexecdir=/lib	\
	--with-usb-ids-path=/usr/share/hwdata/usb.ids	\
	--with-pci-ids-path=/usr/share/hwdata/pci.ids	\
	--with-firmware-path=/lib/firmware		\
	--disable-introspection

UDEV_DEPENDENCIES = host-gperf host-pkgconf util-linux kmod

ifeq ($(BR2_PACKAGE_UDEV_RULES_GEN),y)
UDEV_CONF_OPT += --enable-rule_generator
endif

ifeq ($(BR2_PACKAGE_UDEV_ALL_EXTRAS),y)
UDEV_DEPENDENCIES += acl hwdata libglib2
UDEV_CONF_OPT +=		\
	--enable-udev_acl
else
UDEV_CONF_OPT +=		\
	--disable-gudev
endif

ifeq ($(BR2_PACKAGE_SYSTEMD),y)
	UDEV_CONF_OPT += --with-systemdsystemunitdir=/lib/systemd/system/
endif

define UDEV_INSTALL_INITSCRIPT
	$(INSTALL) -m 0755 package/udev/S10udev $(TARGET_DIR)/etc/init.d/S10udev
	$(INSTALL) -m 0755 package/udev/S99udev-stop-exec-queue $(TARGET_DIR)/etc/init.d/S99udev-stop-exec-queue
endef

define UDEV_NO_AUTO_LOAD_HANDLING
	@echo UDEV_NO_AUTO_LOAD_HANDLING
	# Avoid auto-loading all device drivers, with udev_182. (HACK)
	# Some devices require firmware and are highly dependent on various conditions
	# and thus handled by specific scripts.
	( cd $(TARGET_DIR)/lib/udev; \
	  [ -f rules.d/??-drivers.rules ] \
	  && { mkdir -p rules.disabled; mv rules.d/??-drivers.rules rules.disabled; } || : \
	)
endef

UDEV_POST_INSTALL_TARGET_HOOKS += UDEV_INSTALL_INITSCRIPT
UDEV_POST_INSTALL_TARGET_HOOKS += UDEV_NO_AUTO_LOAD_HANDLING

$(eval $(autotools-package))
