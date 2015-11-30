#############################################################
#
# DHD driver
#
#############################################################

DHD_VERSION = local
DHD_SITE = package/lrd-closed-source/externals/dhd
DHD_SITE_METHOD = local

DHD_DEPENDENCIES = linux
DHD_MAKE_ENV = CC="$(TARGET_CC)" \
               CXX="$(TARGET_CXX)" \
               ARCH="$(KERNEL_ARCH)" \
               CFLAGS="$(TARGET_CFLAGS)" \
               LINUXDIR="$(LINUX_DIR)" \
               CROSS_COMPILE="$(TARGET_CROSS)"

DHD_BT_FW1 = BCM4329B1_002.002.023.0924.1027.hcd
DHD_BT_FW2 = BCM4329B1_002.002.023.0924.1032.hcd
DHD_FIRMWARE_FILENAME_1 = 4329b1_4_220_55_sdio-ag-cdc-full11n-reclaim-roml-wme-aoe-pktfilter-keepalive-extsup.bin
DHD_FIRMWARE_FILENAME_2 = 4329b1_4_220_55_sdio-ag-cdc-reclaim-roml-wme-aoe-pktfilter-keepalive-ccxv4-extsup-minccx.bin
DHD_DEBUG = -debug
DHD_TARGET_DIR = $(TARGET_DIR)

define DHD_CONFIGURE_CMDS
endef

define DHD_BUILD_CMDS
	#$(MAKE) -C $(@D) clean
    #make ARCH=arm CROSS_COMPILE=arm-sdc-linux-gnueabi- LINUXDIR=~/dev_linux/wb40n/basic/kernel/ dhd-cdc-sdmmc-cfg80211-gpl
	$(DHD_MAKE_ENV) $(MAKE) -C $(@D)/open-src/src/dhd/linux V=1 dhd-cdc-sdmmc-cfg80211-gpl$(DHD_DEBUG)
    $(MAKE) -C $(@D)/open-src/src/wl/exe CC="$(TARGET_CC)"
endef

define DHD_INSTALL_TARGET_CMDS
	$(MAKE) --no-print-directory -C $(LINUX_DIR) kernelrelease ARCH=arm CROSS_COMPILE="$(TARGET_CROSS)" > $(@D)/kernel.release
	$(MAKE) --no-print-directory -C $(LINUX_DIR) kernelversion ARCH=arm CROSS_COMPILE="$(TARGET_CROSS)" > $(@D)/kernel.version
	$(INSTALL) -D -m 644 $(@D)/open-src/src/dhd/linux/dhd-cdc-sdmmc-cfg80211-gpl$(DHD_DEBUG)-`cat $(@D)/kernel.release`/dhd.ko  \
        $(DHD_TARGET_DIR)/lib/modules/`cat $(@D)/kernel.release`/extra/drivers/net/wireless/dhd.ko
   $(INSTALL) -D -m 644 $(@D)/firmware/4329b1/$(DHD_FIRMWARE_FILENAME_1) \
        $(DHD_TARGET_DIR)/etc/summit/firmware/$(DHD_FIRMWARE_FILENAME_1)
   $(INSTALL) -D -m 644 $(@D)/firmware/4329b1/$(DHD_FIRMWARE_FILENAME_2) \
        $(DHD_TARGET_DIR)/etc/summit/firmware/$(DHD_FIRMWARE_FILENAME_2)
    ln -sf $(DHD_FIRMWARE_FILENAME_1) $(DHD_TARGET_DIR)/etc/summit/firmware/fw
    ln -sf $(DHD_FIRMWARE_FILENAME_2) $(DHD_TARGET_DIR)/etc/summit/firmware/fw-ccx
    $(INSTALL) -D -m 644 $(@D)/nvram/production.nv $(DHD_TARGET_DIR)/etc/summit/nvram/nv
    $(INSTALL) -D -m 755 $(@D)/open-src/src/wl/exe/wl $(DHD_TARGET_DIR)/usr/bin/wl
    $(INSTALL) -D -m 644 $(@D)/firmware/bt/$(DHD_BT_FW1) $(DHD_TARGET_DIR)/etc/summit/firmware/$(DHD_BT_FW1)
    $(INSTALL) -D -m 644 $(@D)/firmware/bt/$(DHD_BT_FW2) $(DHD_TARGET_DIR)/etc/summit/firmware/$(DHD_BT_FW2)
endef

#define DHD_UNINSTALL_TARGET_CMDS
#endef

$(eval $(generic-package))
