MSD_BINARIES_VERSION = 6.0.0.54
MSD_BINARIES_COMPANY_PROJECT = $(call qstrip,$(BR2_MSD_BINARIES_COMPANY_PROJECT))

MSD_BINARIES_WB_PLATFORM := $(call qstrip,$(BR2_LRD_PLATFORM))
ifeq ($(MSD_BINARIES_WB_PLATFORM),wb50n)
	MSD_BINARIES_PLATFORM = msd50n
else ifeq ($(MSD_BINARIES_WB_PLATFORM),wb45n)
	MSD_BINARIES_PLATFORM = msd45n
else ifeq ($(BR2_PACKAGE_MSD_BINARIES),y)
	$(error "ERROR: Expected BR2_LRD_PLATFORM to be wb50n, or wb45n.")
endif

MSD_BINARIES_SITE = https://github.com/LairdCP/wb-package-archive/raw/master

MSD_BINARIES_SOURCE = $(MSD_BINARIES_PLATFORM)-$(MSD_BINARIES_COMPANY_PROJECT)-$(MSD_BINARIES_VERSION).tar.bz2
MSD_BINARIES_DEPENDENCIES =
MSD_BINARIES_INSTALL_STAGING = YES

define MSD_BINARIES_EXTRACT_CMDS
	$(TAR) -C "$(@D)" -xf $(DL_DIR)/$(MSD_BINARIES_SOURCE) --strip-components=1
endef

define MSD_BINARIES_CONFIGURE_CMDS
	(cd $(@D) && ls -1 && tar xf rootfs.tar)
endef

