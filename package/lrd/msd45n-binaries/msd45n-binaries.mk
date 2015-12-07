MSD45N_BINARIES_VERSION = $(call qstrip,$(BR2_MSD45N_BINARIES_VERSION))
MSD45N_BINARIES_COMPANY_PROJECT = $(call qstrip,$(BR2_MSD45N_BINARIES_COMPANY_PROJECT))

MSD45N_BINARIES_WB_PLATFORM := $(call qstrip,$(BR2_LRD_PLATFORM))
ifeq ($(MSD45N_BINARIES_WB_PLATFORM),wb50n)
	MSD45N_BINARIES_PLATFORM = msd50n
else ifeq ($(MSD45N_BINARIES_WB_PLATFORM),wb45n)
	MSD45N_BINARIES_PLATFORM = msd45n
else ifeq ($(BR2_PACKAGE_MSD45N_BINARIES),y)
	$(error "ERROR: Expected BR2_LRD_PLATFORM to be wb50n, or wb45n.")
endif

MSD45N_BINARIES_SITE = http://devops.lairdtech.com/share/builds/linux/$(MSD45N_BINARIES_PLATFORM)/$(MSD45N_BINARIES_COMPANY_PROJECT)/$(MSD45N_BINARIES_VERSION)

MSD45N_BINARIES_SOURCE = $(MSD45N_BINARIES_PLATFORM)-$(MSD45N_BINARIES_COMPANY_PROJECT)-$(MSD45N_BINARIES_VERSION).tar.bz2
MSD45N_BINARIES_DEPENDENCIES =
MSD45N_BINARIES_INSTALL_STAGING = YES

define MSD45N_BINARIES_EXTRACT_CMDS
	$(TAR) -C "$(@D)" -xf $(DL_DIR)/$(MSD45N_BINARIES_SOURCE) --strip-components=1
endef

define MSD45N_BINARIES_CONFIGURE_CMDS
	(cd $(@D) && ls -1 && tar xf rootfs.tar)
endef

define MSD45N_BINARIES_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/bin
	$(INSTALL) -D -m 755 $(@D)/usr/bin/sdc_cli $(TARGET_DIR)/usr/bin/sdc_cli
	$(INSTALL) -D -m 755 $(@D)/usr/sbin/smu_cli $(TARGET_DIR)/usr/sbin/smu_cli
	$(INSTALL) -D -m 755 $(@D)/usr/bin/sdcsupp $(TARGET_DIR)/usr/bin/sdcsupp
	$(INSTALL) -D -m 755 $(@D)/usr/bin/athtestcmd $(TARGET_DIR)/usr/bin/athtestcmd
	$(INSTALL) -D -m 755 $(@D)/usr/bin/dhcp_injector $(TARGET_DIR)/usr/bin/dhcp_injector
	$(INSTALL) -D -m 755 $(@D)/usr/bin/smartSS $(TARGET_DIR)/usr/bin/smartSS
	$(INSTALL) -D -m 755 $(@D)/usr/bin/smartBASIC $(TARGET_DIR)/usr/bin/smartBASIC
	mkdir -p $(TARGET_DIR)/usr/lib
	$(INSTALL) -m 755 $(@D)/usr/lib/libsdc_sdk.so* $(TARGET_DIR)/usr/lib/
	$(MAKE) --no-print-directory -C $(LINUX_DIR) kernelrelease ARCH=arm CROSS_COMPILE="$(TARGET_CROSS)" > $(@D)/kernel.release
	mkdir -p $(TARGET_DIR)/lib/modules/`cat $(@D)/kernel.release`/extra
	$(INSTALL) -D -m 755 $(@D)/etc/init.d/S95bluetooth $(TARGET_DIR)/etc/init.d/S95bluetooth
	mkdir -p $(TARGET_DIR)/var/www/docs
	mkdir -p $(TARGET_DIR)/var/www/docs/assets/css
	mkdir -p $(TARGET_DIR)/var/www/docs/assets/img
	mkdir -p $(TARGET_DIR)/var/www/docs/assets/js
	$(INSTALL) -D -m 644  $(@D)/var/www/docs/*.html   $(TARGET_DIR)/var/www/docs/
	$(INSTALL) -D -m 644  $(@D)/var/www/docs/*.php   $(TARGET_DIR)/var/www/docs/
	$(INSTALL) -D -m 644  $(@D)/var/www/docs/assets/css/*.css   $(TARGET_DIR)/var/www/docs/assets/css/
	$(INSTALL) -D -m 644  $(@D)/var/www/docs/assets/img/*.png   $(TARGET_DIR)/var/www/docs/assets/img/
	$(INSTALL) -D -m 644  $(@D)/var/www/docs/assets/js/*.js   $(TARGET_DIR)/var/www/docs/assets/js/
	mkdir -p $(TARGET_DIR)/etc/lighttpd
	$(INSTALL) -D -m 644  $(@D)/etc/lighttpd/lighttpd.*  $(TARGET_DIR)/etc/lighttpd/
	mkdir -p -m 700 $(TARGET_DIR)/usr/sbfs
endef

define MSD45N_BINARIES_INSTALL_STAGING_CMDS
	rm -f $(STAGING_DIR)/usr/lib/libsdc_sdk.so*
	$(INSTALL) -D -m 0755 $(@D)/usr/lib/libsdc_sdk.so.1.0 $(STAGING_DIR)/usr/lib/
	cd  $(STAGING_DIR)/usr/lib/ && ln -s libsdc_sdk.so.1.0 libsdc_sdk.so.1
	cd  $(STAGING_DIR)/usr/lib/ && ln -s libsdc_sdk.so.1 libsdc_sdk.so
	$(INSTALL) -D -m 0644 $(@D)/include/sdc_sdk.h \
		$(@D)/include/sdc_events.h \
		$(@D)/include/lrd_sdk_pil.h \
		$(STAGING_DIR)/usr/include/
endef

define MSD45N_BINARIES_INSTALL_FIPS_BINARIES
	$(INSTALL) -D -m 755 $(@D)/usr/bin/sdcu $(TARGET_DIR)/usr/bin/sdcu
endef

ifeq ($(MSD45N_BINARIES_COMPANY_PROJECT),laird_fips)
	MSD45N_BINARIES_DEPENDENCIES += linux
	MSD45N_BINARIES_POST_INSTALL_TARGET_HOOKS += MSD45N_BINARIES_INSTALL_FIPS_BINARIES
else ifeq ($(MSD45N_BINARIES_WB_PLATFORM),wb50n)
	# wb50n gets fips, but there's no extra laird_fips name in the msd package name
	MSD45N_BINARIES_DEPENDENCIES += linux
	MSD45N_BINARIES_POST_INSTALL_TARGET_HOOKS += MSD45N_BINARIES_INSTALL_FIPS_BINARIES
endif

$(eval $(generic-package))
