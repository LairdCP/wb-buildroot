################################################################################
#
# FLATCC
#
################################################################################
FLATCC_VERSION = v0.4.3
FLATCC_SITE =$(call github,dvidelabs,flatcc,$(FLATCC_VERSION))
FLATCC_LICENSE = Apache-2.0
FLATCC_LICENSE_FILES = LICENSE
FLATCC_INSTALL_STAGING = YES
FLATCC_DEPENDENCIES = host-flatcc

FLATCC_CONF_OPTS += -DFLATCC_TEST=OFF
HOST_FLATCC_CONF_OPTS += -DFLATCC_TEST=OFF

define HOST_FLATCC_INSTALL_CMDS
	$(INSTALL) -D -m 0755 $(@D)/bin/flatcc $(HOST_DIR)/usr/bin/flatcc
endef

# Need to force flatcc to do static or shared or both libraries
ifeq ($(BR2_STATIC_LIBS),y)
FLATCC_CONF_OPTS += -DBUILD_SHARED_LIBS=OFF -DFLATCC_RTONLY=ON
else ifeq ($(BR2_SHARED_STATIC_LIBS),y)
FLATCC_CONF_OPTS += -DBUILD_SHARED_LIBS=ON -DFLATCC_RTONLY=ON
else ifeq ($(BR2_SHARED_LIBS),y)
FLATCC_CONF_OPTS += -DBUILD_SHARED_LIBS=ON -DFLATCC_RTONLY=OFF
endif

# flatcc's cmake build doesn't include install targets, so we need to manually
# install the various components to their respective destinations. There's
# several cases that need to be taken care of, so we do a little dance to do so.
ifeq ($(BR2_SHARED_LIBS),)
define FLATCC_INSTALL_STAGING_STATIC
	$(INSTALL) -D -m 0755 $(@D)/lib/libflatcc.a $(STAGING_DIR)/usr/lib/libflatcc.a
	$(INSTALL) -D -m 0755 $(@D)/lib/libflatccrt.a $(STAGING_DIR)/usr/lib/libflatccrt.a
endef
endif

ifeq ($(BR2_STATIC_LIBS),)
define FLATCC_INSTALL_STAGING_SHARED
	$(INSTALL) -D -m 0755 $(@D)/lib/libflatcc.so $(STAGING_DIR)/usr/lib/libflatcc.so
	$(INSTALL) -D -m 0755 $(@D)/lib/libflatccrt.so $(STAGING_DIR)/usr/lib/libflatccrt.so
endef
endif

define FLATCC_INSTALL_STAGING_CMDS
	cp -r $(@D)/include/flatcc $(STAGING_DIR)/usr/include/.
	$(FLATCC_INSTALL_STAGING_STATIC)
	$(FLATCC_INSTALL_STAGING_SHARED)
endef

# If we don't have the shared libs to install, don't run target install
ifeq ($(FLATCC_INSTALL_STAGING_SHARED),)
FLATCC_INSTALL_TARGET = NO
endif

define FLATCC_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/lib/libflatcc.so $(TARGET_DIR)/usr/lib/libflatcc.so
	$(INSTALL) -D -m 0755 $(@D)/lib/libflatccrt.so $(TARGET_DIR)/usr/lib/libflatccrt.so
endef

$(eval $(cmake-package))
$(eval $(host-cmake-package))
