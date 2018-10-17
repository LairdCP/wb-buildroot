################################################################################
#
# easycwmp
#
################################################################################
EASYCWMP_VERSION = 8a4c3f36d49cd85b33ebb8b9f05b448bcad85e51
EASYCWMP_SITE = git://github.com/pivasoftware/easycwmp.git
EASYCWMP_DEPENDENCIES = libcurl libubox ubus openssl libuci microxml

EASYCWMP_AUTORECONF = YES

TARGET_CFLAGS += \
	-D_GNU_SOURCE

TARGET_LDFLAGS += \
	-Wl,-rpath-link=$(STAGING_DIR)/usr/lib

EASYCWMP_CONF_OPTS += \
	--with-uci-include-path=$(STAGING_DIR)/usr/include \
	--with-libubox-include-path=$(STAGING_DIR)/usr/include \
	--with-libubus-include-path=$(STAGING_DIR)/usr/include

EASYCWMP_CONF_OPTS += \
	--enable-debug

EASYCWMP_CONF_OPTS += \
	--enable-devel

EASYCWMP_CONF_OPTS += \
	--enable-acs=multi

EASYCWMP_CONF_OPTS += \
	--enable-jsonc=1

define EASYCWMP_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/etc/config
	mkdir -p $(TARGET_DIR)/etc/easycwmp
	mkdir -p $(TARGET_DIR)/usr/share/easycwmp/functions
	mkdir -p $(TARGET_DIR)/lib/config
	mkdir -p $(TARGET_DIR)/lib/functions
	$(INSTALL) -m 0755 $(@D)/ext/openwrt/scripts/easycwmp.sh $(TARGET_DIR)/usr/sbin/easycwmp
	$(INSTALL) -m 0755 $(@D)/ext/openwrt/scripts/defaults $(TARGET_DIR)/usr/share/easycwmp
	$(INSTALL) -m 0755 $(@D)/ext/openwrt/scripts/functions/common/common $(TARGET_DIR)/usr/share/easycwmp/functions
	$(INSTALL) -m 0755 $(@D)/ext/openwrt/scripts/functions/common/device_info $(TARGET_DIR)/usr/share/easycwmp/functions
	$(INSTALL) -m 0755 $(@D)/ext/openwrt/scripts/functions/common/management_server $(TARGET_DIR)/usr/share/easycwmp/functions
	$(INSTALL) -m 0755 $(@D)/ext/openwrt/scripts/functions/common/ipping_launch $(TARGET_DIR)/usr/share/easycwmp/functions
	$(INSTALL) -m 0755 $(@D)/ext/openwrt/scripts/functions/tr098/root $(TARGET_DIR)/usr/share/easycwmp/functions
	$(INSTALL) -m 0755 $(@D)/ext/openwrt/scripts/functions/tr098/wan_device $(TARGET_DIR)/usr/share/easycwmp/functions
	$(INSTALL) -m 0755 $(@D)/ext/openwrt/scripts/functions/tr098/lan_device $(TARGET_DIR)/usr/share/easycwmp/functions
	$(INSTALL) -m 0755 $(@D)/ext/openwrt/scripts/functions/tr098/ipping_diagnostic $(TARGET_DIR)/usr/share/easycwmp/functions
	$(INSTALL) -m 0755 $(@D)/ext/openwrt/scripts/functions/laird/laird_device $(TARGET_DIR)/usr/share/easycwmp/functions
	$(INSTALL) -m 0755 $(@D)/ext/openwrt/config/easycwmp $(TARGET_DIR)/etc/config/easycwmp
	$(INSTALL) -m 0755 $(@D)/bin/easycwmpd $(TARGET_DIR)/usr/sbin
	$(INSTALL) -m 0755 $(@D)/ext/openwrt/scripts/functions/laird/functions.sh $(TARGET_DIR)/lib/
	$(INSTALL) -m 0755 $(@D)/ext/openwrt/scripts/functions/laird/uci.sh $(TARGET_DIR)/lib/config
	$(INSTALL) -m 0755 $(@D)/ext/openwrt/scripts/functions/laird/network.sh $(TARGET_DIR)/lib/functions
	$(INSTALL) -m 0755 $(@D)/ext/openwrt/init.d/easycwmpd $(TARGET_DIR)/etc/easycwmp
	$(INSTALL) -m 0755 package/lrd/easycwmp/S97easycwmp $(TARGET_DIR)/etc/init.d/S97easycwmp
endef

$(eval $(autotools-package))

