################################################################################
#
# FLATCC
#
################################################################################
FLATCC_VERSION = v0.3.0
FLATCC_SITE =$(call github,dvidelabs,flatcc,$(FLATCC_VERSION))
FLATCC_LICENSE = Apache-2.0
FLATCC_LICENSE_FILES = LICENSE
FLATCC_INSTALL_STAGING = YES
FLATCC_DEPENDENCIES += host-flatcc

FLATCC_CONF_OPTS += -DFLATCC_TEST=OFF -DFLATCC_PORTABLE=ON
HOST_FLATCC_CONF_OPTS += -DFLATCC_TEST=OFF

define HOST_FLATCC_INSTALL_CMDS
	$(INSTALL) -D -m 0755 $(@D)/bin/flatcc $(HOST_DIR)/usr/bin/flatcc
endef

ifeq ($(BR2_STATIC_LIBS),y)
	FLATCC_INSTALL_TARGET = NO
define FLATCC_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0755 $(@D)/lib/libflatcc.a $(STAGING_DIR)/usr/lib/libflatcc.a
	$(INSTALL) -D -m 0755 $(@D)/lib/libflatccrt.a $(STAGING_DIR)/usr/lib/libflatccrt.a
	cp -r $(@D)/include/flatcc $(STAGING_DIR)/usr/include/.
endef
else
define FLATCC_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0755 $(@D)/lib/libflatcc.so $(STAGING_DIR)/usr/lib/libflatcc.so
	$(INSTALL) -D -m 0755 $(@D)/lib/libflatccrt.so $(STAGING_DIR)/usr/lib/libflatccrt.so
	cp -r $(@D)/include/flatcc $(STAGING_DIR)/usr/include/.
endef
endif

define FLATCC_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/lib/libflatcc.so $(TARGET_DIR)/usr/lib/libflatcc.so
	$(INSTALL) -D -m 0755 $(@D)/lib/libflatccrt.so $(TARGET_DIR)/usr/lib/libflatccrt.so
endef

$(eval $(cmake-package))
$(eval $(host-cmake-package))
