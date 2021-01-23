#############################################################
#
# LRD_USERSPACE_EXAMPLES
#
#############################################################

LRD_USERSPACE_EXAMPLES_VERSION = local
LRD_USERSPACE_EXAMPLES_SITE = package/lrd/externals/lrd-userspace-examples
LRD_USERSPACE_EXAMPLES_SITE_METHOD = local
LRD_USERSPACE_EXAMPLES_LICENSE = LGPL-2.0+

LRD_USERSPACE_EXAMPLES_DEPENDENCIES = host-pkgconf lrd-network-manager
LRD_USERSPACE_EXAMPLES_INSTALL_STAGING=YES
LRD_USERSPACE_EXAMPLES_AUTORECONF = YES

LRD_USERSPACE_EXAMPLES_CONF_OPTS =

ifeq ($(BR2_PACKAGE_LRD_USERSPACE_NETWORKMANAGER_EXAMPLES),y)
	LRD_USERSPACE_EXAMPLES_CONF_OPTS += --enable-nm-examples
endif

ifeq ($(BR2_PACKAGE_LRD_USERSPACE_NETLINK_EXAMPLES),y)
	LRD_USERSPACE_EXAMPLES_CONF_OPTS += --enable-nl-examples
endif

ifeq ($(BR2_PACKAGE_LRD_USERSPACE_CMUX),y)
	LRD_USERSPACE_EXAMPLES_CONF_OPTS += --enable-cmux
define LRD_USERSPACE_EXAMPLES_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 package/lrd/lrd-userspace-examples/cmux.service \
		$(TARGET_DIR)/usr/lib/systemd/system/cmux.service
	mkdir -p $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
	ln -rsf $(TARGET_DIR)/usr/lib/systemd/system/cmux.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/cmux.service
endef
endif

$(eval $(autotools-package))