define MSD_BINARIES_WEBLCM_INSTALL_TARGET
	mkdir -p -m 0775 $(TARGET_DIR)/var/www/docs
	mkdir -p -m 0775 $(TARGET_DIR)/var/www/docs/assets/css
	mkdir -p -m 0775 $(TARGET_DIR)/var/www/docs/assets/img
	mkdir -p -m 0775 $(TARGET_DIR)/var/www/docs/assets/js
	mkdir -p -m 0775 $(TARGET_DIR)/var/www/docs/assets/fonts
	mkdir -p -m 0775 $(TARGET_DIR)/var/www/docs/html
	mkdir -p -m 0775 $(TARGET_DIR)/var/www/docs/php
	mkdir -p -m 0775 $(TARGET_DIR)/var/www/docs/plugins
	mkdir -p -m 0775 $(TARGET_DIR)/etc/lighttpd
	cp -r $(@D)/var/www/docs/php/* $(TARGET_DIR)/var/www/docs/php
	cp -r $(@D)/var/www/docs/plugins/* $(TARGET_DIR)/var/www/docs/plugins
	cp -r $(@D)/var/www/docs/html/* $(TARGET_DIR)/var/www/docs/html
	$(INSTALL) -D -m 644 $(@D)/var/www/docs/webLCM.* $(TARGET_DIR)/var/www/docs/
	$(INSTALL) -D -m 644 $(@D)/var/www/docs/assets/css/*.css $(TARGET_DIR)/var/www/docs/assets/css/
	$(INSTALL) -D -m 644 $(@D)/var/www/docs/assets/img/*.png $(TARGET_DIR)/var/www/docs/assets/img/
	$(INSTALL) -D -m 644 $(@D)/var/www/docs/assets/js/*.js $(TARGET_DIR)/var/www/docs/assets/js/
	$(INSTALL) -D -m 0755 $(@D)/var/www/docs/assets/fonts/* $(TARGET_DIR)/var/www/docs/assets/fonts/
	$(INSTALL) -D -m 644 $(@D)/etc/lighttpd/lighttpd.* $(TARGET_DIR)/etc/lighttpd/
endef
ifeq ($(BR2_MSD_BINARIES_WEBLCM),y)
	MSD_BINARIES_POST_INSTALL_TARGET_HOOKS += MSD_BINARIES_WEBLCM_INSTALL_TARGET
endif

define MSD_BINARIES_EVENTMON_INSTALL_TARGET
	$(INSTALL) -D -m 755 $(@D)/usr/bin/event_mon $(TARGET_DIR)/usr/bin/event_mon
endef
ifeq ($(BR2_MSD_BINARIES_EVENTMON),y)
	MSD_BINARIES_POST_INSTALL_TARGET_HOOKS += MSD_BINARIES_EVENTMON_INSTALL_TARGET
endif

define MSD_BINARIES_SDCCLI_INSTALL_TARGET
	$(INSTALL) -D -m 755 $(@D)/usr/bin/sdc_cli $(TARGET_DIR)/usr/bin/sdc_cli
endef
ifeq ($(BR2_MSD_BINARIES_SDCCLI),y)
	MSD_BINARIES_POST_INSTALL_TARGET_HOOKS += MSD_BINARIES_SDCCLI_INSTALL_TARGET
endif

define MSD_BINARIES_SDCSUPP_INSTALL_TARGET
	$(INSTALL) -D -m 755 $(@D)/usr/bin/sdcsupp $(TARGET_DIR)/usr/bin/sdcsupp
endef
ifeq ($(BR2_MSD_BINARIES_SDCSUPP),y)
	MSD_BINARIES_POST_INSTALL_TARGET_HOOKS += MSD_BINARIES_SDCSUPP_INSTALL_TARGET
endif

define MSD_BINARIES_SDCSDK_INSTALL_TARGET
	$(INSTALL) -D -m 755 $(@D)/usr/bin/dhcp_injector $(TARGET_DIR)/usr/bin/dhcp_injector
	$(INSTALL) -m 755 $(@D)/usr/lib/libsdc_sdk.so* $(TARGET_DIR)/usr/lib/
endef
define MSD_BINARIES_SDCSDK_STAGING_TARGET
	rm -f $(STAGING_DIR)/usr/lib/libsdc_sdk.so*
	$(INSTALL) -D -m 0755 $(@D)/usr/lib/libsdc_sdk.so.1.0 $(STAGING_DIR)/usr/lib/
	cd  $(STAGING_DIR)/usr/lib/ && ln -s libsdc_sdk.so.1.0 libsdc_sdk.so.1
	cd  $(STAGING_DIR)/usr/lib/ && ln -s libsdc_sdk.so.1 libsdc_sdk.so
	$(INSTALL) -D -m 0644 $(@D)/include/sdc_sdk.h \
		$(@D)/include/sdc_events.h \
		$(@D)/include/lrd_sdk_pil.h \
		$(@D)/include/lrd_sdk_eni.h \
		$(STAGING_DIR)/usr/include/
endef
	MSD_BINARIES_POST_INSTALL_TARGET_HOOKS += MSD_BINARIES_SDCSDK_INSTALL_TARGET
	MSD_BINARIES_POST_INSTALL_STAGING_HOOKS += MSD_BINARIES_SDCSDK_STAGING_TARGET

define MSD_BINARIES_LLAGENT_INSTALL_TARGET
	$(INSTALL) -D -m 755 $(@D)/usr/bin/llagent $(TARGET_DIR)/usr/bin/llagent
	$(INSTALL) -D -m 755 $(@D)/etc/init.d/opt/S99agent $(TARGET_DIR)/etc/init.d/opt/S99agent
endef
ifeq ($(BR2_MSD_BINARIES_LLAGENT),y)
	MSD_BINARIES_POST_INSTALL_TARGET_HOOKS += MSD_BINARIES_LLAGENT_INSTALL_TARGET
endif

define MSD_BINARIES_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/bin
	mkdir -p $(TARGET_DIR)/usr/lib
	$(MAKE) --no-print-directory -C $(LINUX_DIR) kernelrelease ARCH=arm CROSS_COMPILE="$(TARGET_CROSS)" > $(@D)/kernel.release
	mkdir -p $(TARGET_DIR)/lib/modules/`cat $(@D)/kernel.release`/extra
	mkdir -p -m 700 $(TARGET_DIR)/usr/sbfs
endef

define MSD_BINARIES_INSTALL_STAGING_CMDS
endef

define MSD_BINARIES_INSTALL_FIPS_BINARIES
	$(INSTALL) -D -m 755 $(@D)/usr/bin/sdcu $(TARGET_DIR)/usr/bin/sdcu
endef

define MSD_BINARIES_LAIRD_FIRMWARE_AR6003
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/ath6k
	cp -r $(@D)/lib/firmware/ath6k/AR6003 $(TARGET_DIR)/lib/firmware/ath6k
endef
ifeq ($(BR2_MSD_BINARIES_LAIRD_FIRMWARE_AR6003),y)
	MSD_BINARIES_POST_INSTALL_TARGET_HOOKS += MSD_BINARIES_LAIRD_FIRMWARE_AR6003
endif

define MSD_BINARIES_LAIRD_FIRMWARE_AR6004
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/ath6k
	cp -r $(@D)/lib/firmware/ath6k/AR6004 $(TARGET_DIR)/lib/firmware/ath6k
endef
ifeq ($(BR2_MSD_BINARIES_LAIRD_FIRMWARE_AR6004),y)
	MSD_BINARIES_POST_INSTALL_TARGET_HOOKS += MSD_BINARIES_LAIRD_FIRMWARE_AR6004
endif

define MSD_BINARIES_LAIRD_FIRMWARE_BT
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware
	cp -r $(@D)/lib/firmware/bluetopia $(TARGET_DIR)/lib/firmware
endef
ifeq ($(BR2_MSD_BINARIES_LAIRD_FIRMWARE_BT),y)
	MSD_BINARIES_POST_INSTALL_TARGET_HOOKS += MSD_BINARIES_LAIRD_FIRMWARE_BT
endif

MSD_BINARIES_DEPENDENCIES += linux
MSD_BINARIES_POST_INSTALL_TARGET_HOOKS += MSD_BINARIES_INSTALL_FIPS_BINARIES

$(eval $(generic-package))
