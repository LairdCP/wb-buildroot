################################################################################
#
# node-ssl-shim
#
################################################################################

NODE_SSL_SHIM_VERSION = 70e39fdc1db4525191acc765f9d524ddb58a1756
NODE_SSL_SHIM_SITE = $(call github,sclorg,node-ssl-shim,$(NODE_SSL_SHIM_VERSION))
NODE_SSL_SHIM_DEPENDENCIES = openssl

NODE_SSL_SHIM_LICENSE = MIT
NODE_SSL_SHIM_LICENSE_FILES = LICENSE

NODE_SSL_SHIM_INSTALL_STAGING = YES

define NODE_SSL_SHIM_BUILD_CMDS
	$(MAKE) -C $(@D) $(TARGET_CONFIGURE_OPTS)
endef

define NODE_SSL_SHIM_INSTALL_STAGING_CMDS
	$(INSTALL) -D -t $(STAGING_DIR)/usr/lib -m 0644 $(@D)/libnode-ssl-shim.a
	$(INSTALL) -D -t $(STAGING_DIR)/usr/include/node-ssl-shim -m 0644 $(@D)/src/*.h
endef

$(eval $(generic-package))
