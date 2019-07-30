WIFI_TEST_SUITE_VERSION = master
WIFI_TEST_SUITE_SITE_METHOD = git
WIFI_TEST_SUITE_SITE = git://github.com/Wi-FiTestSuite/Wi-FiTestSuite-Linux-DUT

define WIFI_TEST_SUITE_BUILD_CMDS
	$(MAKE)  -C $(@D) \
	CC="$(TARGET_CC)"  AR="$(TARGET_AR)"
endef

define WIFI_TEST_SUITE_INSTALL_TARGET_CMDS
     $(INSTALL) -D -m 0755 $(@D)/dut/wfa_dut $(TARGET_DIR)/usr/bin/wfa_dut
     $(INSTALL) -D -m 0755 $(@D)/ca/wfa_ca $(TARGET_DIR)/usr/bin/wfa_ca
     $(INSTALL) -D -m 0755 $(@D)/console_src/wfa_con $(TARGET_DIR)/usr/bin/wfa_con
     $(INSTALL) -D -m 0755 $(@D)/WTGService/WTG $(TARGET_DIR)/usr/bin/WTG
     $(INSTALL) -D -m 0755 $(@D)/scripts/getipconfig.sh $(TARGET_DIR)/usr/sbin/getipconfig.sh
endef

$(eval $(generic-package))
