WIFI_TEST_SUITE_VERSION = 12e85fbeca8ca21a632d18e55089a8a7606d64aa
WIFI_TEST_SUITE_SITE = $(call github,Wi-FiTestSuite,Wi-FiTestSuite-Linux-DUT,$(WIFI_TEST_SUITE_VERSION))

WIFI_TEST_SUITE_CFLAGS = -D_REENTRANT -DWFA_DEBUG -I../inc -pthread

ifeq ($(BR2_PACKAGE_LIBTIRPC),y)
WIFI_TEST_SUITE_DEPENDENCIES += libtirpc host-pkgconf
WIFI_TEST_SUITE_CFLAGS += $(shell $(PKG_CONFIG_HOST_BINARY) --cflags libtirpc)
WIFI_TEST_SUITE_CFLAGS += $(shell $(PKG_CONFIG_HOST_BINARY) --libs libtirpc)
endif

define WIFI_TEST_SUITE_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) $(TARGET_CONFIGURE_OPTS) CFLAGS+="$(WIFI_TEST_SUITE_CFLAGS)"
endef

define WIFI_TEST_SUITE_INSTALL_TARGET_CMDS
     $(INSTALL) -D -m 0755 $(@D)/dut/wfa_dut $(TARGET_DIR)/usr/bin/wfa_dut
     $(INSTALL) -D -m 0755 $(@D)/ca/wfa_ca $(TARGET_DIR)/usr/bin/wfa_ca
     $(INSTALL) -D -m 0755 $(@D)/console_src/wfa_con $(TARGET_DIR)/usr/bin/wfa_con
     $(INSTALL) -D -m 0755 $(@D)/WTGService/WTG $(TARGET_DIR)/usr/bin/WTG
     $(INSTALL) -D -m 0755 $(@D)/scripts/getipconfig.sh $(TARGET_DIR)/usr/sbin/getipconfig.sh
endef

$(eval $(generic-package))
