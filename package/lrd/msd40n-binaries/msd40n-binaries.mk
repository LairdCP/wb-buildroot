MSD40N_BINARIES_VERSION = $(call qstrip,$(BR2_MSD40N_BINARIES_VERSION))
MSD40N_BINARIES_COMPANY_PROJECT = $(call qstrip,$(BR2_MSD40N_BINARIES_COMPANY_PROJECT))
MSD40N_BINARIES_SITE = http://boris.corp.lairdtech.com/builds/linux/msd40n/$(BR2_MSD40N_BINARIES_COMPANY_PROJECT)/$(MSD40N_BINARIES_VERSION)
MSD40N_BINARIES_SOURCE = msd40n-$(MSD40N_BINARIES_COMPANY_PROJECT)-$(MSD40N_BINARIES_VERSION).tar.bz2
MSD40N_BINARIES_DEPENDENCIES = linux
MSD40N_BINARIES_INSTALL_STAGING = YES

define MSD40N_BINARIES_EXTRACT_CMDS
	$(TAR) -C "$(@D)" -xf $(DL_DIR)/$(MSD40N_BINARIES_SOURCE) --strip-components=1
endef

define MSD40N_BINARIES_CONFIGURE_CMDS
	(cd $(@D) && ls -1 && tar xf rootfs.tar)
endef

define MSD40N_BINARIES_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/bin
	$(INSTALL) -D -m 755 $(@D)/usr/bin/sdc_cli $(TARGET_DIR)/usr/bin/sdc_cli
	$(INSTALL) -D -m 755 $(@D)/usr/sbin/smu_cli $(TARGET_DIR)/usr/sbin/smu_cli
	$(INSTALL) -D -m 755 $(@D)/usr/bin/sdcsupp $(TARGET_DIR)/usr/bin/sdcsupp
	$(INSTALL) -D -m 755 $(@D)/usr/bin/dhcp_injector $(TARGET_DIR)/usr/bin/dhcp_injector
	mkdir -p $(TARGET_DIR)/usr/lib
	$(INSTALL) -m 755 $(@D)/usr/lib/libsdc_sdk.so* $(TARGET_DIR)/usr/lib/
	$(INSTALL) -D -m 755 $(@D)/usr/bin/wl $(TARGET_DIR)/usr/bin/wl
	mkdir -p $(DHD_TARGET_DIR)/etc/summit
	tar c -C $(@D)/etc/summit . | tar x -C $(DHD_TARGET_DIR)/etc/summit
	find $(DHD_TARGET_DIR)/etc/summit -type d -exec chmod 755 "{}" ";"
	find $(DHD_TARGET_DIR)/etc/summit -type f -exec chmod 644 "{}" ";"
	$(MAKE) --no-print-directory -C $(LINUX_DIR) kernelrelease ARCH=arm CROSS_COMPILE="$(TARGET_CROSS)" > $(@D)/kernel.release
	$(INSTALL) -D -m 644 $(@D)/lib/modules/`cat $(@D)/kernel.release`/extra/drivers/net/wireless/dhd.ko \
	$(DHD_TARGET_DIR)/lib/modules/`cat $(@D)/kernel.release`/extra/drivers/net/wireless/dhd.ko
endef

define MSD40N_BINARIES_INSTALL_STAGING_CMDS
	rm -f $(STAGING_DIR)/usr/lib/libsdc_sdk.so*
	$(INSTALL) -D -m 0755 $(@D)/usr/lib/libsdc_sdk.so.1.0 $(STAGING_DIR)/usr/lib/
	cd  $(STAGING_DIR)/usr/lib/ && ln -s libsdc_sdk.so.1.0 libsdc_sdk.so.1
	cd  $(STAGING_DIR)/usr/lib/ && ln -s libsdc_sdk.so.1 libsdc_sdk.so
	$(INSTALL) -D -m 0644 $(@D)/include/sdc_sdk.h \
		$(@D)/include/sdc_events.h \
		$(@D)/include/lrd_sdk_pil.h \
		$(STAGING_DIR)/usr/include/
endef

$(eval $(generic-package))
